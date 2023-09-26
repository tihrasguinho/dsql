import 'dart:io';

import 'package:dsql/dsql.dart';
import 'package:dsql/src/dsql_gen.dart';

import 'lib/dsql.dart';

void main() async {
  // await regenerate();
  await test();
}

Future<void> regenerate() async {
  final root = Directory.current;

  final migrations = Directory(join(root.path, 'migrations'));

  await DSQLGen.readMigrations(migrations.path);
}

Future<void> test() async {
  final dsql =
      DSQL(postgresURL: 'postgres://postgres:postgres@localhost:5432/dsql');

  await dsql.init();

  final users =
      await dsql.userrepository.delete('8a3de226-69c1-44e4-876b-0363af7826ae');

  // print(users.map((e) => e.toMap()).toList());

  print(users.toMap());
}
