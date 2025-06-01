import 'package:cloud_firestore/cloud_firestore.dart';
class Emprendimiento {
  final String id;
  final String nombre;
  final String descripcion;
  final String propietarioId;
  final GeoPoint? ubicacionActual; // Ubicación en tiempo real
  final bool disponible; // Si está disponible para mostrar ubicación
  final String categoria;
  final String? imagenUrl;
  final String horario;
  final String contacto;
  final DateTime fechaCreacion;
  final List<String> productosServicios;

  Emprendimiento({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.propietarioId,
    this.ubicacionActual,
    this.disponible = false,
    required this.categoria,
    this.imagenUrl,
    required this.horario,
    required this.contacto,
    required this.fechaCreacion,
    required this.productosServicios,
  });

  factory Emprendimiento.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;

    return Emprendimiento(
      id: doc.id,
      nombre: data['nombre'],
      descripcion: data['descripcion'],
      propietarioId: data['propietarioId'],
      ubicacionActual: data['ubicacionActual'],
      disponible: data['disponible'] ?? false,
      categoria: data['categoria'],
      imagenUrl: data['imagenUrl'],
      horario: data['horario'],
      contacto: data['contacto'],
      fechaCreacion: (data['fechaCreacion'] as Timestamp).toDate(),
      productosServicios: List<String>.from(data['productosServicios'] ?? []),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'nombre': nombre,
      'descripcion': descripcion,
      'propietarioId': propietarioId,
      'ubicacionActual': ubicacionActual,
      'disponible': disponible,
      'categoria': categoria,
      'imagenUrl': imagenUrl,
      'horario': horario,
      'contacto': contacto,
      'fechaCreacion': Timestamp.fromDate(fechaCreacion),
      'productosServicios': productosServicios,
    };
  }
  //copyWith method to create a new instance with updated values
  Emprendimiento copyWith({
    String? id,
    String? nombre,
    String? descripcion,
    String? propietarioId,
    GeoPoint? ubicacionActual,
    bool? disponible,
    String? categoria,
    String? imagenUrl,
    String? horario,
    String? contacto,
    DateTime? fechaCreacion,
    List<String>? productosServicios,
  }) {
    return Emprendimiento(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      descripcion: descripcion ?? this.descripcion,
      propietarioId: propietarioId ?? this.propietarioId,
      ubicacionActual: ubicacionActual ?? this.ubicacionActual,
      disponible: disponible ?? this.disponible,
      categoria: categoria ?? this.categoria,
      imagenUrl: imagenUrl ?? this.imagenUrl,
      horario: horario ?? this.horario,
      contacto: contacto ?? this.contacto,
      fechaCreacion: fechaCreacion ?? this.fechaCreacion,
      productosServicios:
          productosServicios ?? List<String>.from(this.productosServicios),
    );
  }
}
