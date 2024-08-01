import 'package:dsql/dsql.dart';
import 'package:dsql/src/internal/shared.dart';
import 'package:strings/strings.dart';

import 'table.dart';

String builder(Table table) {
  final buffer = StringBuffer();
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
  return buffer.toString();
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
  final Connection _conn;
  final bool verbose;

  const ${table.repository}(this._conn, {this.verbose = false});

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

      final result = await _conn.execute(params.query, parameters: params.parameters);

      if (result.isEmpty) {
        return Error(SQLException('Fail to insert data on table `${table.name}`!'));
      }

      final [
        ${table.columns.map((c) => '${fieldType(c)}${isNullable(c) ? '?' : ''} \$${fieldName(c)},').join('\n')}
      ] = result.first as List;

      final entity = ${table.entity}(
        ${table.columns.map((c) => '${fieldName(c)}: \$${fieldName(c)},').join('\n')}
      );

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

      final result = await _conn.execute(params.query, parameters: params.parameters);

      if (result.isEmpty) {
        return Error(SQLException('Fail to insert data on table `${table.name}`!'));
      }

      final entities = result.map(
        (row) {
          final [
            ${table.columns.map((c) => '${fieldType(c)}${isNullable(c) ? '?' : ''} \$${fieldName(c)},').join('\n')}
          ] = row as List;

          return ${table.entity}(
            ${table.columns.map((c) => '${fieldName(c)}: \$${fieldName(c)},').join('\n')}
          );
        },
      );

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

      final result = await _conn.execute(params.query, parameters: params.parameters);

      if (result.isEmpty) {
        return Error(SQLException('No data found on table `${table.name}`!'));
      }

      final [
        ${table.columns.map((c) => '${fieldType(c)}${isNullable(c) ? '?' : ''} \$${fieldName(c)},').join('\n')}
      ] = result.first as List;

      final entity = ${table.entity}(
        ${table.columns.map((c) => '${fieldName(c)}: \$${fieldName(c)},').join('\n')}
      );

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

      final result = await _conn.execute(params.query, parameters: params.parameters);

      final entities = result.map(
        (row) {
          final [
            ${table.columns.map((c) => '${fieldType(c)}${isNullable(c) ? '?' : ''} \$${fieldName(c)},').join('\n')}
          ] = row as List;

          return ${table.entity}(
            ${table.columns.map((c) => '${fieldName(c)}: \$${fieldName(c)},').join('\n')}
          );
        },
      );

      return Success(entities.toList());
    } on Exception catch (e) {
      return Error(SQLException(e.toString()));
    }
  }

  @override
  AsyncResult<Page<${table.entity}>, DSQLException> findManyPaginated([FindMany${table.rawEntity}Params params = const FindMany${table.rawEntity}Params()]) async {
    throw UnimplementedError();
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

      final result = await _conn.execute(params.query, parameters: params.parameters);

      if (result.isEmpty) {
        return Error(SQLException('No data found on table `${table.name}` to update!'));
      }

      final [
        ${table.columns.map((c) => '${fieldType(c)}${isNullable(c) ? '?' : ''} \$${fieldName(c)},').join('\n')}
      ] = result.first as List;

      final entity = ${table.entity}(
        ${table.columns.map((c) => '${fieldName(c)}: \$${fieldName(c)},').join('\n')}
      );

      return Success(entity);
    } on DSQLException catch (e) {
      return Error(e);
    } on Exception catch (e) {
      return Error(SQLException(e.toString()));
    }
  }

  @override
  AsyncResult<List<${table.entity}>, DSQLException> updateMany(UpdateMany${table.rawEntity}Params params) async {
    throw UnimplementedError();
  }

  @override
  AsyncResult<${table.entity}, DSQLException> deleteOne(DeleteOne${table.rawEntity}Params params) async {
    throw UnimplementedError();
  }

  @override
  AsyncResult<List<${table.entity}>, DSQLException> deleteMany(DeleteMany${table.rawEntity}Params params) async {
    throw UnimplementedError();
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
  final cols = table.columns.where((c) => !isPrimaryKey(c)).toList();
  return '''class UpdateOne${table.rawEntity}Params extends UpdateOneParams {
  ${table.columns.map((c) => 'final Where? where${fieldName(c).toSnakeCase().toCamelCase()};').join('\n')}
  ${cols.map((c) => 'final ${fieldType(c)}? ${fieldName(c)};').join('\n')}

  const UpdateOne${table.rawEntity}Params({
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
    if (wheres.isEmpty) {
      throw SQLException('UpdateOne${table.rawEntity}Params must have at least one where!');
    }

    if (values.isEmpty) {
      throw SQLException('UpdateOne${table.rawEntity}Params must have at least one value!');
    }

    return 'UPDATE ${table.name} SET \${values.entries.indexedMap((i, e) => '\${e.key} = \\\$\${i + 1}').join(', ')} WHERE \${wheres.entries.map((entry) => '\${entry.key} \${entry.value.op} (SELECT \${entry.key} FROM ${table.name} WHERE \${wheres.entries.indexedMap((innerIndex, innerEntry) => '\${innerEntry.key} \${innerEntry.value.op} \\\$\${innerIndex + 1 + values.length}').join(' AND ')} LIMIT 1)').join(' AND ')} RETURNING *;';
  }

  @override
  List get parameters => [...values.values, ...wheres.values.map((v) => v.value),];
}''';
}

String _updateManyParamsBuilder(Table table) {
  return '''class UpdateMany${table.rawEntity}Params extends UpdateManyParams {
  const UpdateMany${table.rawEntity}Params();
}''';
}

String _deleteOneParamsBuilder(Table table) {
  return '''class DeleteOne${table.rawEntity}Params extends DeleteOneParams {
  const DeleteOne${table.rawEntity}Params();
}''';
}

String _deleteManyParamsBuilder(Table table) {
  return '''class DeleteMany${table.rawEntity}Params extends DeleteManyParams {
  const DeleteMany${table.rawEntity}Params();
}''';
}
