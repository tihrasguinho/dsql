import 'dart:io';

import 'package:example/generated/dsql.dart';

void main() async {
  final dsql = DSQL.withPool(
    'postgres://postgres:postgres@localhost:5432/dev',
    verbose: true,
  );

  final users = await dsql.users.findMany();

  return users.when(
    (success) {
      print(success);
      exit(0);
    },
    (error) {
      print(error.message);
      exit(0);
    },
  );
  //  Because we are using verbose = true the current query and parameters will be printed in the console
  //  ********************************************************************************
  //  FindManyUserParams
  //  ********************************************************************************
  //  QUERY: SELECT * FROM tb_users OFFSET 0 LIMIT 20;
  //  PARAMETERS: []
  //  ********************************************************************************
  //
  //  Printed data:
  //  [UserEntity(id: da11189a-34cf-4d2e-a507-dac8a8cfe192, name: Tiago Alves, username: tihrasguinho, email: tiago@gmail.com, password: 667623, image: null, bio: Soldado sem braço não faz sentido!, createdAt: 2024-07-30 18:35:44.158241Z, updatedAt: 2024-07-30 18:35:44.158241Z)]
}
