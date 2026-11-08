import '../../../../core/failures.dart';
import '../../../../data/api_errors.dart';
import '../../domain/entities/auth_session.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  // GANTI titik ini dengan FirebaseAuth.instance.signInWithEmailAndPassword
  // atau GoogleSignIn saat backend Firebase sudah siap.
  @override
  Future<({AuthSession? session, Failure? failure})> login({
    required String email,
    required String password,
  }) async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      if (!email.contains('@') || password.length < 6) {
        throw const UserFacingException('Email atau kata sandi tidak valid');
      }
      return (
        session: AuthSession(
          access: 'mock-access-for-$email',
          refresh: 'mock-refresh-for-$email',
        ),
        failure: null,
      );
    } on UserFacingException catch (e) {
      return (session: null, failure: AuthFailure(e.message));
    } catch (e) {
      return (session: null, failure: UnknownFailure('$e'));
    }
  }

  @override
  Future<({String? accessToken, Failure? failure})> refresh(
    String refreshToken,
  ) async {
    try {
      await Future.delayed(const Duration(milliseconds: 300));
      if (refreshToken.isEmpty) throw Exception('Refresh token hilang');
      return (
        accessToken:
            'mock-access-renewed-${DateTime.now().millisecondsSinceEpoch}',
        failure: null,
      );
    } catch (e) {
      return (accessToken: null, failure: AuthFailure('$e'));
    }
  }
}