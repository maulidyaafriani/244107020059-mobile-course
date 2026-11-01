import 'package:flutter_test/flutter_test.dart';
import 'package:campus_notify/features/auth/domain/usecases/validate_login_input.dart';

void main() {
  const validate = ValidateLoginInput();

  group('email', () {
    test('kosong ditolak', () {
      expect(validate.email(''), 'Email tidak boleh kosong');
    });
    test('null ditolak', () {
      expect(validate.email(null), 'Email tidak boleh kosong');
    });
    test('format salah ditolak', () {
      expect(validate.email('abc'), 'Format email tidak valid');
    });
    test('label domain yang cacat ditolak', () {
      expect(validate.email('user@example..com'), 'Format email tidak valid');
      expect(validate.email('user@-example.com'), 'Format email tidak valid');
    });
    test('format benar diterima', () {
      expect(validate.email('user@mail.com'), isNull);
    });
  });

  group('password', () {
    test('kosong ditolak', () {
      expect(validate.password(''), 'Password tidak boleh kosong');
    });
    test('null ditolak', () {
      expect(validate.password(null), 'Password tidak boleh kosong');
    });
    test('terlalu pendek ditolak', () {
      expect(
        validate.password('12345'),
        'Password minimal ${ValidateLoginInput.minPasswordLength} karakter',
      );
    });
    test('tepat 6 karakter diterima', () {
      expect(validate.password('123456'), isNull);
    });
  });
}
