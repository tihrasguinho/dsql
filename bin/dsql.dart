import 'dart:convert';
import 'dart:io';

import 'package:args/args.dart';
import 'package:path/path.dart' as p;
import 'package:postgres/postgres.dart' hide Type;
import 'package:strings/strings.dart';

final _regFk1 = RegExp(r'^CONSTRAINT\s(\w+)\sFOREIGN\sKEY\s\((\w+)\)\sREFERENCES\s(\w+)\s\((\w+)\)');
final _regFk2 = RegExp(r'REFERENCES\s(\w+)\s?\((\w+)\)');
final _regTb = RegExp(r"--\sentity:\s([\w]+)\sCREATE TABLE(?: IF NOT EXISTS)?\s([\w]+)\s\(([\s\w\d\(\)\,\']+)\s\);");

void main(List<String> args) async {
  final parser = ArgParser()
    ..addOption('output', abbr: 'o')
    ..addOption('input', abbr: 'i')
    ..addFlag('migrate', abbr: 'm', help: 'Migrate the database based on the sql files!', negatable: false)
    ..addFlag('generate', abbr: 'g', help: 'Generate the dart files from the sql files!', negatable: false);

  final results = parser.parse(args);

  final root = Directory.current;

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
    return _migrate(root, input, output);
  } else if (results.flag('generate')) {
    return _generate(input, output);
  } else {
    stdout.writeln('Wrong arguments, please see --help!');
    exit(0);
  }
}

void _migrate(Directory root, Directory input, Directory output) async {
  String source;
  final env = File(p.join(root.path, '.env'));
  if (env.existsSync()) {
    final lines = env.readAsLinesSync().where((l) => l.isNotEmpty).toList();
    final index = lines.indexWhere(RegExp(r'^DATABASE_URL=').hasMatch);
    if (index == -1) {
      source = String.fromEnvironment('DATABASE_URL');
    } else {
      final line = lines[index].split('DATABASE_URL=')[1];
      source = line.replaceAll('"', '').trim();
    }
  } else {
    source = String.fromEnvironment('DATABASE_URL');
  }

  if (source.isEmpty) {
    _showUriError('Missing DATABASE_URL environment variable!');
    exit(0);
  }

  final uri = Uri.parse(source);

  final host = uri.host;
  final port = uri.hasPort ? uri.port : 5432;
  if (!uri.hasAuthority || uri.userInfo.isEmpty || uri.pathSegments.isEmpty) {
    _showUriError('Invalid DATABASE_URL!');
    exit(0);
  }
  final user = uri.userInfo.split(':')[0];
  final password = uri.userInfo.split(':')[1];
  final database = uri.pathSegments.first;
  final schema = uri.queryParameters['schema'] ?? 'public';
  final ssl = uri.queryParameters['sslmode'] == 'require';

  if (!input.existsSync()) {
    _showOutputError(p.relative(input.path, from: Directory.current.path));
    exit(0);
  }
  final files = input.listSync(recursive: true).where((f) => p.extension(f.path) == '.sql');
  if (files.isEmpty) {
    _showFilesError(p.relative(input.path, from: Directory.current.path));
    exit(0);
  }
  try {
    final conn = await Connection.open(
      Endpoint(
        host: host,
        database: database,
        username: user,
        password: password,
        port: port,
      ),
      settings: ConnectionSettings(
        sslMode: ssl ? SslMode.require : SslMode.disable,
        onOpen: (connection) async {
          await connection.execute('SET search_path TO $schema;');
        },
      ),
    );

    final migrations = files.map((file) => File(file.path).readAsLinesSync().join('\n'));

    final newTables = migrations.map(_regTb.allMatches).expand((m) => m).fold(
      <String, String>{},
      (prev, next) {
        final table = next.group(2)!;

        return {...prev, table: next.group(0)!};
      },
    );

    await conn.runTx(
      (tx) async {
        final checkResult = await tx.execute(
          r'SELECT EXISTS(SELECT FROM pg_tables WHERE schemaname = $1 AND tablename = $2);',
          parameters: [schema, '__migrations'],
        );

        final check = checkResult.first.first as bool;

        if (check) {
          final last = await tx.execute('SELECT * FROM __migrations ORDER BY created_at DESC LIMIT 1;');

          if (last.isNotEmpty) {
            final [
              int _,
              Map<String, dynamic> oldTables,
              DateTime _,
            ] = last.first as List;

            if (!_mapEquals(newTables, oldTables)) {
              stdout.writeln('Updating...');

              final tablesResult = await tx.execute(
                r'SELECT tablename FROM pg_tables WHERE schemaname = $1 AND tablename != $2;',
                parameters: [schema, '__migrations'],
              );

              for (final name in tablesResult.map((r) => r.join(', ')).toList()) {
                await tx.execute('DROP TABLE IF EXISTS $name CASCADE;');
              }

              final insertMigration = await tx.execute(
                r'INSERT INTO __migrations (tables) VALUES ($1) RETURNING id;',
                parameters: [jsonEncode(newTables)],
              );

              await tx.execute(migrations.join('\n'), queryMode: QueryMode.simple);

              stdout.writeln('Updated, the current version is ${insertMigration.first.first as int}!');
            } else {
              stdout.writeln('Nothing to do, the current version is ${last.first.first as int}!');
            }
          } else {
            stdout.writeln('Updating...');

            final insertMigration = await tx.execute(
              r'INSERT INTO __migrations (schema) VALUES ($1);',
              parameters: [jsonEncode(newTables)],
            );

            await tx.execute(migrations.join('\n'), queryMode: QueryMode.simple);

            stdout.writeln('Updated, the current version is ${insertMigration.first.first as int}!');
          }
        } else {
          await tx.execute('CREATE TABLE __migrations (id INTEGER PRIMARY KEY GENERATED ALWAYS AS IDENTITY, tables JSONB NOT NULL, created_at TIMESTAMP NOT NULL DEFAULT NOW());');

          await tx.execute(
            r'INSERT INTO __migrations (tables) VALUES ($1);',
            parameters: [jsonEncode(newTables)],
          );

          await tx.execute(migrations.join('\n'), queryMode: QueryMode.simple);

          stdout.writeln('Created, the current version is 1!');
        }
      },
    );
    await conn.close();
    return _generate(input, output);
  } on Exception catch (e) {
    _showExceptionError(e);
    exit(0);
  }
}

