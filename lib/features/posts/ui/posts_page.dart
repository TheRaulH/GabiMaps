import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gabimaps/features/auth/providers/auth_providers.dart';
import 'package:gabimaps/features/posts/ui/my_posts_page.dart';
import 'package:gabimaps/features/posts/ui/widgets/create_post_button.dart';
import 'package:gabimaps/features/user/providers/user_providers.dart';
import '../../posts/data/post_model.dart';
import '../provider/posts_provider.dart';
import 'post_detail_page.dart';
import 'widgets/new_post_form.dart';
import 'widgets/post_card.dart';

class PostsPage extends ConsumerWidget {
  const PostsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final postsAsync = ref.watch(filteredPostsProvider);
    final selectedType = ref.watch(postTypeFilterProvider);
    final selectedVisibility = ref.watch(postVisibilityFilterProvider);
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    //obtener uduario autenticado
    final authUser = ref.watch(userModelProvider).value;

    return Scaffold(
      appBar: AppBar(
        //quitar boton de retroceso
        automaticallyImplyLeading: false,
        //agregar icono del usuario y el nombre
        title: GestureDetector(
          // <--- Envuelve el Row con GestureDetector
          onTap: () {
            // Aquí es donde navegas a MyPostsPage
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MyPostsPage(),
              ), // Asegúrate de que MyPostsPage esté importada
            );
          },
          child: Row(
            children: [
              CircleAvatar(
                backgroundImage:
                    authUser?.photoURL != null
                        ? NetworkImage(authUser!.photoURL!)
                        : const AssetImage('assets/images/default_avatar.jpg')
                            as ImageProvider,
                radius: 15,
              ),
              const SizedBox(width: 8),
              Text(
                authUser?.nombre ?? 'Usuario',
                //tamano de texto chico
                style: theme.textTheme.titleMedium?.copyWith(
                  fontSize: 18,
                  color:
                      isDarkMode
                          ? theme.colorScheme.onSurface
                          : theme.colorScheme.onBackground,
                ),
              ),
            ],
          ),
        ),

        centerTitle: true,
        elevation: 0,
        actions: [
          // Botón para limpiar filtros con mejor feedback visual
          Tooltip(
            message: 'Limpiar filtros',
            child: IconButton(
              icon: Icon(
                Icons.filter_alt_off,
                color:
                    (selectedType != null || selectedVisibility != null)
                        ? theme.colorScheme.secondary
                        : theme.iconTheme.color?.withOpacity(0.5),
              ),
              onPressed: () {
                ref.read(postTypeFilterProvider.notifier).state = null;
                ref.read(postVisibilityFilterProvider.notifier).state = null;
              },
            ),
          ),
          const SizedBox(width: 8),
          // Botón para crear publicación con mejor estilo
          const Padding(
            padding: EdgeInsets.only(right: 12),
            child: CreatePostButton(isOfficial: true),
          ),
        ],
      ),
      body: Column(
        children: [
          // Filtros con mejor diseño
          Material(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: _FiltersRow(
                selectedType: selectedType,
                selectedVisibility: selectedVisibility,
                onTypeChanged:
                    (newType) =>
                        ref.read(postTypeFilterProvider.notifier).state =
                            newType,
                onVisibilityChanged:
                    (newVis) =>
                        ref.read(postVisibilityFilterProvider.notifier).state =
                            newVis,
              ),
            ),
          ),
          // Lista de publicaciones con mejor manejo de estados
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                // Aquí podrías añadir lógica para recargar los posts
                ref.invalidate(filteredPostsProvider);
              },
              child: postsAsync.when(
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
                            'No hay publicaciones',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: theme.disabledColor,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Intenta cambiar los filtros o crear una nueva',
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
                          heroTag: 'postHero_${post.postId}',
                          onTap:
                              () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (_) =>
                                          PostDetailPage(postId: post.postId),
                                ),
                              ).then((_) {
                                // Actualizar la vista al volver si es necesario
                                ref.invalidate(filteredPostsProvider);
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
                            'Error al cargar publicaciones',
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
                                () => ref.invalidate(filteredPostsProvider),
                          ),
                        ],
                      ),
                    ),
              ),
            ),
          ),
        ],
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
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Row(
      children: [
        Expanded(
          child: InputDecorator(
            decoration: InputDecoration(
              labelText: 'Tipo',
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 4,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: theme.dividerColor.withOpacity(0.5),
                  width: 1,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: theme.dividerColor.withOpacity(0.5),
                  width: 1,
                ),
              ),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<PostType?>(
                value: selectedType,
                isExpanded: true,
                icon: const Icon(Icons.arrow_drop_down),
                style: theme.textTheme.bodyMedium,
                dropdownColor:
                    isDarkMode
                        ? theme.colorScheme.surface
                        : theme.colorScheme.background,
                borderRadius: BorderRadius.circular(12),
                onChanged: onTypeChanged,
                items: [
                  const DropdownMenuItem(
                    value: null,
                    child: Text('Todos los tipos'),
                  ),
                  ...PostType.values
                      .where((t) => t != PostType.comment)
                      .map(
                        (type) => DropdownMenuItem(
                          value: type,
                          child: Row(
                            children: [
                              Icon(
                                _getTypeIcon(type),
                                size: 20,
                                color: theme.colorScheme.onSurface,
                              ),
                              const SizedBox(width: 8),
                              Text(type.displayName),
                            ],
                          ),
                        ),
                      ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: InputDecorator(
            decoration: InputDecoration(
              labelText: 'Visibilidad',
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 4,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: theme.dividerColor.withOpacity(0.5),
                  width: 1,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: theme.dividerColor.withOpacity(0.5),
                  width: 1,
                ),
              ),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<PostVisibility?>(
                value: selectedVisibility,
                isExpanded: true,
                icon: const Icon(Icons.arrow_drop_down),
                style: theme.textTheme.bodyMedium,
                dropdownColor:
                    isDarkMode
                        ? theme.colorScheme.surface
                        : theme.colorScheme.background,
                borderRadius: BorderRadius.circular(12),
                onChanged: onVisibilityChanged,
                items: [
                  const DropdownMenuItem(
                    value: null,
                    child: Text('Todas las visibilidades'),
                  ),
                  ...PostVisibility.values.map(
                    (vis) => DropdownMenuItem(
                      value: vis,
                      child: Row(
                        children: [
                          Icon(
                            _getVisibilityIcon(vis),
                            size: 20,
                            color: theme.colorScheme.onSurface,
                          ),
                          const SizedBox(width: 8),
                          Text(vis.name),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  IconData _getTypeIcon(PostType type) {
    switch (type) {
      case PostType.general:
        return Icons.article;
      case PostType.event:
        return Icons.event;
      case PostType.internship:
        return Icons.warning;
      case PostType.comment:
        return Icons.comment;
      default:
        return Icons.post_add;
    }
  }

  IconData _getVisibilityIcon(PostVisibility vis) {
    switch (vis) {
      case PostVisibility.public:
        return Icons.public;
      case PostVisibility.teachers:
        return Icons.lock;
      case PostVisibility.university:
        return Icons.people;
      default:
        return Icons.visibility;
    }
  }
}
