import 'dart:io';

import 'package:args/args.dart';
import 'package:path/path.dart' as p;
import 'package:postgres/postgres.dart' hide Type;
import 'package:strings/strings.dart';

void main(List<String> args) async {
  final parser = ArgParser()
    ..addOption('output', abbr: 'o')
    ..addOption('input', abbr: 'i')
    ..addFlag('migrate', abbr: 'm', help: 'Migrate the database based on the sql files!', negatable: false)
    ..addFlag('generate', abbr: 'g', help: 'Generate the dart files from the sql files!', negatable: false);

  final results = parser.parse(args);

  Directory input, output;

  if (results.option('input')?.isNotEmpty ?? false) {
    input = Directory(p.normalize(results['input'] as String));
  } else {
    input = Directory(p.join(Directory.current.path, 'migrations'));
  }

  if (results.option('output')?.isNotEmpty ?? false) {
    output = Directory(p.normalize(results['output'] as String));
  } else {
    output = Directory(p.join(Directory.current.path, 'lib', 'generated'));
  }

  if (results.flag('generate') && results.flag('migrate')) {
    stdout.writeln('Cannot generate and migrate at the same time!');
    stdout.writeln();
    stdout.writeln('Please use either --generate or --migrate, not both.');
    stdout.writeln();
    stdout.writeln('See --help for more information.');
    stdout.writeln();
    exit(1);
  }

  if (results.flag('migrate')) {
    while (true) {
      stdout.writeln('Welcome to the DSQL migration tool!');
      stdout.writeln();
      stdout.writeln('This tool will help you to migrate your database using DSQL.');
      stdout.writeln();
      stdout.write('Press ENTER to continue...');
      stdin.readLineSync();
      stdout.writeln();
      stdout.write('First set the PostgreSQL url: ');
      final url = stdin.readLineSync();
      stdout.writeln();
      if (url == null || url.isEmpty) {
        _showUriError();
        continue;
      }
      final uri = Uri.parse(url);
      final host = uri.host;
      final port = uri.hasPort ? uri.port : 5432;
      if (!uri.hasAuthority || uri.userInfo.isEmpty || uri.pathSegments.isEmpty) {
        _showUriError();
        continue;
      }
      final user = uri.userInfo.split(':')[0];
      final password = uri.userInfo.split(':')[1];
      final database = uri.pathSegments.first;
      final ssl = uri.queryParameters['sslmode'] == 'require';
      stdout.writeln('Looking for migrations...');
      if (!input.existsSync()) {
        _showOutputError(p.relative(input.path, from: Directory.current.path));
        exit(0);
      }
      final files = input.listSync(recursive: true).where((f) => p.extension(f.path) == '.sql');
      if (files.isEmpty) {
        _showFilesError(p.relative(input.path, from: Directory.current.path));
        exit(0);
      }
      stdout.writeln();
      stdout.writeln('-' * 80);
      stdout.writeln('${files.length} migrations found');
      stdout.writeln('-' * 80);
      for (final file in files) {
        stdout.writeln('  - ${p.relative(file.path, from: input.path)}');
      }
      stdout.writeln('-' * 80);
      stdout.writeln();
      stdout.writeln('Connecting to database...');
      stdout.writeln();
      try {
        final conn = await Connection.open(
          Endpoint(
            host: host,
            database: database,
            username: user,
            password: password,
            port: port,
          ),
          settings: ConnectionSettings(sslMode: ssl ? SslMode.require : SslMode.disable),
        );

        final migrations = files.map((file) => File(file.path).readAsStringSync());

        stdout.writeln('Migrating database...');

        stdout.writeln();

        await conn.runTx(
          (tx) async {
            for (final m in migrations) {
              try {
                await tx.execute(m, queryMode: QueryMode.simple);
              } on Exception catch (e) {
                _showExceptionError(e);
                await tx.rollback();
              }
            }
          },
        );
      } on Exception catch (e) {
        _showExceptionError(e);
        exit(0);
      }
      stdout.writeln('Done!');
      stdout.writeln();
      stdout.write('Press ENTER to continue...');
      stdin.readLineSync();
      exit(0);
    }
  } else if (results.flag('generate')) {
    _clearConsole();
    stdout.writeln('Generating dart files...');
    stdout.writeln();
    _generateDartFiles(input, output);
    stdout.writeln('Done, your dart files are in ${p.relative(output.path, from: Directory.current.path)}!');
    stdout.writeln();
    stdout.write('Press ENTER to exit...');
    stdin.readLineSync();
    exit(0);
  } else {
    _clearConsole();
    stdout.writeln('Wrong arguments!');
    stdout.writeln();
    stdout.write('Press ENTER to exit...');
    stdin.readLineSync();
    exit(0);
  }
}

