import 'package:dio/dio.dart';

String apiErrorMessage(Object? error) {
  if (error is UserFacingException) return error.message;
  if (error is! DioException) {
    return 'Terjadi kesalahan. Silakan coba lagi.';
  }

  if (error.response?.statusCode == 401) {
    return 'Sesi login berakhir. Silakan masuk kembali.';
  }

  switch (error.type) {
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.sendTimeout:
    case DioExceptionType.receiveTimeout:
    case DioExceptionType.transformTimeout:
      return 'Koneksi terlalu lama. Periksa jaringan lalu coba lagi.';
    case DioExceptionType.connectionError:
      return 'Tidak dapat terhubung. Periksa koneksi internet Anda.';
    case DioExceptionType.badResponse:
      return 'Server tidak dapat memproses permintaan. Coba lagi nanti.';
    case DioExceptionType.cancel:
      return 'Permintaan dibatalkan.';
    case DioExceptionType.badCertificate:
    case DioExceptionType.unknown:
      return 'Terjadi kesalahan jaringan. Silakan coba lagi.';
  }
}

class UserFacingException implements Exception {
  const UserFacingException(this.message);

  final String message;
}
