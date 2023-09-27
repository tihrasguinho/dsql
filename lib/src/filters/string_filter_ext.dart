import 'string_filter.dart';

extension StringFilterExt on String {
  /// Equivalent to `StringFilter(equals: this)`
  StringFilter get equals => StringFilter(equals: this);

  /// Equivalent to `StringFilter(startsWith: this)`
  StringFilter get startsWith => StringFilter(startsWith: this);

  /// Equivalent to `StringFilter(endsWith: this)`
  StringFilter get endsWith => StringFilter(endsWith: this);

  /// Equivalent to `StringFilter(contains: this)`
  StringFilter get contains => StringFilter(contains: this);
}