void _generate(Directory input, Directory output) {
  final entitiesBuffer = StringBuffer();

  final queriesBuffer = StringBuffer();

  final tables = <_Table>[];

  for (final current in input.listSync(recursive: true)) {
    if (p.extension(current.path) != '.sql') continue;

    final file = File(current.path);

    if (!file.existsSync()) continue;

    final content = file.readAsLinesSync().join('\n');

    tables.addAll(
      _regTb.allMatches(content).map(
            (match) => _Table(
              entity: match.group(1)!,
              name: match.group(2)!,
              lines: match.group(3)!.split('\n').map((l) => l.trim()).where((l) => l.isNotEmpty).toList(),
            ),
          ),
    );
  }

  for (var i = 0; i < tables.length; i++) {
    _Table table = tables[i];

    for (final line in table.lines) {
      final match1 = _regFk1.firstMatch(line);
      final match2 = _regFk2.firstMatch(line);

      if (match1 != null) {
        final constraintRef = match1.group(1);
        final colOrigin = match1.group(2)!;
        final tableRef = match1.group(3)!;
        // final columnRef = match1.group(4)!;

        final index = tables.indexWhere((t) => t.name == tableRef);
        if (index < 0) continue;

        tables[index] = tables[index].copyWith(
          references: {
            ...tables[index].references,
            '${constraintRef ?? tableRef}:$colOrigin': table,
          },
        );
      } else if (match2 != null) {
        final colOrigin = match2.group(1)!;
        final tableRef = match2.group(1)!;
        // final columnRef = match2.group(2)!;

        final index = tables.indexWhere((t) => t.name == tableRef);
        if (index < 0) continue;
        tables[index] = tables[index].copyWith(
          references: {
            ...tables[index].references,
            '$tableRef:$colOrigin': table,
          },
        );
      }
    }
  }

  entitiesBuffer.writeln(_entitiesBuilder(tables));

  queriesBuffer.writeln(_dsqlBuilder(tables));

  final entities = File(p.join(output.path, 'entities.dart'));

  final dsql = File(p.join(output.path, 'dsql.dart'));

  if (!entities.existsSync()) entities.createSync(recursive: true);

  entities.writeAsStringSync(_entitiesImportsBuilder(entitiesBuffer.toString()));

  if (!dsql.existsSync()) dsql.createSync(recursive: true);

  dsql.writeAsStringSync(_dsqlImportsBuilder(queriesBuffer.toString()));

  _format(output);

  stdout.writeln('Done, your dart files are in ${p.relative(output.path, from: Directory.current.path)}!');

  exit(0);
}

