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
      .updateOne(
        UpdateOneUserParams(
          whereEmail: Where.eq('email1@example.com'),
          whereCreatedAt: Where.lte(DateTime.now()),
          name: 'Tiago Alves',
          username: 'tihrasguinho',
          email: 'tiago@gmail.com',
          password: '667623',
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
