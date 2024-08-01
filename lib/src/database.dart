import 'package:postgres/postgres.dart';

import 'exceptions.dart';

class Database {
  final Connection? _conn;
  final Pool? _pool;

  Database(this._conn, this._pool) {
    assert(() {
      if (_pool == null && _conn == null) {
        throw DSQLException('Pool or Connection is required!');
      }

      if (_pool != null && _conn != null) {
        throw DSQLException('Only one of Pool or Connection is allowed!');
      }

      return true;
    }());
  }

  Future<Result> execute(Object query, {Object? parameters}) async {
    if (_pool != null) {
      return _pool!.execute(query, parameters: parameters);
    } else if (_conn != null) {
      return _conn!.execute(query, parameters: parameters);
    } else {
      throw DSQLException('Pool or Connection is required!');
    }
  }

  Future<Result> runTx(Future<Result> Function(TxSession tx) func) async {
    if (_pool != null) {
      return _pool!.runTx(func);
    } else if (_conn != null) {
      return _conn!.runTx(func);
    } else {
      throw DSQLException('Pool or Connection is required!');
    }
  }
}
