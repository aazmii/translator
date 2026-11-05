/// A domain operation with one explicit input and output type.
abstract interface class UseCase<Result, Params> {
  Result call(Params params);
}

/// Used by use cases that do not require input.
final class NoParams {
  const NoParams();
}
