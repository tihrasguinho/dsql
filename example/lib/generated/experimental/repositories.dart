import 'package:dsql/dsql.dart';
import 'dart:convert';
part 'entities.dart';

class UsersRepository extends Repository<
    UserEntity,
    InsertOneUserParams,
    InsertManyUserParams,
    FindOneUserParams,
    FindManyUserParams,
    UpdateOneUserParams,
    UpdateManyUserParams,
    DeleteOneUserParams,
    DeleteManyUserParams> {
  final Connection _conn;
  final bool verbose;

  const UsersRepository(this._conn, {this.verbose = false});

  @override
  AsyncResult<UserEntity, DSQLException> insertOne(
      InsertOneUserParams params) async {
    try {
      if (verbose) {
        print('*' * 80);
        print('InsertOneUserParams');
        print('*' * 80);
        print('QUERY: ${params.query}');
        print('PARAMETERS: ${params.parameters}');
        print('*' * 80);
      }

      final result =
          await _conn.execute(params.query, parameters: params.parameters);

      if (result.isEmpty) {
        return Error(SQLException('Fail to insert data on table `tb_users`!'));
      }

      final [
        String $id,
        String $name,
        String $username,
        String $email,
        String $password,
        String? $image,
        String? $bio,
        DateTime $createdAt,
        DateTime $updatedAt,
      ] = result.first as List;

      final entity = UserEntity(
        id: $id,
        name: $name,
        username: $username,
        email: $email,
        password: $password,
        image: $image,
        bio: $bio,
        createdAt: $createdAt,
        updatedAt: $updatedAt,
      );

      return Success(entity);
    } on Exception catch (e) {
      return Error(SQLException(e.toString()));
    }
  }

  @override
  AsyncResult<List<UserEntity>, DSQLException> insertMany(
      InsertManyUserParams params) async {
    try {
      if (verbose) {
        print('*' * 80);
        print('InsertManyUserParams');
        print('*' * 80);
        print('QUERY: ${params.query}');
        print('PARAMETERS: ${params.parameters}');
        print('*' * 80);
      }

      final result =
          await _conn.execute(params.query, parameters: params.parameters);

      if (result.isEmpty) {
        return Error(SQLException('Fail to insert data on table `tb_users`!'));
      }

      final entities = result.map(
        (row) {
          final [
            String $id,
            String $name,
            String $username,
            String $email,
            String $password,
            String? $image,
            String? $bio,
            DateTime $createdAt,
            DateTime $updatedAt,
          ] = row as List;

          return UserEntity(
            id: $id,
            name: $name,
            username: $username,
            email: $email,
            password: $password,
            image: $image,
            bio: $bio,
            createdAt: $createdAt,
            updatedAt: $updatedAt,
          );
        },
      );

      return Success(entities.toList());
    } on Exception catch (e) {
      return Error(SQLException(e.toString()));
    }
  }

  @override
  AsyncResult<UserEntity, DSQLException> findOne(
      FindOneUserParams params) async {
    try {
      if (verbose) {
        print('*' * 80);
        print('FindOneUserParams');
        print('*' * 80);
        print('QUERY: ${params.query}');
        print('PARAMETERS: ${params.parameters}');
        print('*' * 80);
      }

      final result =
          await _conn.execute(params.query, parameters: params.parameters);

      if (result.isEmpty) {
        return Error(SQLException('No data found on table `tb_users`!'));
      }

      final [
        String $id,
        String $name,
        String $username,
        String $email,
        String $password,
        String? $image,
        String? $bio,
        DateTime $createdAt,
        DateTime $updatedAt,
      ] = result.first as List;

      final entity = UserEntity(
        id: $id,
        name: $name,
        username: $username,
        email: $email,
        password: $password,
        image: $image,
        bio: $bio,
        createdAt: $createdAt,
        updatedAt: $updatedAt,
      );

      return Success(entity);
    } on DSQLException catch (e) {
      return Error(e);
    } on Exception catch (e) {
      return Error(SQLException(e.toString()));
    }
  }

  @override
  AsyncResult<List<UserEntity>, DSQLException> findMany(
      [FindManyUserParams params = const FindManyUserParams()]) async {
    try {
      if (verbose) {
        print('*' * 80);
        print('FindManyUserParams');
        print('*' * 80);
        print('QUERY: ${params.query}');
        print('PARAMETERS: ${params.parameters}');
        print('*' * 80);
      }

      final result =
          await _conn.execute(params.query, parameters: params.parameters);

      final entities = result.map(
        (row) {
          final [
            String $id,
            String $name,
            String $username,
            String $email,
            String $password,
            String? $image,
            String? $bio,
            DateTime $createdAt,
            DateTime $updatedAt,
          ] = row as List;

          return UserEntity(
            id: $id,
            name: $name,
            username: $username,
            email: $email,
            password: $password,
            image: $image,
            bio: $bio,
            createdAt: $createdAt,
            updatedAt: $updatedAt,
          );
        },
      );

      return Success(entities.toList());
    } on Exception catch (e) {
      return Error(SQLException(e.toString()));
    }
  }

  @override
  AsyncResult<Page<UserEntity>, DSQLException> findManyPaginated(
      [FindManyUserParams params = const FindManyUserParams()]) async {
    throw UnimplementedError();
  }

  @override
  AsyncResult<UserEntity, DSQLException> updateOne(
      UpdateOneUserParams params) async {
    try {
      if (verbose) {
        print('*' * 80);
        print('UpdateOneUserParams');
        print('*' * 80);
        print('QUERY: ${params.query}');
        print('PARAMETERS: ${params.parameters}');
        print('*' * 80);
      }

      final result =
          await _conn.execute(params.query, parameters: params.parameters);

      if (result.isEmpty) {
        return Error(
            SQLException('No data found on table `tb_users` to update!'));
      }

      final [
        String $id,
        String $name,
        String $username,
        String $email,
        String $password,
        String? $image,
        String? $bio,
        DateTime $createdAt,
        DateTime $updatedAt,
      ] = result.first as List;

      final entity = UserEntity(
        id: $id,
        name: $name,
        username: $username,
        email: $email,
        password: $password,
        image: $image,
        bio: $bio,
        createdAt: $createdAt,
        updatedAt: $updatedAt,
      );

      return Success(entity);
    } on DSQLException catch (e) {
      return Error(e);
    } on Exception catch (e) {
      return Error(SQLException(e.toString()));
    }
  }

  @override
  AsyncResult<List<UserEntity>, DSQLException> updateMany(
      UpdateManyUserParams params) async {
    try {
      if (verbose) {
        print('*' * 80);
        print('UpdateManyUserParams');
        print('*' * 80);
        print('QUERY: ${params.query}');
        print('PARAMETERS: ${params.parameters}');
        print('*' * 80);
      }

      final result =
          await _conn.execute(params.query, parameters: params.parameters);

      final entities = result.map(
        (row) {
          final [
            String $id,
            String $name,
            String $username,
            String $email,
            String $password,
            String? $image,
            String? $bio,
            DateTime $createdAt,
            DateTime $updatedAt,
          ] = row as List;

          return UserEntity(
            id: $id,
            name: $name,
            username: $username,
            email: $email,
            password: $password,
            image: $image,
            bio: $bio,
            createdAt: $createdAt,
            updatedAt: $updatedAt,
          );
        },
      );

      return Success(entities.toList());
    } on DSQLException catch (e) {
      return Error(e);
    } on Exception catch (e) {
      return Error(SQLException(e.toString()));
    }
  }

  @override
  AsyncResult<UserEntity, DSQLException> deleteOne(
      DeleteOneUserParams params) async {
    try {
      if (verbose) {
        print('*' * 80);
        print('DeleteOneUserParams');
        print('*' * 80);
        print('QUERY: ${params.query}');
        print('PARAMETERS: ${params.parameters}');
        print('*' * 80);
      }

      final result =
          await _conn.execute(params.query, parameters: params.parameters);

      if (result.isEmpty) {
        return Error(
            SQLException('No data found on table `tb_users` to delete!'));
      }

      final [
        String $id,
        String $name,
        String $username,
        String $email,
        String $password,
        String? $image,
        String? $bio,
        DateTime $createdAt,
        DateTime $updatedAt,
      ] = result.first as List;

      final entity = UserEntity(
        id: $id,
        name: $name,
        username: $username,
        email: $email,
        password: $password,
        image: $image,
        bio: $bio,
        createdAt: $createdAt,
        updatedAt: $updatedAt,
      );

      return Success(entity);
    } on DSQLException catch (e) {
      return Error(e);
    } on Exception catch (e) {
      return Error(SQLException(e.toString()));
    }
  }

  @override
  AsyncResult<List<UserEntity>, DSQLException> deleteMany(
      DeleteManyUserParams params) async {
    try {
      if (verbose) {
        print('*' * 80);
        print('DeleteManyUserParams');
        print('*' * 80);
        print('QUERY: ${params.query}');
        print('PARAMETERS: ${params.parameters}');
        print('*' * 80);
      }

      final result =
          await _conn.execute(params.query, parameters: params.parameters);

      final entities = result.map(
        (row) {
          final [
            String $id,
            String $name,
            String $username,
            String $email,
            String $password,
            String? $image,
            String? $bio,
            DateTime $createdAt,
            DateTime $updatedAt,
          ] = row as List;

          return UserEntity(
            id: $id,
            name: $name,
            username: $username,
            email: $email,
            password: $password,
            image: $image,
            bio: $bio,
            createdAt: $createdAt,
            updatedAt: $updatedAt,
          );
        },
      );

      return Success(entities.toList());
    } on DSQLException catch (e) {
      return Error(e);
    } on Exception catch (e) {
      return Error(SQLException(e.toString()));
    }
  }
}

