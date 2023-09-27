import 'filter.dart';

class IntegerFilter extends Filter<int> {
  final int? eq;
  final int? lt;
  final int? gt;
  final int? lte;
  final int? gte;

  IntegerFilter({this.eq, this.lt, this.gt, this.lte, this.gte}) {
    assert(eq != null || lt != null || gt != null || lte != null || gte != null, 'Invalid Integer filters, you must provide at least one filter!');
  }

  @override
  String get operator {
    if (eq != null) return '=';
    if (lt != null) return '<';
    if (gt != null) return '>';
    if (lte != null) return '<=';
    if (gte != null) return '>=';
    throw Exception('Invalid Integer filters, you must provide at least one filter!');
  }

  @override
  int get value {
    if (eq != null) return eq!;
    if (lt != null) return lt!;
    if (gt != null) return gt!;
    if (lte != null) return lte!;
    if (gte != null) return gte!;
    throw Exception('Invalid Integer filters, you must provide at least one filter!');
  }
}

/// Equivalent to `IntegerFilter(eq: value)`
IntegerFilter integerEQ(int value) => IntegerFilter(eq: value);

/// Equivalent to `IntegerFilter(lt: value)`
IntegerFilter integerLT(int value) => IntegerFilter(lt: value);

/// Equivalent to `IntegerFilter(gt: value)`
IntegerFilter integerGT(int value) => IntegerFilter(gt: value);

/// Equivalent to `IntegerFilter(lte: value)`
IntegerFilter integerLTE(int value) => IntegerFilter(lte: value);

/// Equivalent to `IntegerFilter(gte: value)`
IntegerFilter integerGTE(int value) => IntegerFilter(gte: value);
