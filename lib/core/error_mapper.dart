import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'result.dart';

class ErrorMapper {
  ErrorMapper._();

  static Failure map(Object error) {
    if (error is Failure) return error;

    if (error is AuthException) {
      return _mapAuthException(error);
    }

    if (error is PostgrestException) {
      return _mapPostgrestException(error);
    }

    if (error is SocketException) {
      return Failure(
        message:
            'No internet connection. Please check your network and try again.',
        code: ErrorCode.network,
        original: error,
      );
    }

    if (error.toString().contains('SocketException') ||
        error.toString().contains('ClientException')) {
      return Failure(
        message: 'Network error. Please check your connection.',
        code: ErrorCode.network,
        original: error,
      );
    }

    // Fallback based on string matching for specific known errors if needed
    final msg = error.toString();
    if (msg.contains('binus.ac.id')) {
      return Failure(
          message: 'Only @binus.ac.id emails are allowed.',
          code: ErrorCode.auth,
          original: error);
    }
    if (msg.contains('Invalid login')) {
      return Failure(
          message: 'Invalid email or password.',
          code: ErrorCode.auth,
          original: error);
    }
    if (msg.contains('Email not confirmed')) {
      return Failure(
          message: 'Please verify your email first.',
          code: ErrorCode.auth,
          original: error);
    }
    if (msg.contains('already registered')) {
      return Failure(
          message: 'This email is already registered. Try signing in.',
          code: ErrorCode.auth,
          original: error);
    }
    if (msg.contains('rate limit') || msg.contains('429')) {
      return Failure(
          message: 'Too many attempts. Please wait a moment and try again.',
          code: ErrorCode.rateLimit,
          original: error);
    }

    return Failure(
      message: 'Something went wrong. Please try again.',
      code: ErrorCode.unknown,
      original: error,
    );
  }

  static Failure _mapAuthException(AuthException error) {
    final msg = error.message.toLowerCase();
    if (msg.contains('invalid login credentials')) {
      return Failure(
          message: 'Invalid email or password.',
          code: ErrorCode.auth,
          original: error);
    } else if (msg.contains('already registered')) {
      return Failure(
          message: 'This email is already registered. Try signing in.',
          code: ErrorCode.auth,
          original: error);
    } else if (msg.contains('email not confirmed')) {
      return Failure(
          message: 'Please verify your email first.',
          code: ErrorCode.auth,
          original: error);
    } else if (error.statusCode == '429' || msg.contains('rate limit')) {
      return Failure(
          message: 'Too many attempts. Please wait a moment and try again.',
          code: ErrorCode.rateLimit,
          original: error);
    }
    return Failure(
        message: error.message, code: ErrorCode.auth, original: error);
  }

  static Failure _mapPostgrestException(PostgrestException error) {
    final msg = error.message.toLowerCase();
    final details = error.details?.toString().toLowerCase() ?? '';

    if (msg.contains('time conflict') || details.contains('time conflict')) {
      return Failure(
          message:
              'Time conflict: you already have a lobby during this time slot.',
          code: ErrorCode.conflict,
          original: error);
    }

    if (error.code == '23505') {
      // unique_violation
      return Failure(
          message:
              'This action has already been performed or a conflict exists.',
          code: ErrorCode.conflict,
          original: error);
    }

    if (error.code == 'PGRST116') {
      // Not found / empty results
      return Failure(
          message: 'The requested resource was not found.',
          code: ErrorCode.notFound,
          original: error);
    }

    return Failure(
        message: 'Database error occurred. Please try again later.',
        code: ErrorCode.unknown,
        original: error);
  }
}
