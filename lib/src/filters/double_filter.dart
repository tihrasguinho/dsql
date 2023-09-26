import 'filter.dart';

class DoubleFilter extends Filter<double> {
  final double? equals;
  final double? lt;
  final double? gt;
  final double? lte;
  final double? gte;

  DoubleFilter({this.equals, this.lt, this.gt, this.lte, this.gte}) {
    assert(
        equals != null ||
            lt != null ||
            gt != null ||
            lte != null ||
            gte != null,
        'Invalid Double filters, you must provide at least one filter!');
  }

  @override
  String get operator {
    if (equals != null) return '=';
    if (lt != null) return '<';
    if (gt != null) return '>';
    if (lte != null) return '<=';
    if (gte != null) return '>=';
    throw Exception(
        'Invalid Double filters, you must provide at least one filter!');
  }

  @override
  double get value {
    if (equals != null) return equals!;
    if (lt != null) return lt!;
    if (gt != null) return gt!;
    if (lte != null) return lte!;
    if (gte != null) return gte!;
    throw Exception(
        'Invalid Double filters, you must provide at least one filter!');
  }
}
