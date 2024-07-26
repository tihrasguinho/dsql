import 'lib/generated/dsql.dart';

void main() async {
  final dsql = await DSQL.open(
    'postgres://postgres:postgres@localhost:5432/dsql',
    verbose: true,
  );

  final result = await dsql.users.insertOne(
    InsertOneUserParams(
      name: 'Tiago Alves',
      username: 'tihrasguinho',
      email: 'tiago@gmail.com',
      password: '123456',
    ),
  );

  return result.when(print, print);

//   --------------------------------------------------------------------------------
//   SQL => INSERT INTO tb_users (name, username, email, password) VALUES ($1, $2, $3, $4) RETURNING *;
//   PARAMS => [Tiago Alves, tihrasguinho, tiago@gmail.com, 123456]
//   --------------------------------------------------------------------------------
//   UserEntity(id: 7b2549c8-3858-4d64-96fb-f9f38b20042b, name: Tiago Alves, username: tihrasguinho, email: tiago@gmail.com, password: 123456, image: null, bio: null, website: null, createdAt: 2024-07-26 12:48:27.154991Z, updatedAt: 2024-07-26 12:48:27.154991Z)
}