import 'exceptions.dart';
import 'page.dart';
import 'params.dart';
import 'result.dart';

abstract class Repository<
    T extends Object,
    IO extends InsertOneParams,
    IM extends InsertManyParams,
    FO extends FindOneParams,
    FM extends FindManyParams,
    UO extends UpdateOneParams,
    UM extends UpdateManyParams,
    DO extends DeleteOneParams,
    DM extends DeleteManyParams> {
  const Repository();
  AsyncResult<T, DSQLException> insertOne(IO params);
  AsyncResult<List<T>, DSQLException> insertMany(IM params);
  AsyncResult<List<T>, DSQLException> findMany([FM params]);
  AsyncResult<Page<T>, DSQLException> findManyPaginated([FM params]);
  AsyncResult<T, DSQLException> findOne(FO params);
  AsyncResult<T, DSQLException> updateOne(UO params);
  AsyncResult<List<T>, DSQLException> updateMany(UM params);
  AsyncResult<T, DSQLException> deleteOne(DO params);
  AsyncResult<List<T>, DSQLException> deleteMany(DM params);
}
