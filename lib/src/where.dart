import 'dsql_utils.dart';

class Where {
  late final String column;
  late final Operator operator;

  late final StringBuffer _buffer;
  final Map<String, dynamic> _substitutionValues = {};

  Where(this.column, this.operator) {
    _validate(column, operator);

    final randomized = '${DSQLUtils.randomStr(11)}_$column';

    _buffer = StringBuffer('$column ${operator.operator} @$randomized');
    _substitutionValues.addAll({randomized: operator.value});
  }

  Where.emphasis(Where where)
      : column = where.column,
        operator = where.operator {
    _validate(column, operator);

    _buffer = StringBuffer('(${where._buffer.toString()})');
    _substitutionValues.addAll({...where.substitutionValues});
  }

  void _validate(String column, Operator operator) {
    if (column.isEmpty) {
      throw Exception('Column must not be empty!');
    }

    if ([EQ, NOTEQ, LT, GT, LTE, GTE].contains(operator.runtimeType) && ![int, double, DateTime, String].contains(operator.value.runtimeType)) {
      throw Exception('Only operators [EQ, NOTEQ, LT, GT, LTE, GTE] allowed for ${operator.value.runtimeType}!');
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

final class NOTEQ extends Operator {
  const NOTEQ(dynamic value) : super('!=', value);
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