void _generateDartFiles(Directory input, Directory output) {
  final entitiesBuffer = StringBuffer();

  final queriesBuffer = StringBuffer();

  final matches = <RegExpMatch>[];

  for (final current in input.listSync(recursive: true)) {
    if (p.extension(current.path) != '.sql') continue;

    final file = File(current.path);

    if (!file.existsSync()) continue;

    final content = file.readAsLinesSync().join('\n');

    final regex = RegExp(r"--\sentity:\s([\w]+)\sCREATE TABLE(?: IF NOT EXISTS)?\s([\w]+)\s\(([\s\w\d\(\)\,\']+)\s\);");

    matches.addAll(regex.allMatches(content));
  }

  entitiesBuffer.writeln(_entitiesBuilder(matches));

  queriesBuffer.writeln(_queriesBuilder(matches));

  final entities = File(p.join(output.path, 'entities.dart'));

  final queries = File(p.join(output.path, 'queries.dart'));

  final where = File(p.join(output.path, 'where.dart'));

  final result = File(p.join(output.path, 'result.dart'));

  final order = File(p.join(output.path, 'order.dart'));

  if (!entities.existsSync()) entities.createSync(recursive: true);

  entities.writeAsStringSync(_entitiesImportsBuilder(entitiesBuffer.toString()));

  if (!queries.existsSync()) queries.createSync(recursive: true);

  queries.writeAsStringSync(_queriesImportsBuilder(queriesBuffer.toString()));

  if (!where.existsSync()) where.createSync(recursive: true);

  where.writeAsStringSync(_whereBuilder());

  if (!result.existsSync()) result.createSync(recursive: true);

  result.writeAsStringSync(_resultBuilder());

  if (!order.existsSync()) order.createSync(recursive: true);

  order.writeAsStringSync(_orderByBuilder());

  _format(output);
}

String _fieldName(String col) {
  return col.split(' ')[0].toCamelCase(lower: true);
}

Type _fieldType(String col) {
  final sql = col.split(' ')[1].toUpperCase();

  if (sql.startsWith('VARCHAR')) {
    return String;
  }

  return switch (sql) {
    'TEXT' || 'UUID' || 'CHAR' => String,
    'SMALLINT' || 'INTEGER' || 'BIGINT' || 'SERIAL' || 'BIGSERIAL' || 'SMALLSERIAL' => int,
    'REAL' || 'DECIMAL' || 'NUMERIC' || 'DOUBLE' => double,
    'BOOLEAN' => bool,
    'TIMESTAMP' || 'TIMESTAMPTZ' || 'DATE' || 'TIME' => DateTime,
    _ => Null,
  };
}

bool _isRequired(String col) {
  if (col.toUpperCase().contains('DEFAULT') || !col.toUpperCase().contains('NOT NULL')) {
    return false;
  }
  return true;
}

bool _isNullable(String col) {
  return !col.toUpperCase().contains('NOT NULL') && !col.toUpperCase().contains('PRIMARY KEY');
}

bool _isPrimaryKey(String col) {
  return col.toUpperCase().contains('PRIMARY KEY');
}

