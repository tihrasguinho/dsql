import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:postgres/postgres.dart';

import 'dsql_utils.dart';
import 'internal/table.dart';

class DSQLGen {
  static String schema = 'public';

  static final _tableRegex = RegExp(
    r'^--\s*Entity\s*=>\s*(\w+)\s*\n\s*CREATE\s+TABLE(?:\s+IF\s+NOT\s+EXISTS)?\s+(\w+)\s*\(([^;]*?)\);$',
    caseSensitive: false,
    multiLine: true,
  );

  static Future<void> readMigrations(String path, {required Uri databaseURL, String? output}) async {
    final dir = Directory(path);

    if (!dir.existsSync()) {
      stdout.writeln('No migrations directory found!');
      exit(0);
    }

    final files = dir.listSync(recursive: true).where((file) => file.statSync().type == FileSystemEntityType.file);

    final versions = files.where((file) => RegExp(r'^\V[\d]+\_\_(.*).sql$').hasMatch(p.basename(file.path))).toList();

    if (versions.isEmpty) {
      stdout.writeln('No versions found in migrations directory!');
      exit(0);
    }

    versions.sort((a, b) => p.basename(a.path).compareTo(p.basename(b.path)));

    final lastVersion = await File(versions.last.path).readAsString();

    stdout.writeln('Migration found... ${p.basename(versions.last.path)}');

    try {
      final userInfo = databaseURL.userInfo.split(':');

      final PostgreSQLConnection conn = PostgreSQLConnection(
        databaseURL.host,
        databaseURL.port,
        databaseURL.pathSegments.isNotEmpty ? databaseURL.pathSegments.first : '',
        username: userInfo.isNotEmpty ? userInfo[0] : '',
        password: userInfo.length > 1 ? userInfo[1] : '',
        useSSL: databaseURL.queryParameters['sslmode'] == 'require',
      );

      schema = databaseURL.queryParameters['schema'] ?? 'public';

      await conn.open();

      if (schema != 'public') {
        final result = await conn.query(
          'SELECT exists(SELECT schema_name FROM information_schema.schemata WHERE schema_name = @schema)',
          substitutionValues: {
            'schema': schema,
          },
        );

        final [bool exists] = result.first;

        if (!exists && userInfo.isNotEmpty) {
          stdout.writeln('Schema $schema does not exists, creating...');

          await conn.execute('CREATE SCHEMA $schema AUTHORIZATION ${userInfo.isNotEmpty ? userInfo[0] : ''};');
        }

        stdout.writeln('Set search_path to $schema...');

        await conn.execute('SET search_path TO $schema;');
      }

      await conn.execute(lastVersion);

      await conn.close();
    } on PostgreSQLException catch (e) {
      stdout.writeln(e.message);
      exit(0);
    } on Exception catch (e) {
      stdout.writeln(e.toString());
      exit(0);
    }

    final tablesMatched = _tableRegex.allMatches(lastVersion);

    final entityMetadatas = <EntityMetadata>[];

    for (final match in tablesMatched) {
      final entityName = match.group(1) ?? '';
      final tableName = match.group(2) ?? '';
      final content = match.group(3) ?? '';

      entityMetadatas.add(_getEntityMetadata(entityName, '$schema.$tableName', content));
    }

    final content = _generateDSQLClasses(entityMetadatas);

    final outputDir = Directory(output ?? p.join(path, '..', 'lib', 'generated'));

    if (!outputDir.existsSync()) {
      outputDir.createSync(recursive: true);
    }

    await File(p.join(outputDir.path, 'dsql.dart')).writeAsString(content);

    await Process.run('dart', ['format', outputDir.path]);

    stdout.writeln('dsql.dart generated successfully${output != null ? 'in $output' : ''}!');

    exit(0);
  }

