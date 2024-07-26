// This file is generated by DSQL.
// Do not modify it manually.

part of 'dsql.dart';

class UserEntity {
  final String id;
  final String name;
  final String username;
  final String email;
  final String password;
  final String? image;
  final String? bio;
  final String? website;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserEntity({
    required this.id,
    required this.name,
    required this.username,
    required this.email,
    required this.password,
    this.image,
    this.bio,
    this.website,
    required this.createdAt,
    required this.updatedAt,
  });

  UserEntity copyWith({
    String? id,
    String? name,
    String? username,
    String? email,
    String? password,
    String? image,
    String? bio,
    String? website,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      username: username ?? this.username,
      email: email ?? this.email,
      password: password ?? this.password,
      image: image ?? this.image,
      bio: bio ?? this.bio,
      website: website ?? this.website,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'username': username,
      'email': email,
      'password': password,
      'image': image,
      'bio': bio,
      'website': website,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  String toJson() => json.encode(toMap());

  factory UserEntity.fromMap(Map<String, dynamic> map) {
    return UserEntity(
      id: map['id'] as String,
      name: map['name'] as String,
      username: map['username'] as String,
      email: map['email'] as String,
      password: map['password'] as String,
      image: map['image'] as String,
      bio: map['bio'] as String,
      website: map['website'] as String,
      createdAt: map['created_at'] as DateTime,
      updatedAt: map['updated_at'] as DateTime,
    );
  }

  factory UserEntity.fromJson(String source) =>
      UserEntity.fromMap(json.decode(source));

  @override
  String toString() {
    return 'UserEntity(id: $id, name: $name, username: $username, email: $email, password: $password, image: $image, bio: $bio, website: $website, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is UserEntity &&
        other.id == id &&
        other.name == name &&
        other.username == username &&
        other.email == email &&
        other.password == password &&
        other.image == image &&
        other.bio == bio &&
        other.website == website &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode =>
      id.hashCode ^
      name.hashCode ^
      username.hashCode ^
      email.hashCode ^
      password.hashCode ^
      image.hashCode ^
      bio.hashCode ^
      website.hashCode ^
      createdAt.hashCode ^
      updatedAt.hashCode;
}

class PostEntity {
  final String id;
  final String? postId;
  final String title;
  final String body;
  final String ownerId;
  final DateTime createdAt;
  final DateTime updatedAt;

  const PostEntity({
    required this.id,
    this.postId,
    required this.title,
    required this.body,
    required this.ownerId,
    required this.createdAt,
    required this.updatedAt,
  });

  PostEntity copyWith({
    String? id,
    String? postId,
    String? title,
    String? body,
    String? ownerId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PostEntity(
      id: id ?? this.id,
      postId: postId ?? this.postId,
      title: title ?? this.title,
      body: body ?? this.body,
      ownerId: ownerId ?? this.ownerId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'post_id': postId,
      'title': title,
      'body': body,
      'owner_id': ownerId,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  String toJson() => json.encode(toMap());

  factory PostEntity.fromMap(Map<String, dynamic> map) {
    return PostEntity(
      id: map['id'] as String,
      postId: map['post_id'] as String,
      title: map['title'] as String,
      body: map['body'] as String,
      ownerId: map['owner_id'] as String,
      createdAt: map['created_at'] as DateTime,
      updatedAt: map['updated_at'] as DateTime,
    );
  }

  factory PostEntity.fromJson(String source) =>
      PostEntity.fromMap(json.decode(source));

  @override
  String toString() {
    return 'PostEntity(id: $id, postId: $postId, title: $title, body: $body, ownerId: $ownerId, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is PostEntity &&
        other.id == id &&
        other.postId == postId &&
        other.title == title &&
        other.body == body &&
        other.ownerId == ownerId &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode =>
      id.hashCode ^
      postId.hashCode ^
      title.hashCode ^
      body.hashCode ^
      ownerId.hashCode ^
      createdAt.hashCode ^
      updatedAt.hashCode;
}

class LikeEntity {
  final String id;
  final String postId;
  final String userId;
  final DateTime createdAt;

  const LikeEntity({
    required this.id,
    required this.postId,
    required this.userId,
    required this.createdAt,
  });

  LikeEntity copyWith({
    String? id,
    String? postId,
    String? userId,
    DateTime? createdAt,
  }) {
    return LikeEntity(
      id: id ?? this.id,
      postId: postId ?? this.postId,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'post_id': postId,
      'user_id': userId,
      'created_at': createdAt,
    };
  }

  String toJson() => json.encode(toMap());

  factory LikeEntity.fromMap(Map<String, dynamic> map) {
    return LikeEntity(
      id: map['id'] as String,
      postId: map['post_id'] as String,
      userId: map['user_id'] as String,
      createdAt: map['created_at'] as DateTime,
    );
  }

  factory LikeEntity.fromJson(String source) =>
      LikeEntity.fromMap(json.decode(source));

  @override
  String toString() {
    return 'LikeEntity(id: $id, postId: $postId, userId: $userId, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is LikeEntity &&
        other.id == id &&
        other.postId == postId &&
        other.userId == userId &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode =>
      id.hashCode ^ postId.hashCode ^ userId.hashCode ^ createdAt.hashCode;
}
