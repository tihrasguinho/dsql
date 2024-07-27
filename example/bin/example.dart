import 'dart:io';

import 'package:example/generated/dsql.dart';

void main() async {
  final dsql = await DSQL.open(
    'postgres://postgres:postgres@localhost:5432/dsql',
    verbose: true,
  );

  // await dsql.posts.insertOne(
  //   InsertOnePostParams(
  //     title: 'title ${DateTime.now().toIso8601String()}',
  //     body: 'body',
  //     ownerId: '058781b0-207f-48fa-aad1-6725cc303c33',
  //   ),
  // );

  final result = await dsql.users.findByPK('058781b0-207f-48fa-aad1-6725cc303c33', includeUserposts: true);

  if (result.isError) {
    print(result.getErrorOrThrow());
    exit(0);
  }

  final user = result.getSuccessOrThrow();

  print(user);

//   --------------------------------------------------------------------------------
//   SQL => INSERT INTO tb_users (name, username, email, password) VALUES ($1, $2, $3, $4) RETURNING *;
//   PARAMS => [Tiago Alves, tihrasguinho, tiago@gmail.com, 123456]
//   --------------------------------------------------------------------------------
//   UserEntity(id: 7b2549c8-3858-4d64-96fb-f9f38b20042b, name: Tiago Alves, username: tihrasguinho, email: tiago@gmail.com, password: 123456, image: null, bio: null, website: null, createdAt: 2024-07-26 12:48:27.154991Z, updatedAt: 2024-07-26 12:48:27.154991Z)
}
