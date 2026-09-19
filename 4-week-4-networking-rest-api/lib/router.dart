import 'package:go_router/go_router.dart';
import 'pages/post_list_page.dart';
import 'pages/post_detail_page.dart';

final appRouter = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const PostListPage(),
    ),
    GoRoute(
      path: '/post/:id',
      builder: (context, state) {
        final idString = state.pathParameters['id'] ?? '0';
        final id = int.tryParse(idString) ?? 0;
        return PostDetailPage(postId: id);
      },
    ),
  ],
);