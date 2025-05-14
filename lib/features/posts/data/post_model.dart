import 'package:cloud_firestore/cloud_firestore.dart';

/// Enumeración para los tipos de publicaciones
enum PostType {
  general,
  class_notice,
  scholarship,
  internship,
  agreement,
  event,
  comment,
}

/// Enumeración para la visibilidad de las publicaciones
enum PostVisibility { public, university, teachers }

/// Modelo para representar una publicación, comentario o respuesta
class Post {
  final String postId;
  final String userId;
  final PostType type;
  final String? title;
  final String content;
  final List<String>? mediaUrls;
  final String? parentId;
  final String threadId;
  final int depth;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? locationId;
  final PostVisibility visibility;
  final bool isOfficial;
  final int likesCount;
  final int dislikesCount;
  final int commentsCount;
  final Map<String, dynamic>? customFields;

  Post({
    required this.postId,
    required this.userId,
    required this.type,
    this.title,
    required this.content,
    this.mediaUrls,
    this.parentId,
    required this.threadId,
    required this.depth,
    required this.createdAt,
    required this.updatedAt,
    this.locationId,
    required this.visibility,
    required this.isOfficial,
    required this.likesCount,
    required this.dislikesCount,
    required this.commentsCount,
    this.customFields,
  });

  /// Convierte un objeto Post a un mapa compatible con Firestore
  Map<String, dynamic> toJson() {
    return {
      'postId': postId,
      'userId': userId,
      'type': type.toString().split('.').last, // Convierte enum a string
      'title': title,
      'content': content,
      'mediaUrls': mediaUrls,
      'parentId': parentId,
      'threadId': threadId,
      'depth': depth,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'locationId': locationId,
      'visibility':
          visibility.toString().split('.').last, // Convierte enum a string
      'isOfficial': isOfficial,
      'likesCount': likesCount,
      'dislikesCount': dislikesCount,
      'commentsCount': commentsCount,
      'customFields': customFields,
    };
  }

