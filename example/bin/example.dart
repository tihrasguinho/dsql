import 'dart:io';

import 'package:dsql/dsql.dart';
import 'package:example/generated/experimental/repositories.dart';

void main() async {
  final conn = await Connection.open(
    Endpoint(
      host: 'localhost',
      database: 'dev',
      username: 'postgres',
      password: 'postgres',
    ),
    settings: ConnectionSettings(
      sslMode: SslMode.disable,
    ),
  );

  final users = UsersRepository(conn, verbose: true);

  await users
      .deleteMany(
        DeleteManyUserParams(
          whereEmail: Where.endsWith('example.com'),
        ),
      )
      .then(
        (r) => r.when(
          (_) {},
          (e) => print(e.message),
        ),
      );

  await conn.close();

  exit(0);
}
