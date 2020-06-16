abstract class Failure {
  final String message;

  Failure([this.message]);
}

extension OnFailures<T> on Stream<T> {
  Stream<T> whereFailures(List<dynamic> failures) {
    return where((failure) {
      if (failure == null) return true;
      return failures.any((f) => failure.runtimeType == f);
    });
  }
}
