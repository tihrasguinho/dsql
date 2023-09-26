import 'package:path/path.dart' as p;

class DSQLUtils {
  static final _pascalCaseRegex = RegExp(r'^[A-Z][a-zA-Z\d]*$');

  static final _snakeCaseRegex = RegExp(r'^[a-z\d_]+$');

  static final _camelCaseRegex = RegExp(r'^[a-z][a-zA-Z\d]*$');

  static final _kebabCaseRegex = RegExp(r'^[a-z][a-z\d]*(-[a-z\d]+)*$');

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
    } else if (_kebabCaseRegex.hasMatch(value)) {
      final newValue = value.split('-').map((e) => e[0].toUpperCase() + e.substring(1)).join('');
      return '${newValue[0].toLowerCase()}${newValue.substring(1)}';
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
    } else if (_kebabCaseRegex.hasMatch(value)) {
      return value.split('-').map((e) => e[0].toUpperCase() + e.substring(1)).join('');
    } else {
      return value;
    }
  }

  static String toSnakeCase(String value, {bool screaming = false}) {
    if (_pascalCaseRegex.hasMatch(value)) {
      var newValue = value.split('').map((e) => RegExp('[A-Z]').hasMatch(e) ? '_${e.toLowerCase()}' : e).join('');
      if (newValue.startsWith('_')) {
        newValue = newValue.substring(1);
      }
      return screaming ? newValue.toUpperCase() : newValue;
    } else if (_snakeCaseRegex.hasMatch(value)) {
      return screaming ? value.toUpperCase() : value;
    } else if (_camelCaseRegex.hasMatch(value)) {
      var newValue = value.split('').map((e) => RegExp('[A-Z]').hasMatch(e) ? '_${e.toLowerCase()}' : e).join('');
      if (newValue.startsWith('_')) {
        newValue = newValue.substring(1);
      }
      return screaming ? newValue.toUpperCase() : newValue;
    } else if (_kebabCaseRegex.hasMatch(value)) {
      return screaming ? value.replaceAll('-', '_').toUpperCase() : value.replaceAll('-', '_').toLowerCase();
    } else {
      return value;
    }
  }

  static String toKebabCase(String value, {bool screaming = false}) {
    if (_pascalCaseRegex.hasMatch(value)) {
      var newValue = value.split('').map((e) => RegExp('[A-Z]').hasMatch(e) ? '-${e.toLowerCase()}' : e).join('');
      if (newValue.startsWith('-')) {
        newValue = newValue.substring(1);
      }
      return screaming ? newValue.toUpperCase() : newValue;
    } else if (_snakeCaseRegex.hasMatch(value)) {
      return screaming ? value.replaceAll('_', '-').toUpperCase() : value.replaceAll('_', '-').toLowerCase();
    } else if (_camelCaseRegex.hasMatch(value)) {
      var newValue = value.split('').map((e) => RegExp('[A-Z]').hasMatch(e) ? '-${e.toLowerCase()}' : e).join('');
      if (newValue.startsWith('-')) {
        newValue = newValue.substring(1);
      }
      return screaming ? newValue.toUpperCase() : newValue.toLowerCase();
    } else if (_kebabCaseRegex.hasMatch(value)) {
      return screaming ? value.toUpperCase() : value.toLowerCase();
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

extension DSQLStrings on String {
  String toSnakeCase({bool screaming = false}) => DSQLUtils.toSnakeCase(this, screaming: screaming);

  String toKebabCase({bool screaming = false}) => DSQLUtils.toKebabCase(this, screaming: screaming);

  String toCamelCase() => DSQLUtils.toCamelCase(this);

  String toPascalCase() => DSQLUtils.toPascalCase(this);
}
