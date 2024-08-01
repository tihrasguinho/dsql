import 'constraint.dart';
import 'shared.dart';

class Table {
  final String entity;
  final String name;
  final List<String> lines;
  final Map<Constraint, Table> hasMany;
  final Map<Constraint, Table> hasOne;

  const Table({
    required this.entity,
    required this.name,
    required this.lines,
    this.hasMany = const {},
    this.hasOne = const {},
  });

  String get rawEntity => entity.substring(0, entity.length - 6);

  String get repository => '${tryToPluralize(rawEntity)}Repository';

  List<String> get columns => lines
      .where((l) => !RegExp(r'^(CONSTRAINT|FOREIGN KEY)').hasMatch(l))
      .toList();

  String get nameWithoutPrefixTB => switch (name.startsWith('tb_')) {
        true => name.substring(3),
        false => name,
      };

  Table copyWith({
    String? entity,
    String? name,
    List<String>? lines,
    Map<Constraint, Table>? hasMany,
    Map<Constraint, Table>? hasOne,
  }) {
    return Table(
      entity: entity ?? this.entity,
      name: name ?? this.name,
      lines: lines ?? this.lines,
      hasMany: hasMany ?? this.hasMany,
      hasOne: hasOne ?? this.hasOne,
    );
  }
}
