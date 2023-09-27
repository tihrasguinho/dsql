import 'integer_filter.dart';

extension IntegerFilterExt on int {
  /// Equivalent to `IntegerFilter(eq: this)`
  IntegerFilter get eq => IntegerFilter(eq: this);

  /// Equivalent to `IntegerFilter(lt: this)`
  IntegerFilter get lt => IntegerFilter(lt: this);

  /// Equivalent to `IntegerFilter(gt: this)`
  IntegerFilter get gt => IntegerFilter(gt: this);

  /// Equivalent to `IntegerFilter(lte: this)`
  IntegerFilter get lte => IntegerFilter(lte: this);

  /// Equivalent to `IntegerFilter(gte: this)`
  IntegerFilter get gte => IntegerFilter(gte: this);
}
