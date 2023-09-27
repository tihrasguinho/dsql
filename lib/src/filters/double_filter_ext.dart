import 'double_filter.dart';

extension DoubleFilterExt on double {
  /// Equivalent to `DoubleFilter(eq: this)`
  DoubleFilter get eq => DoubleFilter(eq: this);

  /// Equivalent to `DoubleFilter(lt: this)`
  DoubleFilter get lt => DoubleFilter(lt: this);

  /// Equivalent to `DoubleFilter(gt: this)`
  DoubleFilter get gt => DoubleFilter(gt: this);

  /// Equivalent to `DoubleFilter(lte: this)`
  DoubleFilter get lte => DoubleFilter(lte: this);

  /// Equivalent to `DoubleFilter(gte: this)`
  DoubleFilter get gte => DoubleFilter(gte: this);
}
