class AppConstants {
  static const List<String> locationCategories = [
    'Módulo',
    'Curichi (punto de encuentro)',
    'Biblioteca',
    'Tienda',
    'Baño',
    'Centro Interno',
    'Librería',
    'Dirección de Carrera',
    'CPD',
    'Estacionamiento',
  ];
  // Lista de facultades y carreras
  static const Map<String, List<String>> facultiesAndCareers = {
    'Facultad de Ciencias Tecnológicas': [
      'Ingeniería Informática',
      'Ingeniería de Sistemas',
      'Ingeniería Electrónica',
      'Ingeniería Civil',
      'Ingeniería Industrial',
    ],
    'Facultad de Ciencias Económicas': [
      'Administración de Empresas',
      'Contaduría Pública',
      'Economía',
      'Marketing',
    ],
    'Facultad de Humanidades': [
      'Psicología',
      'Comunicación Social',
      'Derecho',
      'Arquitectura',
    ],
    'Facultad de Ciencias de la Salud': [
      'Medicina',
      'Enfermería',
      'Odontología',
      'Bioquímica',
    ],
  };

  // Método para obtener todas las facultades
  static List<String> get faculties => facultiesAndCareers.keys.toList();

  // Método para obtener carreras por facultad
  static List<String> getCareersByFaculty(String faculty) {
    return facultiesAndCareers[faculty] ?? [];
  }
}
