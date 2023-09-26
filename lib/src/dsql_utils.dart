import 'package:strings/strings.dart' as strings;
import 'package:path/path.dart' as p;

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

  static String toSnakeCase(String input) {
    return strings.Strings.toSnakeCase(input);
  }

  static String toPascalCase(String input) {
    return strings.Strings.toCamelCase(input);
  }

  static String toCamelCase(String input) {
    return strings.Strings.toCamelCase(input, lower: true);
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
