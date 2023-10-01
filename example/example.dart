import 'package:dsql/dsql.dart';

void main() {
  final where = Where('id', EQ(1)).or(Where('first_name', Contains('Tiago')).and(Where('email', EQ('DqG5A@example.com'))), parentesis: true);
  print(where.queryString);
  print(where.substitutionValues);

  final orderBy = ASC('name');

  print(orderBy.queryString);
}
