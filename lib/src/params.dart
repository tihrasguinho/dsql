import 'where.dart';

abstract class InsertOneParams {
  const InsertOneParams();

  String get query;

  List get parameters;
}

abstract class InsertManyParams {
  const InsertManyParams();

  String get query;

  List get parameters;
}

abstract class FindOneParams {
  const FindOneParams();
  Map<String, Where> get wheres;
  String get query;
  List get parameters;
}

abstract class FindManyParams {
  const FindManyParams();
  Map<String, Where> get wheres;
  String get query;
  List get parameters;
}

abstract class UpdateOneParams {
  const UpdateOneParams();
  Map<String, Where> get wheres;
  String get query;
  List get parameters;
}

abstract class UpdateManyParams {
  const UpdateManyParams();
}

abstract class DeleteOneParams {
  const DeleteOneParams();
}

abstract class DeleteManyParams {
  const DeleteManyParams();
}
