import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gabimaps/domain/entities/user.dart';

class UserModel extends User {
  UserModel({
    required super.uid,
    super.nombre,
    super.apellido,
    required super.email,
    required super.rol,
    super.facultad,
    super.carrera,
    super.fechaRegistro,
    super.telefono,
    super.direccion,
    super.photoURL,
  });    

    factory UserModel.fromFirestore(Map<String, dynamic> data, String uid) {
    return UserModel(
      uid: uid,
      nombre: data['nombre'],
      apellido: data['apellido'],
      email: data['email'] ?? '',
      rol: data['rol'] ?? 'usuario',
      facultad:
          (data['facultad'] as List<dynamic>?)
              ?.cast<String>(), // Manejo de lista nullable
      carrera: data['carrera'],
      fechaRegistro:
          data['fechaRegistro'] != null
              ? (data['fechaRegistro'] as Timestamp).toDate()
              : null,
      telefono: data['telefono'],
      direccion: data['direccion'],
      photoURL: data['photoURL'],
    );
  }

  // Método para convertir un User a un mapa para Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'nombre': nombre,
      'apellido': apellido,
      'email': email,
      'rol': rol,
      'facultad': facultad,
      'carrera': carrera,
      'fechaRegistro': fechaRegistro,
      'telefono': telefono,
      'direccion': direccion,
      'photoURL': photoURL,
    };
  }
  }

  // Método para crear un User desde un documento de Firestore
  

