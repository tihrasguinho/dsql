import 'lib/generated/dsql.dart';

void main() async {
  final dsql = DSQL('localhost', 5432, 'database', username: 'username', password: 'password');

  await dsql.initialize();

  final user = await dsql.user.create(name: 'name', email: 'email', password: 'password', image: 'image');

  await dsql.user.findMany(name: 'name');

  await dsql.user.findById(user.id);
}
