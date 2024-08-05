import 'dart:io';

import 'package:dsql/src/internal/constraint.dart';
import 'package:path/path.dart' as p;
import 'package:strings/strings.dart';

import 'table.dart';

bool isRequired(String col) {
  if (col.toUpperCase().contains('DEFAULT') ||
      !col.toUpperCase().contains('NOT NULL')) {
    return false;
  }
  return true;
}

String fieldName(String col) {
  return col.split(' ')[0].toCamelCase(lower: true);
}

Type fieldType(String col) {
  final sql = col.split(' ')[1].toUpperCase().replaceAll(RegExp(r'[,.]'), '');

  if (sql.startsWith('VARCHAR')) {
    return String;
  }

  return switch (sql) {
    'TEXT' || 'UUID' || 'CHAR' => String,
    'SMALLINT' ||
    'INTEGER' ||
    'BIGINT' ||
    'SERIAL' ||
    'BIGSERIAL' ||
    'SMALLSERIAL' =>
      int,
    'REAL' || 'DECIMAL' || 'NUMERIC' || 'DOUBLE' => double,
    'BOOLEAN' => bool,
    'TIMESTAMP' || 'TIMESTAMPTZ' || 'DATE' || 'TIME' => DateTime,
    _ => Null,
  };
}

bool isNullable(String col) {
  return !col.toUpperCase().contains('NOT NULL') &&
      !col.toUpperCase().contains('PRIMARY KEY');
}

bool isPk(String col) {
  return col.toUpperCase().contains('PRIMARY KEY');
}

bool hasPk(List<String> cols) {
  return cols.any(isPk);
}

String getPkName(List<String> cols) {
  return cols.firstWhere(isPk).split(' ')[0];
}

Type getPkType(List<String> cols) {
  return fieldType(cols.firstWhere(isPk));
}

Map<String, Type> getUniqueKeysMapped(List<String> cols) {
  return Map.fromEntries(
    cols.where((col) => col.toUpperCase().contains('UNIQUE')).map(
          (col) => MapEntry(
            col.split(' ')[0],
            fieldType(col),
          ),
        ),
  );
}

String tryToPluralize(String word) {
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
  } else if (word.endsWith('ing') ||
      word.endsWith('ed') ||
      word.endsWith('ers')) {
    return word;
  } else {
    return '${word}s';
  }
}

String constraintNameNormalizer(String constraint) {
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
  if (RegExp(r'^fk(?:\w+)_').hasMatch(base)) {
    base = base.replaceAll(RegExp(r'^fk(?:\w+)_'), '');
  }
  return base.toCamelCase(lower: true);
}

bool mapEquals(Map<String, dynamic> m1, Map<String, dynamic> m2) {
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

List<Table> extractTables(Directory input) {
  final tables = <Table>[];

  final tb = RegExp(
      r"--\sentity:\s([\w]+)\sCREATE TABLE(?: IF NOT EXISTS)?\s([\w]+)\s\(([\s\w\d\(\)\,\']+)\s\);");
  final fk1 = RegExp(
      r'^CONSTRAINT\s(\w+)\sFOREIGN\sKEY\s\((\w+)\)\sREFERENCES\s(\w+)\s\((\w+)\)(?:\sON DELETE CASCADE)?(?:\sON UPDATE CASCADE)?$');
  final fk2 = RegExp(
      r'^FOREIGN\sKEY\s\((\w+)\)\sREFERENCES\s(\w+)\s\((\w+)\)(?:\sON DELETE CASCADE)?(?:\sON UPDATE CASCADE)?$');
  final fk3 = RegExp(
      r'REFERENCES\s(\w+)\s?\((\w+)\)(?:\sON DELETE CASCADE)?(?:\sON UPDATE CASCADE)?$');

  final files = input
      .listSync(recursive: true)
      .where((file) => p.basename(file.path).endsWith('.sql'))
      .map((file) => File(file.path))
      .toList();

  for (final file in files) {
    tables.addAll(
      tb.allMatches(file.readAsLinesSync().join('\n')).map(
        (match) {
          return Table(
            entity: match.group(1)!,
            name: match.group(2)!,
            lines: match
                .group(3)!
                .split('\n')
                .map((l) => l.trim())
                .map((l) => l.endsWith(',') ? l.substring(0, l.length - 1) : l)
                .where((l) => l.isNotEmpty)
                .toList(),
          );
        },
      ),
    );
  }

  for (var i = 0; i < tables.length; i++) {
    for (final line in tables[i].lines) {
      final match1 = fk1.firstMatch(line);
      final match2 = fk2.firstMatch(line);
      final match3 = fk3.firstMatch(line);

      Constraint? constraint;
      int? index;

      if (match1 != null) {
        constraint = Constraint(
          name: match1.group(1)!,
          column: match1.group(2)!,
          targetTable: match1.group(3)!,
          targetColumn: match1.group(4)!,
        );

        index = tables.indexWhere((t) => t.name == constraint?.targetTable);

        if (index < 0) continue;
      } else if (match2 != null) {
        constraint = Constraint(
          name: '',
          column: match2.group(2)!,
          targetTable: match2.group(3)!,
          targetColumn: match2.group(4)!,
        );

        index = tables.indexWhere((t) => t.name == constraint?.targetTable);

        if (index < 0) continue;

        constraint = constraint.copyWith(
          name:
              'fk${tables[index].nameWithoutPrefixTB}_${tables[i].nameWithoutPrefixTB}',
        );
      } else if (match3 != null) {
        constraint = Constraint(
          name: '',
          column: fieldName(line).toSnakeCase(),
          targetTable: match3.group(1)!,
          targetColumn: match3.group(2)!,
        );

        index = tables.indexWhere((t) => t.name == constraint?.targetTable);

        if (index < 0) continue;

        constraint = constraint.copyWith(
          name:
              'fk${tables[index].nameWithoutPrefixTB}_${tables[i].nameWithoutPrefixTB}',
        );
      }

      if (constraint == null || index == null) continue;

      tables[index] = tables[index].copyWith(
        hasMany: {
          ...tables[index].hasMany,
          constraint: tables[i],
        },
      );

      tables[i] = tables[i].copyWith(
        hasOne: {
          ...tables[i].hasOne,
          constraint: tables[index],
        },
      );
    }
  }

  return tables;
}
