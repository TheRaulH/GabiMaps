import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; 
import 'package:gabimaps/features/auth/providers/auth_providers.dart';
import 'package:gabimaps/features/posts/data/post_model.dart';
import 'package:gabimaps/features/posts/provider/posts_provider.dart';
import 'package:gabimaps/features/posts/ui/post_detail_page.dart';
import 'package:gabimaps/features/posts/ui/widgets/post_card.dart';

class MyPostsPage extends ConsumerWidget {
  const MyPostsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final currentUser = ref.watch(authStateProvider).value;

    // Si no hay usuario autenticado, mostramos un mensaje
    if (currentUser == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Mis Publicaciones')),
        body: const Center(
          child: Text('Debes iniciar sesión para ver tus publicaciones'),
        ),
      );
    }

    // Usamos directamente el userPostsProvider con el ID del usuario actual
    final myPostsAsync = ref.watch(userPostsProvider(currentUser.uid));

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Mis Publicaciones',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(userPostsProvider(currentUser.uid)),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(userPostsProvider(currentUser.uid));
        },
        child: myPostsAsync.when(
          data: (posts) {
            if (posts.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.feed_outlined,
                      size: 64,
                      color: theme.disabledColor,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No tienes publicaciones',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.disabledColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Crea tu primera publicación',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.only(top: 8),
              itemCount: posts.length,
              separatorBuilder:
                  (context, index) => const Divider(
                    height: 1,
                    thickness: 1,
                    indent: 16,
                    endIndent: 16,
                  ),
              itemBuilder: (context, index) {
                final post = posts[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  child: PostCard(
                    post: post,
                    heroTag: 'myPostHero_${post.postId}',
                    onTap:
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => PostDetailPage(postId: post.postId),
                          ),
                        ).then((_) {
                          // Actualizar la vista al volver
                          ref.invalidate(userPostsProvider(currentUser.uid));
                        }),
                  ),
                );
              },
            );
          },
          loading:
              () => const Center(
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
          error:
              (e, _) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 48,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Error al cargar tus publicaciones',
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Text(
                        e.toString(),
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      icon: const Icon(Icons.refresh),
                      label: const Text('Reintentar'),
                      onPressed:
                          () => ref.invalidate(
                            userPostsProvider(currentUser.uid),
                          ),
                    ),
                  ],
                ),
              ),
        ),
      ),
    );
  }
}
