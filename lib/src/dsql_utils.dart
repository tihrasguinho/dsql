import 'package:path/path.dart' as p;

class DSQLUtils {
  static final _pascalCaseRegex = RegExp(r'^[A-Z][a-zA-Z\d]*$');

  static final _snakeCaseRegex = RegExp(r'^[a-z\d_]+$');

  static final _camelCaseRegex = RegExp(r'^[a-z][a-zA-Z\d]*$');

  const DSQLUtils._();

  static String dartTypeToFilter(Type type) => switch (type) {
        String => 'StringFilter',
        int => 'IntegerFilter',
        double => 'DoubleFilter',
        bool => 'BooleanFilter',
        DateTime => 'TimestampFilter',
        _ => throw Exception('DSQLUtils: unsupported type $type'),
      };

  static String toCamelCase(String value) {
    if (_pascalCaseRegex.hasMatch(value)) {
      return '${value[0].toLowerCase()}${value.substring(1)}';
    } else if (_snakeCaseRegex.hasMatch(value)) {
      final parts = value.split('_');
      return '${parts[0][0].toLowerCase()}${parts[0].substring(1)}${parts.skip(1).map((e) => e[0].toUpperCase() + e.substring(1)).join('')}';
    } else if (_camelCaseRegex.hasMatch(value)) {
      return value;
    } else {
      return value;
    }
  }

  static String toPascalCase(String value) {
    if (_pascalCaseRegex.hasMatch(value)) {
      return value;
    } else if (_snakeCaseRegex.hasMatch(value)) {
      final parts = value.split('_');
      return parts.map((e) => e[0].toUpperCase() + e.substring(1)).join('');
    } else if (_camelCaseRegex.hasMatch(value)) {
      return '${value[0].toUpperCase()}${value.substring(1)}';
    } else {
      return value;
    }
  }

  static String toSnakeCase(String value) {
    if (_pascalCaseRegex.hasMatch(value)) {
      final newValue = value.split('').map((e) => RegExp('[A-Z]').hasMatch(e) ? '_${e.toLowerCase()}' : e).join('');
      return newValue.startsWith('_') ? newValue.substring(1) : newValue;
    } else if (_snakeCaseRegex.hasMatch(value)) {
      return value;
    } else if (_camelCaseRegex.hasMatch(value)) {
      final newValue = value.split('').map((e) => RegExp('[A-Z]').hasMatch(e) ? '_${e.toLowerCase()}' : e).join('');
      return newValue.startsWith('_') ? newValue.substring(1) : newValue;
    } else {
      return value;
    }
  }

  static String basename(String path) {
    return p.basename(path);
  }

  static String dirname(String path) {
    return p.dirname(path);
  }

  static String extension(String path) {
    return p.extension(path);
  }

  static String join(
    String part1, [
    String? part2,
    String? part3,
    String? part4,
    String? part5,
    String? part6,
    String? part7,
    String? part8,
    String? part9,
    String? part10,
    String? part11,
    String? part12,
    String? part13,
    String? part14,
    String? part15,
    String? part16,
  ]) {
    return p.join(part1, part2, part3, part4, part5, part6, part7, part8, part9, part10, part11, part12, part13, part14, part15, part16);
  }
}
