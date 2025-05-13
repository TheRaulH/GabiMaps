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

  // Mejorar el manejo de fechas y valores nulos
  factory Location.fromMap(Map<String, dynamic> data, String documentId) {
    return Location(
      id: documentId,
      name: data['name'] ?? 'Sin nombre',
      position: data['position'] as GeoPoint? ?? const GeoPoint(0.0, 0.0),
      layer: data['layer'] as int? ?? 0,
      description: data['description'] as String?,
      address: data['address'] as String?,
      categories:
          (data['categories'] as List?)?.map((e) => e.toString()).toList(),
      imageUrl: data['imageUrl'] as String?,
      rating: data['rating']?.toDouble(),
      reviewCount: data['reviewCount'] as int?,
      createdAt: _parseTimestamp(data['createdAt']),
      updatedAt: _parseTimestamp(data['updatedAt']),
    );
  }

  static DateTime? _parseTimestamp(dynamic timestamp) {
    if (timestamp == null) return null;
    if (timestamp is Timestamp) return timestamp.toDate();
    if (timestamp is num)
      return DateTime.fromMillisecondsSinceEpoch(timestamp as int);
    return null;
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
