import 'dart:convert';

class Page<T extends Object> {
  final List<T> items;
  final int page;
  final int pageSize;
  final int count;
  final bool hasNext;
  final bool hasPrevious;

  const Page({
    required this.items,
    this.page = 1,
    this.pageSize = 10,
    this.count = 0,
    this.hasNext = false,
    this.hasPrevious = false,
  });

  int get total => items.length;

  @override
  String toString() {
    return 'Page(items: $items, total: $total, page: $page, pageSize: $pageSize, count: $count, hasNext: $hasNext, hasPrevious: $hasPrevious)';
  }

  Map<String, dynamic> toMap(
      List<Map<String, dynamic>> Function(List<T> origin) mapper) {
    return {
      'items': mapper(items),
      'total': total,
      'page': page,
      'page_size': pageSize,
      'count': count,
      'has_next': hasNext,
      'has_previous': hasPrevious,
    };
  }

  String toJson(List<Map<String, dynamic>> Function(List<T> origin) mapper) =>
      json.encode(toMap(mapper));

  factory Page.fromMap(
    Map<String, dynamic> map,
    List<T> Function(List<Map<String, dynamic>> map) mapper,
  ) {
    return Page(
      items: mapper(map['items'] as List<Map<String, dynamic>>),
      page: map['page'] as int,
      pageSize: map['page_size'] as int,
      count: map['count'] as int,
      hasNext: map['has_next'] as bool,
      hasPrevious: map['has_previous'] as bool,
    );
  }

  factory Page.fromJson(
      String source, List<T> Function(List<Map<String, dynamic>> map) mapper) {
    return Page.fromMap(json.decode(source) as Map<String, dynamic>, mapper);
  }

  @override
  bool operator ==(covariant Page<T> other) {
    if (identical(this, other)) return true;
    bool listEquals(List a, List b) {
      if (a.length != b.length) return false;
      for (int i = 0; i < a.length; i++) {
        if (a[i] != b[i]) return false;
      }
      return true;
    }

    return listEquals(other.items, items) &&
        other.total == total &&
        other.page == page &&
        other.pageSize == pageSize &&
        other.hasNext == hasNext &&
        other.hasPrevious == hasPrevious;
  }

  @override
  int get hashCode {
    return items.hashCode ^
        total.hashCode ^
        page.hashCode ^
        pageSize.hashCode ^
        hasNext.hashCode ^
        hasPrevious.hashCode;
  }
}
