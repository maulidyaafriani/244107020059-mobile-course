import 'package:flutter_test/flutter_test.dart';
import 'package:campus_notify/core/failures.dart';
import 'package:campus_notify/features/auth/domain/entities/auth_session.dart';
import 'package:campus_notify/features/auth/domain/repositories/auth_repository.dart';
import 'package:campus_notify/features/auth/domain/usecases/login.dart';

class FakeAuthRepository implements AuthRepository {
  FakeAuthRepository({this.fail = false});

  final bool fail;

  @override
  Future<({AuthSession? session, Failure? failure})> login({
    required String email,
    required String password,
  }) async {
    if (fail) {
      return (session: null, failure: const AuthFailure('gagal (simulasi)'));
    }
    return (
      session: const AuthSession(access: 'a', refresh: 'r'),
      failure: null,
    );
  }

  @override
  Future<({String? accessToken, Failure? failure})> refresh(
    String refreshToken,
  ) {
    throw UnimplementedError();
  }
}

void main() {
  test('Login meneruskan sesi dari repository', () async {
    final result = await Login(FakeAuthRepository())
        .call(email: 'tes@kampus.ac.id', password: '123456');
    expect(result.failure, isNull);
    expect(result.session?.access, 'a');
  });

  test('Login meneruskan failure tanpa melempar', () async {
    final result = await Login(FakeAuthRepository(fail: true))
        .call(email: 'tes@kampus.ac.id', password: '123456');
    expect(result.failure, isA<AuthFailure>());
    expect(result.session, isNull);
  });
}