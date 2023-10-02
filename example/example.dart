import 'package:dsql/dsql.dart';

void main() {
  final where = Where.emphasis(
    Where('name', StartsWith('a')).or(Where('name', StartsWith('b'))),
  ).or(
    Where.emphasis(Where('id', NOTEQ(1))),
  );
  print(where.queryString);
  print(where.substitutionValues);
}