bool _hasUniqueKey(List<String> cols) {
  return cols.any((col) => col.toUpperCase().contains('UNIQUE'));
}

Map<String, Type> _getUniqueKeysMapped(List<String> cols) {
  return Map.fromEntries(cols.where((col) => col.toUpperCase().contains('UNIQUE')).map((col) => MapEntry(col.split(' ')[0], _fieldType(col))));
}

bool _hasPrimaryKey(List<String> cols) {
  return cols.any(_isPrimaryKey);
}

String _getPkName(List<String> cols) {
  return cols.firstWhere(_isPrimaryKey).split(' ')[0];
}

Type _getPkType(List<String> cols) {
  return _fieldType(cols.firstWhere(_isPrimaryKey));
}

String _queriesBuilder(Iterable<RegExpMatch> matches) {
  final queries = <String>[];

  queries.add('''class Queries {
${matches.map(
    (match) {
      final query = '${match.group(1)!.substring(0, match.group(1)!.length - 6)}Query';
      final name = match.group(2)!.startsWith('tb_') ? match.group(2)!.substring(3) : match.group(2)!;

      return '  late final $query $name;';
    },
  ).join('\n')}

  Queries(Connection conn, {bool verbose = false}) {
${matches.map(
    (match) {
      final query = '${match.group(1)!.substring(0, match.group(1)!.length - 6)}Query';
      final name = match.group(2)!.startsWith('tb_') ? match.group(2)!.substring(3) : match.group(2)!;

      return '    $name = $query(conn, verbose: verbose);';
    },
  ).join('\n')}
  }
}''');

  for (final match in matches) {
    final entity = match.group(1)!;
    final table = match.group(2)!;
    final columns = match.group(3)!.split('\n').where((l) => l.isNotEmpty).map((l) => l.trim()).toList();
    final content = '''class ${entity.substring(0, entity.length - 6)}Query {
  final Connection _conn;
  final bool verbose;

  const ${entity.substring(0, entity.length - 6)}Query(this._conn, {this.verbose = false});

  ${_insertOneBuilder(table, entity, columns)}

  ${_findManyBuilder(table, entity, columns)}

  ${_findByPkBuilder(table, entity, columns)}

  ${_findByUniqueKeyBuilder(table, entity, columns)}

  ${_updateOneBuilder(table, entity, columns)}

  ${_deleteOneBuilder(table, entity, columns)}
}

${_insertOneParamsBuilder(entity, columns)}

${_findManyParamsBuilder(entity, columns)}

${_updateOneParamsBuilder(entity, columns)}

${_deleteOneParamsBuilder(entity, columns)}
''';
    queries.add(content);
  }

  return queries.join('\n\n');
}

String _queriesImportsBuilder(String content) {
  return '''// This file is generated by DSQL.
// Do not modify it manually.

import 'package:postgres/postgres.dart';
import 'dart:convert';

part 'where.dart';
part 'result.dart';
part 'entities.dart';
part 'order.dart';

$content
''';
}

