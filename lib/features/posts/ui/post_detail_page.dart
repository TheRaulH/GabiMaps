import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../posts/data/post_model.dart';
import '../provider/posts_provider.dart';
import 'widgets/comment_list.dart';
import 'widgets/post_card.dart';
import 'widgets/new_post_form.dart';

class PostDetailPage extends ConsumerWidget {
  final String postId;

  const PostDetailPage({super.key, required this.postId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final postAsync = ref.watch(postByIdProvider(postId));

    return Scaffold(
      appBar: AppBar(title: const Text('Detalle del post')),
      body: postAsync.when(
        data: (post) {
          if (post == null) {
            return const Center(child: Text('Post no encontrado'));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                PostCard(post: post, heroTag: 'postHero_${post.postId}'),
                const SizedBox(height: 16),
                Text(
                  'Comentarios',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                CommentList(postId: post.postId),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  icon: const Icon(Icons.add_comment),
                  label: const Text('Agregar comentario'),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder:
                          (_) => NewPostForm(parentId: post.postId, depth: 1),
                    );
                  },
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error al cargar post: $e')),
      ),
    );
  }
}
