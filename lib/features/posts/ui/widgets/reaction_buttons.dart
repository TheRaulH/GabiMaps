import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/reaction_model.dart';
import '../../provider/reaction_provider.dart';

class ReactionButtons extends ConsumerWidget {
  final String postId;

  const ReactionButtons({Key? key, required this.postId}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reactionState = ref.watch(reactionInterfaceProvider(postId));
    final reactionNotifier = ref.read(reactionNotifierProvider.notifier);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Like button
        IconButton(
          icon: Icon(
            reactionState.isLiked ? Icons.thumb_up : Icons.thumb_up_outlined,
            color: reactionState.isLiked ? Colors.blue : null,
          ),
          onPressed: () => reactionNotifier.likePost(postId),
        ),
        Text('${reactionState.likesCount}'),
        const SizedBox(width: 16),

        // Dislike button
        IconButton(
          icon: Icon(
            reactionState.isDisliked
                ? Icons.thumb_down
                : Icons.thumb_down_outlined,
            color: reactionState.isDisliked ? Colors.red : null,
          ),
          onPressed: () => reactionNotifier.dislikePost(postId),
        ),
        Text('${reactionState.dislikesCount}'),
      ],
    );
  }
}
