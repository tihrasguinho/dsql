import 'package:dsql/dsql.dart';
import 'package:dsql/src/internal/shared.dart';
import 'package:strings/strings.dart';

import 'table.dart';

String builder(List<Table> tables) {
  final buffer = StringBuffer();
  buffer.writeln(_importsBuilder());
  buffer.writeln();
  buffer.writeln(_dsqlBuilder(tables));
  buffer.writeln();
  for (final table in tables) {
    buffer.writeln(_repositoryBuilder(table));
    buffer.writeln();
    buffer.writeln(_insertOneParamsBuilder(table));
    buffer.writeln();
    buffer.writeln(_insertManyParamsBuilder(table));
    buffer.writeln();
    buffer.writeln(_findOneParamsBuider(table));
    buffer.writeln();
    buffer.writeln(_findManyParamsBuilder(table));
    buffer.writeln();
    buffer.writeln(_updateOneParamsBuilder(table));
    buffer.writeln();
    buffer.writeln(_updateManyParamsBuilder(table));
    buffer.writeln();
    buffer.writeln(_deleteOneParamsBuilder(table));
    buffer.writeln();
    buffer.writeln(_deleteManyParamsBuilder(table));
  }
  return buffer.toString();
}

String _importsBuilder() {
  return '''// This file is generated by DSQL.
// Do not modify it manually.

import 'package:dsql/dsql.dart';
import 'dart:convert';

part 'entities.dart';''';
}

String _dsqlBuilder(List<Table> tables) {
  return '''class DSQL {
    ${tables.map((t) => 'final ${t.repository} ${t.nameWithoutPrefixTB.toCamelCase(lower: true)};').join('\n')}

    const DSQL._({
      ${tables.map((t) => 'required this.${t.nameWithoutPrefixTB.toCamelCase(lower: true)},').join('\n')}
    });

    static Future<DSQL> withConnection(String databaseURL, {bool verbose = false}) async {
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
        false => throw DSQLException('Database name is required!'),
      };
      final sslMode = switch (uri.queryParameters['sslmode']) {
        'require' => SslMode.require,
        'verify-full' => SslMode.verifyFull,
        'disable' => SslMode.disable,
        _ => SslMode.disable,
      };
      final schema = uri.queryParameters['schema'];
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
            onOpen: (connection) async {
              if (schema != null) {
                await connection.execute('SET search_path TO \$schema;');
              }
            },
          ),
      );
      return DSQL._(
        ${tables.map((t) => '${t.nameWithoutPrefixTB.toCamelCase(lower: true)}: ${t.repository}(Database(conn, null), verbose: verbose),').join('\n')}
      );
    }

    static DSQL withPool(
      String databaseURL, {
      bool verbose = false,
      int? maxConnectionCount,
      Duration? maxConnectionAge,
      int? maxQueryCount,
    }) {
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
        false => throw DSQLException('Database name is required!'),
      };
      final sslMode = switch (uri.queryParameters['sslmode']) {
        'require' => SslMode.require,
        'verify-full' => SslMode.verifyFull,
        'disable' => SslMode.disable,
        _ => SslMode.disable,
      };
      final schema = uri.queryParameters['schema'];
      final pool = Pool.withEndpoints(
        [
          Endpoint(
            host: host,
            port: port,
            username: username,
            password: password,
            database: database,
          ),
        ],
        settings: PoolSettings(
          onOpen: (connection) async {
            if (schema != null) {
              await connection.execute('SET search_path TO \$schema;');
            }
          },
          sslMode: sslMode,
          maxConnectionCount: maxConnectionCount,
          maxConnectionAge: maxConnectionAge,
          maxQueryCount: maxQueryCount,
        ),
      );
      return DSQL._(
        ${tables.map((t) => '${t.nameWithoutPrefixTB.toCamelCase(lower: true)}: ${t.repository}(Database(null, pool), verbose: verbose),').join('\n')}
      );
    }
  }''';
}