class InsertOneUserParams extends InsertOneParams {
  final String name;
  final String username;
  final String email;
  final String password;

  const InsertOneUserParams({
    required this.name,
    required this.username,
    required this.email,
    required this.password,
  });

  @override
  String get query =>
      'INSERT INTO tb_users (name, username, email, password) VALUES (\$1, \$2, \$3, \$4) RETURNING *;';

  @override
  List get parameters => [name, username, email, password];
}

class InsertManyUserParams extends InsertManyParams {
  final List<InsertManyUserFields> fields;

  const InsertManyUserParams(this.fields);

  @override
  String get query =>
      'INSERT INTO tb_users (name, username, email, password)  VALUES ${fields.indexedMap((index, field) => '(${List.generate(field.parameters.length, (i) => '\$${(i + 1) + (index * 4)}').join(', ')})').join(', ')} RETURNING *;';

  @override
  List get parameters => fields.expand((f) => f.parameters).toList();
}

class InsertManyUserFields {
  final String name;
  final String username;
  final String email;
  final String password;

  const InsertManyUserFields({
    required this.name,
    required this.username,
    required this.email,
    required this.password,
  });

  List get parameters => [name, username, email, password];
}

class FindOneUserParams extends FindOneParams {
  final Where? id;
  final Where? name;
  final Where? username;
  final Where? email;
  final Where? password;
  final Where? image;
  final Where? bio;
  final Where? createdAt;
  final Where? updatedAt;

  const FindOneUserParams({
    this.id,
    this.name,
    this.username,
    this.email,
    this.password,
    this.image,
    this.bio,
    this.createdAt,
    this.updatedAt,
  });

  @override
  Map<String, Where> get wheres => {
        if (id != null) 'id': id!,
        if (name != null) 'name': name!,
        if (username != null) 'username': username!,
        if (email != null) 'email': email!,
        if (password != null) 'password': password!,
        if (image != null) 'image': image!,
        if (bio != null) 'bio': bio!,
        if (createdAt != null) 'created_at': createdAt!,
        if (updatedAt != null) 'updated_at': updatedAt!,
      };

  @override
  String get query {
    if (wheres.isEmpty) {
      throw SQLException('FindOneUserParams must have at least one where!');
    }

    return 'SELECT * FROM tb_users WHERE ${wheres.entries.indexedMap((i, e) => '${e.key} ${e.value.op} \$${i + 1}').join(' AND ')} LIMIT 1;';
  }

  @override
  List get parameters => wheres.values.map((v) => v.value).toList();
}

class FindManyUserParams extends FindManyParams {
  final Where? id;
  final Where? name;
  final Where? username;
  final Where? email;
  final Where? password;
  final Where? image;
  final Where? bio;
  final Where? createdAt;
  final Where? updatedAt;
  final int page;
  final int pageSize;
  final OrderBy? orderBy;

  const FindManyUserParams({
    this.id,
    this.name,
    this.username,
    this.email,
    this.password,
    this.image,
    this.bio,
    this.createdAt,
    this.updatedAt,
    this.page = 1,
    this.pageSize = 20,
    this.orderBy,
  });

  @override
  Map<String, Where> get wheres => {
        if (id != null) 'id': id!,
        if (name != null) 'name': name!,
        if (username != null) 'username': username!,
        if (email != null) 'email': email!,
        if (password != null) 'password': password!,
        if (image != null) 'image': image!,
        if (bio != null) 'bio': bio!,
        if (createdAt != null) 'created_at': createdAt!,
        if (updatedAt != null) 'updated_at': updatedAt!,
      };

  @override
  String get query {
    final offsetQuery = switch (page >= 1) {
      true => ' OFFSET ${page - 1}',
      false => ' OFFSET 0',
    };

    final limitQuery = ' LIMIT $pageSize';

    final orderByQuery = switch (orderBy != null) {
      false => '',
      true => ' ORDER BY ${orderBy?.sql}',
    };

    if (wheres.isEmpty) {
      return 'SELECT * FROM tb_users$orderByQuery$offsetQuery$limitQuery;';
    } else {
      return 'SELECT * FROM tb_users WHERE ${wheres.entries.indexedMap((i, e) => '${e.key} ${e.value.op} \$${i + 1}').join(' AND ')}$orderByQuery$offsetQuery$limitQuery;';
    }
  }

  @override
  List get parameters => wheres.values.map((v) => v.value).toList();
}

class UpdateOneUserParams extends UpdateOneParams {
  /// PrimaryKey `tb_users.id`
  final Where? whereId;

  /// UniqueKey `tb_users.username`
  final Where? whereUsername;

