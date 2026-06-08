import 'package:flutter/foundation.dart';
import 'result.dart';
import 'error_mapper.dart';

Future<Result<T>> withRetry<T>(
  Future<T> Function() operation, {
  int maxAttempts = 3,
  Duration initialDelay = const Duration(milliseconds: 500),
}) async {
  int attempt = 0;
  Duration delay = initialDelay;

  while (attempt < maxAttempts) {
    try {
      final result = await operation();
      return Success(result);
    } catch (e) {
      attempt++;
      final failure = ErrorMapper.map(e);

      // Do not retry on auth, conflict, or notFound errors
      if (failure.code == ErrorCode.auth ||
          failure.code == ErrorCode.conflict ||
          failure.code == ErrorCode.notFound) {
        return failure;
      }

      if (attempt >= maxAttempts) {
        return failure;
      }

      debugPrint(
          'Operation failed (attempt $attempt/$maxAttempts). Retrying in ${delay.inMilliseconds}ms... Error: ${failure.message}. Original error: $e');
      await Future.delayed(delay);
      delay *= 2; // Exponential backoff
    }
  }

  return Failure(message: 'Operation failed after $maxAttempts attempts.');
}
