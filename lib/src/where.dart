class Where {
  final String column;
  final Operator operator;

  late final StringBuffer _buffer;
  late final Map<String, dynamic> _substitutionValues;

  Where(this.column, this.operator) {
    _validate();
    _buffer = StringBuffer('$column ${operator.operator} @$column');
    _substitutionValues = {column: operator.value};
  }

  void _validate() {
    if (column.isEmpty) {
      throw Exception('Column must not be empty!');
    }

    if ([EQ, LT, GT, LTE, GTE].contains(operator.runtimeType) && ![int, double, DateTime, String].contains(operator.value.runtimeType)) {
      throw Exception('Only operators [EQ, LT, GT, LTE, GTE] allowed for ${operator.value.runtimeType}!');
    }
  }

  String get queryString => _buffer.toString();

  Map<String, dynamic> get substitutionValues => _substitutionValues;

  Where and(Where other, {bool parentesis = false}) {
    _buffer.write(' AND ${parentesis ? '(' : ''}${other._buffer.toString()}${parentesis ? ')' : ''}');
    _substitutionValues.addAll(other.substitutionValues);
    return this;
  }

  Where or(Where other, {bool parentesis = false}) {
    _buffer.write(' OR ${parentesis ? '(' : ''}${other._buffer.toString()}${parentesis ? ')' : ''}');

    _substitutionValues.addAll(other.substitutionValues);
    return this;
  }
}

String opToPG(String operator) => switch (operator) {
      'eq' => '=',
      'lt' => '<',
      'gt' => '>',
      'lte' => '<=',
      'gte' => '>=',
      'startsWith' || 'endsWith' || 'contains' => 'ILIKE',
      _ => '=',
    };

dynamic valueToPG(Operator operator, dynamic value) => switch (operator) {
      StartsWith() => '$value%',
      EndsWith() => '%$value',
      Contains() => '%$value%',
      _ => value,
    };

sealed class Operator {
  final String operator;
  final dynamic value;

  const Operator(this.operator, this.value);
}

final class EQ extends Operator {
  const EQ(dynamic value) : super('=', value);
}

final class LT extends Operator {
  const LT(dynamic value) : super('<', value);
}

final class GT extends Operator {
  const GT(dynamic value) : super('>', value);
}

final class LTE extends Operator {
  const LTE(dynamic value) : super('<=', value);
}

final class GTE extends Operator {
  const GTE(dynamic value) : super('>=', value);
}

final class Contains extends Operator {
  const Contains(String value) : super('ILIKE', '%$value%');
}

final class StartsWith extends Operator {
  const StartsWith(String value) : super('ILIKE', '$value%');
}

final class EndsWith extends Operator {
  const EndsWith(String value) : super('ILIKE', '%$value');
}