String _fieldName(String col) {
  return col.split(' ')[0].toCamelCase(lower: true);
}

Type _fieldType(String col) {
  final sql = col.split(' ')[1].toUpperCase().replaceAll(RegExp(r'[,.]'), '');

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

String _dsqlBuilder(List<_Table> tables) {
  final queries = <String>[];

  queries.add('''class DSQL {
${tables.map(
    (table) {
      final name = table.name.startsWith('tb_') ? table.name.substring(3) : table.name;

      return '  late final ${table.repository} ${_tryToPluralize(name)};';
    },
  ).join('\n')}

  DSQL._(Connection conn, {bool verbose = false}) {
${tables.map(
    (table) {
      final name = table.name.startsWith('tb_') ? table.name.substring(3) : table.name;

      return '${_tryToPluralize(name)} = ${table.repository}(conn, verbose: verbose);';
    },
  ).join('\n')}
  }

  static Future<DSQL> open(String databaseURL, {bool verbose = false}) async {
    final uri = Uri.parse(databaseURL);
    final host = uri.host;
    final port = uri.hasPort ? uri.port : 5432;
    final username = switch (uri.hasAuthority && uri.userInfo.isNotEmpty) {
      false => null,
      true => uri.userInfo.split(':')[0],
    };
    final password = switch (uri.hasAuthority && uri.userInfo.isNotEmpty) {
      false => null,
      true => uri.userInfo.split(':')[1],
    };
    final database = switch (uri.pathSegments.isNotEmpty) {
      true => uri.pathSegments.first,
      false => throw Exception('Database name is required!'),
    };
    final sslMode = switch (uri.queryParameters['sslmode']) {
      'require' => SslMode.require,
      'verify-full' => SslMode.verifyFull,
      'disable' => SslMode.disable,
      _ => SslMode.disable,
    };
    final conn = await Connection.open(
        Endpoint(
          host: host,
          port: port,
          username: username,
          password: password,
          database: database,
        ),
        settings: ConnectionSettings(
          sslMode: sslMode,
        ),
    );

    return DSQL._(conn, verbose: verbose);
  }
}''');

  for (final table in tables) {
    final content = '''class ${table.repository} {
  final Connection _conn;
  final bool verbose;

  const ${table.repository}(this._conn, {this.verbose = false});

  ${_insertOneBuilder(table)}

  ${_insertManyBuilder(table)}

  ${_findManyBuilder(table)}

  ${_findOneBuilder(table)}

  ${_findByPkBuilder(table)}

  ${_findByUniqueKeyBuilder(table)}

  ${_updateOneBuilder(table)}

  ${_deleteOneBuilder(table)}
}''';
    queries.add(content);
  }

  return queries.join('\n\n');
}

String _dsqlImportsBuilder(String content) {
  return '''// This file is generated by DSQL.
// Do not modify it manually.

import 'package:dsql/dsql.dart';
import 'dart:convert';

part 'entities.dart';

$content
''';
}

String _entitiesBuilder(List<_Table> tables) {
  final entities = <String>[];

  for (final table in tables) {
    final hasReferences = table.references.isNotEmpty;
    final content = '''class ${table.entity} {
    
${table.columns.map((c) => 'final ${_fieldType(c)}${_isNullable(c) ? '?' : ''} ${_fieldName(c)};').join('\n')}
${table.references.entries.map((entry) {
      return 'final List<${entry.value.entity}> ${_tryToPluralize(_constraintNameNormalizer(entry.key.split(':').first))};';
    }).join('\n')}

const ${table.entity}({
  ${table.columns.map((c) => _isNullable(c) ? 'this.${_fieldName(c)},' : 'required this.${_fieldName(c)},').join('\n')}
  ${table.references.entries.map((entry) {
      return 'this.${_tryToPluralize(_constraintNameNormalizer(entry.key.split(':').first))} = const <${entry.value.entity}>[],';
    }).join('\n')}
});

${table.entity} copyWith({
${table.columns.map((c) => '${_fieldType(c)}? ${_fieldName(c)},').join('\n')}
${table.references.entries.map((entry) => 'List<${entry.value.entity}>? ${_tryToPluralize(_constraintNameNormalizer(entry.key.split(':').first))},').join('\n')}
  }) {
    return ${table.entity}(
${table.columns.map((c) => '${_fieldName(c)}: ${_fieldName(c)} ?? this.${_fieldName(c)},').join('\n')}
${table.references.entries.map((entry) {
      return '${_tryToPluralize(_constraintNameNormalizer(entry.key.split(':').first))}: ${_tryToPluralize(_constraintNameNormalizer(entry.key.split(':').first))} ?? this.${_tryToPluralize(_constraintNameNormalizer(entry.key.split(':').first))},';
    }).join('\n')}
    );
  }

  Map<String, dynamic> toMap() {
    return {
${table.columns.map((c) => '\'${_fieldName(c).toSnakeCase()}\': ${_fieldName(c)},').join('\n')}
${table.references.entries.map((entry) {
      return '\'${_tryToPluralize(_constraintNameNormalizer(entry.key.split(':').first)).toSnakeCase()}\': ${_tryToPluralize(_constraintNameNormalizer(entry.key.split(':').first))}.map((e) => e.toMap()).toList(),';
    }).join('\n')}
    };
  }

  String toJson() => json.encode(toMap());

  factory ${table.entity}.fromMap(Map<String, dynamic> map) {
      return ${table.entity}(
${table.columns.map((c) => '        ${_fieldName(c)}: map[\'${_fieldName(c).toSnakeCase()}\'] as ${_fieldType(c)},').join('\n')}
${table.references.entries.map(
      (entry) {
        return '''${_tryToPluralize(_constraintNameNormalizer(entry.key.split(":").first))}: List<${entry.value.entity}>.from(
            (map['${_tryToPluralize(_constraintNameNormalizer(entry.key.split(":").first)).toSnakeCase()}'] as List).map((innerMap) {
              return ${entry.value.entity}.fromMap(innerMap);
            },
          ),
        ),''';
      },
    ).join('\n')}
      );
  }

  @override
  String toString() {
    return '${table.entity}(${table.columns.map((c) => '${_fieldName(c)}: \$${_fieldName(c)}').join(', ')}${hasReferences ? ', ' : ''}${table.references.entries.map((entry) => '${_tryToPluralize(_constraintNameNormalizer(entry.key.split(':').first))}: \$${_tryToPluralize(_constraintNameNormalizer(entry.key.split(':').first))}').join(', ')})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ${table.entity} && ${table.columns.map((c) => 'other.${_fieldName(c)} == ${_fieldName(c)}').join(' && ')};
  }

  @override
  int get hashCode {
    return ${table.columns.map((c) => '${_fieldName(c)}.hashCode').join(' ^ ')};
  }
}''';

    entities.add(content);
  }

  return entities.join('\n\n');
}

String _insertOneBuilder(_Table table) {
  return '''AsyncResult<${table.entity}, Exception> insertOne({
${table.columns.where((c) => _isRequired(c)).map((c) => 'required ${_fieldType(c)} ${_fieldName(c)},').join('\n')}
  }) async {
    try {
      final query = r'INSERT INTO ${table.name} (${table.columns.where((c) => _isRequired(c)).map((c) => _fieldName(c).toSnakeCase()).join(', ')}) VALUES (${table.columns.where((c) => _isRequired(c)).indexedMap((i, c) => '\$${i + 1}').join(', ')}) RETURNING *;';

      if (verbose) {
        print('${'-' * 80}');

        print('SQL => \$query');

        print('PARAMS => ${table.columns.where((c) => _isRequired(c)).map((c) => '\$${_fieldName(c)}').join(', ')}');

        print('${'-' * 80}');
      }

      final result = await _conn.execute(
          query,
          parameters: [${table.columns.where((c) => _isRequired(c)).map((c) => ' ${_fieldName(c)}').join(', ')}],
      );

      if (result.isEmpty) {
        return Error(Exception('Fail to insert data on table `${table.name}`!'));
      }

      final row = result.first;

      final [
${table.columns.map((c) => '${_fieldType(c)}${_isNullable(c) ? '?' : ''} \$${_fieldName(c)},').join('\n')}
      ] = row as List;

      final entity = ${table.entity}(
${table.columns.map((c) => '${_fieldName(c)}: \$${_fieldName(c)},').join('\n')}
      );

      return Success(entity);
    } on Exception catch (e) {
      return Error(e);
    }
  }''';
}

String _insertManyBuilder(_Table table) {
  return '''AsyncResult<List<${table.entity}>, Exception> insertMany({
required List<({${table.columns.where((c) => _isRequired(c)).map((c) => '${_fieldType(c)} ${_fieldName(c)}').join(', ')}})> values,
  }) async {
  try {
    if (values.isEmpty) {
      return Error(Exception('Fail to insert: no data to insert!'));
    }

    final query = 'INSERT INTO ${table.name} (${table.columns.where((c) => _isRequired(c)).map((c) => _fieldName(c).toSnakeCase()).join(', ')}) VALUES \${values.indexedMap((index, value) => '(${table.columns.where((c) => _isRequired(c)).indexedMap((i, c) => '\\\$\${$i + 1 + (index * ${table.columns.where((c) => _isRequired(c)).length})}').join(', ')})').join(', ')} RETURNING *;';

    final parameters = values.map((v) => [${table.columns.where((c) => _isRequired(c)).map((value) => 'v.${_fieldName(value)}').join(', ')}]).expand((v) => v).toList();

    if (verbose) {
      print('${'-' * 80}');

      print('SQL => \$query');

      print('PARAMS => \$parameters');

      print('${'-' * 80}');
    }

    final result = await _conn.execute(
      query,
      parameters: parameters,
    );

    if (result.isEmpty) {
      return Error(Exception('Fail to insert data on table `${table.name}`!'));
    }

    if (result.length != values.length) {
      return Error(Exception('Fail to insert data on table `${table.name}`!'));
    }

    final entities = List<${table.entity}>.from(
        result.map((row) {
          final [
  ${table.columns.map((c) => '${_fieldType(c)}${_isNullable(c) ? '?' : ''} \$${_fieldName(c)},').join('\n')}
          ] = row as List;

          final entity = ${table.entity}(
  ${table.columns.map((c) => '${_fieldName(c)}: \$${_fieldName(c)},').join('\n')}
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

String _findManyBuilder(_Table table) {
  return '''AsyncResult<List<${table.entity}>, Exception> findMany({
  ${table.columns.map((c) => 'Where? ${_fieldName(c)},').join('\n')}
  int? limit,
  int? offset,
  OrderBy? orderBy,
  }) async {
    try {
      String query = 'SELECT * FROM ${table.name};';

      final wheres = <String, Where>{
${table.columns.map((c) => 'if (${_fieldName(c)} != null) \'${_fieldName(c).toSnakeCase()}\': ${_fieldName(c)},').join('\n')}
      };

      if (wheres.isNotEmpty) {
        query = 'SELECT * FROM ${table.name} WHERE \${wheres.entries.indexedMap((index, entry) => '\${entry.key} \${entry.value.op} \\\$\${index + 1}').join(' AND ')}';
      }

      if (offset != null) {
        query += ' OFFSET \$offset';
      }

      if (limit != null) {
        query += ' LIMIT \$limit';
      }

      if (orderBy != null) {
        query += ' ORDER BY \${orderBy.sql}';
      }

      query += ';';

      if (verbose) {
        print('${'-' * 80}');

        print('SQL => \$query');

        print('PARAMS => \${wheres.values.map((w) => w.value).toList()}');

        print('${'-' * 80}');
      }

      final result = await _conn.execute(
        query, 
        parameters: wheres.values.map((w) => w.value).toList(),
      );

      final entities = List<${table.entity}>.from(
        result.map((row) {
            final [${table.columns.map((c) => '${_fieldType(c)}${_isNullable(c) ? '?' : ''} \$${_fieldName(c)},').join('\n')}] = row as List;
            
            return ${table.entity}(
              ${table.columns.map((c) => '${_fieldName(c)}: \$${_fieldName(c)},').join('\n')}
            );
          },
        ),
      );

      return Success(entities);
    } on Exception catch (e) {
      return Error(e);
    }
  }''';
}

String _findOneBuilder(_Table table) {
  return '''AsyncResult<${table.entity}, Exception> findOne({
  ${table.columns.map((c) => 'Where? ${_fieldName(c)},').join('\n')}
  }) async {
    try {
      final wheres = <String, Where>{
${table.columns.map((c) => 'if (${_fieldName(c)} != null) \'${_fieldName(c).toSnakeCase()}\': ${_fieldName(c)},').join('\n')}
      };

      if (wheres.isEmpty) {
        return Error(Exception('You need to pass at least one where parameter!'));
      }

      final query = 'SELECT * FROM ${table.name} WHERE \${wheres.entries.indexedMap((index, entry) => '\${entry.key} \${entry.value.op} \\\$\${index + 1}').join(' AND ')} LIMIT 1;';

      if (verbose) {
        print('${'-' * 80}');

        print('SQL => \$query');

        print('PARAMS => \${wheres.values.map((w) => w.value).toList()}');

        print('${'-' * 80}');
      }

      final result = await _conn.execute(
        query, 
        parameters: wheres.values.map((w) => w.value).toList(),
      );

      if (result.isEmpty) {
        return Error(Exception('${table.entity} not found'));
      }

      final row = result.first;

      final [${table.columns.map((c) => '${_fieldType(c)}${_isNullable(c) ? '?' : ''} \$${_fieldName(c)},').join('\n')}] = row as List;
            
      final entity = ${table.entity}(
        ${table.columns.map((c) => '${_fieldName(c)}: \$${_fieldName(c)},').join('\n')}
      );

      return Success(entity);
    } on Exception catch (e) {
      return Error(e);
    }
  }''';
}

String _findByPkBuilder(_Table table) {
  return switch (_hasPrimaryKey(table.columns)) {
    false => '',
    true => '''AsyncResult<${table.entity}, Exception> findByPK(
    ${_getPkType(table.columns)} ${_getPkName(table.columns)}
  ) async {
  try {
    String query = r'SELECT * FROM ${table.name} WHERE ${_getPkName(table.columns).toSnakeCase()} = \$1 LIMIT 1;';

    if (verbose) {
      print('${'-' * 80}');

      print('SQL => \$query');

      print('PARAMS => \$${_getPkName(table.columns)}');

      print('${'-' * 80}');
    }

    final result = await _conn.execute(
      query, 
      parameters: [${_getPkName(table.columns)}],
    );
  
    if (result.isEmpty) {
      return Error(Exception('Fail to find data on table `${table.name}`!'));
    }
  
    final row = result.first;

    final [
${table.columns.map((c) => '${_fieldType(c)}${_isNullable(c) ? '?' : ''} \$${_fieldName(c)},').join('\n')}
    ] = row as List;

    final entity = ${table.entity}(
${table.columns.map((c) => '${_fieldName(c)}: \$${_fieldName(c)},').join('\n')}
    );
  
    return Success(entity);
  } on Exception catch (e) {
    return Error(e);
  }
}''',
  };
}

String _findByUniqueKeyBuilder(_Table table) {
  return switch (_hasUniqueKey(table.columns)) {
    false => '',
    true => _getUniqueKeysMapped(table.columns).entries.map(
        (uk) {
          return '''AsyncResult<${table.entity}, Exception> findBy${uk.key.toSnakeCase().toCamelCase()}(
    ${uk.value} ${uk.key}
  ) async {
  try {
    final query = r'SELECT * FROM ${table.name} WHERE ${uk.key.toSnakeCase()} = \$1 LIMIT 1;';

    if (verbose) {
      print('${'-' * 80}');

      print('SQL => \$query');

      print('PARAMS => \$${uk.key}');

      print('${'-' * 80}');
    }

    final result = await _conn.execute(
      query, 
      parameters: [${uk.key}],
    );
  
    if (result.isEmpty) {
      return Error(Exception('Fail to find data on table `${table.name}`!'));
    }
  
    final row = result.first;
  
    final [
      ${table.columns.map((c) => '${_fieldType(c)}${_isNullable(c) ? '?' : ''} \$${_fieldName(c)},').join('\n')}
    ] = row as List;
  
    final entity = ${table.entity}(
      ${table.columns.map((c) => '${_fieldName(c)}: \$${_fieldName(c)},').join('\n')}
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

String _updateOneBuilder(_Table table) {
  return '''AsyncResult<${table.entity}, Exception> updateOne({
${table.columns.map((c) => 'Where? where${_fieldName(c).toSnakeCase().toCamelCase()},').join('\n')}
${table.columns.where((c) => !_isPrimaryKey(c)).map((c) => '${_fieldType(c)}? set${_fieldName(c).toSnakeCase().toCamelCase()},').join('\n')}
  }) async {
    try {
    final wheres = <String, Where>{
${table.columns.map((c) => 'if (where${_fieldName(c).toSnakeCase().toCamelCase()} != null) \'${_fieldName(c).toSnakeCase()}\': where${_fieldName(c).toSnakeCase().toCamelCase()},').join('\n')}
    };

    if (wheres.isEmpty) {
      return Error(Exception('No filters to update!'));
    }

    final parameters = <String, dynamic>{
${table.columns.where((c) => !_isPrimaryKey(c)).map((c) => 'if (set${_fieldName(c).toSnakeCase().toCamelCase()} != null) \'${_fieldName(c).toSnakeCase()}\': set${_fieldName(c).toSnakeCase().toCamelCase()},').join('\n')}
    };

    if (parameters.isEmpty) {
      return Error(Exception('No data to update!'));
    }

    final query = 'UPDATE ${table.name} SET \${parameters.entries.indexedMap((index, entry) => '\${entry.key} = \\\$\${index + 1}').join(', ')} WHERE \${wheres.entries.indexedMap((index, entry) => '\${entry.key} \${entry.value.op} \\\$\${index + 1 + parameters.length}').join(' AND ')} RETURNING *;';

    if (verbose) {
      print('${'-' * 80}');

      print('SQL => \$query');

      print('PARAMS => \${parameters.values.join(', ')}, \${wheres.values.map((w) => w.value).join(', ')}');

      print('${'-' * 80}');
    }

    final result = await _conn.execute(
      query, 
      parameters: [...parameters.values, ...wheres.values.map((w) => w.value)],
    );
    
    if (result.isEmpty) {
      return Error(Exception('Fail to update data on table `${table.name}`!'));
    }

    final row = result.first;

    final [
${table.columns.map((c) => '${_fieldType(c)}${_isNullable(c) ? '?' : ''} \$${_fieldName(c)},').join('\n')}
    ] = row as List;

    final entity = ${table.entity}(
${table.columns.map((c) => '${_fieldName(c)}: \$${_fieldName(c)},').join('\n')}
    );

    return Success(entity);
    } on Exception catch (e) {
      return Error(e);
    }
  }''';
}

String _deleteOneBuilder(_Table table) {
  return '''AsyncResult<${table.entity}, Exception> deleteOne({
${table.columns.map((c) => 'Where? where${_fieldName(c).toSnakeCase().toCamelCase()},').join('\n')}
  }) async {
    try {
      final wheres = <String, Where>{
${table.columns.map((c) => 'if (where${_fieldName(c).toSnakeCase().toCamelCase()} != null) \'${_fieldName(c).toSnakeCase()}\': where${_fieldName(c).toSnakeCase().toCamelCase()},').join('\n')}
      };

      if (wheres.isEmpty) {
        return Error(Exception('No filters to delete!'));
      }

      final query = 'DELETE FROM ${table.name} WHERE \${wheres.entries.indexedMap((index, entry) => '\${entry.key} \${entry.value.op} \\\$\${index + 1}').join(' AND ')} RETURNING *;';
    
      if (verbose) {
        print('${'-' * 80}');

        print('SQL => \$query');

        print('PARAMS => \${wheres.values.map((w) => w.value).join(', ')}');

        print('${'-' * 80}');
      }

      final result = await _conn.execute(
        query, 
        parameters: wheres.values.map((w) => w.value).toList(),
      );
      
      if (result.isEmpty) {
        return Error(Exception('Fail to delete data on table `${table.name}`!'));
      }

      final row = result.first;

      final [
${table.columns.map((c) => '${_fieldType(c)}${_isNullable(c) ? '?' : ''} \$${_fieldName(c)},').join('\n')}
      ] = row as List;

      final entity = ${table.entity}(
${table.columns.map((c) => '${_fieldName(c)}: \$${_fieldName(c)},').join('\n')}
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

part of 'dsql.dart';

$content
''';
}

String _tryToPluralize(String word) {
  if (word.endsWith('s')) {
    return word;
  } else if (word.endsWith('y')) {
    return '${word.substring(0, word.length - 1)}ies';
  } else if (word.endsWith('ch')) {
    return '${word.substring(0, word.length - 2)}ches';
  } else if (word.endsWith('f')) {
    return '${word.substring(0, word.length - 1)}ves';
  } else if (word.endsWith('fe')) {
    return '${word.substring(0, word.length - 2)}ves';
  } else if (word.endsWith('x')) {
    return '${word.substring(0, word.length - 1)}xes';
  } else if (word.endsWith('z')) {
    return '${word.substring(0, word.length - 1)}zes';
  } else if (word.endsWith('us')) {
    return '${word.substring(0, word.length - 2)}i';
  } else if (word.endsWith('ss')) {
    return '${word.substring(0, word.length - 2)}es';
  } else if (word.endsWith('sh')) {
    return '${word.substring(0, word.length - 2)}es';
  } else if (word.endsWith('o')) {
    return '${word.substring(0, word.length - 1)}oes';
  } else if (word.endsWith('er')) {
    return '${word.substring(0, word.length - 2)}ers';
  } else if (word.endsWith('ing') || word.endsWith('ed') || word.endsWith('ers')) {
    return word;
  } else {
    return '${word}s';
  }
}

String _constraintNameNormalizer(String constraint) {
  String base = constraint;
  if (base.toLowerCase().startsWith('tb_')) {
    base = base.substring(3);
  }
  if (base.toLowerCase().startsWith('fk_')) {
    base = base.substring(3);
  }
  if (base.toLowerCase().endsWith('_id')) {
    base = base.substring(0, base.length - 3);
  }
  return base.toCamelCase(lower: true);
}

void _format(Directory output) {
  Process.runSync('dart', ['format', output.path]);
}

void _showUriError(String message) {
  _clearConsole();
  stdout.writeln('-' * 80);
  stdout.writeln('ERROR');
  stdout.writeln('-' * 80);
  stdout.writeln(message);
  stdout.writeln();
  stdout.writeln('e.g. postgresql://username:password@localhost:5432/database');
  stdout.writeln('-' * 80);
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
  stdout.writeln('-' * 80);
  stdout.writeln('ERROR');
  stdout.writeln('-' * 80);
  stdout.writeln('An unexpected error has occurred!');
  stdout.writeln();
  stdout.writeln(ex.toString());
  stdout.writeln('-' * 80);
}

void _clearConsole() => stdout.write('\x1B[2J\x1B[0;0H');

bool _mapEquals(Map<String, dynamic> m1, Map<String, dynamic> m2) {
  if (m1.length != m2.length) {
    return false;
  }
  for (final key in m1.keys) {
    if (m1[key] != m2[key]) {
      return false;
    }
  }
  return true;
}

class _Table {
  final String entity;
  final String name;
  final List<String> lines;
  final Map<String, _Table> references;

  const _Table({required this.entity, required this.name, required this.lines, this.references = const {}});

  String get rawEntityName => entity.substring(0, entity.length - 6);

  String get repository => '${_tryToPluralize(rawEntityName)}Repository';

  List<String> get columns => lines.where((l) => !RegExp(r'^(CONSTRAINT|FOREIGN KEY)').hasMatch(l)).toList();

  String get nameWithoutPrefixTB => switch (name.startsWith('tb_')) {
        true => name.substring(3),
        false => name,
      };

  _Table copyWith({
    String? entity,
    String? name,
    List<String>? lines,
    Map<String, _Table>? references,
  }) {
    return _Table(
      entity: entity ?? this.entity,
      name: name ?? this.name,
      lines: lines ?? this.lines,
      references: references ?? this.references,
    );
  }
}

extension _ListExt<T> on Iterable<T> {
  Iterable<S> indexedMap<S>(S Function(int index, T element) func) {
    return Iterable<S>.generate(length, (i) => func(i, elementAt(i)));
  }
}
