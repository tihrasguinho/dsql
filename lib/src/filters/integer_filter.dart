import 'filter.dart';

class IntegerFilter extends Filter<int> {
  final int? equals;
  final int? lt;
  final int? gt;
  final int? lte;
  final int? gte;

  IntegerFilter({this.equals, this.lt, this.gt, this.lte, this.gte}) {
    assert(
        equals != null ||
            lt != null ||
            gt != null ||
            lte != null ||
            gte != null,
        'Invalid Integer filters, you must provide at least one filter!');
  }

  @override
  String get operator {
    if (equals != null) return '=';
    if (lt != null) return '<';
    if (gt != null) return '>';
    if (lte != null) return '<=';
    if (gte != null) return '>=';
    throw Exception(
        'Invalid Integer filters, you must provide at least one filter!');
  }

  @override
  int get value {
    if (equals != null) return equals!;
    if (lt != null) return lt!;
    if (gt != null) return gt!;
    if (lte != null) return lte!;
    if (gte != null) return gte!;
    throw Exception(
        'Invalid Integer filters, you must provide at least one filter!');
  }
}
