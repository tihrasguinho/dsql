extension IterableExt<T> on Iterable<T> {
  Iterable<S> indexedMap<S>(S Function(int index, T element) func) {
    return Iterable<S>.generate(length, (i) => func(i, elementAt(i)));
  }
}