String _repositoryBuilder(Table table) {
  final params = <String>[
    'InsertOne${table.rawEntity}Params',
    'InsertMany${table.rawEntity}Params',
    'FindOne${table.rawEntity}Params',
    'FindMany${table.rawEntity}Params',
    'UpdateOne${table.rawEntity}Params',
    'UpdateMany${table.rawEntity}Params',
    'DeleteOne${table.rawEntity}Params',
    'DeleteMany${table.rawEntity}Params',
  ];

  return '''class ${table.repository} extends Repository<${table.entity}, ${params.join(', ')}>  {
  final Database _db;
  final bool verbose;

  const ${table.repository}(this._db, {this.verbose = false});

  @override
  AsyncResult<${table.entity}, DSQLException> insertOne(InsertOne${table.rawEntity}Params params) async {
    try {
      if (verbose) {
        print('*' * 80);
        print('InsertOne${table.rawEntity}Params');
        print('*' * 80);
        print('QUERY: \${params.query}');
        print('PARAMETERS: \${params.parameters}');
        print('*' * 80);
      }

      final result = await _db.execute(params.query, parameters: params.parameters);

      if (result.isEmpty) {
        return Error(SQLException('Fail to insert data on table `${table.name}`!'));
      }

      final entity = ${table.entity}.fromRow(result.first);

      return Success(entity);
    } on Exception catch (e) {
      return Error(SQLException(e.toString()));
    }
  }

  @override
  AsyncResult<List<${table.entity}>, DSQLException> insertMany(InsertMany${table.rawEntity}Params params) async {
    try {
      if (verbose) {
        print('*' * 80);
        print('InsertMany${table.rawEntity}Params');
        print('*' * 80);
        print('QUERY: \${params.query}');
        print('PARAMETERS: \${params.parameters}');
        print('*' * 80);
      }

      final result = await _db.execute(params.query, parameters: params.parameters);

      if (result.isEmpty) {
        return Error(SQLException('Fail to insert data on table `${table.name}`!'));
      }

      final entities = result.map((row) => ${table.entity}.fromRow(row));

      return Success(entities.toList());
    } on Exception catch (e) {
      return Error(SQLException(e.toString()));
    }
  }

  @override
  AsyncResult<${table.entity}, DSQLException> findOne(FindOne${table.rawEntity}Params params) async {
    try {
      if (verbose) {
        print('*' * 80);
        print('FindOne${table.rawEntity}Params');
        print('*' * 80);
        print('QUERY: \${params.query}');
        print('PARAMETERS: \${params.parameters}');
        print('*' * 80);
      }

      final result = await _db.execute(params.query, parameters: params.parameters);

      if (result.isEmpty) {
        return Error(SQLException('No data found on table `${table.name}`!'));
      }

      final entity = ${table.entity}.fromRow(result.first);

      return Success(entity);
    } on DSQLException catch (e) {
      return Error(e);
    } on Exception catch (e) {
      return Error(SQLException(e.toString()));
    }
  }

  @override
  AsyncResult<List<${table.entity}>, DSQLException> findMany([FindMany${table.rawEntity}Params params = const FindMany${table.rawEntity}Params()]) async {
    try {
      if (verbose) {
        print('*' * 80);
        print('FindMany${table.rawEntity}Params');
        print('*' * 80);
        print('QUERY: \${params.query}');
        print('PARAMETERS: \${params.parameters}');
        print('*' * 80);
      }

      final entitiesResult = await _db.execute(params.query, parameters: params.parameters);

      final entities = entitiesResult.map((row) => ${table.entity}.fromRow(row));

      return Success(entities.toList());
    } on PgException catch (e) {
      return Error(SQLException(e.message));
    } on Exception catch (e) {
      return Error(SQLException(e.toString()));
    }
  }

  @override
  AsyncResult<Page<${table.entity}>, DSQLException> findManyPaginated([FindMany${table.rawEntity}Params params = const FindMany${table.rawEntity}Params()]) async {
    try {
      if (verbose) {
        print('*' * 80);
        print('FindMany${table.rawEntity}Params');
        print('*' * 80);
        print('QUERY: \${params.query}');
        print('PARAMETERS: \${params.parameters}');
        print('*' * 80);
      }

      final page = await _db.runTx<Page<${table.entity}>>((tx) async {
        final entitiesResult = await tx.execute(params.query, parameters: params.parameters);

        final countQuery = params.query.replaceFirst(RegExp(r' ORDER BY \\w+'), '')
              .replaceFirst(RegExp(r'SELECT \\* FROM'), 'SELECT COUNT(*) FROM')
              .replaceFirst(RegExp(r' LIMIT \\d+'), '')
              .replaceFirst(RegExp(r' OFFSET \\d+'), '');

        final countResult = await tx.execute(countQuery, parameters: params.parameters);

        final count = countResult[0][0] as int;

        return Page(
          items: entitiesResult.map((row) => ${table.entity}.fromRow(row)).toList(),
          page: params.page,
          pageSize: params.pageSize,
          count: count,
          hasNext: params.page * params.pageSize < count,
          hasPrevious: params.page > 1,
        );
      });

      return Success(page);
    } on DSQLException catch (e) {
      return Error(e);
    } on PgException catch (e) {
      return Error(SQLException(e.message));
    } on Exception catch (e) {
      return Error(SQLException(e.toString()));
    }
  }

  @override
  AsyncResult<${table.entity}, DSQLException> updateOne(UpdateOne${table.rawEntity}Params params) async {
    try {
      if (verbose) {
        print('*' * 80);
        print('UpdateOne${table.rawEntity}Params');
        print('*' * 80);
        print('QUERY: \${params.query}');
        print('PARAMETERS: \${params.parameters}');
        print('*' * 80);
      }

      final result = await _db.execute(params.query, parameters: params.parameters);

      if (result.isEmpty) {
        return Error(SQLException('No data found on table `${table.name}` to update!'));
      }

      final entity = ${table.entity}.fromRow(result.first);

      return Success(entity);
    } on DSQLException catch (e) {
      return Error(e);
    } on Exception catch (e) {
      return Error(SQLException(e.toString()));
    }
  }

  @override
  AsyncResult<List<${table.entity}>, DSQLException> updateMany(UpdateMany${table.rawEntity}Params params) async {
    try {
      if (verbose) {
        print('*' * 80);
        print('UpdateMany${table.rawEntity}Params');
        print('*' * 80);
        print('QUERY: \${params.query}');
        print('PARAMETERS: \${params.parameters}');
        print('*' * 80);
      }

      final result = await _db.execute(params.query, parameters: params.parameters);

      final entities = result.map((row) => ${table.entity}.fromRow(row));

      return Success(entities.toList());
    } on DSQLException catch (e) {
      return Error(e);
    } on Exception catch (e) {
      return Error(SQLException(e.toString()));
    }
  }

  @override
  AsyncResult<${table.entity}, DSQLException> deleteOne(DeleteOne${table.rawEntity}Params params) async {
    try {
      if (verbose) {
        print('*' * 80);
        print('DeleteOne${table.rawEntity}Params');
        print('*' * 80);
        print('QUERY: \${params.query}');
        print('PARAMETERS: \${params.parameters}');
        print('*' * 80);
      }

      final result = await _db.execute(params.query, parameters: params.parameters);

      if (result.isEmpty) {
        return Error(SQLException('No data found on table `${table.name}` to delete!'));
      }

      final entity = ${table.entity}.fromRow(result.first);

      return Success(entity);
    } on DSQLException catch (e) {
      return Error(e);
    } on Exception catch (e) {
      return Error(SQLException(e.toString()));
    }
  }

  @override
  AsyncResult<List<${table.entity}>, DSQLException> deleteMany(DeleteMany${table.rawEntity}Params params) async {
    try {
      if (verbose) {
        print('*' * 80);
        print('DeleteMany${table.rawEntity}Params');
        print('*' * 80);
        print('QUERY: \${params.query}');
        print('PARAMETERS: \${params.parameters}');
        print('*' * 80);
      }

      final result = await _db.execute(params.query, parameters: params.parameters);

      final entities = result.map((row) => ${table.entity}.fromRow(row));

      return Success(entities.toList());
    } on DSQLException catch (e) {
      return Error(e);
    } on Exception catch (e) {
      return Error(SQLException(e.toString()));
    }
  }
}''';
}