  /// Crea una instancia de Post a partir de un mapa de Firestore
  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      postId: json['postId'] as String,
      userId: json['userId'] as String,
      type: _parsePostType(json['type'] as String),
      title: json['title'] as String?,
      content: json['content'] as String,
      mediaUrls: (json['mediaUrls'] as List?)?.map((e) => e as String).toList(),
      parentId: json['parentId'] as String?,
      threadId: json['threadId'] as String,
      depth: json['depth'] as int,
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      updatedAt: (json['updatedAt'] as Timestamp).toDate(),
      locationId: json['locationId'] as String?,
      visibility: _parsePostVisibility(json['visibility'] as String),
      isOfficial: json['isOfficial'] as bool,
      likesCount: json['likesCount'] as int,
      dislikesCount: json['dislikesCount'] as int,
      commentsCount: json['commentsCount'] as int,
      customFields: json['customFields'] as Map<String, dynamic>?,
    );
  }

  /// Método de fábrica para crear un nuevo post raíz
  factory Post.createRoot({
    required String userId,
    required PostType type,
    required String title,
    required String content,
    List<String>? mediaUrls,
    String? locationId,
    required PostVisibility visibility,
    required bool isOfficial,
    Map<String, dynamic>? customFields,
  }) {
    final String postId =
        FirebaseFirestore.instance.collection('posts').doc().id;
    final DateTime now = DateTime.now();

    return Post(
      postId: postId,
      userId: userId,
      type: type,
      title: title,
      content: content,
      mediaUrls: mediaUrls,
      parentId: null,
      threadId: postId, // Usa el mismo postId como threadId
      depth: 0,
      createdAt: now,
      updatedAt: now,
      locationId: locationId,
      visibility: visibility,
      isOfficial: isOfficial,
      likesCount: 0,
      dislikesCount: 0,
      commentsCount: 0,
      customFields: customFields,
    );
  }

  /// Método de fábrica para crear un comentario a un post
  factory Post.createComment({
    required String userId,
    required String parentPostId,
    required String threadId,
    required String content,
    List<String>? mediaUrls,
    required bool isOfficial,
  }) {
    final String postId =
        FirebaseFirestore.instance.collection('posts').doc().id;
    final DateTime now = DateTime.now();

    return Post(
      postId: postId,
      userId: userId,
      type: PostType.comment,
      title: null,
      content: content,
      mediaUrls: mediaUrls,
      parentId: parentPostId,
      threadId: threadId,
      depth: 1, // Nivel 1 para comentarios directos
      createdAt: now,
      updatedAt: now,
      locationId: null,
      visibility:
          PostVisibility.public, // Por defecto los comentarios son públicos
      isOfficial: isOfficial,
      likesCount: 0,
      dislikesCount: 0,
      commentsCount: 0,
      customFields: null,
    );
  }

  /// Método de fábrica para crear una respuesta a un comentario
  factory Post.createReply({
    required String userId,
    required String parentCommentId,
    required String threadId,
    required int parentDepth,
    required String content,
    List<String>? mediaUrls,
    required bool isOfficial,
  }) {
    final String postId =
        FirebaseFirestore.instance.collection('posts').doc().id;
    final DateTime now = DateTime.now();

    return Post(
      postId: postId,
      userId: userId,
      type: PostType.comment,
      title: null,
      content: content,
      mediaUrls: mediaUrls,
      parentId: parentCommentId,
      threadId: threadId,
      depth: parentDepth + 1, // Incrementa el nivel de anidamiento
      createdAt: now,
      updatedAt: now,
      locationId: null,
      visibility:
          PostVisibility.public, // Por defecto las respuestas son públicas
      isOfficial: isOfficial,
      likesCount: 0,
      dislikesCount: 0,
      commentsCount: 0,
      customFields: null,
    );
  }

  /// Crea una copia de este Post con los campos proporcionados actualizados
  Post copyWith({
    String? postId,
    String? userId,
    PostType? type,
    String? title,
    String? content,
    List<String>? mediaUrls,
    String? parentId,
    String? threadId,
    int? depth,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? locationId,
    PostVisibility? visibility,
    bool? isOfficial,
    int? likesCount,
    int? dislikesCount,
    int? commentsCount,
    Map<String, dynamic>? customFields,
  }) {
    return Post(
      postId: postId ?? this.postId,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      title: title ?? this.title,
      content: content ?? this.content,
      mediaUrls: mediaUrls ?? this.mediaUrls,
      parentId: parentId ?? this.parentId,
      threadId: threadId ?? this.threadId,
      depth: depth ?? this.depth,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      locationId: locationId ?? this.locationId,
      visibility: visibility ?? this.visibility,
      isOfficial: isOfficial ?? this.isOfficial,
      likesCount: likesCount ?? this.likesCount,
      dislikesCount: dislikesCount ?? this.dislikesCount,
      commentsCount: commentsCount ?? this.commentsCount,
      customFields: customFields ?? this.customFields,
    );
  }

  /// Analiza el string para convertirlo en enum PostType
  static PostType _parsePostType(String value) {
    return PostType.values.firstWhere(
      (type) => type.toString().split('.').last == value,
      orElse: () => PostType.general,
    );
  }

  /// Analiza el string para convertirlo en enum PostVisibility
  static PostVisibility _parsePostVisibility(String value) {
    return PostVisibility.values.firstWhere(
      (visibility) => visibility.toString().split('.').last == value,
      orElse: () => PostVisibility.public,
    );
  }
}

/// Extensión para manejar diferentes tipos de post institucionales
extension PostTypeExtension on PostType {
  bool get isInstitutional {
    return this != PostType.general && this != PostType.comment;
  }

  String get displayName {
    switch (this) {
      case PostType.general:
        return 'General';
      case PostType.class_notice:
        return 'Aviso de clase';
      case PostType.scholarship:
        return 'Beca';
      case PostType.internship:
        return 'Pasantía';
      case PostType.agreement:
        return 'Convenio';
      case PostType.event:
        return 'Evento';
      case PostType.comment:
        return 'Comentario';
      default:
        return 'General';
    }
  }
}
