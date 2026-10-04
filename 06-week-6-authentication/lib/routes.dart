class AppRoutes {
  const AppRoutes._();

  static const home = '/';
  static const login = '/login';
  static const loading = '/loading';
  static const announcementPattern = '/pengumuman/:id';

  static String announcement(String id) => '/pengumuman/$id';
}

String routeFromMessage(Map<String, dynamic> data) {
  final value = data['route'];
  if (value is! String || value.trim().isEmpty) return AppRoutes.home;

  final valueTrimmed = value.trim();
  final originalUri = Uri.tryParse(valueTrimmed);
  if (originalUri == null ||
      originalUri.hasScheme ||
      originalUri.hasAuthority) {
    return AppRoutes.home;
  }

  final route = valueTrimmed.startsWith('/') ? valueTrimmed : '/$valueTrimmed';
  final uri = Uri.tryParse(route);
  if (uri == null ||
      uri.hasScheme ||
      uri.hasAuthority ||
      !uri.path.startsWith('/') ||
      uri.path.startsWith('//')) {
    return AppRoutes.home;
  }

  return route;
}
