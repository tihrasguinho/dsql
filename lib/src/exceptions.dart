abstract class DSQLException implements Exception {
  final String message;
  final StackTrace? stackTrace;

  const DSQLException(this.message, [this.stackTrace]);
}

class SQLException extends DSQLException {
  const SQLException(super.message, [super.stackTrace]);
}
