import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../data/post_model.dart';
import '../data/reaction_model.dart';

/// Repositorio para manejar las operaciones de Firestore relacionadas con los posts
class PostsRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  PostsRepository({FirebaseFirestore? firestore, FirebaseAuth? auth})
    : _firestore = firestore ?? FirebaseFirestore.instance,
      _auth = auth ?? FirebaseAuth.instance;

  /// Referencia a la colección de posts
  CollectionReference get _postsCollection => _firestore.collection('posts');

  /// Obtiene un post por su ID
  Future<Post?> getPostById(String postId) async {
    final doc = await _postsCollection.doc(postId).get();
    if (!doc.exists) return null;
    return Post.fromJson(doc.data() as Map<String, dynamic>);
  }

  /// Crea un nuevo post raíz
  Future<Post> createPost({
    required PostType type,
    required String title,
    required String content,
    List<String>? mediaUrls,
    String? locationId,
    required PostVisibility visibility,
    required bool isOfficial,
    Map<String, dynamic>? customFields,
  }) async {
    if (_auth.currentUser == null) {
      throw Exception('No hay usuario autenticado');
    }

    final post = Post.createRoot(
      userId: _auth.currentUser!.uid,
      type: type,
      title: title,
      content: content,
      mediaUrls: mediaUrls,
      locationId: locationId,
      visibility: visibility,
      isOfficial: isOfficial,
      customFields: customFields,
    );

    await _postsCollection.doc(post.postId).set(post.toJson());
    return post;
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
    final post = await getPostById(postId);
    if (post == null) {
      throw Exception('Post no encontrado');
    }

    if (_auth.currentUser == null || _auth.currentUser!.uid != post.userId) {
      throw Exception('No tienes permiso para actualizar este post');
    }

    final DateTime now = DateTime.now();
    final updatedPost = post.copyWith(
      title: title,
      content: content,
      mediaUrls: mediaUrls,
      locationId: locationId,
      visibility: visibility,
      updatedAt: now,
      customFields: customFields,
    );

    await _postsCollection.doc(postId).update(updatedPost.toJson());
  }

  /// Elimina un post
  Future<void> deletePost(String postId) async {
    final post = await getPostById(postId);
    if (post == null) {
      throw Exception('Post no encontrado');
    }

    if (_auth.currentUser == null || _auth.currentUser!.uid != post.userId) {
      throw Exception('No tienes permiso para eliminar este post');
    }

    // Si es un post raíz, eliminar también todos los comentarios y respuestas
    if (post.depth == 0) {
      final QuerySnapshot commentsSnapshot =
          await _postsCollection
              .where('threadId', isEqualTo: postId)
              .where('postId', isNotEqualTo: postId) // Excluir el post raíz
              .get();

      final batch = _firestore.batch();
      for (final doc in commentsSnapshot.docs) {
        batch.delete(doc.reference);
      }
      batch.delete(_postsCollection.doc(postId));
      await batch.commit();
    } else {
      // Es un comentario o respuesta, eliminar y actualizar count
      await _postsCollection.doc(postId).delete();

      // Si tiene un padre, actualizar commentsCount
      if (post.parentId != null) {
        await _updateCommentCount(post.parentId!, -1);
      }
    }
  }

  /// Crea un nuevo comentario en un post
  Future<Post> createComment({
    required String parentPostId,
    required String content,
    List<String>? mediaUrls,
    required bool isOfficial,
  }) async {
    if (_auth.currentUser == null) {
      throw Exception('No hay usuario autenticado');
    }

    final parentPost = await getPostById(parentPostId);
    if (parentPost == null) {
      throw Exception('Post padre no encontrado');
    }

    final comment = Post.createComment(
      userId: _auth.currentUser!.uid,
      parentPostId: parentPostId,
      threadId: parentPost.threadId,
      content: content,
      mediaUrls: mediaUrls,
      isOfficial: isOfficial,
    );

    final batch = _firestore.batch();
    batch.set(_postsCollection.doc(comment.postId), comment.toJson());

    // Actualizar el contador de comentarios del post padre
    batch.update(_postsCollection.doc(parentPostId), {
      'commentsCount': FieldValue.increment(1),
    });

    await batch.commit();
    return comment;
  }

  /// Crea una respuesta a un comentario
  Future<Post> createReply({
    required String parentCommentId,
    required String content,
    List<String>? mediaUrls,
    required bool isOfficial,
  }) async {
    if (_auth.currentUser == null) {
      throw Exception('No hay usuario autenticado');
    }

    final parentComment = await getPostById(parentCommentId);
    if (parentComment == null) {
      throw Exception('Comentario padre no encontrado');
    }

    final reply = Post.createReply(
      userId: _auth.currentUser!.uid,
      parentCommentId: parentCommentId,
      threadId: parentComment.threadId,
      parentDepth: parentComment.depth,
      content: content,
      mediaUrls: mediaUrls,
      isOfficial: isOfficial,
    );

    final batch = _firestore.batch();
    batch.set(_postsCollection.doc(reply.postId), reply.toJson());

    // Actualizar el contador de comentarios del comentario padre
    batch.update(_postsCollection.doc(parentCommentId), {
      'commentsCount': FieldValue.increment(1),
    });

    await batch.commit();
    return reply;
  }

  /// Actualiza el contador de comentarios de un post
  Future<void> _updateCommentCount(String postId, int delta) async {
    await _postsCollection.doc(postId).update({
      'commentsCount': FieldValue.increment(delta),
    });
  }

  /// Obtiene todos los posts principales (no comentarios)
  Stream<List<Post>> getMainPosts({
    int limit = 20,
    DocumentSnapshot? startAfter,
  }) {
    Query query = _postsCollection
        .where('depth', isEqualTo: 0)
        .orderBy('createdAt', descending: true)
        .limit(limit);

    if (startAfter != null) {
      query = query.startAfterDocument(startAfter);
    }

    return query.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => Post.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    });
  }

  /// Obtiene los posts institucionales por tipo
  Stream<List<Post>> getInstitutionalPosts({
    required PostType type,
    PostVisibility? visibility,
    int limit = 20,
    DocumentSnapshot? startAfter,
  }) {
    Query query = _postsCollection
        .where('type', isEqualTo: type.toString().split('.').last)
        .where('depth', isEqualTo: 0)
        .orderBy('createdAt', descending: true)
        .limit(limit);

    if (visibility != null) {
      query = query.where(
        'visibility',
        isEqualTo: visibility.toString().split('.').last,
      );
    }

    if (startAfter != null) {
      query = query.startAfterDocument(startAfter);
    }

    return query.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => Post.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    });
  }

  /// Obtiene los comentarios directos de un post
  Stream<List<Post>> getPostComments(String postId, {int limit = 50}) {
    return _postsCollection
        .where('parentId', isEqualTo: postId)
        .where('depth', isEqualTo: 1)
        .orderBy('createdAt', descending: false)
        .limit(limit)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => Post.fromJson(doc.data() as Map<String, dynamic>))
              .toList();
        });
  }

  /// Obtiene todas las respuestas de un comentario
  Stream<List<Post>> getCommentReplies(String commentId, {int limit = 20}) {
    return _postsCollection
        .where('parentId', isEqualTo: commentId)
        .orderBy('createdAt', descending: false)
        .limit(limit)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => Post.fromJson(doc.data() as Map<String, dynamic>))
              .toList();
        });
  }

  /// Obtiene todo el hilo de discusión de un post
  Stream<List<Post>> getThreadPosts(String threadId, {int limit = 100}) {
    return _postsCollection
        .where('threadId', isEqualTo: threadId)
        .orderBy('depth')
        .orderBy('createdAt')
        .limit(limit)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => Post.fromJson(doc.data() as Map<String, dynamic>))
              .toList();
        });
  }

  /// Agrega una reacción a un post
  Future<void> addReaction({
    required String postId,
    required ReactionType type,
  }) async {
    if (_auth.currentUser == null) {
      throw Exception('No hay usuario autenticado');
    }

    final userId = _auth.currentUser!.uid;
    final reactionRef = _postsCollection
        .doc(postId)
        .collection('reactions')
        .doc(userId);

    final reactionDoc = await reactionRef.get();
    final batch = _firestore.batch();

    // Si ya existe una reacción de este usuario
    if (reactionDoc.exists) {
      final oldReaction = Reaction.fromJson(
        postId,
        userId,
        reactionDoc.data() as Map<String, dynamic>,
      );

      // Si el tipo es el mismo, eliminar la reacción
      if (oldReaction.type == type) {
        batch.delete(reactionRef);

        // Decrementar el contador correspondiente
        if (type == ReactionType.like) {
          batch.update(_postsCollection.doc(postId), {
            'likesCount': FieldValue.increment(-1),
          });
        } else {
          batch.update(_postsCollection.doc(postId), {
            'dislikesCount': FieldValue.increment(-1),
          });
        }
      }
      // Si el tipo es diferente, actualizar la reacción
      else {
        final newReaction = Reaction.create(
          postId: postId,
          userId: userId,
          type: type,
        );

        batch.set(reactionRef, newReaction.toJson());

        // Actualizar contadores: decrementar uno e incrementar otro
        if (type == ReactionType.like) {
          batch.update(_postsCollection.doc(postId), {
            'likesCount': FieldValue.increment(1),
            'dislikesCount': FieldValue.increment(-1),
          });
        } else {
          batch.update(_postsCollection.doc(postId), {
            'likesCount': FieldValue.increment(-1),
            'dislikesCount': FieldValue.increment(1),
          });
        }
      }
    }
    // Si no existe reacción previa, crear una nueva
    else {
      final newReaction = Reaction.create(
        postId: postId,
        userId: userId,
        type: type,
      );

      batch.set(reactionRef, newReaction.toJson());

      // Incrementar el contador correspondiente
      if (type == ReactionType.like) {
        batch.update(_postsCollection.doc(postId), {
          'likesCount': FieldValue.increment(1),
        });
      } else {
        batch.update(_postsCollection.doc(postId), {
          'dislikesCount': FieldValue.increment(1),
        });
      }
    }

    await batch.commit();
  }

  /// Obtiene la reacción de un usuario específico a un post
  Future<Reaction?> getUserReaction({
    required String postId,
    String? userId,
  }) async {
    final uid = userId ?? _auth.currentUser?.uid;
    if (uid == null) return null;

    final doc =
        await _postsCollection
            .doc(postId)
            .collection('reactions')
            .doc(uid)
            .get();

    if (!doc.exists) return null;
    return Reaction.fromJson(postId, uid, doc.data() as Map<String, dynamic>);
  }

  /// Obtiene los posts de un usuario específico
  Stream<List<Post>> getUserPosts(String userId, {int limit = 20}) {
    return _postsCollection
        .where('userId', isEqualTo: userId)
        .where('depth', isEqualTo: 0) // Solo posts principales, no comentarios
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => Post.fromJson(doc.data() as Map<String, dynamic>))
              .toList();
        });
  }
}
