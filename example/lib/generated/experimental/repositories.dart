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
    throw UnimplementedError();
  }

  @override
  AsyncResult<Page<UserEntity>, DSQLException> findManyPaginated(
      [FindManyUserParams params = const FindManyUserParams()]) async {
    throw UnimplementedError();
  }

  @override
  AsyncResult<UserEntity, DSQLException> updateOne(
      UpdateOneUserParams params) async {
    throw UnimplementedError();
  }

  @override
  AsyncResult<List<UserEntity>, DSQLException> updateMany(
      UpdateManyUserParams params) async {
    throw UnimplementedError();
  }

  @override
  AsyncResult<UserEntity, DSQLException> deleteOne(
      DeleteOneUserParams params) async {
    throw UnimplementedError();
  }

  @override
  AsyncResult<List<UserEntity>, DSQLException> deleteMany(
      DeleteManyUserParams params) async {
    throw UnimplementedError();
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
  const FindManyUserParams();

  @override
  Map<String, Where> get wheres => throw UnimplementedError();
}

class UpdateOneUserParams extends UpdateOneParams {
  const UpdateOneUserParams();
}

class UpdateManyUserParams extends UpdateManyParams {
  const UpdateManyUserParams();
}

class DeleteOneUserParams extends DeleteOneParams {
  const DeleteOneUserParams();
}

class DeleteManyUserParams extends DeleteManyParams {
  const DeleteManyUserParams();
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
    throw UnimplementedError();
  }

  @override
  AsyncResult<Page<PostEntity>, DSQLException> findManyPaginated(
      [FindManyPostParams params = const FindManyPostParams()]) async {
    throw UnimplementedError();
  }

  @override
  AsyncResult<PostEntity, DSQLException> updateOne(
      UpdateOnePostParams params) async {
    throw UnimplementedError();
  }

  @override
  AsyncResult<List<PostEntity>, DSQLException> updateMany(
      UpdateManyPostParams params) async {
    throw UnimplementedError();
  }

  @override
  AsyncResult<PostEntity, DSQLException> deleteOne(
      DeleteOnePostParams params) async {
    throw UnimplementedError();
  }

  @override
  AsyncResult<List<PostEntity>, DSQLException> deleteMany(
      DeleteManyPostParams params) async {
    throw UnimplementedError();
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
  const FindManyPostParams();

  @override
  Map<String, Where> get wheres => throw UnimplementedError();
}

class UpdateOnePostParams extends UpdateOneParams {
  const UpdateOnePostParams();
}

class UpdateManyPostParams extends UpdateManyParams {
  const UpdateManyPostParams();
}

class DeleteOnePostParams extends DeleteOneParams {
  const DeleteOnePostParams();
}

class DeleteManyPostParams extends DeleteManyParams {
  const DeleteManyPostParams();
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
    throw UnimplementedError();
  }

  @override
  AsyncResult<Page<LikeEntity>, DSQLException> findManyPaginated(
      [FindManyLikeParams params = const FindManyLikeParams()]) async {
    throw UnimplementedError();
  }

  @override
  AsyncResult<LikeEntity, DSQLException> updateOne(
      UpdateOneLikeParams params) async {
    throw UnimplementedError();
  }

  @override
  AsyncResult<List<LikeEntity>, DSQLException> updateMany(
      UpdateManyLikeParams params) async {
    throw UnimplementedError();
  }

  @override
  AsyncResult<LikeEntity, DSQLException> deleteOne(
      DeleteOneLikeParams params) async {
    throw UnimplementedError();
  }

  @override
  AsyncResult<List<LikeEntity>, DSQLException> deleteMany(
      DeleteManyLikeParams params) async {
    throw UnimplementedError();
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
  const FindManyLikeParams();

  @override
  Map<String, Where> get wheres => throw UnimplementedError();
}

class UpdateOneLikeParams extends UpdateOneParams {
  const UpdateOneLikeParams();
}

class UpdateManyLikeParams extends UpdateManyParams {
  const UpdateManyLikeParams();
}

class DeleteOneLikeParams extends DeleteOneParams {
  const DeleteOneLikeParams();
}

class DeleteManyLikeParams extends DeleteManyParams {
  const DeleteManyLikeParams();
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
        String $id,
        String $followerId,
        String $followingId,
        DateTime $createdAt,
      ] = result.first as List;

      final entity = FollowerEntity(
        id: $id,
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
            String $id,
            String $followerId,
            String $followingId,
            DateTime $createdAt,
          ] = row as List;

          return FollowerEntity(
            id: $id,
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
        String $id,
        String $followerId,
        String $followingId,
        DateTime $createdAt,
      ] = result.first as List;

      final entity = FollowerEntity(
        id: $id,
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
    throw UnimplementedError();
  }

  @override
  AsyncResult<Page<FollowerEntity>, DSQLException> findManyPaginated(
      [FindManyFollowerParams params = const FindManyFollowerParams()]) async {
    throw UnimplementedError();
  }

  @override
  AsyncResult<FollowerEntity, DSQLException> updateOne(
      UpdateOneFollowerParams params) async {
    throw UnimplementedError();
  }

  @override
  AsyncResult<List<FollowerEntity>, DSQLException> updateMany(
      UpdateManyFollowerParams params) async {
    throw UnimplementedError();
  }

  @override
  AsyncResult<FollowerEntity, DSQLException> deleteOne(
      DeleteOneFollowerParams params) async {
    throw UnimplementedError();
  }

  @override
  AsyncResult<List<FollowerEntity>, DSQLException> deleteMany(
      DeleteManyFollowerParams params) async {
    throw UnimplementedError();
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
  final Where? id;
  final Where? followerId;
  final Where? followingId;
  final Where? createdAt;

  const FindOneFollowerParams({
    this.id,
    this.followerId,
    this.followingId,
    this.createdAt,
  });

  @override
  Map<String, Where> get wheres => {
        if (id != null) 'id': id!,
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
  const FindManyFollowerParams();

  @override
  Map<String, Where> get wheres => throw UnimplementedError();
}

class UpdateOneFollowerParams extends UpdateOneParams {
  const UpdateOneFollowerParams();
}

class UpdateManyFollowerParams extends UpdateManyParams {
  const UpdateManyFollowerParams();
}

class DeleteOneFollowerParams extends DeleteOneParams {
  const DeleteOneFollowerParams();
}

class DeleteManyFollowerParams extends DeleteManyParams {
  const DeleteManyFollowerParams();
}
