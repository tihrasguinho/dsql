import 'filter.dart';

class StringFilter extends Filter<String> {
  final String? equals;
  final String? startsWith;
  final String? endsWith;
  final String? contains;

  StringFilter({this.equals, this.startsWith, this.endsWith, this.contains}) {
    assert(
        equals != null ||
            startsWith != null ||
            endsWith != null ||
            contains != null,
        'Invalid String filters, you must provide at least one filter!');
  }

  @override
  String get value {
    if (equals?.isNotEmpty ?? false) return equals!;
    if (startsWith?.isNotEmpty ?? false) return '$startsWith%';
    if (endsWith?.isNotEmpty ?? false) return '%$endsWith';
    if (contains?.isNotEmpty ?? false) return '%$contains%';
    throw Exception(
        'Invalid String filters, you must provide at least one filter!');
  }

  @override
  String get operator {
    if (equals?.isNotEmpty ?? false) return '=';
    if (startsWith?.isNotEmpty ?? false) return 'ILIKE';
    if (endsWith?.isNotEmpty ?? false) return 'ILIKE';
    if (contains?.isNotEmpty ?? false) return 'ILIKE';
    throw Exception(
        'Invalid String filters, you must provide at least one filter!');
  }
}
