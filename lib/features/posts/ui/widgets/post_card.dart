import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gabimaps/features/user/data/user_model.dart';
import 'package:gabimaps/features/user/providers/user_providers.dart';
import '../../data/post_model.dart';
import '../../provider/posts_provider.dart';
import 'reaction_buttons.dart';

final userDataProvider = FutureProvider.family<UserModel, String>((
  ref,
  userId,
) async {
  final userRepository = ref.read(userRepositoryProvider);
  return await userRepository.getUser(userId);
});

class PostCard extends ConsumerWidget {
  final Post post;
  final bool showActions;
  final bool isInThread;
  final VoidCallback? onTap;
  final String? heroTag;



  const PostCard({
    Key? key,
    required this.post,
    this.showActions = true,
    this.isInThread = false,
    this.onTap,
    this.heroTag,

  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final postsNotifier = ref.read(postsNotifierProvider.notifier);
    final theme = Theme.of(context);
    final userAsync = ref.watch(userDataProvider(post.userId));


    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with user info, type and date
              Row(
                children: [
                  // User avatar placeholder
                  // User avatar
                  userAsync.when(
                    loading:
                        () => const CircleAvatar(
                          child: CircularProgressIndicator(),
                        ),
                    error:
                        (error, stack) =>
                            const CircleAvatar(child: Icon(Icons.error)),
                    data:
                        (user) => CircleAvatar(
                          backgroundImage:
                              user.photoURL != null
                                  ? NetworkImage(user.photoURL!)
                                  : const AssetImage(
                                    'assets/images/default_avatar.jpg',
                                  ),
                        ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            userAsync.when(
                              loading:
                                  () => Text(
                                    'Cargando...',
                                    style: theme.textTheme.bodyLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                              error:
                                  (error, stack) => Text(
                                    'Usuario ${post.userId.substring(0, 4)}',
                                    style: theme.textTheme.bodyLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                              data:
                                  (user) => Text(
                                    user.nombre ??
                                        'Usuario ${post.userId.substring(0, 4)}',
                                    style: theme.textTheme.bodyLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                            ),
                            if (post.isOfficial)
                              Padding(
                                padding: const EdgeInsets.only(left: 4),
                                child: Icon(
                                  Icons.verified,
                                  color: Colors.blue,
                                  size: 16,
                                ),
                              ),
                          ],
                        ),
                        Text(
                          '${post.type.displayName} · ${_formatDate(post.createdAt)}',
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),

                  // Post options menu
                  if (showActions)
                    PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'delete') {
                          postsNotifier.deletePost(post.postId);
                        }
                      },
                      itemBuilder:
                          (context) => [
                            if (post.type != PostType.comment)
                              const PopupMenuItem(
                                value: 'edit',
                                child: Row(
                                  children: [
                                    Icon(Icons.edit),
                                    SizedBox(width: 8),
                                    Text('Editar'),
                                  ],
                                ),
                              ),
                            const PopupMenuItem(
                              value: 'delete',
                              child: Row(
                                children: [
                                  Icon(Icons.delete, color: Colors.red),
                                  SizedBox(width: 8),
                                  Text('Eliminar'),
                                ],
                              ),
                            ),
                          ],
                    ),
                ],
              ),

              // Title (only for main posts)
              if (post.title != null && post.depth == 0)
                Padding(
                  padding: const EdgeInsets.only(top: 12, bottom: 8),
                  child: Text(post.title!, style: theme.textTheme.titleLarge),
                ),

              // Post content
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(post.content),
              ),

              // Media attachments
              if (post.mediaUrls != null && post.mediaUrls!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                     
                    child:
                        heroTag != null
                            ? Hero(
                              tag: heroTag!,
                              child: Image.network(
                                post.mediaUrls!.first,
                                height: 200,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder:
                                    (context, error, stackTrace) => Container(
                                      height: 120,
                                      color: Colors.grey.shade300,
                                      child: const Center(
                                        child: Icon(Icons.image_not_supported),
                                      ),
                                    ),
                              ),
                            )
                            : Image.network(
                              post.mediaUrls!.first,
                              height: 200,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder:
                                  (context, error, stackTrace) => Container(
                                    height: 120,
                                    color: Colors.grey.shade300,
                                    child: const Center(
                                      child: Icon(Icons.image_not_supported),
                                    ),
                                  ),
                            ),
                    
                  ),
                ),

              // Custom fields for institutional posts
              if (post.customFields != null && post.customFields!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: _buildCustomFields(post.customFields!, post.type),
                ),

              // Reactions and comments
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Reaction buttons
                    ReactionButtons(postId: post.postId),

                    // Comments counter
                    if (!isInThread && post.depth < 2)
                      TextButton.icon(
                        onPressed: onTap,
                        icon: const Icon(Icons.comment_outlined),
                        label: Text('${post.commentsCount}'),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper method to format date
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays}d';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m';
    } else {
      return 'ahora';
    }
  }

  // Helper method to build custom fields based on post type
  Widget _buildCustomFields(Map<String, dynamic> customFields, PostType type) {
    if (type == PostType.event) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(),
          if (customFields['startDate'] != null)
            _buildInfoRow(
              Icons.calendar_today,
              'Fecha: ${_formatFullDate(customFields['startDate'])}',
            ),
          if (customFields['organizer'] != null)
            _buildInfoRow(
              Icons.group,
              'Organizador: ${customFields['organizer']}',
            ),
          if (customFields['registrationLink'] != null)
            _buildInfoRow(
              Icons.link,
              'Registro: ${customFields['registrationLink']}',
            ),
        ],
      );
    } else if (type == PostType.scholarship) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(),
          if (customFields['deadline'] != null)
            _buildInfoRow(
              Icons.calendar_today,
              'Fecha límite: ${_formatFullDate(customFields['deadline'])}',
            ),
          if (customFields['amount'] != null)
            _buildInfoRow(
              Icons.attach_money,
              'Monto: ${customFields['amount']}',
            ),
        ],
      );
    }

    // Default for other types
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children:
          customFields.entries.map((entry) {
            return _buildInfoRow(
              Icons.info_outline,
              '${entry.key}: ${entry.value}',
            );
          }).toList(),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16),
          const SizedBox(width: 8),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }

  String _formatFullDate(dynamic dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateStr.toString();
    }
  }
}
