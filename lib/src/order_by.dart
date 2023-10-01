sealed class OrderBy {
  final String column;
  final String operator;

  OrderBy(this.column, this.operator);

  String get queryString => 'ORDER BY $column $operator';
}

final class ASC extends OrderBy {
  ASC(String column) : super(column, 'ASC');
}

final class DESC extends OrderBy {
  DESC(String column) : super(column, 'DESC');
}
