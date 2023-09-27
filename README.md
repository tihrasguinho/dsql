### DSQL ORM

#### An Experimental Dart ORM or Something Similar

##### Initially, the idea is to read a .sql file, as in Spring Migration, for example, and generate the classes to be used in Dart!

##### - Example:

##### First you need to install the dsql globally

```shell
dart pub global activate dsql
```

##### Then add the dsql package to your pubspec.yaml

```yaml
dependencies:
  dsql: ^0.0.9
```

##### In the root of the project, create a folder called "migrations" and place your migrations inside it, each with its current version number (similar to Spring Boot).

 - root/migrations/V1__initial.sql

##### Inside the SQL script for table creations, you need to provide the "EntityName" that will be used to generate Dart classes based on it.

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

##### After that, you will need to run the "dsql" command to generate all classes for manipulation on PostgreSQL.

```shell
dsql --generate
```

##### It will create a "dsql.dart" file inside the "lib/generated" directory, or if you want to generate it in another directory, you can use "--output" or "-o" to specify another path.


##### Afterward, you can create an instance of the DSQL class, providing all the database configurations, and then call the "initialize" method.

```dart
void main() async {
  final dsql = DSQL('localhost', 5432, 'postgres');

  await dsql.initialize():
}
```

##### All the provided entities will generate a repository inside the DSQL class, and you can easily access them by their name.

##### - Example based on this SQL:

```dart
void main() async {
  final dsql = DSQL('localhost', 5432, 'postgres');

  await dsql.initialize():

  await dsql.user.create(name: 'name', email: 'email', password: 'password', image: 'image');

  await dsql.user.findMany();

  await dsql.user.findById('some_user_id');

  await dsql.user.update('some_user_id', name: 'new_name', email: 'new_email');

  await dsql.user.delete('some_user_id');}
```

##### Next steps:

##### - Add more SQL types (currently only VARCHAR, TEXT, UUID, BOOLEAN, INTEGER, DOUBLE, TIMESTAMP are supported)
##### - Add relationship between entities
##### - Add others drivers like MySQL, MSSQL, SQLite!

##### Twitter: @tihraguinho

