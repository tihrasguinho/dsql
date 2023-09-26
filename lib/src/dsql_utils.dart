import 'package:strings/strings.dart';

class DSQLUtils {
  const DSQLUtils._();

  static String dartTypeToFilter(Type type) => switch (type) {
        String => 'StringFilter',
        int => 'IntegerFilter',
        double => 'DoubleFilter',
        bool => 'BooleanFilter',
        DateTime => 'TimestampFilter',
        _ => throw Exception('DSQLUtils: unsupported type $type'),
      };

  static String keyNameAsSnakeCase(String value) {
    return value.toSnakeCase();
  }

  static String toSnakeCase(String input) {
    final snakeCase = input.replaceAllMapped(RegExp(r'([A-Z])'), (match) => '_${match.group(0)!.toLowerCase()}');

    return snakeCase.trim().toLowerCase();
  }

  static String toPascalCase(String input) {
    final words = input.replaceAll(RegExp(r'[^a-zA-Z0-9]'), ' ').trim().split(' ');

    final pascalCase = words.map((word) => word[0].toUpperCase() + word.substring(1)).join('');

    return pascalCase;
  }

  static String toCamelCase(String input) {
    final words = input.replaceAll(RegExp(r'[^a-zA-Z0-9]'), ' ').trim().split(' ');

    final camelCase = words[0].toLowerCase() + words.sublist(1).map((word) => word[0].toUpperCase() + word.substring(1)).join('');

    return camelCase;
  }
}