  /// UniqueKey `tb_users.email`
  final Where? whereEmail;
  final String? name;
  final String? username;
  final String? email;
  final String? password;
  final String? image;
  final String? bio;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const UpdateOneUserParams({
    this.whereId,
    this.whereUsername,
    this.whereEmail,
    this.name,
    this.username,
    this.email,
    this.password,
    this.image,
    this.bio,
    this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> get values => {
        if (name != null) 'name': name,
        if (username != null) 'username': username,
        if (email != null) 'email': email,
        if (password != null) 'password': password,
        if (image != null) 'image': image,
        if (bio != null) 'bio': bio,
        if (createdAt != null) 'created_at': createdAt,
        if (updatedAt != null) 'updated_at': updatedAt
      };

  @override
  Map<String, Where> get wheres => {
        if (whereId != null) 'id': whereId!,
        if (whereUsername != null) 'username': whereUsername!,
        if (whereEmail != null) 'email': whereEmail!,
      };

  @override
  String get query {
    if (wheres.isEmpty) {
      throw SQLException('UpdateOneUserParams cannot be conditionless!');
    }

    if (wheres.length > 1) {
      throw SQLException('UpdateOneUserParams must have only one where!');
    }

    if (values.isEmpty) {
      throw SQLException('UpdateOneUserParams must have at least one value!');
    }

    return 'UPDATE tb_users SET ${values.entries.indexedMap((index, entry) => '${entry.key} = \$${index + 1}').join(', ')} WHERE ${wheres.entries.indexedMap((index, entry) => '${entry.key} ${entry.value.op} \$${index + 1 + values.length}').join(' AND ')} RETURNING *;';
  }

  @override
  List get parameters => [
        ...values.values,
        ...wheres.values.map((v) => v.value),
      ];
}

class UpdateManyUserParams extends UpdateManyParams {
  final Where? whereId;
  final Where? whereName;
  final Where? whereUsername;
  final Where? whereEmail;
  final Where? wherePassword;
  final Where? whereImage;
  final Where? whereBio;
  final Where? whereCreatedAt;
  final Where? whereUpdatedAt;
  final String? name;
  final String? username;
  final String? email;
  final String? password;
  final String? image;
  final String? bio;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const UpdateManyUserParams({
    this.whereId,
    this.whereName,
    this.whereUsername,
    this.whereEmail,
    this.wherePassword,
    this.whereImage,
    this.whereBio,
    this.whereCreatedAt,
    this.whereUpdatedAt,
    this.name,
    this.username,
    this.email,
    this.password,
    this.image,
    this.bio,
    this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> get values => {
        if (name != null) 'name': name,
        if (username != null) 'username': username,
        if (email != null) 'email': email,
        if (password != null) 'password': password,
        if (image != null) 'image': image,
        if (bio != null) 'bio': bio,
        if (createdAt != null) 'created_at': createdAt,
        if (updatedAt != null) 'updated_at': updatedAt
      };

  @override
  Map<String, Where> get wheres => {
        if (whereId != null) 'id': whereId!,
        if (whereName != null) 'name': whereName!,
        if (whereUsername != null) 'username': whereUsername!,
        if (whereEmail != null) 'email': whereEmail!,
        if (wherePassword != null) 'password': wherePassword!,
        if (whereImage != null) 'image': whereImage!,
        if (whereBio != null) 'bio': whereBio!,
        if (whereCreatedAt != null) 'created_at': whereCreatedAt!,
        if (whereUpdatedAt != null) 'updated_at': whereUpdatedAt!,
      };

  @override
  String get query {
    if (values.isEmpty) {
      throw SQLException('UpdateManyUserParams must have at least one value!');
    }

    return 'UPDATE tb_users SET ${values.entries.indexedMap((index, entry) => '${entry.key} = \$${index + 1}').join(', ')}${wheres.isEmpty ? '' : ' WHERE ${wheres.entries.indexedMap((innerIndex, innerEntry) => '${innerEntry.key} ${innerEntry.value.op} \$${innerIndex + 1 + values.length}').join(' AND ')}'} RETURNING *;';
  }

  @override
  List get parameters => [
        ...values.values,
        ...wheres.values.map((v) => v.value),
      ];
}

class DeleteOneUserParams extends DeleteOneParams {
  /// PrimaryKey `tb_users.id`
  final Where? whereId;

  /// UniqueKey `tb_users.username`
  final Where? whereUsername;

  /// UniqueKey `tb_users.email`
  final Where? whereEmail;

  const DeleteOneUserParams({
    this.whereId,
    this.whereUsername,
    this.whereEmail,
  });

  @override
  Map<String, Where> get wheres => {
        if (whereId != null) 'id': whereId!,
        if (whereUsername != null) 'username': whereUsername!,
        if (whereEmail != null) 'email': whereEmail!,
      };

  @override
  String get query {
    if (wheres.isEmpty) {
      throw SQLException('DeleteOneUserParams cannot be conditionless!');
    }

    if (wheres.length > 1) {
      throw SQLException('DeleteOneUserParams can only have one condition!');
    }

    return 'DELETE FROM tb_users WHERE ${wheres.entries.indexedMap((index, entry) => '${entry.key} ${entry.value.op} \$${index + 1}').join(' AND ')} RETURNING *;';
  }

  @override
  List get parameters => wheres.values.map((v) => v.value).toList();
}

class DeleteManyUserParams extends DeleteManyParams {
  /// PrimaryKey `tb_users.id`
  final Where? whereId;

  /// UniqueKey `tb_users.name`
  final Where? whereName;

  /// UniqueKey `tb_users.username`
  final Where? whereUsername;

  /// UniqueKey `tb_users.email`
  final Where? whereEmail;

  /// UniqueKey `tb_users.password`
  final Where? wherePassword;

  /// UniqueKey `tb_users.image`
  final Where? whereImage;

  /// UniqueKey `tb_users.bio`
  final Where? whereBio;

  /// UniqueKey `tb_users.created_at`
  final Where? whereCreatedAt;

  /// UniqueKey `tb_users.updated_at`
  final Where? whereUpdatedAt;
  final String? id;

  const DeleteManyUserParams({
    this.whereId,
    this.whereName,
    this.whereUsername,
    this.whereEmail,
    this.wherePassword,
    this.whereImage,
    this.whereBio,
    this.whereCreatedAt,
    this.whereUpdatedAt,
    this.id,
  });

  @override
  Map<String, Where> get wheres => {
        if (whereId != null) 'id': whereId!,
        if (whereName != null) 'name': whereName!,
        if (whereUsername != null) 'username': whereUsername!,
        if (whereEmail != null) 'email': whereEmail!,
        if (wherePassword != null) 'password': wherePassword!,
        if (whereImage != null) 'image': whereImage!,
        if (whereBio != null) 'bio': whereBio!,
        if (whereCreatedAt != null) 'created_at': whereCreatedAt!,
        if (whereUpdatedAt != null) 'updated_at': whereUpdatedAt!,
      };

  @override
  String get query {
    if (wheres.isEmpty) {
      throw SQLException('DeleteManyUserParams cannot be conditionless!');
    }

    return 'DELETE FROM tb_users WHERE ${wheres.entries.indexedMap((index, entry) => '${entry.key} ${entry.value.op} \$${index + 1}').join(' AND ')} RETURNING *;';
  }

  @override
  List get parameters => wheres.values.map((v) => v.value).toList();
}

class PostsRepository extends Repository<
    PostEntity,
    InsertOnePostParams,
    InsertManyPostParams,
    FindOnePostParams,
    FindManyPostParams,
    UpdateOnePostParams,
    UpdateManyPostParams,
    DeleteOnePostParams,
    DeleteManyPostParams> {
  final Connection _conn;
  final bool verbose;

  const PostsRepository(this._conn, {this.verbose = false});

  @override
  AsyncResult<PostEntity, DSQLException> insertOne(
      InsertOnePostParams params) async {
    try {
      if (verbose) {
        print('*' * 80);
        print('InsertOnePostParams');
        print('*' * 80);
        print('QUERY: ${params.query}');
        print('PARAMETERS: ${params.parameters}');
        print('*' * 80);
      }

      final result =
          await _conn.execute(params.query, parameters: params.parameters);

      if (result.isEmpty) {
        return Error(SQLException('Fail to insert data on table `tb_posts`!'));
      }

      final [
        String $id,
        String? $postId,
        String $content,
        String $userId,
        DateTime $createdAt,
        DateTime $updatedAt,
      ] = result.first as List;

      final entity = PostEntity(
        id: $id,
        postId: $postId,
        content: $content,
        userId: $userId,
        createdAt: $createdAt,
        updatedAt: $updatedAt,
      );

      return Success(entity);
    } on Exception catch (e) {
      return Error(SQLException(e.toString()));
    }
  }

  @override
  AsyncResult<List<PostEntity>, DSQLException> insertMany(
      InsertManyPostParams params) async {
    try {
      if (verbose) {
        print('*' * 80);
        print('InsertManyPostParams');
        print('*' * 80);
        print('QUERY: ${params.query}');
        print('PARAMETERS: ${params.parameters}');
        print('*' * 80);
      }

      final result =
          await _conn.execute(params.query, parameters: params.parameters);

      if (result.isEmpty) {
        return Error(SQLException('Fail to insert data on table `tb_posts`!'));
      }

      final entities = result.map(
        (row) {
          final [
            String $id,
            String? $postId,
            String $content,
            String $userId,
            DateTime $createdAt,
            DateTime $updatedAt,
          ] = row as List;

          return PostEntity(
            id: $id,
            postId: $postId,
            content: $content,
            userId: $userId,
            createdAt: $createdAt,
            updatedAt: $updatedAt,
          );
        },
      );

      return Success(entities.toList());
    } on Exception catch (e) {
      return Error(SQLException(e.toString()));
    }
  }

  @override
  AsyncResult<PostEntity, DSQLException> findOne(
      FindOnePostParams params) async {
    try {
      if (verbose) {
        print('*' * 80);
        print('FindOnePostParams');
        print('*' * 80);
        print('QUERY: ${params.query}');
        print('PARAMETERS: ${params.parameters}');
        print('*' * 80);
      }

      final result =
          await _conn.execute(params.query, parameters: params.parameters);

      if (result.isEmpty) {
        return Error(SQLException('No data found on table `tb_posts`!'));
      }

      final [
        String $id,
        String? $postId,
        String $content,
        String $userId,
        DateTime $createdAt,
        DateTime $updatedAt,
      ] = result.first as List;

      final entity = PostEntity(
        id: $id,
        postId: $postId,
        content: $content,
        userId: $userId,
        createdAt: $createdAt,
        updatedAt: $updatedAt,
      );

      return Success(entity);
    } on DSQLException catch (e) {
      return Error(e);
    } on Exception catch (e) {
      return Error(SQLException(e.toString()));
    }
  }

  @override
  AsyncResult<List<PostEntity>, DSQLException> findMany(
      [FindManyPostParams params = const FindManyPostParams()]) async {
    try {
      if (verbose) {
        print('*' * 80);
        print('FindManyPostParams');
        print('*' * 80);
        print('QUERY: ${params.query}');
        print('PARAMETERS: ${params.parameters}');
        print('*' * 80);
      }

      final result =
          await _conn.execute(params.query, parameters: params.parameters);

      final entities = result.map(
        (row) {
          final [
            String $id,
            String? $postId,
            String $content,
            String $userId,
            DateTime $createdAt,
            DateTime $updatedAt,
          ] = row as List;

          return PostEntity(
            id: $id,
            postId: $postId,
            content: $content,
            userId: $userId,
            createdAt: $createdAt,
            updatedAt: $updatedAt,
          );
        },
      );

      return Success(entities.toList());
    } on Exception catch (e) {
      return Error(SQLException(e.toString()));
    }
  }

  @override
  AsyncResult<Page<PostEntity>, DSQLException> findManyPaginated(
      [FindManyPostParams params = const FindManyPostParams()]) async {
    throw UnimplementedError();
  }

  @override
  AsyncResult<PostEntity, DSQLException> updateOne(
      UpdateOnePostParams params) async {
    try {
      if (verbose) {
        print('*' * 80);
        print('UpdateOnePostParams');
        print('*' * 80);
        print('QUERY: ${params.query}');
        print('PARAMETERS: ${params.parameters}');
        print('*' * 80);
      }

      final result =
          await _conn.execute(params.query, parameters: params.parameters);

      if (result.isEmpty) {
        return Error(
            SQLException('No data found on table `tb_posts` to update!'));
      }

      final [
        String $id,
        String? $postId,
        String $content,
        String $userId,
        DateTime $createdAt,
        DateTime $updatedAt,
      ] = result.first as List;

      final entity = PostEntity(
        id: $id,
        postId: $postId,
        content: $content,
        userId: $userId,
        createdAt: $createdAt,
        updatedAt: $updatedAt,
      );

      return Success(entity);
    } on DSQLException catch (e) {
      return Error(e);
    } on Exception catch (e) {
      return Error(SQLException(e.toString()));
    }
  }

  @override
  AsyncResult<List<PostEntity>, DSQLException> updateMany(
      UpdateManyPostParams params) async {
    try {
      if (verbose) {
        print('*' * 80);
        print('UpdateManyPostParams');
        print('*' * 80);
        print('QUERY: ${params.query}');
        print('PARAMETERS: ${params.parameters}');
        print('*' * 80);
      }

      final result =
          await _conn.execute(params.query, parameters: params.parameters);

      final entities = result.map(
        (row) {
          final [
            String $id,
            String? $postId,
            String $content,
            String $userId,
            DateTime $createdAt,
            DateTime $updatedAt,
          ] = row as List;

          return PostEntity(
            id: $id,
            postId: $postId,
            content: $content,
            userId: $userId,
            createdAt: $createdAt,
            updatedAt: $updatedAt,
          );
        },
      );

      return Success(entities.toList());
    } on DSQLException catch (e) {
      return Error(e);
    } on Exception catch (e) {
      return Error(SQLException(e.toString()));
    }
  }

  @override
  AsyncResult<PostEntity, DSQLException> deleteOne(
      DeleteOnePostParams params) async {
    try {
      if (verbose) {
        print('*' * 80);
        print('DeleteOnePostParams');
        print('*' * 80);
        print('QUERY: ${params.query}');
        print('PARAMETERS: ${params.parameters}');
        print('*' * 80);
      }

      final result =
          await _conn.execute(params.query, parameters: params.parameters);

      if (result.isEmpty) {
        return Error(
            SQLException('No data found on table `tb_posts` to delete!'));
      }

      final [
        String $id,
        String? $postId,
        String $content,
        String $userId,
        DateTime $createdAt,
        DateTime $updatedAt,
      ] = result.first as List;

      final entity = PostEntity(
        id: $id,
        postId: $postId,
        content: $content,
        userId: $userId,
        createdAt: $createdAt,
        updatedAt: $updatedAt,
      );

      return Success(entity);
    } on DSQLException catch (e) {
      return Error(e);
    } on Exception catch (e) {
      return Error(SQLException(e.toString()));
    }
  }

  @override
  AsyncResult<List<PostEntity>, DSQLException> deleteMany(
      DeleteManyPostParams params) async {
    try {
      if (verbose) {
        print('*' * 80);
        print('DeleteManyPostParams');
        print('*' * 80);
        print('QUERY: ${params.query}');
        print('PARAMETERS: ${params.parameters}');
        print('*' * 80);
      }

      final result =
          await _conn.execute(params.query, parameters: params.parameters);

      final entities = result.map(
        (row) {
          final [
            String $id,
            String? $postId,
            String $content,
            String $userId,
            DateTime $createdAt,
            DateTime $updatedAt,
          ] = row as List;

          return PostEntity(
            id: $id,
            postId: $postId,
            content: $content,
            userId: $userId,
            createdAt: $createdAt,
            updatedAt: $updatedAt,
          );
        },
      );

      return Success(entities.toList());
    } on DSQLException catch (e) {
      return Error(e);
    } on Exception catch (e) {
      return Error(SQLException(e.toString()));
    }
  }
}

class InsertOnePostParams extends InsertOneParams {
  final String content;
  final String userId;

  const InsertOnePostParams({
    required this.content,
    required this.userId,
  });

  @override
  String get query =>
      'INSERT INTO tb_posts (content, user_id) VALUES (\$1, \$2) RETURNING *;';

  @override
  List get parameters => [content, userId];
}

class InsertManyPostParams extends InsertManyParams {
  final List<InsertManyPostFields> fields;

  const InsertManyPostParams(this.fields);

  @override
  String get query =>
      'INSERT INTO tb_posts (content, user_id)  VALUES ${fields.indexedMap((index, field) => '(${List.generate(field.parameters.length, (i) => '\$${(i + 1) + (index * 2)}').join(', ')})').join(', ')} RETURNING *;';

  @override
  List get parameters => fields.expand((f) => f.parameters).toList();
}

class InsertManyPostFields {
  final String content;
  final String userId;

  const InsertManyPostFields({
    required this.content,
    required this.userId,
  });

  List get parameters => [content, userId];
}

class FindOnePostParams extends FindOneParams {
  final Where? id;
  final Where? postId;
  final Where? content;
  final Where? userId;
  final Where? createdAt;
  final Where? updatedAt;

  const FindOnePostParams({
    this.id,
    this.postId,
    this.content,
    this.userId,
    this.createdAt,
    this.updatedAt,
  });

  @override
  Map<String, Where> get wheres => {
        if (id != null) 'id': id!,
        if (postId != null) 'post_id': postId!,
        if (content != null) 'content': content!,
        if (userId != null) 'user_id': userId!,
        if (createdAt != null) 'created_at': createdAt!,
        if (updatedAt != null) 'updated_at': updatedAt!,
      };

  @override
  String get query {
    if (wheres.isEmpty) {
      throw SQLException('FindOnePostParams must have at least one where!');
    }

    return 'SELECT * FROM tb_posts WHERE ${wheres.entries.indexedMap((i, e) => '${e.key} ${e.value.op} \$${i + 1}').join(' AND ')} LIMIT 1;';
  }

  @override
  List get parameters => wheres.values.map((v) => v.value).toList();
}

class FindManyPostParams extends FindManyParams {
  final Where? id;
  final Where? postId;
  final Where? content;
  final Where? userId;
  final Where? createdAt;
  final Where? updatedAt;
  final int page;
  final int pageSize;
  final OrderBy? orderBy;

  const FindManyPostParams({
    this.id,
    this.postId,
    this.content,
    this.userId,
    this.createdAt,
    this.updatedAt,
    this.page = 1,
    this.pageSize = 20,
    this.orderBy,
  });

  @override
  Map<String, Where> get wheres => {
        if (id != null) 'id': id!,
        if (postId != null) 'post_id': postId!,
        if (content != null) 'content': content!,
        if (userId != null) 'user_id': userId!,
        if (createdAt != null) 'created_at': createdAt!,
        if (updatedAt != null) 'updated_at': updatedAt!,
      };

  @override
  String get query {
    final offsetQuery = switch (page >= 1) {
      true => ' OFFSET ${page - 1}',
      false => ' OFFSET 0',
    };

    final limitQuery = ' LIMIT $pageSize';

    final orderByQuery = switch (orderBy != null) {
      false => '',
      true => ' ORDER BY ${orderBy?.sql}',
    };

    if (wheres.isEmpty) {
      return 'SELECT * FROM tb_posts$orderByQuery$offsetQuery$limitQuery;';
    } else {
      return 'SELECT * FROM tb_posts WHERE ${wheres.entries.indexedMap((i, e) => '${e.key} ${e.value.op} \$${i + 1}').join(' AND ')}$orderByQuery$offsetQuery$limitQuery;';
    }
  }

  @override
  List get parameters => wheres.values.map((v) => v.value).toList();
}

class UpdateOnePostParams extends UpdateOneParams {
  /// PrimaryKey `tb_posts.id`
  final Where? whereId;
  final String? postId;
  final String? content;
  final String? userId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const UpdateOnePostParams({
    this.whereId,
    this.postId,
    this.content,
    this.userId,
    this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> get values => {
        if (postId != null) 'post_id': postId,
        if (content != null) 'content': content,
        if (userId != null) 'user_id': userId,
        if (createdAt != null) 'created_at': createdAt,
        if (updatedAt != null) 'updated_at': updatedAt
      };

  @override
  Map<String, Where> get wheres => {
        if (whereId != null) 'id': whereId!,
      };

  @override
  String get query {
    if (wheres.isEmpty) {
      throw SQLException('UpdateOnePostParams cannot be conditionless!');
    }

    if (wheres.length > 1) {
      throw SQLException('UpdateOnePostParams must have only one where!');
    }

    if (values.isEmpty) {
      throw SQLException('UpdateOnePostParams must have at least one value!');
    }

    return 'UPDATE tb_posts SET ${values.entries.indexedMap((index, entry) => '${entry.key} = \$${index + 1}').join(', ')} WHERE ${wheres.entries.indexedMap((index, entry) => '${entry.key} ${entry.value.op} \$${index + 1 + values.length}').join(' AND ')} RETURNING *;';
  }

  @override
  List get parameters => [
        ...values.values,
        ...wheres.values.map((v) => v.value),
      ];
}

class UpdateManyPostParams extends UpdateManyParams {
  final Where? whereId;
  final Where? wherePostId;
  final Where? whereContent;
  final Where? whereUserId;
  final Where? whereCreatedAt;
  final Where? whereUpdatedAt;
  final String? postId;
  final String? content;
  final String? userId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const UpdateManyPostParams({
    this.whereId,
    this.wherePostId,
    this.whereContent,
    this.whereUserId,
    this.whereCreatedAt,
    this.whereUpdatedAt,
    this.postId,
    this.content,
    this.userId,
    this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> get values => {
        if (postId != null) 'post_id': postId,
        if (content != null) 'content': content,
        if (userId != null) 'user_id': userId,
        if (createdAt != null) 'created_at': createdAt,
        if (updatedAt != null) 'updated_at': updatedAt
      };

  @override
  Map<String, Where> get wheres => {
        if (whereId != null) 'id': whereId!,
        if (wherePostId != null) 'post_id': wherePostId!,
        if (whereContent != null) 'content': whereContent!,
        if (whereUserId != null) 'user_id': whereUserId!,
        if (whereCreatedAt != null) 'created_at': whereCreatedAt!,
        if (whereUpdatedAt != null) 'updated_at': whereUpdatedAt!,
      };

  @override
  String get query {
    if (values.isEmpty) {
      throw SQLException('UpdateManyPostParams must have at least one value!');
    }

    return 'UPDATE tb_posts SET ${values.entries.indexedMap((index, entry) => '${entry.key} = \$${index + 1}').join(', ')}${wheres.isEmpty ? '' : ' WHERE ${wheres.entries.indexedMap((innerIndex, innerEntry) => '${innerEntry.key} ${innerEntry.value.op} \$${innerIndex + 1 + values.length}').join(' AND ')}'} RETURNING *;';
  }

  @override
  List get parameters => [
        ...values.values,
        ...wheres.values.map((v) => v.value),
      ];
}

class DeleteOnePostParams extends DeleteOneParams {
  /// PrimaryKey `tb_posts.id`
  final Where? whereId;

  const DeleteOnePostParams({
    this.whereId,
  });

  @override
  Map<String, Where> get wheres => {
        if (whereId != null) 'id': whereId!,
      };

  @override
  String get query {
    if (wheres.isEmpty) {
      throw SQLException('DeleteOnePostParams cannot be conditionless!');
    }

    if (wheres.length > 1) {
      throw SQLException('DeleteOnePostParams can only have one condition!');
    }

    return 'DELETE FROM tb_posts WHERE ${wheres.entries.indexedMap((index, entry) => '${entry.key} ${entry.value.op} \$${index + 1}').join(' AND ')} RETURNING *;';
  }

  @override
  List get parameters => wheres.values.map((v) => v.value).toList();
}

class DeleteManyPostParams extends DeleteManyParams {
  /// PrimaryKey `tb_posts.id`
  final Where? whereId;

  /// UniqueKey `tb_posts.post_id`
  final Where? wherePostId;

  /// UniqueKey `tb_posts.content`
  final Where? whereContent;

  /// UniqueKey `tb_posts.user_id`
  final Where? whereUserId;

  /// UniqueKey `tb_posts.created_at`
  final Where? whereCreatedAt;

  /// UniqueKey `tb_posts.updated_at`
  final Where? whereUpdatedAt;
  final String? id;

  const DeleteManyPostParams({
    this.whereId,
    this.wherePostId,
    this.whereContent,
    this.whereUserId,
    this.whereCreatedAt,
    this.whereUpdatedAt,
    this.id,
  });

  @override
  Map<String, Where> get wheres => {
        if (whereId != null) 'id': whereId!,
        if (wherePostId != null) 'post_id': wherePostId!,
        if (whereContent != null) 'content': whereContent!,
        if (whereUserId != null) 'user_id': whereUserId!,
        if (whereCreatedAt != null) 'created_at': whereCreatedAt!,
        if (whereUpdatedAt != null) 'updated_at': whereUpdatedAt!,
      };

  @override
  String get query {
    if (wheres.isEmpty) {
      throw SQLException('DeleteManyPostParams cannot be conditionless!');
    }

    return 'DELETE FROM tb_posts WHERE ${wheres.entries.indexedMap((index, entry) => '${entry.key} ${entry.value.op} \$${index + 1}').join(' AND ')} RETURNING *;';
  }

  @override
  List get parameters => wheres.values.map((v) => v.value).toList();
}

class LikesRepository extends Repository<
    LikeEntity,
    InsertOneLikeParams,
    InsertManyLikeParams,
    FindOneLikeParams,
    FindManyLikeParams,
    UpdateOneLikeParams,
    UpdateManyLikeParams,
    DeleteOneLikeParams,
    DeleteManyLikeParams> {
  final Connection _conn;
  final bool verbose;

  const LikesRepository(this._conn, {this.verbose = false});

  @override
  AsyncResult<LikeEntity, DSQLException> insertOne(
      InsertOneLikeParams params) async {
    try {
      if (verbose) {
        print('*' * 80);
        print('InsertOneLikeParams');
        print('*' * 80);
        print('QUERY: ${params.query}');
        print('PARAMETERS: ${params.parameters}');
        print('*' * 80);
      }

      final result =
          await _conn.execute(params.query, parameters: params.parameters);

      if (result.isEmpty) {
        return Error(SQLException('Fail to insert data on table `tb_likes`!'));
      }

      final [
        String $id,
        String $postId,
        String $userId,
        DateTime $createdAt,
      ] = result.first as List;

      final entity = LikeEntity(
        id: $id,
        postId: $postId,
        userId: $userId,
        createdAt: $createdAt,
      );

      return Success(entity);
    } on Exception catch (e) {
      return Error(SQLException(e.toString()));
    }
  }

  @override
  AsyncResult<List<LikeEntity>, DSQLException> insertMany(
      InsertManyLikeParams params) async {
    try {
      if (verbose) {
        print('*' * 80);
        print('InsertManyLikeParams');
        print('*' * 80);
        print('QUERY: ${params.query}');
        print('PARAMETERS: ${params.parameters}');
        print('*' * 80);
      }

      final result =
          await _conn.execute(params.query, parameters: params.parameters);

      if (result.isEmpty) {
        return Error(SQLException('Fail to insert data on table `tb_likes`!'));
      }

      final entities = result.map(
        (row) {
          final [
            String $id,
            String $postId,
            String $userId,
            DateTime $createdAt,
          ] = row as List;

          return LikeEntity(
            id: $id,
            postId: $postId,
            userId: $userId,
            createdAt: $createdAt,
          );
        },
      );

      return Success(entities.toList());
    } on Exception catch (e) {
      return Error(SQLException(e.toString()));
    }
  }

  @override
  AsyncResult<LikeEntity, DSQLException> findOne(
      FindOneLikeParams params) async {
    try {
      if (verbose) {
        print('*' * 80);
        print('FindOneLikeParams');
        print('*' * 80);
        print('QUERY: ${params.query}');
        print('PARAMETERS: ${params.parameters}');
        print('*' * 80);
      }

      final result =
          await _conn.execute(params.query, parameters: params.parameters);

      if (result.isEmpty) {
        return Error(SQLException('No data found on table `tb_likes`!'));
      }

      final [
        String $id,
        String $postId,
        String $userId,
        DateTime $createdAt,
      ] = result.first as List;

      final entity = LikeEntity(
        id: $id,
        postId: $postId,
        userId: $userId,
        createdAt: $createdAt,
      );

      return Success(entity);
    } on DSQLException catch (e) {
      return Error(e);
    } on Exception catch (e) {
      return Error(SQLException(e.toString()));
    }
  }

  @override
  AsyncResult<List<LikeEntity>, DSQLException> findMany(
      [FindManyLikeParams params = const FindManyLikeParams()]) async {
    try {
      if (verbose) {
        print('*' * 80);
        print('FindManyLikeParams');
        print('*' * 80);
        print('QUERY: ${params.query}');
        print('PARAMETERS: ${params.parameters}');
        print('*' * 80);
      }

      final result =
          await _conn.execute(params.query, parameters: params.parameters);

      final entities = result.map(
        (row) {
          final [
            String $id,
            String $postId,
            String $userId,
            DateTime $createdAt,
          ] = row as List;

          return LikeEntity(
            id: $id,
            postId: $postId,
            userId: $userId,
            createdAt: $createdAt,
          );
        },
      );

      return Success(entities.toList());
    } on Exception catch (e) {
      return Error(SQLException(e.toString()));
    }
  }

  @override
  AsyncResult<Page<LikeEntity>, DSQLException> findManyPaginated(
      [FindManyLikeParams params = const FindManyLikeParams()]) async {
    throw UnimplementedError();
  }

  @override
  AsyncResult<LikeEntity, DSQLException> updateOne(
      UpdateOneLikeParams params) async {
    try {
      if (verbose) {
        print('*' * 80);
        print('UpdateOneLikeParams');
        print('*' * 80);
        print('QUERY: ${params.query}');
        print('PARAMETERS: ${params.parameters}');
        print('*' * 80);
      }

      final result =
          await _conn.execute(params.query, parameters: params.parameters);

      if (result.isEmpty) {
        return Error(
            SQLException('No data found on table `tb_likes` to update!'));
      }

      final [
        String $id,
        String $postId,
        String $userId,
        DateTime $createdAt,
      ] = result.first as List;

      final entity = LikeEntity(
        id: $id,
        postId: $postId,
        userId: $userId,
        createdAt: $createdAt,
      );

      return Success(entity);
    } on DSQLException catch (e) {
      return Error(e);
    } on Exception catch (e) {
      return Error(SQLException(e.toString()));
    }
  }

  @override
  AsyncResult<List<LikeEntity>, DSQLException> updateMany(
      UpdateManyLikeParams params) async {
    try {
      if (verbose) {
        print('*' * 80);
        print('UpdateManyLikeParams');
        print('*' * 80);
        print('QUERY: ${params.query}');
        print('PARAMETERS: ${params.parameters}');
        print('*' * 80);
      }

      final result =
          await _conn.execute(params.query, parameters: params.parameters);

      final entities = result.map(
        (row) {
          final [
            String $id,
            String $postId,
            String $userId,
            DateTime $createdAt,
          ] = row as List;

          return LikeEntity(
            id: $id,
            postId: $postId,
            userId: $userId,
            createdAt: $createdAt,
          );
        },
      );

      return Success(entities.toList());
    } on DSQLException catch (e) {
      return Error(e);
    } on Exception catch (e) {
      return Error(SQLException(e.toString()));
    }
  }

  @override
  AsyncResult<LikeEntity, DSQLException> deleteOne(
      DeleteOneLikeParams params) async {
    try {
      if (verbose) {
        print('*' * 80);
        print('DeleteOneLikeParams');
        print('*' * 80);
        print('QUERY: ${params.query}');
        print('PARAMETERS: ${params.parameters}');
        print('*' * 80);
      }

      final result =
          await _conn.execute(params.query, parameters: params.parameters);

      if (result.isEmpty) {
        return Error(
            SQLException('No data found on table `tb_likes` to delete!'));
      }

      final [
        String $id,
        String $postId,
        String $userId,
        DateTime $createdAt,
      ] = result.first as List;

      final entity = LikeEntity(
        id: $id,
        postId: $postId,
        userId: $userId,
        createdAt: $createdAt,
      );

      return Success(entity);
    } on DSQLException catch (e) {
      return Error(e);
    } on Exception catch (e) {
      return Error(SQLException(e.toString()));
    }
  }

  @override
  AsyncResult<List<LikeEntity>, DSQLException> deleteMany(
      DeleteManyLikeParams params) async {
    try {
      if (verbose) {
        print('*' * 80);
        print('DeleteManyLikeParams');
        print('*' * 80);
        print('QUERY: ${params.query}');
        print('PARAMETERS: ${params.parameters}');
        print('*' * 80);
      }

      final result =
          await _conn.execute(params.query, parameters: params.parameters);

      final entities = result.map(
        (row) {
          final [
            String $id,
            String $postId,
            String $userId,
            DateTime $createdAt,
          ] = row as List;

          return LikeEntity(
            id: $id,
            postId: $postId,
            userId: $userId,
            createdAt: $createdAt,
          );
        },
      );

      return Success(entities.toList());
    } on DSQLException catch (e) {
      return Error(e);
    } on Exception catch (e) {
      return Error(SQLException(e.toString()));
    }
  }
}

class InsertOneLikeParams extends InsertOneParams {
  final String postId;
  final String userId;

  const InsertOneLikeParams({
    required this.postId,
    required this.userId,
  });

  @override
  String get query =>
      'INSERT INTO tb_likes (post_id, user_id) VALUES (\$1, \$2) RETURNING *;';

  @override
  List get parameters => [postId, userId];
}

class InsertManyLikeParams extends InsertManyParams {
  final List<InsertManyLikeFields> fields;

  const InsertManyLikeParams(this.fields);

  @override
  String get query =>
      'INSERT INTO tb_likes (post_id, user_id)  VALUES ${fields.indexedMap((index, field) => '(${List.generate(field.parameters.length, (i) => '\$${(i + 1) + (index * 2)}').join(', ')})').join(', ')} RETURNING *;';

  @override
  List get parameters => fields.expand((f) => f.parameters).toList();
}

class InsertManyLikeFields {
  final String postId;
  final String userId;

  const InsertManyLikeFields({
    required this.postId,
    required this.userId,
  });

  List get parameters => [postId, userId];
}

class FindOneLikeParams extends FindOneParams {
  final Where? id;
  final Where? postId;
  final Where? userId;
  final Where? createdAt;

  const FindOneLikeParams({
    this.id,
    this.postId,
    this.userId,
    this.createdAt,
  });

  @override
  Map<String, Where> get wheres => {
        if (id != null) 'id': id!,
        if (postId != null) 'post_id': postId!,
        if (userId != null) 'user_id': userId!,
        if (createdAt != null) 'created_at': createdAt!,
      };

  @override
  String get query {
    if (wheres.isEmpty) {
      throw SQLException('FindOneLikeParams must have at least one where!');
    }

    return 'SELECT * FROM tb_likes WHERE ${wheres.entries.indexedMap((i, e) => '${e.key} ${e.value.op} \$${i + 1}').join(' AND ')} LIMIT 1;';
  }

  @override
  List get parameters => wheres.values.map((v) => v.value).toList();
}

class FindManyLikeParams extends FindManyParams {
  final Where? id;
  final Where? postId;
  final Where? userId;
  final Where? createdAt;
  final int page;
  final int pageSize;
  final OrderBy? orderBy;

  const FindManyLikeParams({
    this.id,
    this.postId,
    this.userId,
    this.createdAt,
    this.page = 1,
    this.pageSize = 20,
    this.orderBy,
  });

  @override
  Map<String, Where> get wheres => {
        if (id != null) 'id': id!,
        if (postId != null) 'post_id': postId!,
        if (userId != null) 'user_id': userId!,
        if (createdAt != null) 'created_at': createdAt!,
      };

  @override
  String get query {
    final offsetQuery = switch (page >= 1) {
      true => ' OFFSET ${page - 1}',
      false => ' OFFSET 0',
    };

    final limitQuery = ' LIMIT $pageSize';

    final orderByQuery = switch (orderBy != null) {
      false => '',
      true => ' ORDER BY ${orderBy?.sql}',
    };

    if (wheres.isEmpty) {
      return 'SELECT * FROM tb_likes$orderByQuery$offsetQuery$limitQuery;';
    } else {
      return 'SELECT * FROM tb_likes WHERE ${wheres.entries.indexedMap((i, e) => '${e.key} ${e.value.op} \$${i + 1}').join(' AND ')}$orderByQuery$offsetQuery$limitQuery;';
    }
  }

  @override
  List get parameters => wheres.values.map((v) => v.value).toList();
}

class UpdateOneLikeParams extends UpdateOneParams {
  /// PrimaryKey `tb_likes.id`
  final Where? whereId;
  final String? postId;
  final String? userId;
  final DateTime? createdAt;

  const UpdateOneLikeParams({
    this.whereId,
    this.postId,
    this.userId,
    this.createdAt,
  });

  Map<String, dynamic> get values => {
        if (postId != null) 'post_id': postId,
        if (userId != null) 'user_id': userId,
        if (createdAt != null) 'created_at': createdAt
      };

  @override
  Map<String, Where> get wheres => {
        if (whereId != null) 'id': whereId!,
      };

  @override
  String get query {
    if (wheres.isEmpty) {
      throw SQLException('UpdateOneLikeParams cannot be conditionless!');
    }

    if (wheres.length > 1) {
      throw SQLException('UpdateOneLikeParams must have only one where!');
    }

    if (values.isEmpty) {
      throw SQLException('UpdateOneLikeParams must have at least one value!');
    }

    return 'UPDATE tb_likes SET ${values.entries.indexedMap((index, entry) => '${entry.key} = \$${index + 1}').join(', ')} WHERE ${wheres.entries.indexedMap((index, entry) => '${entry.key} ${entry.value.op} \$${index + 1 + values.length}').join(' AND ')} RETURNING *;';
  }

  @override
  List get parameters => [
        ...values.values,
        ...wheres.values.map((v) => v.value),
      ];
}

class UpdateManyLikeParams extends UpdateManyParams {
  final Where? whereId;
  final Where? wherePostId;
  final Where? whereUserId;
  final Where? whereCreatedAt;
  final String? postId;
  final String? userId;
  final DateTime? createdAt;

  const UpdateManyLikeParams({
    this.whereId,
    this.wherePostId,
    this.whereUserId,
    this.whereCreatedAt,
    this.postId,
    this.userId,
    this.createdAt,
  });

  Map<String, dynamic> get values => {
        if (postId != null) 'post_id': postId,
        if (userId != null) 'user_id': userId,
        if (createdAt != null) 'created_at': createdAt
      };

  @override
  Map<String, Where> get wheres => {
        if (whereId != null) 'id': whereId!,
        if (wherePostId != null) 'post_id': wherePostId!,
        if (whereUserId != null) 'user_id': whereUserId!,
        if (whereCreatedAt != null) 'created_at': whereCreatedAt!,
      };

  @override
  String get query {
    if (values.isEmpty) {
      throw SQLException('UpdateManyLikeParams must have at least one value!');
    }

    return 'UPDATE tb_likes SET ${values.entries.indexedMap((index, entry) => '${entry.key} = \$${index + 1}').join(', ')}${wheres.isEmpty ? '' : ' WHERE ${wheres.entries.indexedMap((innerIndex, innerEntry) => '${innerEntry.key} ${innerEntry.value.op} \$${innerIndex + 1 + values.length}').join(' AND ')}'} RETURNING *;';
  }

  @override
  List get parameters => [
        ...values.values,
        ...wheres.values.map((v) => v.value),
      ];
}

class DeleteOneLikeParams extends DeleteOneParams {
  /// PrimaryKey `tb_likes.id`
  final Where? whereId;

  const DeleteOneLikeParams({
    this.whereId,
  });

  @override
  Map<String, Where> get wheres => {
        if (whereId != null) 'id': whereId!,
      };

  @override
  String get query {
    if (wheres.isEmpty) {
      throw SQLException('DeleteOneLikeParams cannot be conditionless!');
    }

    if (wheres.length > 1) {
      throw SQLException('DeleteOneLikeParams can only have one condition!');
    }

    return 'DELETE FROM tb_likes WHERE ${wheres.entries.indexedMap((index, entry) => '${entry.key} ${entry.value.op} \$${index + 1}').join(' AND ')} RETURNING *;';
  }

  @override
  List get parameters => wheres.values.map((v) => v.value).toList();
}

class DeleteManyLikeParams extends DeleteManyParams {
  /// PrimaryKey `tb_likes.id`
  final Where? whereId;

  /// UniqueKey `tb_likes.post_id`
  final Where? wherePostId;

  /// UniqueKey `tb_likes.user_id`
  final Where? whereUserId;

  /// UniqueKey `tb_likes.created_at`
  final Where? whereCreatedAt;
  final String? id;

  const DeleteManyLikeParams({
    this.whereId,
    this.wherePostId,
    this.whereUserId,
    this.whereCreatedAt,
    this.id,
  });

  @override
  Map<String, Where> get wheres => {
        if (whereId != null) 'id': whereId!,
        if (wherePostId != null) 'post_id': wherePostId!,
        if (whereUserId != null) 'user_id': whereUserId!,
        if (whereCreatedAt != null) 'created_at': whereCreatedAt!,
      };

  @override
  String get query {
    if (wheres.isEmpty) {
      throw SQLException('DeleteManyLikeParams cannot be conditionless!');
    }

    return 'DELETE FROM tb_likes WHERE ${wheres.entries.indexedMap((index, entry) => '${entry.key} ${entry.value.op} \$${index + 1}').join(' AND ')} RETURNING *;';
  }

  @override
  List get parameters => wheres.values.map((v) => v.value).toList();
}

class FollowersRepository extends Repository<
    FollowerEntity,
    InsertOneFollowerParams,
    InsertManyFollowerParams,
    FindOneFollowerParams,
    FindManyFollowerParams,
    UpdateOneFollowerParams,
    UpdateManyFollowerParams,
    DeleteOneFollowerParams,
    DeleteManyFollowerParams> {
  final Connection _conn;
  final bool verbose;

  const FollowersRepository(this._conn, {this.verbose = false});

  @override
  AsyncResult<FollowerEntity, DSQLException> insertOne(
      InsertOneFollowerParams params) async {
    try {
      if (verbose) {
        print('*' * 80);
        print('InsertOneFollowerParams');
        print('*' * 80);
        print('QUERY: ${params.query}');
        print('PARAMETERS: ${params.parameters}');
        print('*' * 80);
      }

      final result =
          await _conn.execute(params.query, parameters: params.parameters);

      if (result.isEmpty) {
        return Error(
            SQLException('Fail to insert data on table `tb_followers`!'));
      }

      final [
        String $followerId,
        String $followingId,
        DateTime $createdAt,
      ] = result.first as List;

      final entity = FollowerEntity(
        followerId: $followerId,
        followingId: $followingId,
        createdAt: $createdAt,
      );

      return Success(entity);
    } on Exception catch (e) {
      return Error(SQLException(e.toString()));
    }
  }

  @override
  AsyncResult<List<FollowerEntity>, DSQLException> insertMany(
      InsertManyFollowerParams params) async {
    try {
      if (verbose) {
        print('*' * 80);
        print('InsertManyFollowerParams');
        print('*' * 80);
        print('QUERY: ${params.query}');
        print('PARAMETERS: ${params.parameters}');
        print('*' * 80);
      }

      final result =
          await _conn.execute(params.query, parameters: params.parameters);

      if (result.isEmpty) {
        return Error(
            SQLException('Fail to insert data on table `tb_followers`!'));
      }

      final entities = result.map(
        (row) {
          final [
            String $followerId,
            String $followingId,
            DateTime $createdAt,
          ] = row as List;

          return FollowerEntity(
            followerId: $followerId,
            followingId: $followingId,
            createdAt: $createdAt,
          );
        },
      );

      return Success(entities.toList());
    } on Exception catch (e) {
      return Error(SQLException(e.toString()));
    }
  }

  @override
  AsyncResult<FollowerEntity, DSQLException> findOne(
      FindOneFollowerParams params) async {
    try {
      if (verbose) {
        print('*' * 80);
        print('FindOneFollowerParams');
        print('*' * 80);
        print('QUERY: ${params.query}');
        print('PARAMETERS: ${params.parameters}');
        print('*' * 80);
      }

      final result =
          await _conn.execute(params.query, parameters: params.parameters);

      if (result.isEmpty) {
        return Error(SQLException('No data found on table `tb_followers`!'));
      }

      final [
        String $followerId,
        String $followingId,
        DateTime $createdAt,
      ] = result.first as List;

      final entity = FollowerEntity(
        followerId: $followerId,
        followingId: $followingId,
        createdAt: $createdAt,
      );

      return Success(entity);
    } on DSQLException catch (e) {
      return Error(e);
    } on Exception catch (e) {
      return Error(SQLException(e.toString()));
    }
  }

  @override
  AsyncResult<List<FollowerEntity>, DSQLException> findMany(
      [FindManyFollowerParams params = const FindManyFollowerParams()]) async {
    try {
      if (verbose) {
        print('*' * 80);
        print('FindManyFollowerParams');
        print('*' * 80);
        print('QUERY: ${params.query}');
        print('PARAMETERS: ${params.parameters}');
        print('*' * 80);
      }

      final result =
          await _conn.execute(params.query, parameters: params.parameters);

      final entities = result.map(
        (row) {
          final [
            String $followerId,
            String $followingId,
            DateTime $createdAt,
          ] = row as List;

          return FollowerEntity(
            followerId: $followerId,
            followingId: $followingId,
            createdAt: $createdAt,
          );
        },
      );

      return Success(entities.toList());
    } on Exception catch (e) {
      return Error(SQLException(e.toString()));
    }
  }

  @override
  AsyncResult<Page<FollowerEntity>, DSQLException> findManyPaginated(
      [FindManyFollowerParams params = const FindManyFollowerParams()]) async {
    throw UnimplementedError();
  }

  @override
  AsyncResult<FollowerEntity, DSQLException> updateOne(
      UpdateOneFollowerParams params) async {
    try {
      if (verbose) {
        print('*' * 80);
        print('UpdateOneFollowerParams');
        print('*' * 80);
        print('QUERY: ${params.query}');
        print('PARAMETERS: ${params.parameters}');
        print('*' * 80);
      }

      final result =
          await _conn.execute(params.query, parameters: params.parameters);

      if (result.isEmpty) {
        return Error(
            SQLException('No data found on table `tb_followers` to update!'));
      }

      final [
        String $followerId,
        String $followingId,
        DateTime $createdAt,
      ] = result.first as List;

      final entity = FollowerEntity(
        followerId: $followerId,
        followingId: $followingId,
        createdAt: $createdAt,
      );

      return Success(entity);
    } on DSQLException catch (e) {
      return Error(e);
    } on Exception catch (e) {
      return Error(SQLException(e.toString()));
    }
  }

  @override
  AsyncResult<List<FollowerEntity>, DSQLException> updateMany(
      UpdateManyFollowerParams params) async {
    try {
      if (verbose) {
        print('*' * 80);
        print('UpdateManyFollowerParams');
        print('*' * 80);
        print('QUERY: ${params.query}');
        print('PARAMETERS: ${params.parameters}');
        print('*' * 80);
      }

      final result =
          await _conn.execute(params.query, parameters: params.parameters);

      final entities = result.map(
        (row) {
          final [
            String $followerId,
            String $followingId,
            DateTime $createdAt,
          ] = row as List;

          return FollowerEntity(
            followerId: $followerId,
            followingId: $followingId,
            createdAt: $createdAt,
          );
        },
      );

      return Success(entities.toList());
    } on DSQLException catch (e) {
      return Error(e);
    } on Exception catch (e) {
      return Error(SQLException(e.toString()));
    }
  }

  @override
  AsyncResult<FollowerEntity, DSQLException> deleteOne(
      DeleteOneFollowerParams params) async {
    try {
      if (verbose) {
        print('*' * 80);
        print('DeleteOneFollowerParams');
        print('*' * 80);
        print('QUERY: ${params.query}');
        print('PARAMETERS: ${params.parameters}');
        print('*' * 80);
      }

      final result =
          await _conn.execute(params.query, parameters: params.parameters);

      if (result.isEmpty) {
        return Error(
            SQLException('No data found on table `tb_followers` to delete!'));
      }

      final [
        String $followerId,
        String $followingId,
        DateTime $createdAt,
      ] = result.first as List;

      final entity = FollowerEntity(
        followerId: $followerId,
        followingId: $followingId,
        createdAt: $createdAt,
      );

      return Success(entity);
    } on DSQLException catch (e) {
      return Error(e);
    } on Exception catch (e) {
      return Error(SQLException(e.toString()));
    }
  }

  @override
  AsyncResult<List<FollowerEntity>, DSQLException> deleteMany(
      DeleteManyFollowerParams params) async {
    try {
      if (verbose) {
        print('*' * 80);
        print('DeleteManyFollowerParams');
        print('*' * 80);
        print('QUERY: ${params.query}');
        print('PARAMETERS: ${params.parameters}');
        print('*' * 80);
      }

      final result =
          await _conn.execute(params.query, parameters: params.parameters);

      final entities = result.map(
        (row) {
          final [
            String $followerId,
            String $followingId,
            DateTime $createdAt,
          ] = row as List;

          return FollowerEntity(
            followerId: $followerId,
            followingId: $followingId,
            createdAt: $createdAt,
          );
        },
      );

      return Success(entities.toList());
    } on DSQLException catch (e) {
      return Error(e);
    } on Exception catch (e) {
      return Error(SQLException(e.toString()));
    }
  }
}

class InsertOneFollowerParams extends InsertOneParams {
  final String followerId;
  final String followingId;

  const InsertOneFollowerParams({
    required this.followerId,
    required this.followingId,
  });

  @override
  String get query =>
      'INSERT INTO tb_followers (follower_id, following_id) VALUES (\$1, \$2) RETURNING *;';

  @override
  List get parameters => [followerId, followingId];
}

class InsertManyFollowerParams extends InsertManyParams {
  final List<InsertManyFollowerFields> fields;

  const InsertManyFollowerParams(this.fields);

  @override
  String get query =>
      'INSERT INTO tb_followers (follower_id, following_id)  VALUES ${fields.indexedMap((index, field) => '(${List.generate(field.parameters.length, (i) => '\$${(i + 1) + (index * 2)}').join(', ')})').join(', ')} RETURNING *;';

  @override
  List get parameters => fields.expand((f) => f.parameters).toList();
}

class InsertManyFollowerFields {
  final String followerId;
  final String followingId;

  const InsertManyFollowerFields({
    required this.followerId,
    required this.followingId,
  });

  List get parameters => [followerId, followingId];
}

class FindOneFollowerParams extends FindOneParams {
  final Where? followerId;
  final Where? followingId;
  final Where? createdAt;

  const FindOneFollowerParams({
    this.followerId,
    this.followingId,
    this.createdAt,
  });

  @override
  Map<String, Where> get wheres => {
        if (followerId != null) 'follower_id': followerId!,
        if (followingId != null) 'following_id': followingId!,
        if (createdAt != null) 'created_at': createdAt!,
      };

  @override
  String get query {
    if (wheres.isEmpty) {
      throw SQLException('FindOneFollowerParams must have at least one where!');
    }

    return 'SELECT * FROM tb_followers WHERE ${wheres.entries.indexedMap((i, e) => '${e.key} ${e.value.op} \$${i + 1}').join(' AND ')} LIMIT 1;';
  }

  @override
  List get parameters => wheres.values.map((v) => v.value).toList();
}

class FindManyFollowerParams extends FindManyParams {
  final Where? followerId;
  final Where? followingId;
  final Where? createdAt;
  final int page;
  final int pageSize;
  final OrderBy? orderBy;

  const FindManyFollowerParams({
    this.followerId,
    this.followingId,
    this.createdAt,
    this.page = 1,
    this.pageSize = 20,
    this.orderBy,
  });

  @override
  Map<String, Where> get wheres => {
        if (followerId != null) 'follower_id': followerId!,
        if (followingId != null) 'following_id': followingId!,
        if (createdAt != null) 'created_at': createdAt!,
      };

  @override
  String get query {
    final offsetQuery = switch (page >= 1) {
      true => ' OFFSET ${page - 1}',
      false => ' OFFSET 0',
    };

    final limitQuery = ' LIMIT $pageSize';

    final orderByQuery = switch (orderBy != null) {
      false => '',
      true => ' ORDER BY ${orderBy?.sql}',
    };

    if (wheres.isEmpty) {
      return 'SELECT * FROM tb_followers$orderByQuery$offsetQuery$limitQuery;';
    } else {
      return 'SELECT * FROM tb_followers WHERE ${wheres.entries.indexedMap((i, e) => '${e.key} ${e.value.op} \$${i + 1}').join(' AND ')}$orderByQuery$offsetQuery$limitQuery;';
    }
  }

  @override
  List get parameters => wheres.values.map((v) => v.value).toList();
}

class UpdateOneFollowerParams extends UpdateOneParams {
  const UpdateOneFollowerParams();

  @override
  Map<String, Where> get wheres => throw UnimplementedError();

  @override
  String get query => throw UnimplementedError();

  @override
  List get parameters => throw UnimplementedError();
}

class UpdateManyFollowerParams extends UpdateManyParams {
  final Where? whereFollowerId;
  final Where? whereFollowingId;
  final Where? whereCreatedAt;
  final String? followerId;
  final String? followingId;
  final DateTime? createdAt;

  const UpdateManyFollowerParams({
    this.whereFollowerId,
    this.whereFollowingId,
    this.whereCreatedAt,
    this.followerId,
    this.followingId,
    this.createdAt,
  });

  Map<String, dynamic> get values => {
        if (followerId != null) 'follower_id': followerId,
        if (followingId != null) 'following_id': followingId,
        if (createdAt != null) 'created_at': createdAt
      };

  @override
  Map<String, Where> get wheres => {
        if (whereFollowerId != null) 'follower_id': whereFollowerId!,
        if (whereFollowingId != null) 'following_id': whereFollowingId!,
        if (whereCreatedAt != null) 'created_at': whereCreatedAt!,
      };

  @override
  String get query {
    if (values.isEmpty) {
      throw SQLException(
          'UpdateManyFollowerParams must have at least one value!');
    }

    return 'UPDATE tb_followers SET ${values.entries.indexedMap((index, entry) => '${entry.key} = \$${index + 1}').join(', ')}${wheres.isEmpty ? '' : ' WHERE ${wheres.entries.indexedMap((innerIndex, innerEntry) => '${innerEntry.key} ${innerEntry.value.op} \$${innerIndex + 1 + values.length}').join(' AND ')}'} RETURNING *;';
  }

  @override
  List get parameters => [
        ...values.values,
        ...wheres.values.map((v) => v.value),
      ];
}

class DeleteOneFollowerParams extends DeleteOneParams {
  const DeleteOneFollowerParams();

  @override
  Map<String, Where> get wheres => throw UnimplementedError();

  @override
  String get query => throw UnimplementedError();

  @override
  List get parameters => throw UnimplementedError();
}

class DeleteManyFollowerParams extends DeleteManyParams {
  /// UniqueKey `tb_followers.follower_id`
  final Where? whereFollowerId;

  /// UniqueKey `tb_followers.following_id`
  final Where? whereFollowingId;

  /// UniqueKey `tb_followers.created_at`
  final Where? whereCreatedAt;

  const DeleteManyFollowerParams({
    this.whereFollowerId,
    this.whereFollowingId,
    this.whereCreatedAt,
  });

  @override
  Map<String, Where> get wheres => {
        if (whereFollowerId != null) 'follower_id': whereFollowerId!,
        if (whereFollowingId != null) 'following_id': whereFollowingId!,
        if (whereCreatedAt != null) 'created_at': whereCreatedAt!,
      };

  @override
  String get query {
    if (wheres.isEmpty) {
      throw SQLException('DeleteManyFollowerParams cannot be conditionless!');
    }

    return 'DELETE FROM tb_followers WHERE ${wheres.entries.indexedMap((index, entry) => '${entry.key} ${entry.value.op} \$${index + 1}').join(' AND ')} RETURNING *;';
  }

  @override
  List get parameters => wheres.values.map((v) => v.value).toList();
}
