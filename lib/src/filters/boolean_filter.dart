import 'filter.dart';

class BooleanFilter extends Filter<bool> {
  final bool? equals;

  BooleanFilter({this.equals}) {
    assert(equals != null, 'Invalid Boolean filters, you must provide at least one filter!');
  }

  @override
  String get operator {
    if (equals != null) return '=';
    throw Exception('Invalid Boolean filters, you must provide at least one filter!');
  }

  @override
  bool get value {
    if (equals != null) return equals!;
    throw Exception('Invalid Boolean filters, you must provide at least one filter!');
  }
}

/// Equivalent to `BooleanFilter(equals: true)`
BooleanFilter get booleanTRUE => BooleanFilter(equals: true);

/// Equivalent to `BooleanFilter(equals: false)`
BooleanFilter get booleanFALSE => BooleanFilter(equals: false);
