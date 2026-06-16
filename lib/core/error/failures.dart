sealed class Failure {
  const Failure(this.message);
  final String message;
}

final class DatabaseFailure extends Failure {
  const DatabaseFailure(super.message);
}

final class AlarmFailure extends Failure {
  const AlarmFailure(super.message);
}

final class NetworkFailure extends Failure {
  const NetworkFailure(super.message);
}
