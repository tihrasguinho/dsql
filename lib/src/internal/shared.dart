import 'package:strings/strings.dart';

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
