import 'package:equatable/equatable.dart';
import 'package:flutter_web_app/core/error/failure.dart';

/// Success-or-failure value returned across layers instead of throwing.
sealed class Result<T> extends Equatable {
  const Result();

  /// Folds this result into one value.
  R when<R>({
    required R Function(T value) ok,
    required R Function(Failure failure) err,
  }) => switch (this) {
    Ok<T>(:final value) => ok(value),
    Err<T>(:final failure) => err(failure),
  };
}

/// Successful result holding [value].
final class Ok<T> extends Result<T> {
  const Ok(this.value);

  /// The success payload.
  final T value;

  @override
  List<Object?> get props => [value];
}

/// Failed result holding [failure].
final class Err<T> extends Result<T> {
  const Err(this.failure);

  /// Why the operation failed.
  final Failure failure;

  @override
  List<Object?> get props => [failure];
}