String _insertOneParamsBuilder(Table table) {
  final cols = table.columns.where((c) => isRequired(c));
  return '''class InsertOne${table.rawEntity}Params extends InsertOneParams {
  ${cols.map((c) => 'final ${fieldType(c)} ${fieldName(c)};').join('\n')}

  const InsertOne${table.rawEntity}Params({
    ${cols.map((c) => 'required this.${fieldName(c)},').join('\n')}
  });

  @override
  String get query => 'INSERT INTO ${table.name} (${cols.map((c) => fieldName(c).toSnakeCase()).join(', ')}) VALUES (${cols.indexedMap((index, _) => '\\\$${index + 1}').join(', ')}) RETURNING *;';

  @override
  List get parameters => [${cols.map((c) => fieldName(c)).join(', ')}];
}''';
}

String _insertManyParamsBuilder(Table table) {
  final cols = table.columns.where((c) => isRequired(c));
  return '''class InsertMany${table.rawEntity}Params extends InsertManyParams {
  final List<InsertMany${table.rawEntity}Fields> fields;

  const InsertMany${table.rawEntity}Params(this.fields);

  @override
  String get query => 'INSERT INTO ${table.name} (${cols.map((c) => fieldName(c).toSnakeCase()).join(', ')})  VALUES \${fields.indexedMap((index, field) => '(\${List.generate(field.parameters.length, (i) => '\\\$\${(i + 1) + (index * ${cols.length})}').join(', ')})').join(', ')} RETURNING *;';

  @override
  List get parameters => fields.expand((f) => f.parameters).toList();
}

class InsertMany${table.rawEntity}Fields {
  ${cols.map((c) => 'final ${fieldType(c)} ${fieldName(c)};').join('\n')}

  const InsertMany${table.rawEntity}Fields({
    ${cols.map((c) => 'required this.${fieldName(c)},').join('\n')}
  });

  List get parameters => [${cols.map((c) => fieldName(c)).join(', ')}];
}''';
}