String _entitiesBuilder(Iterable<RegExpMatch> matches) {
  final entities = <String>[];

  for (final match in matches) {
    final buffer = StringBuffer();
    final entity = match.group(1)!;
    final columns = match.group(3)!.split('\n').where((l) => l.isNotEmpty).map((l) => l.trim()).toList();

    buffer.writeln('class $entity {');

    buffer.write(columns.map((c) => '  final ${_fieldType(c)}${_isNullable(c) ? '?' : ''} ${_fieldName(c)};').join('\n'));

    buffer.writeln();

    buffer.writeln();

    buffer.writeln('  const $entity({\n${columns.map((c) => '    ${_isNullable(c) ? '' : 'required '}this.${_fieldName(c)},').join('\n')}\n  });');

    buffer.writeln();

    buffer.write('''  $entity copyWith({
${columns.map((c) => '    ${_fieldType(c)}? ${_fieldName(c)},').join('\n')}
  }) {
    return $entity(
${columns.map((c) => '      ${_fieldName(c)}: ${_fieldName(c)} ?? this.${_fieldName(c)},').join('\n')}
    );
  }''');

    buffer.writeln();

    buffer.writeln();

    buffer.writeln('''  Map<String, dynamic> toMap() {
    return {
${columns.map((c) => '      \'${_fieldName(c).toSnakeCase()}\': ${_fieldName(c)},').join('\n')}
    };
  }''');

    buffer.writeln();

    buffer.writeln('''  String toJson() => json.encode(toMap());''');

    buffer.writeln();

    buffer.writeln('''  factory $entity.fromMap(Map<String, dynamic> map) {
      return $entity(
${columns.map((c) => '        ${_fieldName(c)}: map[\'${_fieldName(c).toSnakeCase()}\'] as ${_fieldType(c)},').join('\n')}
      );
  }''');

    buffer.writeln();

    buffer.writeln();

    buffer.writeln('''  factory $entity.fromJson(String source) => $entity.fromMap(json.decode(source));''');

    buffer.writeln('}');

    entities.add(buffer.toString());
  }

  return entities.join('\n\n');
}

String _insertOneParamsBuilder(String entity, List<String> columns) {
  return '''class InsertOne${entity.substring(0, entity.length - 6)}Params {
  ${columns.where((c) => _isRequired(c)).map((c) => 'final ${_fieldType(c)} ${_fieldName(c)};').join('\n')}

  const InsertOne${entity.substring(0, entity.length - 6)}Params({
  ${columns.where((c) => _isRequired(c)).map((c) => 'required this.${_fieldName(c)},').join('\n')}
  });

  List get indexedParams => [
  ${columns.where((c) => _isRequired(c)).map((c) => '${_fieldName(c)},').join('\n')}
  ];
}''';
}

String _insertOneBuilder(String table, String entity, List<String> columns) {
  return '''AsyncResult<$entity, Exception> insertOne(InsertOne${entity.substring(0, entity.length - 6)}Params params) async {
    try {

      if (verbose) {
        print('${'-' * 80}');

        print(r'SQL => INSERT INTO $table (${columns.where((c) => _isRequired(c)).map((c) => _fieldName(c)).join(', ')}) VALUES (${List.generate(columns.where((c) => _isRequired(c)).length, (i) => '\$${i + 1}').join(', ')}) RETURNING *;');

        print('PARAMS => \${params.indexedParams}');

        print('${'-' * 80}');
      }

      final result = await _conn.execute(
          r'INSERT INTO $table (${columns.where((c) => _isRequired(c)).map((c) => _fieldName(c)).join(', ')}) VALUES (${List.generate(columns.where((c) => _isRequired(c)).length, (i) => '\$${i + 1}').join(', ')}) RETURNING *;',
          parameters: params.indexedParams,
      );

      if (result.isEmpty) {
        return Error(Exception('Fail to insert data on table `$table`!'));
      }

      final row = result.first;

      final [
${columns.map((c) => '${_fieldType(c)}${_isNullable(c) ? '?' : ''} ${_fieldName(c)},').join('\n')}
      ] = row as List;

      final entity = $entity(
${columns.map((c) => '${_fieldName(c)}: ${_fieldName(c)},').join('\n')}
      );

      return Success(entity);
    } on Exception catch (e) {
      return Error(e);
    }
  }''';
}

String _findManyParamsBuilder(String entity, List<String> columns) {
  return '''class FindMany${entity.substring(0, entity.length - 6)}Params {
  ${columns.map((c) => 'final Where? ${_fieldName(c)};').join('\n')}
  final int? limit;
  final int? offset;
  final OrderBy? orderBy;

  const FindMany${entity.substring(0, entity.length - 6)}Params({
    ${columns.map((c) => 'this.${_fieldName(c)},').join('\n')}
    this.limit,
    this.offset,
    this.orderBy,
  });

  Map<String, Where> get wheres => {
    ${columns.map((c) => 'if (${_fieldName(c)} != null) \'${_fieldName(c).toSnakeCase()}\': ${_fieldName(c)}!,').join('\n')}
  };
}''';
}

