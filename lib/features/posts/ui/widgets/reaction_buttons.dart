import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/reaction_model.dart';
import '../../provider/reaction_provider.dart';

class ReactionButtons extends ConsumerStatefulWidget {
  final String postId;

  const ReactionButtons({Key? key, required this.postId}) : super(key: key);

  @override
  ConsumerState<ReactionButtons> createState() => _ReactionButtonsState();
}

class _ReactionButtonsState extends ConsumerState<ReactionButtons> {
  bool _isLikeAnimating = false;
  bool _isDislikeAnimating = false;

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(milliseconds: 1200),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final reactionState = ref.watch(reactionInterfaceProvider(widget.postId));
    final reactionNotifier = ref.read(reactionNotifierProvider.notifier);
    final theme = Theme.of(context);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Like button with animation
        _buildReactionButton(
          isActive: reactionState.isLiked,
          isAnimating: _isLikeAnimating,
          activeIcon: Icons.thumb_up,
          inactiveIcon: Icons.thumb_up_outlined,
          activeColor: Colors.blue,
          count: reactionState.likesCount,
          onPressed: () async {
            if (_isLikeAnimating) return;

            setState(() => _isLikeAnimating = true);
            await reactionNotifier.likePost(widget.postId);
            setState(() => _isLikeAnimating = false);

            _showSnack(
              reactionState.isLiked ? 'Like eliminado' : 'Te gustó el post',
            );
          },
        ),
        const SizedBox(width: 16),

        // Dislike button with animation
        _buildReactionButton(
          isActive: reactionState.isDisliked,
          isAnimating: _isDislikeAnimating,
          activeIcon: Icons.thumb_down,
          inactiveIcon: Icons.thumb_down_outlined,
          activeColor: Colors.red,
          count: reactionState.dislikesCount,
          onPressed: () async {
            if (_isDislikeAnimating) return;

            setState(() => _isDislikeAnimating = true);
            await reactionNotifier.dislikePost(widget.postId);
            setState(() => _isDislikeAnimating = false);

            _showSnack(
              reactionState.isDisliked
                  ? 'Dislike eliminado'
                  : 'No te gustó el post',
            );
          },
        ),
      ],
    );
  }

  Widget _buildReactionButton({
    required bool isActive,
    required bool isAnimating,
    required IconData activeIcon,
    required IconData inactiveIcon,
    required Color activeColor,
    required int count,
    required VoidCallback onPressed,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: onPressed,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (child, animation) {
              return ScaleTransition(scale: animation, child: child);
            },
            child:
                isAnimating
                    ? SizedBox(
                      key: ValueKey('animating_$isActive'),
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          isActive ? activeColor : Colors.grey,
                        ),
                      ),
                    )
                    : Icon(
                      key: ValueKey('icon_$isActive'),
                      isActive ? activeIcon : inactiveIcon,
                      color: isActive ? activeColor : Colors.grey[600],
                      size: 24,
                    ),
          ),
        ),
        const SizedBox(width: 4),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          transitionBuilder: (child, animation) {
            return FadeTransition(
              opacity: animation,
              child: SizeTransition(
                sizeFactor: animation,
                axis: Axis.horizontal,
                child: child,
              ),
            );
          },
          child: Text(
            key: ValueKey('count_$count'),
            '$count',
            style: TextStyle(
              color: isActive ? activeColor : Colors.grey[600],
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ],
    );
  }
}