String _findOneParamsBuider(Table table) {
  return '''class FindOne${table.rawEntity}Params extends FindOneParams {
  ${table.columns.map((c) => 'final Where? ${fieldName(c)};').join('\n')}
  
  const FindOne${table.rawEntity}Params({
    ${table.columns.map((c) => 'this.${fieldName(c)},').join('\n')}
  });

  @override
  Map<String, Where> get wheres => {
    ${table.columns.map((c) => 'if (${fieldName(c)} != null) \'${fieldName(c).toSnakeCase()}\': ${fieldName(c)}!,').join('\n')}
  };

  @override
  String get query {
    if (wheres.isEmpty) {
      throw SQLException('FindOne${table.rawEntity}Params must have at least one where!');
    }

    return 'SELECT * FROM ${table.name} WHERE \${wheres.entries.indexedMap((i, e) => '\${e.key} \${e.value.op} \\\$\${i + 1}').join(' AND ')} LIMIT 1;';
  }

  @override
  List get parameters => wheres.values.map((v) => v.value).toList();
}''';
}

String _findManyParamsBuilder(Table table) {
  return '''class FindMany${table.rawEntity}Params extends FindManyParams {
  ${table.columns.map((c) => 'final Where? ${fieldName(c)};').join('\n')}
  final int page;
  final int pageSize;
  final OrderBy? orderBy;

  const FindMany${table.rawEntity}Params({
    ${table.columns.map((c) => 'this.${fieldName(c)},').join('\n')}
    this.page = 1,
    this.pageSize = 20,
    this.orderBy,
  });

  @override
  Map<String, Where> get wheres => {
    ${table.columns.map((c) => 'if (${fieldName(c)} != null) \'${fieldName(c).toSnakeCase()}\': ${fieldName(c)}!,').join('\n')}
  };

  @override
  String get query {
    final offsetQuery = switch (page >= 1) {
      true => ' OFFSET \${page - 1}',
      false => ' OFFSET 0',
    };

    final limitQuery = ' LIMIT \$pageSize';

    final orderByQuery = switch (orderBy != null) {
      false => '',
      true => ' ORDER BY \${orderBy?.sql}',
    };

    if (wheres.isEmpty) {
      return 'SELECT * FROM ${table.name}\$orderByQuery\$offsetQuery\$limitQuery;';
    } else {
      return 'SELECT * FROM ${table.name} WHERE \${wheres.entries.indexedMap((i, e) => '\${e.key} \${e.value.op} \\\$\${i + 1}').join(' AND ')}\$orderByQuery\$offsetQuery\$limitQuery;';
    }
  }

  @override
  List get parameters => wheres.values.map((v) => v.value).toList();
}''';
}

