import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gabimaps/features/posts/ui/widgets/create_post_button.dart';
import '../../posts/data/post_model.dart';
import '../provider/posts_provider.dart';
import 'post_detail_page.dart';
import 'widgets/new_post_form.dart';
import 'widgets/post_card.dart';

class PostsPage extends ConsumerWidget{

  const PostsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final postsAsync = ref.watch(filteredPostsProvider);
    final selectedType = ref.watch(postTypeFilterProvider);
    final selectedVisibility = ref.watch(postVisibilityFilterProvider);     

    return Scaffold(
      appBar: AppBar(
        title: const Text('Publicaciones'),
        actions: [
          // Botón para limpiar filtros
          IconButton(
            icon: const Icon(Icons.clear_all),
            tooltip: 'Limpiar filtros',
            onPressed: () {
              ref.read(postTypeFilterProvider.notifier).state = null;
              ref.read(postVisibilityFilterProvider.notifier).state = null;
            },
          ),
          // Botón para crear una nueva publicación
          const CreatePostButton(
            isOfficial: true,
          ),
        ],
      ),
      body: Column(
        children: [
          _FiltersRow(
            selectedType: selectedType,
            selectedVisibility: selectedVisibility,
            onTypeChanged:
                (newType) =>
                    ref.read(postTypeFilterProvider.notifier).state = newType,
            onVisibilityChanged:
                (newVis) =>
                    ref.read(postVisibilityFilterProvider.notifier).state =
                        newVis,
          ),
          const Divider(),
          Expanded(
            child: postsAsync.when(
              data: (posts) {
                if (posts.isEmpty) {
                  return const Center(child: Text('No hay publicaciones'));
                }

                return ListView.builder(
                  itemCount: posts.length,
                  itemBuilder: (context, index) {
                    final post = posts[index];
                    return PostCard(
                      post: post,
                      onTap:
                          () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (_) => PostDetailPage(postId: post.postId),
                            ),
                          ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(context: context, builder: (_) => const NewPostForm());
        },
        child: const Icon(Icons.add),
        tooltip: 'Nueva publicación',
      ),
    );
  }
}

class _FiltersRow extends StatelessWidget {
  final PostType? selectedType;
  final PostVisibility? selectedVisibility;
  final ValueChanged<PostType?> onTypeChanged;
  final ValueChanged<PostVisibility?> onVisibilityChanged;

  const _FiltersRow({
    required this.selectedType,
    required this.selectedVisibility,
    required this.onTypeChanged,
    required this.onVisibilityChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: DropdownButton<PostType?>(
              value: selectedType,
              isExpanded: true,
              hint: const Text('Tipo'),
              onChanged: onTypeChanged,
              items: [
                const DropdownMenuItem(value: null, child: Text('Todos')),
                ...PostType.values
                    .where((t) => t != PostType.comment)
                    .map(
                      (type) => DropdownMenuItem(
                        value: type,
                        child: Text(type.displayName),
                      ),
                    ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: DropdownButton<PostVisibility?>(
              value: selectedVisibility,
              isExpanded: true,
              hint: const Text('Visibilidad'),
              onChanged: onVisibilityChanged,
              items: [
                const DropdownMenuItem(value: null, child: Text('Todas')),
                ...PostVisibility.values.map(
                  (vis) => DropdownMenuItem(value: vis, child: Text(vis.name)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
