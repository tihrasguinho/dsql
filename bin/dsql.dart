import 'dart:io';

import 'package:args/args.dart';
import 'package:path/path.dart' as p;
import 'package:postgres/postgres.dart' hide Type;
import 'package:strings/strings.dart';

final regFk1 = RegExp(r'^CONSTRAINT\s(\w+)\sFOREIGN\sKEY\s\((\w+)\)\sREFERENCES\s(\w+)\s\((\w+)\)');
final regFk2 = RegExp(r'REFERENCES\s(\w+)\s?\((\w+)\)');

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

  final tables = <_Table>[];

  for (final current in input.listSync(recursive: true)) {
    if (p.extension(current.path) != '.sql') continue;

    final file = File(current.path);

    if (!file.existsSync()) continue;

    final content = file.readAsLinesSync().join('\n');

    final regex = RegExp(r"--\sentity:\s([\w]+)\sCREATE TABLE(?: IF NOT EXISTS)?\s([\w]+)\s\(([\s\w\d\(\)\,\']+)\s\);");

    tables.addAll(
      regex.allMatches(content).map(
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
      final match1 = regFk1.firstMatch(line);
      final match2 = regFk2.firstMatch(line);

      if (match1 != null) {
        final constraintRef = match1.group(1);
        // final colOrigin = match.group(2)!;
        final tableRef = match1.group(3)!;
        final columnRef = match1.group(4)!;

        final index = tables.indexWhere((t) => t.name == tableRef);
        if (index < 0) continue;

        tables[index] = tables[index].copyWith(
          references: {
            ...tables[index].references,
            '${constraintRef ?? tableRef}:$columnRef': table,
          },
        );
      } else if (match2 != null) {
        // final colOrigin = match.group(1)!;
        final tableRef = match2.group(1)!;
        final columnRef = match2.group(2)!;

        print(' ---> FOUND2: $tableRef $columnRef');

        final index = tables.indexWhere((t) => t.name == tableRef);
        if (index < 0) continue;
        tables[index] = tables[index].copyWith(
          references: {
            ...tables[index].references,
            '$tableRef:$columnRef': table,
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

  ${_findManyBuilder(table)}

  ${_findByPkBuilder(table)}

  ${_findByUniqueKeyBuilder(table)}

  ${_updateOneBuilder(table)}

  ${_deleteOneBuilder(table)}
}

${_insertOneParamsBuilder(table)}

${_findManyParamsBuilder(table)}

${_updateOneParamsBuilder(table)}

${_deleteOneParamsBuilder(table)}
''';
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
${table.columns.map((c) => '      \'${_fieldName(c).toSnakeCase()}\': ${_fieldName(c)},').join('\n')}
    };
  }

  String toJson() => json.encode(toMap());

  factory ${table.entity}.fromMap(Map<String, dynamic> map) {
      return ${table.entity}(
${table.columns.map((c) => '        ${_fieldName(c)}: map[\'${_fieldName(c).toSnakeCase()}\'] as ${_fieldType(c)},').join('\n')}
      );
  }
}''';

    entities.add(content);
  }

  return entities.join('\n\n');
}

String _insertOneParamsBuilder(_Table table) {
  return '''class InsertOne${table.rawEntityName}Params {
  ${table.columns.where((c) => _isRequired(c)).map((c) => 'final ${_fieldType(c)} ${_fieldName(c)};').join('\n')}

  const InsertOne${table.rawEntityName}Params({
  ${table.columns.where((c) => _isRequired(c)).map((c) => 'required this.${_fieldName(c)},').join('\n')}
  });

  List get indexedParams => [
  ${table.columns.where((c) => _isRequired(c)).map((c) => '${_fieldName(c)},').join('\n')}
  ];
}''';
}

String _insertOneBuilder(_Table table) {
  return '''AsyncResult<${table.entity}, Exception> insertOne(InsertOne${table.rawEntityName}Params params) async {
    try {

      final query = r'INSERT INTO ${table.name} (${table.columns.where((c) => _isRequired(c)).map((c) => _fieldName(c)).join(', ')}) VALUES (${List.generate(table.columns.where((c) => _isRequired(c)).length, (i) => '\$${i + 1}').join(', ')}) RETURNING *;';

      if (verbose) {
        print('${'-' * 80}');

        print('SQL => \$query');

        print('PARAMS => \${params.indexedParams}');

        print('${'-' * 80}');
      }

      final result = await _conn.execute(
          query,
          parameters: params.indexedParams,
      );

      if (result.isEmpty) {
        return Error(Exception('Fail to insert data on table `${table.name}`!'));
      }

      final row = result.first;

      final [
${table.columns.map((c) => '${_fieldType(c)}${_isNullable(c) ? '?' : ''} ${_fieldName(c)},').join('\n')}
      ] = row as List;

      final entity = ${table.entity}(
${table.columns.map((c) => '${_fieldName(c)}: ${_fieldName(c)},').join('\n')}
      );

      return Success(entity);
    } on Exception catch (e) {
      return Error(e);
    }
  }''';
}

String _findManyParamsBuilder(_Table table) {
  return '''class FindMany${table.rawEntityName}Params {
  ${table.columns.map((c) => 'final Where? ${_fieldName(c)};').join('\n')}
  final int? limit;
  final int? offset;
  final OrderBy? orderBy;

  const FindMany${table.rawEntityName}Params({
    ${table.columns.map((c) => 'this.${_fieldName(c)},').join('\n')}
    this.limit,
    this.offset,
    this.orderBy,
  });

  Map<String, Where> get wheres => {
    ${table.columns.map((c) => 'if (${_fieldName(c)} != null) \'${_fieldName(c).toSnakeCase()}\': ${_fieldName(c)}!,').join('\n')}
  };
}''';
}

String _findManyBuilder(_Table table) {
  return '''AsyncResult<List<${table.entity}>, Exception> findMany([
    FindMany${table.rawEntityName}Params params = const FindMany${table.rawEntityName}Params(),
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

      final query = 'SELECT * FROM ${table.name}\$where\$orderBy\$offset\$limit;';

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

      final entities = List<${table.entity}>.from(
        result.map(
          (row) {
            final [
${table.columns.map((c) => '${_fieldType(c)}${_isNullable(c) ? '?' : ''} ${_fieldName(c)},').join('\n')}
            ] = row as List;

            final entity = ${table.entity}(
${table.columns.map((c) => '${_fieldName(c)}: ${_fieldName(c)},').join('\n')}
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

String _findByPkBuilder(_Table table) {
  return switch (_hasPrimaryKey(table.columns)) {
    false => '',
    true => '''AsyncResult<${table.entity}, Exception> findByPK(
    ${_getPkType(table.columns)} pk
  ) async {
  try {
    final query = r'SELECT * FROM ${table.name} WHERE ${_getPkName(table.columns)} = \$1 LIMIT 1;';

    if (verbose) {
      print('${'-' * 80}');

      print('SQL => \$query');

      print('PARAMS => \${[pk]}');

      print('${'-' * 80}');
    }

    final result = await _conn.execute(
      query, 
      parameters: [pk],
    );
  
    if (result.isEmpty) {
      return Error(Exception('Fail to find data on table `${table.name}`!'));
    }
  
    final row = result.first;
  
    final [
      ${table.columns.map((c) => '${_fieldType(c)}${_isNullable(c) ? '?' : ''} ${_fieldName(c)},').join('\n')}
    ] = row as List;
  
    final entity = ${table.entity}(
      ${table.columns.map((c) => '${_fieldName(c)}: ${_fieldName(c)},').join('\n')}
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
    ${uk.value} unique
  ) async {
  try {
    final query = r'SELECT * FROM ${table.name} WHERE ${uk.key.toSnakeCase()} = \$1 LIMIT 1;';

    if (verbose) {
      print('${'-' * 80}');

      print('SQL => \$query');

      print('PARAMS => \${[unique]}');

      print('${'-' * 80}');
    }

    final result = await _conn.execute(
      query, 
      parameters: [unique],
    );
  
    if (result.isEmpty) {
      return Error(Exception('Fail to find data on table `${table.name}`!'));
    }
  
    final row = result.first;
  
    final [
      ${table.columns.map((c) => '${_fieldType(c)}${_isNullable(c) ? '?' : ''} ${_fieldName(c)},').join('\n')}
    ] = row as List;
  
    final entity = ${table.entity}(
      ${table.columns.map((c) => '${_fieldName(c)}: ${_fieldName(c)},').join('\n')}
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

String _updateOneParamsBuilder(_Table table) {
  return '''class UpdateOne${table.rawEntityName}Params {
  ${table.columns.map((c) => 'final Where? where${_fieldName(c).toSnakeCase().toCamelCase()};').join('\n')}
  ${table.columns.where((c) => !_isPrimaryKey(c)).map((c) => 'final ${_fieldType(c)}? ${_fieldName(c)};').join('\n')}

  const UpdateOne${table.rawEntityName}Params({
    ${table.columns.map((c) => 'this.where${_fieldName(c).toSnakeCase().toCamelCase()},').join('\n')}
    ${table.columns.where((c) => !_isPrimaryKey(c)).map((c) => 'this.${_fieldName(c)},').join('\n')}
  });

  Map<String, Where> get wheres => {
    ${table.columns.map((c) => 'if (where${_fieldName(c).toSnakeCase().toCamelCase()} != null) \'${_fieldName(c).toSnakeCase()}\': where${_fieldName(c).toSnakeCase().toCamelCase()}!,').join('\n')}
  };

  Map<String, dynamic> get parameters => {
    ${table.columns.where((c) => !_isPrimaryKey(c)).map((c) => 'if (${_fieldName(c)} != null) \'${_fieldName(c).toSnakeCase()}\': ${_fieldName(c)},').join('\n')}
  };
}''';
}

String _updateOneBuilder(_Table table) {
  return '''AsyncResult<${table.entity}, Exception> updateOne(UpdateOne${table.rawEntityName}Params params) async {
    try {
    if (params.parameters.isEmpty) {
      return Error(Exception('No data to update!'));
    }

    final query = 'UPDATE ${table.name} SET \${List.generate(params.parameters.length, (i) => '\${params.parameters.keys.elementAt(i)} = \\\$\${i + 1}').join(', ')} WHERE \${List.generate(params.wheres.length, (i) => '\${params.wheres.keys.elementAt(i)} \${params.wheres.values.elementAt(i).op} \\\$\${i + 1 + params.parameters.length}').join(' AND ')} RETURNING *;';

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
      return Error(Exception('Fail to update data on table `${table.name}`!'));
    }

    final row = result.first;

    final [
${table.columns.map((c) => '${_fieldType(c)}${_isNullable(c) ? '?' : ''} ${_fieldName(c)},').join('\n')}
    ] = row as List;

    final entity = ${table.entity}(
${table.columns.map((c) => '${_fieldName(c)}: ${_fieldName(c)},').join('\n')}
    );

    return Success(entity);
    } on Exception catch (e) {
      return Error(e);
    }
  }''';
}

String _deleteOneParamsBuilder(_Table table) {
  return '''class DeleteOne${table.rawEntityName}Params {
  ${table.columns.map((c) => 'final Where? ${_fieldName(c)};').join('\n')}

  const DeleteOne${table.rawEntityName}Params({
  ${table.columns.map((c) => 'this.${_fieldName(c)},').join('\n')}
  });

  Map<String, Where> get wheres => {
  ${table.columns.map((c) => 'if (${_fieldName(c)} != null) \'${_fieldName(c).toSnakeCase()}\': ${_fieldName(c)}!,').join('\n')}
  };
}''';
}

String _deleteOneBuilder(_Table table) {
  return '''AsyncResult<${table.entity}, Exception> deleteOne(DeleteOne${table.rawEntityName}Params params) async {
    try {
      if (params.wheres.isEmpty) {
        return Error(Exception('No data to delete!'));
      }

      final query = 'DELETE FROM ${table.name} WHERE \${List.generate(params.wheres.length, (i) => '\${params.wheres.keys.elementAt(i)} \${params.wheres.values.elementAt(i).op} \\\$\${i + 1}').join(' AND ')} RETURNING *;';
    
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