String _findManyBuilder(String table, String entity, List<String> columns) {
  return '''AsyncResult<List<$entity>, Exception> findMany([
    FindMany${entity.substring(0, entity.length - 6)}Params params = const FindMany${entity.substring(0, entity.length - 6)}Params(),
  ]) async {
    try {
      final where = switch (params.wheres.isEmpty) {
        true => '',
        false => ' WHERE \${List.generate(params.wheres.length, (i) => '\${params.wheres.keys.elementAt(i)} \${params.wheres.values.elementAt(i).op} \\\$\${i + 1}').join(' AND ')}',
      };

      final orderBy = switch (params.orderBy != null) {
        true => ' ORDER BY \${params.orderBy?.sql}',
        false => '',
      };

      final offset = switch (params.offset != null) {
        true => ' OFFSET \${params.offset}',
        false => '',
      };

      final limit = switch (params.limit != null) {
        true => ' LIMIT \${params.limit}',
        false => '',
      };

      final query = 'SELECT * FROM $table\$where\$orderBy\$offset\$limit;';

      if (verbose) {
        print('${'-' * 80}');

        print('SQL => \$query');

        print('PARAMS => \${params.wheres.values.map((w) => w.value).toList()}');

        print('${'-' * 80}');
      }

      final result = await _conn.execute(
        query, 
        parameters: params.wheres.values.map((w) => w.value).toList(),
      );

      final entities = List<$entity>.from(
        result.map(
          (row) {
            final [
${columns.map((c) => '${_fieldType(c)}${_isNullable(c) ? '?' : ''} ${_fieldName(c)},').join('\n')}
            ] = row as List;

            final entity = $entity(
${columns.map((c) => '${_fieldName(c)}: ${_fieldName(c)},').join('\n')}
            );

            return entity;
          },
        ),
      );

      return Success(entities);
    } on Exception catch (e) {
      return Error(e);
    }
  }''';
}

String _findByPkBuilder(String table, String entity, List<String> columns) {
  return switch (_hasPrimaryKey(columns)) {
    false => '',
    true => '''AsyncResult<$entity, Exception> findByPK(
    ${_getPkType(columns)} pk
  ) async {
  try {
    if (verbose) {
      print('${'-' * 80}');

      print(r'SQL => SELECT * FROM $table WHERE ${_getPkName(columns)} = \$1 LIMIT 1;');

      print('PARAMS => \${[pk]}');

      print('${'-' * 80}');
    }

    final result = await _conn.execute(
      r'SELECT * FROM $table WHERE ${_getPkName(columns)} = \$1 LIMIT 1;', 
      parameters: [pk],
    );
  
    if (result.isEmpty) {
      return Error(Exception('Fail to find data on table `$table`!'));
    }
  
    final row = result.first;
  
    final [
      ${columns.map((c) => '${_fieldType(c)}${_isNullable(c) ? '?' : ''} ${_fieldName(c)},').join('\n')}
    ] = row as List;
  
    final entity = $entity(
      ${columns.map((c) => '${_fieldName(c)}: ${_fieldName(c)},').join('\n')}
    );
  
    return Success(entity);
  } on Exception catch (e) {
    return Error(e);
  }
}''',
  };
}

