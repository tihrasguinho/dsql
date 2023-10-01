### DSQL ORM

#### An Experimental Dart ORM or Something Similar

##### Installation

```shell
dart pub global activate dsql
```

##### and add dsql to your pubspec.yaml

```yaml
dependencies:
  dsql: ^0.0.9+3
```

##### Create a file .env in the root of your project with database connection information.

```env
DATABASE_URL=postgresql://postgres:postgres@localhost:5432/postgres?schema=public
```

##### In the root, create a folder called migrations with your .sql file, like spring boot for example.

```sql
-- ./migrations/V1__create_users_table.sql

-- Entity => User
CREATE TABLE users (
  id SERIAL PRIMARY KEY DEFAULT nextval('users_id_seq'),
  name VARCHAR(255) NOT NULL,
  email VARCHAR(255) NOT NULL UNIQUE,
  password VARCHAR(255) NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

##### Then you can run the migrations command with the following command

```
dsql --generate or -g // Generate a dsql.dart file inside the lib/generated folder
dsql -g -o /path/to/output // Generates in a custom path
```

##### Next steps:

##### - Add more SQL types (currently only VARCHAR, TEXT, UUID, BOOLEAN, INTEGER, DOUBLE, TIMESTAMP are supported)
##### - Add relationship between entities
##### - Add others drivers like MySQL, MSSQL, SQLite!

##### Twitter: @tihraguinho

