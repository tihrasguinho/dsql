enum OrderByOption {
  asc('ASC'),
  desc('DESC');

  final String direction;

  const OrderByOption(this.direction);
}

class OrderBy {
  final String column;
  final OrderByOption option;

  const OrderBy._(this.column, this.option);

  const OrderBy.asc(String column) : this._(column, OrderByOption.asc);

  const OrderBy.desc(String column) : this._(column, OrderByOption.desc);

  String get sql => '\$column \${option.direction}';
}