String _updateOneParamsBuilder(Table table) {
  final shouldGenerate =
      hasPk(table.columns) || getUniqueKeysMapped(table.columns).isNotEmpty;

  if (!shouldGenerate) {
    return '''class UpdateOne${table.rawEntity}Params extends UpdateOneParams {
      const UpdateOne${table.rawEntity}Params();

      @override
      Map<String, Where> get wheres => throw UnimplementedError();

      @override
      String get query => throw UnimplementedError();

      @override
      List get parameters => throw UnimplementedError();
    }''';
  }

  final updatable = table.columns.where((c) => !isPk(c)).toList();
  final conditionable = table.columns.where(
    (c) {
      return isPk(c) ||
          getUniqueKeysMapped(table.columns).containsKey(
            fieldName(c).toSnakeCase(),
          );
    },
  ).toList();
  return '''class UpdateOne${table.rawEntity}Params extends UpdateOneParams {
  ${conditionable.map((c) => '/// ${isPk(c) ? 'PrimaryKey' : 'UniqueKey'} `${table.name}.${fieldName(c).toSnakeCase()}`\nfinal Where? where${fieldName(c).toSnakeCase().toCamelCase()};').join('\n')}
  ${updatable.map((c) => 'final ${fieldType(c)}? ${fieldName(c)};').join('\n')}

  const UpdateOne${table.rawEntity}Params({
    ${conditionable.map((c) => 'this.where${fieldName(c).toSnakeCase().toCamelCase()},').join('\n')}
    ${updatable.map((c) => 'this.${fieldName(c)},').join('\n')}
  });

  Map<String, dynamic> get values => {
    ${updatable.map((c) => 'if (${fieldName(c)} != null) \'${fieldName(c).toSnakeCase()}\': ${fieldName(c)}').join(', ')}
  };

  @override
  Map<String, Where> get wheres => {
    ${conditionable.map((c) => 'if (where${fieldName(c).toSnakeCase().toCamelCase()} != null) \'${fieldName(c).toSnakeCase()}\': where${fieldName(c).toSnakeCase().toCamelCase()}!,').join('\n')}
  };

  @override
  String get query {
    if (wheres.isEmpty) {
      throw SQLException('UpdateOne${table.rawEntity}Params cannot be conditionless!');
    }

    if (wheres.length > 1) {
      throw SQLException('UpdateOne${table.rawEntity}Params must have only one where!');
    }

    if (values.isEmpty) {
      throw SQLException('UpdateOne${table.rawEntity}Params must have at least one value!');
    }

    return 'UPDATE ${table.name} SET \${values.entries.indexedMap((index, entry) => '\${entry.key} = \\\$\${index + 1}').join(', ')} WHERE \${wheres.entries.indexedMap((index, entry) => '\${entry.key} \${entry.value.op} \\\$\${index + 1 + values.length}').join(' AND ')} RETURNING *;';
  }

  @override
  List get parameters => [...values.values, ...wheres.values.map((v) => v.value),];
}''';
}

String _updateManyParamsBuilder(Table table) {
  final cols = table.columns.where((c) => !isPk(c)).toList();
  return '''class UpdateMany${table.rawEntity}Params extends UpdateManyParams {
  ${table.columns.map((c) => 'final Where? where${fieldName(c).toSnakeCase().toCamelCase()};').join('\n')}
  ${cols.map((c) => 'final ${fieldType(c)}? ${fieldName(c)};').join('\n')}

  const UpdateMany${table.rawEntity}Params({
    ${table.columns.map((c) => 'this.where${fieldName(c).toSnakeCase().toCamelCase()},').join('\n')}
    ${cols.map((c) => 'this.${fieldName(c)},').join('\n')}
  });

  Map<String, dynamic> get values => {
    ${cols.map((c) => 'if (${fieldName(c)} != null) \'${fieldName(c).toSnakeCase()}\': ${fieldName(c)}').join(', ')}
  };

  @override
  Map<String, Where> get wheres => {
    ${table.columns.map((c) => 'if (where${fieldName(c).toSnakeCase().toCamelCase()} != null) \'${fieldName(c).toSnakeCase()}\': where${fieldName(c).toSnakeCase().toCamelCase()}!,').join('\n')}
  };

  @override
  String get query {
    if (values.isEmpty) {
      throw SQLException('UpdateMany${table.rawEntity}Params must have at least one value!');
    }

    return 'UPDATE ${table.name} SET \${values.entries.indexedMap((index, entry) => '\${entry.key} = \\\$\${index + 1}').join(', ')}\${wheres.isEmpty ? '' : ' WHERE \${wheres.entries.indexedMap((innerIndex, innerEntry) => '\${innerEntry.key} \${innerEntry.value.op} \\\$\${innerIndex + 1 + values.length}').join(' AND ')}'} RETURNING *;';
  }

  @override
  List get parameters => [...values.values, ...wheres.values.map((v) => v.value),];
}''';
}

