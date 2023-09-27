import 'filter.dart';

class TimestampFilter extends Filter<DateTime> {
  final DateTime? eq;
  final DateTime? lt;
  final DateTime? gt;
  final DateTime? lte;
  final DateTime? gte;

  TimestampFilter({this.eq, this.lt, this.gt, this.lte, this.gte}) {
    assert(eq != null || lt != null || gt != null || lte != null || gte != null, 'Invalid Timestamp filters, you must provide at least one filter!');
  }

  @override
  String get operator {
    if (eq != null) return '=';
    if (lt != null) return '<';
    if (gt != null) return '>';
    if (lte != null) return '<=';
    if (gte != null) return '>=';
    throw Exception('Invalid Timestamp filters, you must provide at least one filter!');
  }

  @override
  DateTime get value {
    if (eq != null) return eq!;
    if (lt != null) return lt!;
    if (gt != null) return gt!;
    if (lte != null) return lte!;
    if (gte != null) return gte!;
    throw Exception('Invalid Timestamp filters, you must provide at least one filter!');
  }
}

/// Equivalent to `TimestampFilter(eq: value)`
TimestampFilter timestampEQ(DateTime value) => TimestampFilter(eq: value);

/// Equivalent to `TimestampFilter(lt: value)`
TimestampFilter timestampLT(DateTime value) => TimestampFilter(lt: value);

/// Equivalent to `TimestampFilter(gt: value)`
TimestampFilter timestampGT(DateTime value) => TimestampFilter(gt: value);

/// Equivalent to `TimestampFilter(lte: value)`
TimestampFilter timestampLTE(DateTime value) => TimestampFilter(lte: value);

/// Equivalent to `TimestampFilter(gte: value)`
TimestampFilter timestampGTE(DateTime value) => TimestampFilter(gte: value);