  static String _generateDSQLClasses(List<EntityMetadata> metadatas) {
    final buffer = StringBuffer();

    buffer.writeln('import \'package:dsql/dsql.dart\';');

    buffer.writeln();

    buffer.writeln('// **************************');

    buffer.writeln('// Generated by DSQL don\'t change by hand!');

    buffer.writeln('// **************************');

    buffer.writeln('');

    for (final metadata in metadatas) {
      buffer.writeln('// ${metadata.entityName}');

      buffer.writeln('');

      buffer.writeln(metadata.entityContent);
    }

    for (final metadata in metadatas) {
      buffer.writeln('// ${metadata.repositoryName}');

      buffer.writeln('');

      buffer.writeln(metadata.repositoryContent);
    }

    buffer.writeln();

    buffer.writeln(_dsqlBuilder(metadatas));

    return buffer.toString();
  }

  static EntityMetadata _getEntityMetadata(String entityName, String tableName, String content) {
    final contentLines = content.trim().split('\n');

    assert(entityName.isNotEmpty && tableName.isNotEmpty && contentLines.isNotEmpty, 'Invalid table script, please check your code!');

    final params = <_Param>[];

    for (final line in contentLines) {
      final [name, type, ...parts] = line.trim().split(' ');

      final partsJoined = parts.join(' ').toUpperCase();

      params.add(
        _Param(
          type: sqlDataTypeToDartType(type),
          name: DSQLUtils.toCamelCase(name),
          nullable: !partsJoined.contains(RegExp(r'(NOT NULL|PRIMARY KEY)')),
          required: !partsJoined.contains('DEFAULT'),
          primaryKey: partsJoined.contains('PRIMARY KEY'),
        ),
      );
    }

    final entityBuffer = StringBuffer();

    entityBuffer.writeln(_entityBuilder(entityName, params));

    final repositoryBuffer = StringBuffer();

    repositoryBuffer.writeln(_repositoryBuilder(entityName, tableName, params));

    return EntityMetadata(
      name: tableName,
      entityName: '${entityName}Entity',
      entityContent: entityBuffer.toString(),
      repositoryName: '${entityName}Repository',
      repositoryContent: repositoryBuffer.toString(),
    );
  }

  static Type sqlDataTypeToDartType(String type, [bool nullable = false]) => switch (type) {
        var s when (s.startsWith('VARCHAR') || s == 'TEXT' || s == 'UUID') && !nullable => String,
        var s when s == 'BOOLEAN' && !nullable => bool,
        var s when s == 'INTEGER' && !nullable => int,
        var s when s == 'FLOAT' && !nullable => double,
        var s when s == 'TIMESTAMP' && !nullable => DateTime,
        _ => Null,
      };
}

class _Param {
  final String name;
  final Type type;
  final bool nullable;
  final bool required;
  final bool primaryKey;

  _Param({required this.name, required this.type, required this.nullable, required this.required, required this.primaryKey});
}

String _entityBuilder(String entity, List<_Param> params) {
  return '''class ${entity}Entity {

  ${params.map((e) => 'final ${e.type}${e.nullable ? '?' : ''} ${DSQLUtils.toCamelCase(e.name)};').join('\n')}

  const ${entity}Entity({${params.map((e) => '${e.nullable ? '' : 'required '}this.${DSQLUtils.toCamelCase(e.name)}').join(', ')},});

  Map<String, dynamic> toMap() {
    return {
      ${params.map((e) => '\'${DSQLUtils.toSnakeCase(e.name)}\': ${DSQLUtils.toCamelCase(e.name)}${e.type == DateTime ? '.millisecondsSinceEpoch' : ''}').join(', ')},
    };
  }

  factory ${entity}Entity.fromMap(Map<String, dynamic> map) {
    return ${entity}Entity(
      ${params.map((e) => '${DSQLUtils.toCamelCase(e.name)}: ${e.type == DateTime ? 'DateTime.fromMillisecondsSinceEpoch(map[\'${DSQLUtils.toSnakeCase(e.name)}\'] as int)' : 'map[\'${DSQLUtils.toSnakeCase(e.name)}\'] as ${e.type}'}').join(', ')},
    );
  }

  factory ${entity}Entity.fromRow(List row) {
    final [${params.map((e) => '${e.type}${e.nullable ? '?' : ''} ${DSQLUtils.toCamelCase(e.name)}').join(', ')},] = row;

    return ${entity}Entity(
      ${params.map((e) => '${DSQLUtils.toCamelCase(e.name)}: ${DSQLUtils.toCamelCase(e.name)}').join(', ')},
    );
  }

  @override
  String toString() {
    return '${entity}Entity(${params.map((e) => '${DSQLUtils.toCamelCase(e.name)}: \$${DSQLUtils.toCamelCase(e.name)}').join(', ')})';
  }

  @override
  bool operator ==(covariant ${entity}Entity other) {
    if (identical(this, other)) return true;
    if (runtimeType != other.runtimeType) return false;

    return ${params.map((e) => '${DSQLUtils.toCamelCase(e.name)} == other.${DSQLUtils.toCamelCase(e.name)}').join(' && ')};
  }

  @override
  int get hashCode {
    return ${params.map((e) => '${DSQLUtils.toCamelCase(e.name)}.hashCode').join(' ^ ')};
  }
}''';
}

