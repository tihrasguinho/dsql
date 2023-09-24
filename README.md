### DSQL ORM

#### An experimental Dart ORM or something like that

##### Initially the idea is to read a .sql file as in a spring migration for example, and generate the classes to be used in dart!

##### - Example:

##### In the root of project create a folder called migrations and put inside it your migrations with its current version number. (Exactly like in Spring Boot)

 - root/migrations/V1__initial.sql

##### Inside the sql script for table creations, you need to give the "EntityName" that will used to generate dart classes based on it.

```sql
-- Entity => UserEntity 
CREATE TABLE IF NOT EXISTS tb_users (
  id VARCHAR(11) PRIMARY KEY NOT NULL DEFAULT id_generator(),
  name VARCHAR(255) NOT NULL,
  email VARCHAR(255) UNIQUE NOT NULL,
  password VARCHAR(255) NOT NULL,
  image VARCHAR(255),
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  enabled BOOLEAN NOT NULL DEFAULT TRUE
);
```

##### After that, you will need to run the command of dsql for generate all classes for manipulate on PostgreSQL

```shell
dsql --generate
```

##### It will create a dsql.dart file inside lib/generated/dsql.dart or if you want to generate in another directory you can use --output  or -o to pass another path!

##### After that, you can create a instance of DSQL class passing all the database configuration and then calling the initialize method!

```dart
void main() async {
  final dsql = DSQL('localhost', 5432, 'postgres');

  await dsql.initialize():
}
```

##### All the given entities will generate a repository inside the DSQL class and you can easily call by its name

##### - Example based on its sql:

```dart
void main() async {
  final dsql = DSQL('localhost', 5432, 'postgres');

  await dsql.initialize():

  await dsql.user.create(name: 'name', email: 'email', password: 'password', image: 'image');

  await dsql.user.findMany();

  await dsql.user.findById('some_user_id');

  await dsql.user.update(UserEntity...);

  await dsql.user.delete('some_user_id');
}
```
