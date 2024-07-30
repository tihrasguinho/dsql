class Pagination<T extends Object> {
  final List<T> items;
  final int total;
  final int page;
  final int pageSize;
  final bool hasNext;
  final bool hasPrevious;

  const Pagination({
    required this.items,
    required this.total,
    required this.page,
    required this.pageSize,
    required this.hasNext,
    required this.hasPrevious,
  });

  @override
  String toString() {
    return 'Pagination(items: $items, total: $total, page: $page, pageSize: $pageSize, hasNext: $hasNext, hasPrevious: $hasPrevious)';
  }

  @override
  bool operator ==(covariant Pagination<T> other) {
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
