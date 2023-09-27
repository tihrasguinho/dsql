import 'filter.dart';

class DoubleFilter extends Filter<double> {
  final double? eq;
  final double? lt;
  final double? gt;
  final double? lte;
  final double? gte;

  DoubleFilter({this.eq, this.lt, this.gt, this.lte, this.gte}) {
    assert(eq != null || lt != null || gt != null || lte != null || gte != null, 'Invalid Double filters, you must provide at least one filter!');
  }

  @override
  String get operator {
    if (eq != null) return '=';
    if (lt != null) return '<';
    if (gt != null) return '>';
    if (lte != null) return '<=';
    if (gte != null) return '>=';
    throw Exception('Invalid Double filters, you must provide at least one filter!');
  }

  @override
  double get value {
    if (eq != null) return eq!;
    if (lt != null) return lt!;
    if (gt != null) return gt!;
    if (lte != null) return lte!;
    if (gte != null) return gte!;
    throw Exception('Invalid Double filters, you must provide at least one filter!');
  }
}

/// Equivalent to `DoubleFilter(equals: value)`
DoubleFilter doubleEQ(double value) => DoubleFilter(eq: value);

/// Equivalent to `DoubleFilter(lt: value)`
DoubleFilter doubleLT(double value) => DoubleFilter(lt: value);

/// Equivalent to `DoubleFilter(gt: value)`
DoubleFilter doubleGT(double value) => DoubleFilter(gt: value);

/// Equivalent to `DoubleFilter(lte: value)`
DoubleFilter doubleLTE(double value) => DoubleFilter(lte: value);

/// Equivalent to `DoubleFilter(gte: value)`
DoubleFilter doubleGTE(double value) => DoubleFilter(gte: value);
