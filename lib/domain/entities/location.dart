import 'package:cloud_firestore/cloud_firestore.dart';

class Location {
  final String id;
  final String name;
  final GeoPoint position; // Usamos GeoPoint para latitud y longitud
  final String? description;
  final String? address;
  final List<String>? categories;
  final String? imageUrl;
  final double? rating;
  final int? reviewCount;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int layer;

  Location({
    required this.id,
    required this.name,
    required this.position,
    required this.layer,
    this.description,
    this.address,
    this.categories,
    this.imageUrl,
    this.rating,
    this.reviewCount,
    this.createdAt,
    this.updatedAt,
  });

  factory Location.fromMap(Map<String, dynamic> data, String documentId) {
    return Location(
      id: documentId,
      name: data['name'] ?? '',
      position: data['position'] as GeoPoint? ?? const GeoPoint(0.0, 0.0),
      layer: data['layer'] as int? ?? 0,
      description: data['description'],
      address: data['address'],
      categories: (data['categories'] as List<dynamic>?)?.cast<String>(),
      imageUrl: data['imageUrl'],
      rating: (data['rating'] as num?)?.toDouble(),
      reviewCount: data['reviewCount'] as int?,
      createdAt:
          (data['createdAt'] as num?) != null
              ? DateTime.fromMillisecondsSinceEpoch(data['createdAt'] as int)
              : null,
      updatedAt:
          (data['updatedAt'] as num?) != null
              ? DateTime.fromMillisecondsSinceEpoch(data['updatedAt'] as int)
              : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'position': position, // Guardamos el GeoPoint directamente
      'layer': layer, // Asegúrate de que layer sea un int
      'description': description,
      'address': address,
      'categories': categories,
      'imageUrl': imageUrl,
      'rating': rating,
      'reviewCount': reviewCount,
      'createdAt': createdAt?.millisecondsSinceEpoch,
      'updatedAt': DateTime.now().millisecondsSinceEpoch,
    };
  }

  double get latitude => position.latitude;
  double get longitude => position.longitude;
}
