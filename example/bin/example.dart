import 'package:dsql/dsql.dart';
import 'package:example/generated/dsql.dart';

void main() async {
  final dsql = await DSQL.open(
    'postgres://postgres:postgres@localhost:5432/dev',
    verbose: true,
  );

  await dsql.users
      .findMany(
        FindManyUserParams(
          whereName: Where.contains('a'),
          includePosts: IncludeUserPosts(
            pageSize: 1,
            orderBy: OrderBy.desc('created_at'),
          ),
          orderBy: OrderBy.desc('created_at'),
        ),
      )
      .then(
        (result) => result.when(
          (success) => print(success),
          (error) => print(error),
        ),
      );

//   --------------------------------------------------------------------------------
//   SQL => INSERT INTO tb_users (name, username, email, password) VALUES ($1, $2, $3, $4) RETURNING *;
//   PARAMS => [Tiago Alves, tihrasguinho, tiago@gmail.com, 123456]
//   --------------------------------------------------------------------------------
//   UserEntity(id: 7b2549c8-3858-4d64-96fb-f9f38b20042b, name: Tiago Alves, username: tihrasguinho, email: tiago@gmail.com, password: 123456, image: null, bio: null, website: null, createdAt: 2024-07-26 12:48:27.154991Z, updatedAt: 2024-07-26 12:48:27.154991Z)
}