String _deleteOneParamsBuilder(Table table) {
  final shouldGenerate =
      hasPk(table.columns) || getUniqueKeysMapped(table.columns).isNotEmpty;

  if (!shouldGenerate) {
    return '''class DeleteOne${table.rawEntity}Params extends DeleteOneParams {
      const DeleteOne${table.rawEntity}Params();

      @override
      Map<String, Where> get wheres => throw UnimplementedError();

      @override
      String get query => throw UnimplementedError();

      @override
      List get parameters => throw UnimplementedError();
    }''';
  }

  final cols = table.columns.where(
    (c) {
      return isPk(c) ||
          getUniqueKeysMapped(table.columns).containsKey(
            fieldName(c).toSnakeCase(),
          );
    },
  ).toList();

  return '''class DeleteOne${table.rawEntity}Params extends DeleteOneParams {
  ${cols.map((c) => '/// ${isPk(c) ? 'PrimaryKey' : 'UniqueKey'} `${table.name}.${fieldName(c).toSnakeCase()}`\nfinal Where? where${fieldName(c).toSnakeCase().toCamelCase()};').join('\n')}

  const DeleteOne${table.rawEntity}Params({
    ${cols.map((c) => 'this.where${fieldName(c).toSnakeCase().toCamelCase()},').join('\n')}
  });

  @override
  Map<String, Where> get wheres => {
    ${cols.map((c) => 'if (where${fieldName(c).toSnakeCase().toCamelCase()} != null) \'${fieldName(c).toSnakeCase()}\': where${fieldName(c).toSnakeCase().toCamelCase()}!,').join('\n')}
  };

  @override
  String get query {
    if (wheres.isEmpty) {
      throw SQLException('DeleteOne${table.rawEntity}Params cannot be conditionless!');
    }

    if (wheres.length > 1) {
      throw SQLException('DeleteOne${table.rawEntity}Params can only have one condition!');
    }

    return 'DELETE FROM ${table.name} WHERE \${wheres.entries.indexedMap((index, entry) => '\${entry.key} \${entry.value.op} \\\$\${index + 1}').join(' AND ')} RETURNING *;';
  }

  @override
  List get parameters => wheres.values.map((v) => v.value).toList();
}''';
}

String _deleteManyParamsBuilder(Table table) {
  final updatable = table.columns.where(isPk).toList();
  return '''class DeleteMany${table.rawEntity}Params extends DeleteManyParams {
  ${table.columns.map((c) => '/// ${isPk(c) ? 'PrimaryKey' : 'UniqueKey'} `${table.name}.${fieldName(c).toSnakeCase()}`\nfinal Where? where${fieldName(c).toSnakeCase().toCamelCase()};').join('\n')}
  ${updatable.map((c) => 'final ${fieldType(c)}? ${fieldName(c)};').join('\n')}
  
  const DeleteMany${table.rawEntity}Params({
    ${table.columns.map((c) => 'this.where${fieldName(c).toSnakeCase().toCamelCase()},').join('\n')}
    ${updatable.map((c) => 'this.${fieldName(c)},').join('\n')}
  });

  @override
  Map<String, Where> get wheres => {
    ${table.columns.map((c) => 'if (where${fieldName(c).toSnakeCase().toCamelCase()} != null) \'${fieldName(c).toSnakeCase()}\': where${fieldName(c).toSnakeCase().toCamelCase()}!,').join('\n')}
  };

  @override
  String get query {
    if (wheres.isEmpty) {
      throw SQLException('DeleteMany${table.rawEntity}Params cannot be conditionless!');
    }

    return 'DELETE FROM ${table.name} WHERE \${wheres.entries.indexedMap((index, entry) => '\${entry.key} \${entry.value.op} \\\$\${index + 1}').join(' AND ')} RETURNING *;';
  }

  @override
  List get parameters => wheres.values.map((v) => v.value).toList();
}''';
}
