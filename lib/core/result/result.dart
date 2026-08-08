enum FailureCategory {
  validation,
  authentication,
  authorization,
  network,
  persistence,
  synchronization,
  payment,
  configuration,
  externalProvider,
  unknown,
}

final class Failure {
  const Failure({required this.category, required this.message, this.code, this.cause});
  final FailureCategory category;
  final String message;
  final String? code;
  final Object? cause;
}

sealed class Result<T> {
  const Result();
  bool get isSuccess => this is Success<T>;
  bool get isFailure => this is Error<T>;
}

final class Success<T> extends Result<T> {
  const Success(this.value);
  final T value;
}

final class Error<T> extends Result<T> {
  const Error(this.failure);
  final Failure failure;
}
