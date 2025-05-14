import 'package:cloud_firestore/cloud_firestore.dart';

/// Enumeración para los tipos de reacciones
enum ReactionType { like, dislike }

/// Modelo para representar una reacción a una publicación
class Reaction {
  final String postId;
  final String userId;
  final ReactionType type;
  final DateTime reactedAt;

  Reaction({
    required this.postId,
    required this.userId,
    required this.type,
    required this.reactedAt,
  });

  /// Convierte un objeto Reaction a un mapa compatible con Firestore
  Map<String, dynamic> toJson() {
    return {
      'type': type.toString().split('.').last, // Convierte enum a string
      'reactedAt': reactedAt,
    };
  }

  /// Crea una instancia de Reaction a partir de un mapa de Firestore
  factory Reaction.fromJson(
    String postId,
    String userId,
    Map<String, dynamic> json,
  ) {
    return Reaction(
      postId: postId,
      userId: userId,
      type: _parseReactionType(json['type'] as String),
      reactedAt: (json['reactedAt'] as Timestamp).toDate(),
    );
  }

  /// Crea una nueva reacción
  factory Reaction.create({
    required String postId,
    required String userId,
    required ReactionType type,
  }) {
    return Reaction(
      postId: postId,
      userId: userId,
      type: type,
      reactedAt: DateTime.now(),
    );
  }

  /// Analiza el string para convertirlo en enum ReactionType
  static ReactionType _parseReactionType(String value) {
    return ReactionType.values.firstWhere(
      (type) => type.toString().split('.').last == value,
      orElse: () => ReactionType.like,
    );
  }

  /// Devuelve la ruta del documento en Firestore para esta reacción
  String get documentPath => 'posts/$postId/reactions/$userId';
}
