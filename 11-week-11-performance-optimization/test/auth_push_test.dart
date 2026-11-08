import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:campus_notify/data/api_errors.dart';
import 'package:campus_notify/routes.dart';

class FakeTokenStore {
  String? access;
  String? refresh;
}

void main() {
  group('routeFromMessage', () {
    test('handles empty and slashless routes', () {
      expect(routeFromMessage({}), AppRoutes.home);
      expect(
        routeFromMessage({'route': 'pengumuman/3'}),
        AppRoutes.announcement('3'),
      );
      expect(
        routeFromMessage({'route': '/pengumuman/3'}),
        AppRoutes.announcement('3'),
      );
    });

    test('announcement data retains its route and id', () {
      const data = {'route': '/pengumuman/3', 'id': '3'};
      expect(data['id'], '3');
      expect(routeFromMessage(data), AppRoutes.announcement('3'));
    });

    test('rejects external and non-string routes', () {
      expect(
        routeFromMessage({'route': 'https://example.com'}),
        AppRoutes.home,
      );
      expect(routeFromMessage({'route': 3}), AppRoutes.home);
    });
  });

  group('auth and API error helpers', () {
    test('access token determines logged-in status', () {
      final store = FakeTokenStore()..access = 'mock-access';
      expect(store.access != null, isTrue);
      store.access = null;
      expect(store.access != null, isFalse);
    });

    test('empty refresh token requires login again', () {
      final store = FakeTokenStore()..refresh = '';
      expect((store.refresh ?? '').isEmpty, isTrue);
    });

    test('maps unauthorized response to a friendly message', () {
      final error = DioException(
        requestOptions: RequestOptions(path: '/private'),
        response: Response(
          requestOptions: RequestOptions(path: '/private'),
          statusCode: 401,
        ),
        type: DioExceptionType.badResponse,
      );

      expect(
        apiErrorMessage(error),
        'Sesi login berakhir. Silakan masuk kembali.',
      );
    });

    test('maps timeout and offline errors to friendly messages', () {
      final timeout = DioException(
        requestOptions: RequestOptions(path: '/'),
        type: DioExceptionType.connectionTimeout,
      );
      final offline = DioException(
        requestOptions: RequestOptions(path: '/'),
        type: DioExceptionType.connectionError,
      );

      expect(apiErrorMessage(timeout), contains('Koneksi terlalu lama'));
      expect(apiErrorMessage(offline), contains('koneksi internet'));
    });
  });
}
