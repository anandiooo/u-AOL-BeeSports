import 'package:equatable/equatable.dart';

enum ErrorCode {
  network,
  auth,
  conflict,
  notFound,
  rateLimit,
  unknown,
}

sealed class Result<T> extends Equatable {
  const Result();

  R when<R>({
    required R Function(T data) success,
    required R Function(Failure failure) failure,
  }) {
    if (this is Success<T>) {
      return success((this as Success<T>).data);
    } else if (this is Failure) {
      return failure(this as Failure);
    }
    throw StateError('Unexpected subclass of Result');
  }

  @override
  List<Object?> get props => [];
}

class Success<T> extends Result<T> {
  final T data;

  const Success(this.data);

  @override
  List<Object?> get props => [data];
}

class Failure extends Result<Never> {
  final String message;
  final ErrorCode code;
  final Object? original;

  const Failure({
    required this.message,
    this.code = ErrorCode.unknown,
    this.original,
  });

  @override
  List<Object?> get props => [message, code, original];
}
