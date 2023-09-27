import 'timestamp_filter.dart';

extension TimestampFilterExt on DateTime {
  /// Equivalent to `TimestampFilter(eq: this)`
  TimestampFilter get eq => TimestampFilter(eq: this);

  /// Equivalent to `TimestampFilter(lt: this)`
  TimestampFilter get lt => TimestampFilter(lt: this);

  /// Equivalent to `TimestampFilter(gt: this)`
  TimestampFilter get gt => TimestampFilter(gt: this);

  /// Equivalent to `TimestampFilter(lte: this)`
  TimestampFilter get lte => TimestampFilter(lte: this);

  /// Equivalent to `TimestampFilter(gte: this)`
  TimestampFilter get gte => TimestampFilter(gte: this);
}