String _findByUniqueKeyBuilder(String table, String entity, List<String> columns) {
  return switch (_hasUniqueKey(columns)) {
    false => '',
    true => _getUniqueKeysMapped(columns).entries.map(
        (uk) {
          return '''AsyncResult<$entity, Exception> findBy${uk.key.toSnakeCase().toCamelCase()}(
    ${uk.value} unique
  ) async {
  try {
    if (verbose) {
      print('${'-' * 80}');

      print(r'SQL => SELECT * FROM $table WHERE ${uk.key.toSnakeCase()} = \$1 LIMIT 1;');

      print('PARAMS => \${[unique]}');

      print('${'-' * 80}');
    }

    final result = await _conn.execute(
      r'SELECT * FROM $table WHERE ${uk.key.toSnakeCase()} = \$1 LIMIT 1;', 
      parameters: [unique],
    );
  
    if (result.isEmpty) {
      return Error(Exception('Fail to find data on table `$table`!'));
    }
  
    final row = result.first;
  
    final [
      ${columns.map((c) => '${_fieldType(c)}${_isNullable(c) ? '?' : ''} ${_fieldName(c)},').join('\n')}
    ] = row as List;
  
    final entity = $entity(
      ${columns.map((c) => '${_fieldName(c)}: ${_fieldName(c)},').join('\n')}
    );
  
    return Success(entity);
  } on Exception catch (e) {
    return Error(e);
  }
}''';
        },
      ).join('\n\n')
  };
}

String _updateOneParamsBuilder(String entity, List<String> columns) {
  return '''class UpdateOne${entity.substring(0, entity.length - 6)}Params {
  ${columns.map((c) => 'final Where? where${_fieldName(c).toSnakeCase().toCamelCase()};').join('\n')}
  ${columns.where((c) => !_isPrimaryKey(c)).map((c) => 'final ${_fieldType(c)}? ${_fieldName(c)};').join('\n')}

  const UpdateOne${entity.substring(0, entity.length - 6)}Params({
    ${columns.map((c) => 'this.where${_fieldName(c).toSnakeCase().toCamelCase()},').join('\n')}
    ${columns.where((c) => !_isPrimaryKey(c)).map((c) => 'this.${_fieldName(c)},').join('\n')}
  });

  Map<String, Where> get wheres => {
    ${columns.map((c) => 'if (where${_fieldName(c).toSnakeCase().toCamelCase()} != null) \'${_fieldName(c).toSnakeCase()}\': where${_fieldName(c).toSnakeCase().toCamelCase()}!,').join('\n')}
  };

  Map<String, dynamic> get parameters => {
    ${columns.where((c) => !_isPrimaryKey(c)).map((c) => 'if (${_fieldName(c)} != null) \'${_fieldName(c).toSnakeCase()}\': ${_fieldName(c)},').join('\n')}
  };
}''';
}

String _updateOneBuilder(String table, String entity, List<String> columns) {
  return '''AsyncResult<$entity, Exception> updateOne(UpdateOne${entity.substring(0, entity.length - 6)}Params params) async {
    try {
    if (params.parameters.isEmpty) {
      return Error(Exception('No data to update!'));
    }

    final query = 'UPDATE $table SET \${List.generate(params.parameters.length, (i) => '\${params.parameters.keys.elementAt(i)} = \\\$\${i + 1}').join(', ')} WHERE \${List.generate(params.wheres.length, (i) => '\${params.wheres.keys.elementAt(i)} \${params.wheres.values.elementAt(i).op} \\\$\${i + 1 + params.parameters.length}').join(' AND ')} RETURNING *;';

    if (verbose) {
      print('${'-' * 80}');

      print('SQL => \$query');

      print('PARAMS => \${[...params.parameters.values, ...params.wheres.values.map((w) => w.value)]}');

      print('${'-' * 80}');
    }

    final result = await _conn.execute(
      query, 
      parameters: [...params.parameters.values, ...params.wheres.values.map((w) => w.value)],
    );
    
    if (result.isEmpty) {
      return Error(Exception('Fail to update data on table `$table`!'));
    }

    final row = result.first;

    final [
${columns.map((c) => '${_fieldType(c)}${_isNullable(c) ? '?' : ''} ${_fieldName(c)},').join('\n')}
    ] = row as List;

    final entity = $entity(
${columns.map((c) => '${_fieldName(c)}: ${_fieldName(c)},').join('\n')}
    );

    return Success(entity);
    } on Exception catch (e) {
      return Error(e);
    }
  }''';
}

