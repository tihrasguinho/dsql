import 'package:strings/strings.dart';

import 'shared.dart';
import 'table.dart';

String builder(List<Table> tables) {
  final buffer = StringBuffer();
  buffer.writeln('// This file is generated by DSQL.');
  buffer.writeln('// Do not modify it manually.');
  buffer.writeln();
  buffer.writeln('part of \'dsql.dart\';');
  buffer.writeln();
  for (final table in tables) {
    buffer.writeln(_entityBuilder(table));
    buffer.writeln();
  }
  return buffer.toString();
}

String _entityBuilder(Table table) {
  final relationshipsFields = [
    ...table.hasMany.entries.map(
        (e) => 'final Page<${e.value.entity}>? \$${e.key.nameNormalized};'),
    ...table.hasOne.entries.map((e) =>
        'final ${e.value.entity}? \$${constraintNameNormalizer(e.key.column)};'),
  ];

  final relationshipsParameters = [
    ...table.hasMany.entries.map((e) => 'this.\$${e.key.nameNormalized},'),
    ...table.hasOne.entries
        .map((e) => 'this.\$${constraintNameNormalizer(e.key.column)},'),
  ];

  return '''class ${table.entity} {
    ${table.columns.map((c) => 'final ${fieldType(c)}${isNullable(c) ? '?' : ''} ${fieldName(c)};').join('\n')}
    ${relationshipsFields.join('\n')}

    const ${table.entity}({
      ${table.columns.map((c) => '${isNullable(c) ? '' : 'required '}this.${fieldName(c)},').join('\n')}
      ${relationshipsParameters.join('\n')}
    });

    ${_toMapMethodBuilder(table)}

    ${_fromMapMethodBuilder(table)}

    ${_toJsonMethodBuilder(table)}

    ${_fromJsonMethodBuilder(table)}

    ${_fromRowMethodBuilder(table)}

    ${_toStringMethodBuilder(table)}

    ${_equalityMethodBuilder(table)}
  }''';
}

String _toMapMethodBuilder(Table table) {
  return '''Map<String, dynamic> toMap() {
    return {
      ${table.columns.map((c) => '\'${fieldName(c).toSnakeCase()}\': ${fieldName(c)},').join('\n')}
    };
  }''';
}

String _fromMapMethodBuilder(Table table) {
  return '''factory ${table.entity}.fromMap(Map<String, dynamic> map) {
    return ${table.entity}(
      ${table.columns.map((c) => '${fieldName(c)}: map[\'${fieldName(c).toSnakeCase()}\'],').join('\n')}
    );
  }''';
}

String _toJsonMethodBuilder(Table table) {
  return '''String toJson() => json.encode(toMap());''';
}

String _fromJsonMethodBuilder(Table table) {
  return '''factory ${table.entity}.fromJson(String source) {
    return ${table.entity}.fromMap(json.decode(source));
  }''';
}

String _fromRowMethodBuilder(Table table) {
  return '''factory ${table.entity}.fromRow(List row) {
    final [
    ${table.columns.map((c) => '${fieldType(c)}${isNullable(c) ? '?' : ''} ${fieldName(c)},').join('\n')}
    ] = row;

    return ${table.entity}(${table.columns.map((c) => '${fieldName(c)}: ${fieldName(c)},').join('\n')});
  }''';
}

String _toStringMethodBuilder(Table table) {
  return '''@override
  String toString() {
    return '${table.entity}(${table.columns.map((c) => '${fieldName(c)}: \$${fieldName(c)}').join(', ')})';
  }''';
}

String _equalityMethodBuilder(Table table) {
  return '''@override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ${table.entity} && ${table.columns.map((c) => 'other.${fieldName(c)} == ${fieldName(c)}').join(' && ')};
  }
  
  @override
  int get hashCode {
    return ${table.columns.map((c) => '${fieldName(c)}.hashCode').join(' ^ ')};
  }''';
}