String _repositoryBuilder(String entity, String table, List<_Param> params) {
  final requiredParams = params.where((e) => e.required && !e.nullable).toList();
  final rest = params.where((e) => !e.primaryKey).toList();

  return '''class ${entity}Repository {
  final PostgreSQLConnection conn;

  const ${entity}Repository(this.conn);

  /// Creates a new [${entity}Entity] in database
  Future<${entity}Entity> create({${requiredParams.map((e) => 'required ${e.type} ${e.name}').join(', ')},}) async {
    try {
      final result = await conn.query(
        'INSERT INTO $table (${requiredParams.map((e) => DSQLUtils.toSnakeCase(e.name)).join(', ')}) VALUES (${requiredParams.map((e) => '@${e.name}').join(', ')}) RETURNING *',
        substitutionValues: {
          ${requiredParams.map((e) => '\'${e.name}\': ${e.name}').join(', ')},
        },
      );

      return ${entity}Entity.fromRow(result.first);
    } on PostgreSQLException catch (e) {
      throw Exception(e.message);
    } on Exception catch (e) {
      throw Exception(e);
    }
  }

  /// Returns a list of [${entity}Entity] from database
  Future<List<${entity}Entity>> findMany({
    Where? where,
    OrderBy? orderBy,
    int? limit,
    int? offset,
  }) async {
    try {
      final orderByOffsetAndLimit = '\${orderBy != null ? '\${orderBy.queryString} ' : ''}\${offset != null ? 'OFFSET \$offset ' : ''}\${limit != null ? 'LIMIT \$limit' : ''}';

      PostgreSQLResult result;

      if (where != null) {
        result = await conn.query(
          'SELECT * FROM $table WHERE \${where.queryString}\${orderByOffsetAndLimit.isNotEmpty ? ' \$orderByOffsetAndLimit' : ''};',
          substitutionValues: where.substitutionValues,
        );
      } else {
        result = await conn.query('SELECT * FROM $table\${orderByOffsetAndLimit.isNotEmpty ? ' \$orderByOffsetAndLimit' : ''};');
      }

      return result.map(${entity}Entity.fromRow).toList();
    } on PostgreSQLException catch (e) {
      throw Exception(e.message);
    } on Exception catch (e) {
      throw Exception(e);
    }
  }

  /// Returns a single [${entity}Entity] from database if exists
  Future<${entity}Entity?> findFirst({
    required Where where,
    OrderBy? orderBy,
  }) async {
    try {
      final result = await conn.query(
        'SELECT * FROM $table WHERE \${where.queryString}\${orderBy != null ? ' \${orderBy.queryString}' : ''} LIMIT 1;',
        substitutionValues: where.substitutionValues,
      );

      return result.isNotEmpty ? ${entity}Entity.fromRow(result.first) : null;
    } on PostgreSQLException catch (e) {
      throw Exception(e.message);
    } on Exception catch (e) {
      throw Exception(e);
    }
  }
  
  /// Updates a [${entity}Entity] in database
  Future<${entity}Entity> update({
    ${rest.map((e) => '${e.type}? ${DSQLUtils.toCamelCase(e.name)}').join(', ')},
    required Where where,
  }) async {
    try {
      final valuesToUpdate = <String, dynamic>{
        ${rest.map((e) => 'if (${DSQLUtils.toCamelCase(e.name)} != null) \'${e.name}\': ${DSQLUtils.toCamelCase(e.name)}').join(', ')},
      };

       if (valuesToUpdate.isEmpty) {
        throw Exception('You must provide at least one value to update!');
      }

      final result = await conn.query(
        'UPDATE $table SET \${valuesToUpdate.entries.map((e) => '\${DSQLUtils.toSnakeCase(e.key)} = @\${e.key}').join(', ')} WHERE \${where.queryString} RETURNING *;',
        substitutionValues: {
          ...valuesToUpdate,
          ...where.substitutionValues,
        },
      );

      if (result.isEmpty) {
        throw Exception('${entity}Entity not found!');
      }

      return ${entity}Entity.fromRow(result.first);
    } on PostgreSQLException catch (e) {
      throw Exception(e.message);
    } on Exception catch (e) {
      throw Exception(e);
    }
  }

  /// Deletes a [${entity}Entity] from database
  Future<${entity}Entity?> delete({
    required Where where,
    OrderBy? orderBy,
  }) async {
    try {
      final result = await conn.query(
        'DELETE FROM $table WHERE \${where.queryString}\${orderBy != null ? ' \${orderBy.queryString}' : ''} RETURNING *;',
        substitutionValues: where.substitutionValues,
      );

      return result.isNotEmpty ? ${entity}Entity.fromRow(result.first) : null;
    } on PostgreSQLException catch (e) {
      throw Exception(e.message);
    } on Exception catch (e) {
      throw Exception(e);
    }
  }

  Future<int> aggregate({
    Where? where,
  }) async {
    try {
      final result = await conn.query(
        'SELECT COUNT(*) FROM $table\${where != null ? ' WHERE \${where.queryString}' : ''};',
        substitutionValues: where?.substitutionValues,
      );

      final [count] = result.first;

      return count;
    } on PostgreSQLException catch (e) {
      throw Exception(e.message);
    } on Exception catch (e) {
      throw Exception(e);
    }
  }
}''';
}

