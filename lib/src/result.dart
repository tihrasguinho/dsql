typedef AsyncResult<S extends Object?, E extends Object?>
    = Future<Result<S, E>>;

sealed class Result<S extends Object?, E extends Object?> {
  final S? _success;
  final E? _error;

  const Result(this._success, this._error);

  bool get isSuccess => _success != null;

  S? getSuccessOrNull() => _success;

  S getSuccessOrThrow() {
    if (_success == null) throw Exception('Success value is null');

    return _success!;
  }

  S getSuccessOrElse(S Function() orElse) => _success ?? orElse();

  bool get isError => _error != null;

  E? getErrorOrNull() => _error;

  E getErrorOrThrow() {
    if (_error == null) throw Exception('Error value is null');

    return _error!;
  }

  E getErrorOrElse(E Function() orElse) => _error ?? orElse();

  T when<T>(T Function(S success) onSuccess, T Function(E error) onError) {
    if (isSuccess) {
      return onSuccess(getSuccessOrThrow());
    } else {
      return onError(getErrorOrThrow());
    }
  }
}

final class Success<S extends Object?, E extends Object?> extends Result<S, E> {
  Success(S success) : super(success, null);
}

final class Error<S extends Object?, E extends Object?> extends Result<S, E> {
  Error(E error) : super(null, error);
}
