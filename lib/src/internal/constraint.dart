import 'shared.dart';

class Constraint {
  final String name;
  final String originColumn;
  final String referencedTable;
  final String referencedColumn;

  const Constraint({
    required this.name,
    required this.originColumn,
    required this.referencedTable,
    required this.referencedColumn,
  });

  String get nameNormalized => constraintNameNormalizer(name);
}
