class User {
  final String uid;
  final String? nombre;
  final String? apellido;
  final String email;
  final String rol;
  final List<String>? facultad; // Cambiado a List<String> y hecho opcional
  final String? carrera;
  final DateTime? fechaRegistro; // Hecho opcional
  final String? telefono;
  final String? direccion;
  final String? photoURL; // Hecho opcional

  User({
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
  });

  

  
}