String _dsqlBuilder(List<EntityMetadata> metadatas) {
  return '''class DSQL {
    late final Uri databaseURL;

    late final PostgreSQLConnection _conn;

    ${metadatas.map((e) => 'late final ${DSQLUtils.toPascalCase(e.repositoryName)} _${DSQLUtils.toCamelCase(e.repositoryName)};\n').join('\n')}

    ${metadatas.map((e) => '${DSQLUtils.toPascalCase(e.repositoryName)} get ${DSQLUtils.toCamelCase(e.entityName.replaceAll('Entity', ''))} => _${DSQLUtils.toCamelCase(e.repositoryName)};\n').join('\n')}

    DSQL({requierd String databaseURL}) {
      this.databaseURL = Uri.parse(databaseURL);

      final userInfo = this.databaseURL.userInfo.split(':');

      _conn = PostgreSQLConnection(
        this.databaseURL.host,
        this.databaseURL.port,
        this.databaseURL.pathSegments.isNotEmpty ? this.databaseURL.pathSegments.first : '',
        username: userInfo.isNotEmpty ? Uri.decodeComponent(userInfo[0]) : '',
        password: userInfo.length > 1 ? Uri.decodeComponent(userInfo[1]) : '',
        useSSL: this.databaseURL.queryParameters['sslmode'] == 'require',
      );

      ${metadatas.map((e) => '_${DSQLUtils.toCamelCase(e.repositoryName)} = ${DSQLUtils.toPascalCase(e.repositoryName)}(_conn);').join('\n\n')}
    }

    Future<void> init() async {
      await _conn.open();
      await _conn.execute('SET search_path = \${databaseURL.queryParameters['schema'] ?? 'public'};');
      print('DSQL initialized!');
    }
  }''';
}
