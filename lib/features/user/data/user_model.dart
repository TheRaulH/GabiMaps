import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String? nombre;
  final String? apellido;
  final String email;
  final String rol;
  final String? facultad;
  final String? carrera;
  final DateTime? fechaRegistro;
  final String? telefono;
  final String? direccion;
  final String? photoURL;
  final bool? isActive;


  UserModel({
    required this.uid,
    this.nombre,
    this.apellido,
    required this.email,
    required this.rol,
    this.facultad,
    this.carrera,
    this.fechaRegistro,
    this.telefono,
    this.direccion,
    this.photoURL,
    this.isActive = true,

  });

  // Método para crear un UserModel desde un documento de Firestore
  factory UserModel.fromFirestore(Map<String, dynamic> data, String uid) {
    return UserModel(
      uid: uid,
      nombre: data['nombre'],
      apellido: data['apellido'],
      email: data['email'] ?? '',
      rol: data['rol'] ?? 'usuario',
      facultad: data['facultad'],
      carrera: data['carrera'],
      fechaRegistro:
          data['fechaRegistro'] != null
              ? (data['fechaRegistro'] as Timestamp).toDate()
              : null,
      telefono: data['telefono'],
      direccion: data['direccion'],
      photoURL: data['photoURL'],
      isActive: data['isActive'] ?? true,
    );
  }

  // Método para convertir un UserModel a un mapa para Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'nombre': nombre,
      'apellido': apellido,
      'email': email,
      'rol': rol,
      'facultad': facultad,
      'carrera': carrera,
      'fechaRegistro':
          fechaRegistro != null ? Timestamp.fromDate(fechaRegistro!) : null,
      'telefono': telefono,
      'direccion': direccion,
      'photoURL': photoURL,
      'isActive': isActive,
    };
  }

  // Método para copiar un UserModel con cambios
  UserModel copyWith({
    String? uid,
    String? nombre,
    String? apellido,
    String? email,
    String? rol,
    String? facultad,
    String? carrera,
    DateTime? fechaRegistro,
    String? telefono,
    String? direccion,
    String? photoURL,
    bool? isActive,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      nombre: nombre ?? this.nombre,
      apellido: apellido ?? this.apellido,
      email: email ?? this.email,
      rol: rol ?? this.rol,
      facultad: facultad ?? this.facultad,
      carrera: carrera ?? this.carrera,
      fechaRegistro: fechaRegistro ?? this.fechaRegistro,
      telefono: telefono ?? this.telefono,
      direccion: direccion ?? this.direccion,
      photoURL: photoURL ?? this.photoURL,
      isActive: isActive ?? this.isActive,
    );
  }
}