String _deleteOneParamsBuilder(String entity, List<String> columns) {
  return '''class DeleteOne${entity.substring(0, entity.length - 6)}Params {
  ${columns.map((c) => 'final Where? ${_fieldName(c)};').join('\n')}

  const DeleteOne${entity.substring(0, entity.length - 6)}Params({
  ${columns.map((c) => 'this.${_fieldName(c)},').join('\n')}
  });

  Map<String, Where> get wheres => {
  ${columns.map((c) => 'if (${_fieldName(c)} != null) \'${_fieldName(c).toSnakeCase()}\': ${_fieldName(c)}!,').join('\n')}
  };
}''';
}

String _deleteOneBuilder(String table, String entity, List<String> columns) {
  return '''AsyncResult<$entity, Exception> deleteOne(DeleteOne${entity.substring(0, entity.length - 6)}Params params) async {
    try {
      if (params.wheres.isEmpty) {
        return Error(Exception('No data to delete!'));
      }

      final query = 'DELETE FROM $table WHERE \${List.generate(params.wheres.length, (i) => '\${params.wheres.keys.elementAt(i)} \${params.wheres.values.elementAt(i).op} \\\$\${i + 1}').join(' AND ')} RETURNING *;';
    
      if (verbose) {
        print('${'-' * 80}');

        print('SQL => \$query');

        print('PARAMS => \${params.wheres.values.map((w) => w.value).toList()}');

        print('${'-' * 80}');
      }

      final result = await _conn.execute(
        query, 
        parameters: params.wheres.values.map((w) => w.value).toList(),
      );
      
      if (result.isEmpty) {
        return Error(Exception('Fail to delete data on table `$table`!'));
      }

      final row = result.first;

      final [
${columns.map((c) => '${_fieldType(c)}${_isNullable(c) ? '?' : ''} \$${_fieldName(c)},').join('\n')}
      ] = row as List;

      final entity = $entity(
${columns.map((c) => '${_fieldName(c)}: \$${_fieldName(c)},').join('\n')}
      );

      return Success(entity);
    } on Exception catch (e) {
      return Error(e);
    }
  }''';
}

String _entitiesImportsBuilder(String content) {
  return '''// This file is generated by DSQL.
// Do not modify it manually.

part of 'queries.dart';

$content
''';
}

String _whereBuilder() {
  return '''// This file is generated by DSQL.
// Do not modify it manually.

part of 'queries.dart';

class Where {
  final String op;
  final dynamic value;

  const Where._(this.op, this.value);

  const Where.eq(dynamic value) : this._('=', value);

  const Where.neq(dynamic value) : this._('!=', value);

  const Where.gt(dynamic value) : this._('>', value);

  const Where.gte(dynamic value) : this._('>=', value);

  const Where.lt(dynamic value) : this._('<', value);

  const Where.lte(dynamic value) : this._('<=', value);

  const Where.startsWith(String value, {bool ignoreCase = true})
      : this._(ignoreCase ? 'ILIKE' : 'LIKE', '\$value%');

  const Where.endsWith(String value, {bool ignoreCase = true})
      : this._(ignoreCase ? 'ILIKE' : 'LIKE', '%\$value');

  const Where.contains(String value, {bool ignoreCase = true})
      : this._(ignoreCase ? 'ILIKE' : 'LIKE', '%\$value%');

  String sql(String column) => '\$op @\$column';
}
''';
}

