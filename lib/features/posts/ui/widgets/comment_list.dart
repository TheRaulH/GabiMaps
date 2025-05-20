import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/post_model.dart';
import '../../provider/posts_provider.dart';
import 'post_card.dart';

class CommentList extends ConsumerWidget {
  final String postId;

  const CommentList({Key? key, required this.postId}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final commentsAsync = ref.watch(postCommentsProvider(postId));

    return commentsAsync.when(
      data: (comments) {
        if (comments.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Text('No hay comentarios todavía'),
            ),
          );
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: comments.length,
          itemBuilder: (context, index) {
            final comment = comments[index];
            final isExpanded = ref.watch(
              threadExpandedStateProvider(comment.postId),
            );

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Comment card
                PostCard(
                  post: comment,
                  isInThread: true,
                  heroTag: 'commentHero_${comment.postId}',
                ),

                // Replies section
                if (comment.commentsCount > 0)
                  Padding(
                    padding: const EdgeInsets.only(left: 32),
                    child: TextButton.icon(
                      icon: Icon(
                        isExpanded ? Icons.expand_less : Icons.expand_more,
                      ),
                      label: Text(
                        isExpanded
                            ? 'Ocultar respuestas'
                            : 'Ver ${comment.commentsCount} respuestas',
                      ),
                      onPressed: () {
                        ref
                            .read(
                              threadExpandedStateProvider(
                                comment.postId,
                              ).notifier,
                            )
                            .state = !isExpanded;
                      },
                    ),
                  ),

                // Show replies if expanded
                if (isExpanded && comment.commentsCount > 0)
                  _RepliesList(commentId: comment.postId),

                // New reply form
                if (isExpanded)
                  Padding(
                    padding: const EdgeInsets.only(left: 32),
                    child: _ReplyForm(parentCommentId: comment.postId),
                  ),
              ],
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error:
          (error, stackTrace) =>
              Center(child: Text('Error al cargar comentarios: $error')),
    );
  }
}

// Widget to show replies to a comment
class _RepliesList extends ConsumerWidget {
  final String commentId;

  const _RepliesList({Key? key, required this.commentId}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repliesAsync = ref.watch(commentRepliesProvider(commentId));

    return repliesAsync.when(
      data: (replies) {
        if (replies.isEmpty) {
          return const SizedBox();
        }

        return Padding(
          padding: const EdgeInsets.only(left: 32),
          child: ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: replies.length,
            itemBuilder: (context, index) {
              return PostCard(post: replies[index], isInThread: true);
            },
          ),
        );
      },
      loading:
          () => const Padding(
            padding: EdgeInsets.all(8.0),
            child: Center(child: CircularProgressIndicator()),
          ),
      error:
          (error, stackTrace) => Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text('Error al cargar respuestas: $error'),
          ),
    );
  }
}

// Widget to create a new reply
class _ReplyForm extends ConsumerStatefulWidget {
  final String parentCommentId;

  const _ReplyForm({Key? key, required this.parentCommentId}) : super(key: key);

  @override
  _ReplyFormState createState() => _ReplyFormState();
}

class _ReplyFormState extends ConsumerState<_ReplyForm> {
  final _controller = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submitReply() async {
    if (_controller.text.trim().isEmpty) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      await ref
          .read(postsNotifierProvider.notifier)
          .createReply(
            parentCommentId: widget.parentCommentId,
            content: _controller.text.trim(),
            isOfficial: false, // Configura según necesites
          );

      _controller.clear();
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: const InputDecoration(
                hintText: 'Escribe una respuesta...',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
              maxLines: 1,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _submitReply(),
            ),
          ),
          IconButton(
            icon:
                _isSubmitting
                    ? const CircularProgressIndicator()
                    : const Icon(Icons.send),
            onPressed: _isSubmitting ? null : _submitReply,
          ),
        ],
      ),
    );
  }
}
