import 'package:flutter_riverpod/flutter_riverpod.dart'; 
import 'package:gabimaps/features/posts/data/post_model.dart';
import '../data/reaction_model.dart';
import '../data/posts_repository.dart';
import 'posts_provider.dart';

/// Provider para obtener la reacción de un usuario a un post específico
final userReactionProvider = FutureProvider.autoDispose
    .family<Reaction?, String>((ref, postId) {
      final repository = ref.watch(postsRepositoryProvider);
      return repository.getUserReaction(postId: postId);
    });

/// Provider para verificar si el usuario actual ha dado like a un post
final userLikedPostProvider = FutureProvider.autoDispose.family<bool, String>((
  ref,
  postId,
) async {
  final reaction = await ref.watch(userReactionProvider(postId).future);
  return reaction?.type == ReactionType.like;
});

/// Provider para verificar si el usuario actual ha dado dislike a un post
final userDislikedPostProvider = FutureProvider.autoDispose
    .family<bool, String>((ref, postId) async {
      final reaction = await ref.watch(userReactionProvider(postId).future);
      return reaction?.type == ReactionType.dislike;
    });

/// StateNotifier para gestionar las reacciones a posts
class ReactionNotifier extends StateNotifier<AsyncValue<void>> {
  final PostsRepository _repository;
  final Ref ref; // <-- Añade esto


  ReactionNotifier(this._repository, this.ref)
    : super(const AsyncValue.data(null));

  /// Agrega o cambia una reacción a un post
  Future<void> toggleReaction({
    required String postId,
    required ReactionType type,
  }) async {
    state = const AsyncValue.loading();
    try {
      await _repository.addReaction(postId: postId, type: type);

      // 🚨 Fuerza recarga de los datos de reacción del usuario
      ref.invalidate(userReactionProvider(postId));
      ref.invalidate(userLikedPostProvider(postId));
      ref.invalidate(userDislikedPostProvider(postId));
      ref.invalidate(postByIdProvider(postId));

      // 🚨 También podrías querer recargar el post (para likes/dislikesCount actualizados)
      ref.invalidate(postByIdProvider(postId));

      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  /// Da like a un post
  Future<void> likePost(String postId) async {
    await toggleReaction(postId: postId, type: ReactionType.like);
  }

  /// Da dislike a un post
  Future<void> dislikePost(String postId) async {
    await toggleReaction(postId: postId, type: ReactionType.dislike);
  }
}

/// Provider para el notificador de reacciones
final reactionNotifierProvider =
    StateNotifierProvider<ReactionNotifier, AsyncValue<void>>((ref) {
      final repository = ref.watch(postsRepositoryProvider);
      return ReactionNotifier(repository, ref); // <-- aquí va el ref
    });

/// Provider para post populares (más likes)
final popularPostsProvider = StreamProvider.autoDispose<List<Post>>((ref) {
  final repository = ref.watch(postsRepositoryProvider);
  final typeFilter = ref.watch(postTypeFilterProvider);

  // Aquí usaríamos una consulta específica para posts populares
  // Como Firestore no permite ordenar por campos que no están en la consulta where,
  // tendríamos que obtener los posts filtrados y luego ordenarlos en el cliente

  // Para simplificar, obtenemos los posts normales y los ordenamos por likes
  if (typeFilter != null) {
    return repository
        .getInstitutionalPosts(type: typeFilter)
        .map(
          (posts) =>
              posts..sort((a, b) => b.likesCount.compareTo(a.likesCount)),
        );
  } else {
    return repository.getMainPosts().map(
      (posts) => posts..sort((a, b) => b.likesCount.compareTo(a.likesCount)),
    );
  }
});

/// Provider para mostrar la interfaz de reacción adecuada según el estado actual
final reactionInterfaceProvider = Provider.family<
  ({bool isLiked, bool isDisliked, int likesCount, int dislikesCount}),
  String
>((ref, postId) {
  // Valor por defecto mientras se carga
  var result = (
    isLiked: false,
    isDisliked: false,
    likesCount: 0,
    dislikesCount: 0,
  );

  // Intentar obtener el post
  final postAsync = ref.watch(postByIdProvider(postId));
  final userLikedAsync = ref.watch(userLikedPostProvider(postId));
  final userDislikedAsync = ref.watch(userDislikedPostProvider(postId));

  // Combinar la información cuando está disponible
  return postAsync.when(
    data: (post) {
      if (post != null) {
        result = (
          isLiked: userLikedAsync.value ?? false,
          isDisliked: userDislikedAsync.value ?? false,
          likesCount: post.likesCount,
          dislikesCount: post.dislikesCount,
        );
      }
      return result;
    },
    loading: () => result,
    error: (_, __) => result,
  );
});
