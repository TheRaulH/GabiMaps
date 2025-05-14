import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../data/post_model.dart';
import '../data/posts_repository.dart';

/// Provider para el repositorio de posts
final postsRepositoryProvider = Provider<PostsRepository>((ref) {
  return PostsRepository(
    firestore: FirebaseFirestore.instance,
    auth: FirebaseAuth.instance,
  );
});

/// Provider para obtener posts principales con paginación
final mainPostsProvider = StreamProvider.autoDispose
    .family<List<Post>, DocumentSnapshot?>((ref, lastDocument) {
      final repository = ref.watch(postsRepositoryProvider);
      return repository.getMainPosts(startAfter: lastDocument);
    });

/// Provider para obtener posts institucionales por tipo
final institutionalPostsProvider = StreamProvider.autoDispose.family<
  List<Post>,
  ({PostType type, PostVisibility? visibility, DocumentSnapshot? startAfter})
>((ref, params) {
  final repository = ref.watch(postsRepositoryProvider);
  return repository.getInstitutionalPosts(
    type: params.type,
    visibility: params.visibility,
    startAfter: params.startAfter,
  );
});

/// Provider para obtener los posts de un usuario específico
final userPostsProvider = StreamProvider.autoDispose.family<List<Post>, String>(
  (ref, userId) {
    final repository = ref.watch(postsRepositoryProvider);
    return repository.getUserPosts(userId);
  },
);

/// Provider para obtener un post específico por ID
final postByIdProvider = FutureProvider.autoDispose.family<Post?, String>((
  ref,
  postId,
) {
  final repository = ref.watch(postsRepositoryProvider);
  return repository.getPostById(postId);
});

/// Provider para obtener los comentarios directos de un post
final postCommentsProvider = StreamProvider.autoDispose
    .family<List<Post>, String>((ref, postId) {
      final repository = ref.watch(postsRepositoryProvider);
      return repository.getPostComments(postId);
    });

/// Provider para obtener las respuestas a un comentario
final commentRepliesProvider = StreamProvider.autoDispose
    .family<List<Post>, String>((ref, commentId) {
      final repository = ref.watch(postsRepositoryProvider);
      return repository.getCommentReplies(commentId);
    });

/// Provider para obtener todo el hilo de discusión de un post
final threadPostsProvider = StreamProvider.autoDispose
    .family<List<Post>, String>((ref, threadId) {
      final repository = ref.watch(postsRepositoryProvider);
      return repository.getThreadPosts(threadId);
    });

/// StateNotifier para gestionar la creación y actualización de posts
class PostsNotifier extends StateNotifier<AsyncValue<void>> {
  final PostsRepository _repository;

  PostsNotifier(this._repository) : super(const AsyncValue.data(null));

