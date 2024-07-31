class Where {
  final String op;
  final dynamic value;

  const Where._(this.op, this.value);

  const Where.eq(dynamic value) : this._('=', value);

  const Where.neq(dynamic value) : this._('!=', value);

  const Where.gt(dynamic value) : this._('>', value);

  const Where.gte(dynamic value) : this._('>=', value);

  const Where.lt(dynamic value) : this._('<', value);

  const Where.lte(dynamic value) : this._('<=', value);

  const Where.startsWith(String value, {bool ignoreCase = true}) : this._(ignoreCase ? 'ILIKE' : 'LIKE', '$value%');

  const Where.endsWith(String value, {bool ignoreCase = true}) : this._(ignoreCase ? 'ILIKE' : 'LIKE', '%$value');

  const Where.contains(String value, {bool ignoreCase = true}) : this._(ignoreCase ? 'ILIKE' : 'LIKE', '%$value%');

  String sql(String column) => '$op @$column';
}
