import 'shared.dart';

class Constraint {
  final String name;
  final String column;
  final String targetTable;
  final String targetColumn;

  const Constraint({
    required this.name,
    required this.column,
    required this.targetTable,
    required this.targetColumn,
  });

  String get nameNormalized => constraintNameNormalizer(name);

  Constraint copyWith({
    String? name,
    String? column,
    String? targetTable,
    String? targetColumn,
  }) {
    return Constraint(
      name: name ?? this.name,
      column: column ?? this.column,
      targetTable: targetTable ?? this.targetTable,
      targetColumn: targetColumn ?? this.targetColumn,
    );
  }
}