String _resultBuilder() {
  return '''// This file is generated by DSQL.
// Do not modify it manually.

part of 'queries.dart';

typedef AsyncResult<S extends Object?, E extends Object?>
    = Future<Result<S, E>>;

sealed class Result<S extends Object?, E extends Object?> {
  final S? _success;
  final E? _error;

  const Result(this._success, this._error);

  bool get isSuccess => _success != null;

  S? getSuccessOrNull() => _success;

  S getSuccessOrThrow() {
    if (_success == null) throw Exception('Left value is null');

    return _success;
  }

  S getSuccessOrElse(S Function() orElse) => _success ?? orElse();

  bool get isError => _error != null;

  E? getErrorOrNull() => _error;

  E getErrorOrThrow() {
    if (_error == null) throw Exception('Right value is null');

    return _error;
  }

  E getErrorOrElse(E Function() orElse) => _error ?? orElse();

  T when<T>(T Function(S success) onSuccess, T Function(E error) onError) {
    if (isSuccess) {
      return onSuccess(getSuccessOrThrow());
    } else {
      return onError(getErrorOrThrow());
    }
  }
}

final class Success<S extends Object?, E extends Object?> extends Result<S, E> {
  Success(S success) : super(success, null);
}

final class Error<S extends Object?, E extends Object?> extends Result<S, E> {
  Error(E error) : super(null, error);
}
''';
}

String _orderByBuilder() {
  return '''// This file is generated by DSQL.
// Do not modify it manually.

part of 'queries.dart';

enum OrderByOption {
  asc('ASC'),
  desc('DESC');

  final String direction;

  const OrderByOption(this.direction);
}

class OrderBy {
  final String column;
  final OrderByOption option;

  const OrderBy._(this.column, this.option);

  const OrderBy.asc(String column) : this._(column, OrderByOption.asc);

  const OrderBy.desc(String column) : this._(column, OrderByOption.desc);

  String get sql => '\$column \${option.direction}';
}''';
}

void _format(Directory output) {
  Process.runSync('dart', ['format', output.path]);
}

void _showUriError() {
  _clearConsole();
  stdout.writeln('-' * 80);
  stdout.writeln('ERROR');
  stdout.writeln('-' * 80);
  stdout.writeln('You must set a valid PostgreSQL url!');
  stdout.writeln();
  stdout.writeln('e.g. postgresql://username:password@localhost:5432/database');
  stdout.writeln('-' * 80);
  stdout.writeln();
  stdout.write('Press ENTER to reset...');
  stdin.readLineSync();
  _clearConsole();
}

void _showFilesError(String inputPath) {
  _clearConsole();
  stdout.writeln('-' * 80);
  stdout.writeln('ERROR');
  stdout.writeln('-' * 80);
  stdout.writeln('No files found in `$inputPath` directory!');
  stdout.writeln();
  stdout.writeln('You must to put your .sql files in `$inputPath` directory!');
  stdout.writeln('-' * 80);
  stdout.writeln();
  stdout.write('Press ENTER to reset...');
  stdin.readLineSync();
  _clearConsole();
}

void _showOutputError(String inputPath) {
  _clearConsole();
  stdout.writeln('-' * 80);
  stdout.writeln('ERROR');
  stdout.writeln('-' * 80);
  stdout.writeln('Output directory `$inputPath` is not a valid directory!');
  stdout.writeln();
  stdout.writeln('You must set a valid output directory!');
  stdout.writeln('-' * 80);
  stdout.writeln();
  stdout.write('Press ENTER to reset...');
  stdin.readLineSync();
  _clearConsole();
}

void _showExceptionError(Exception ex) {
  _clearConsole();
  stdout.writeln('-' * 80);
  stdout.writeln('ERROR');
  stdout.writeln('-' * 80);
  stdout.writeln('An unexpected error has occurred!');
  stdout.writeln();
  stdout.writeln(ex.toString());
  stdout.writeln('-' * 80);
  stdout.writeln();
  stdout.write('Press ENTER to reset...');
  stdin.readLineSync();
  _clearConsole();
}

void _clearConsole() => stdout.write('\x1B[2J\x1B[0;0H');