  /// Crea un nuevo post principal
  Future<void> createPost({
    required PostType type,
    required String title,
    required String content,
    List<String>? mediaUrls,
    String? locationId,
    required PostVisibility visibility,
    required bool isOfficial,
    Map<String, dynamic>? customFields,
  }) async {
    state = const AsyncValue.loading();
    try {
      await _repository.createPost(
        type: type,
        title: title,
        content: content,
        mediaUrls: mediaUrls,
        locationId: locationId,
        visibility: visibility,
        isOfficial: isOfficial,
        customFields: customFields,
      );
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  /// Actualiza un post existente
  Future<void> updatePost({
    required String postId,
    String? title,
    String? content,
    List<String>? mediaUrls,
    String? locationId,
    PostVisibility? visibility,
    Map<String, dynamic>? customFields,
  }) async {
    state = const AsyncValue.loading();
    try {
      await _repository.updatePost(
        postId: postId,
        title: title,
        content: content,
        mediaUrls: mediaUrls,
        locationId: locationId,
        visibility: visibility,
        customFields: customFields,
      );
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  /// Elimina un post
  Future<void> deletePost(String postId) async {
    state = const AsyncValue.loading();
    try {
      await _repository.deletePost(postId);
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  /// Crea un nuevo comentario en un post
  Future<void> createComment({
    required String parentPostId,
    required String content,
    List<String>? mediaUrls,
    required bool isOfficial,
  }) async {
    state = const AsyncValue.loading();
    try {
      await _repository.createComment(
        parentPostId: parentPostId,
        content: content,
        mediaUrls: mediaUrls,
        isOfficial: isOfficial,
      );
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  /// Crea una respuesta a un comentario
  Future<void> createReply({
    required String parentCommentId,
    required String content,
    List<String>? mediaUrls,
    required bool isOfficial,
  }) async {
    state = const AsyncValue.loading();
    try {
      await _repository.createReply(
        parentCommentId: parentCommentId,
        content: content,
        mediaUrls: mediaUrls,
        isOfficial: isOfficial,
      );
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}

/// Provider para el notificador de posts
final postsNotifierProvider =
    StateNotifierProvider<PostsNotifier, AsyncValue<void>>((ref) {
      final repository = ref.watch(postsRepositoryProvider);
      return PostsNotifier(repository);
    });

/// Provider para track del estado de paginación (se puede usar con InfiniteScroll)
final postsPageStateProvider = StateProvider.autoDispose<
  ({bool isLoading, bool hasMore, DocumentSnapshot? lastDocument})
>((ref) {
  return (isLoading: false, hasMore: true, lastDocument: null);
});

/// Provider de tipo futuro para cargar más posts (paginación)
final loadMorePostsProvider = FutureProvider.autoDispose<void>((ref) async {
  final pageState = ref.watch(postsPageStateProvider);

  // Si ya estamos cargando o no hay más posts, no hacer nada
  if (pageState.isLoading || !pageState.hasMore) return;

  // Marcar como cargando
  ref.read(postsPageStateProvider.notifier).state = (
    isLoading: true,
    hasMore: pageState.hasMore,
    lastDocument: pageState.lastDocument,
  );

  try {
    // Observar posts con el último documento como referencia
    final postsAsync = ref.watch(mainPostsProvider(pageState.lastDocument));

    // Esperar a que se resuelva la operación
    await postsAsync.whenData((posts) {
      // Actualizar el estado de paginación
      if (posts.isEmpty || posts.length < 20) {
        // 20 es el límite por defecto
        ref.read(postsPageStateProvider.notifier).state = (
          isLoading: false,
          hasMore: false,
          lastDocument: pageState.lastDocument,
        );
      } else {
        // Actualizar el último documento para la siguiente paginación
        final lastDoc =
            posts.isNotEmpty
                ? FirebaseFirestore.instance
                    .collection('posts')
                    .doc(posts.last.postId)
                : null;

        ref.read(postsPageStateProvider.notifier).state = (
          isLoading: false,
          hasMore: true,
          lastDocument: lastDoc as DocumentSnapshot?,
        );
      }
    }).value;
  } catch (e) {
    // En caso de error, dejamos de cargar pero mantenemos hasMore en true para reintentar
    ref.read(postsPageStateProvider.notifier).state = (
      isLoading: false,
      hasMore: true,
      lastDocument: pageState.lastDocument,
    );
    throw e;
  }
});

/// Provider para filtrar posts por tipo
final postTypeFilterProvider = StateProvider<PostType?>((ref) => null);

/// Provider para filtrar posts por visibilidad
final postVisibilityFilterProvider = StateProvider<PostVisibility?>(
  (ref) => null,
);

/// Provider combinado que filtra los posts según los criterios seleccionados
final filteredPostsProvider = StreamProvider.autoDispose<List<Post>>((ref) {
  final typeFilter = ref.watch(postTypeFilterProvider);
  final visibilityFilter = ref.watch(postVisibilityFilterProvider);
  final repository = ref.watch(postsRepositoryProvider);

  if (typeFilter != null) {
    return repository.getInstitutionalPosts(
      type: typeFilter,
      visibility: visibilityFilter,
    );
  } else {
    return repository.getMainPosts();
  }
});

/// Provider para mantener el estado de un hilo de discusión expandido
final threadExpandedStateProvider = StateProvider.family<bool, String>(
  (ref, commentId) => false,
);
