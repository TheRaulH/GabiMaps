// user_profile_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:gabimaps/data/models/user_model.dart';
import 'package:gabimaps/presentation/providers/user_provider.dart';

class UserProfilePage extends ConsumerStatefulWidget {
  const UserProfilePage({super.key});

  @override
  ConsumerState<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends ConsumerState<UserProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  String? _selectedCareer;
  List<String> _selectedFaculties = [];
  File? _imageFile;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUserData();
    });
  }

  void _loadUserData() {
    final userState = ref.read(userProvider);
    if (userState is UserLoaded) {
      final user = userState.user;
      _nameController.text = user.nombre ?? '';
      _lastNameController.text = user.apellido ?? '';
      _phoneController.text = user.telefono ?? '';
      _addressController.text = user.direccion ?? '';
      _selectedCareer = user.carrera;
      _selectedFaculties = user.facultad ?? [];
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _imageFile = File(image.path);
      });
    }
  }

  Future<String?> _uploadImage() async {
    if (_imageFile == null) return null;

    try {
      final userState = ref.read(userProvider);
      if (userState is UserLoaded) {
        final userId = userState.user.uid;
        final storageRef = FirebaseStorage.instance.ref().child(
          'user_profiles/$userId.jpg',
        );
        final uploadTask = await storageRef.putFile(_imageFile!);
        return await uploadTask.ref.getDownloadURL();
      }
      return null;
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error al subir la imagen: $e')));
      return null;
    }
  }

  void _saveProfile() async {
    if (_formKey.currentState?.validate() ?? false) {
      String? photoUrl = await _uploadImage();

      final userState = ref.read(userProvider);
      if (userState is UserLoaded) {
        final updatedUser = UserModel(
          uid: userState.user.uid,
          nombre: _nameController.text,
          apellido: _lastNameController.text,
          email: userState.user.email,
          rol: userState.user.rol,
          facultad: _selectedFaculties,
          carrera: _selectedCareer,
          fechaRegistro: userState.user.fechaRegistro ?? DateTime.now(),
          telefono: _phoneController.text,
          direccion: _addressController.text,
          photoURL: photoUrl ?? userState.user.photoURL,
        );

        ref.read(userProvider.notifier).updateUser(updatedUser);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Perfil actualizado correctamente')),
        );
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userState = ref.watch(userProvider);

    if (userState is UserLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (userState is UserError) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Error: ${userState.message}'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.read(userProvider.notifier).loadUser(),
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      );
    }

    final user = userState is UserLoaded ? userState.user : null;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil de Usuario'),
        centerTitle: true,
        backgroundColor: colorScheme.primaryContainer,
        foregroundColor: colorScheme.onPrimaryContainer,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Avatar y selector de imagen
                GestureDetector(
                  onTap: _pickImage,
                  child: Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundImage:
                            _imageFile != null
                                ? FileImage(_imageFile!) as ImageProvider
                                : (user?.photoURL != null
                                        ? NetworkImage(user!.photoURL!)
                                        : const AssetImage(
                                          'assets/default_avatar.png',
                                        ))
                                    as ImageProvider,
                      ),
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: colorScheme.primary,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.camera_alt,
                          size: 20,
                          color: colorScheme.onPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Información del usuario
                Text(
                  user?.email ?? "",
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                if (user?.fechaRegistro != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      'Miembro desde: ${DateFormat('dd/MM/yyyy').format(user!.fechaRegistro!)}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                const SizedBox(height: 24),

                // Campos del formulario
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nombre',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingresa tu nombre';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _lastNameController,
                  decoration: const InputDecoration(
                    labelText: 'Apellido',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingresa tu apellido';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _phoneController,
                  decoration: const InputDecoration(
                    labelText: 'Teléfono',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.phone),
                  ),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _addressController,
                  decoration: const InputDecoration(
                    labelText: 'Dirección',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.home),
                  ),
                ),
                const SizedBox(height: 24),

                // Selector de Facultad (multiselección)
                Card(
                  elevation: 0,
                  color: colorScheme.surfaceContainerHighest,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Facultades',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          children: [
                            _buildFacultyChip('Ingeniería'),
                            _buildFacultyChip('Ciencias'),
                            _buildFacultyChip('Artes'),
                            _buildFacultyChip('Medicina'),
                            _buildFacultyChip('Derecho'),
                            _buildFacultyChip('Economía'),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Selector de Carrera
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Carrera',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.school),
                  ),
                  value: _selectedCareer,
                  onChanged: (newValue) {
                    setState(() {
                      _selectedCareer = newValue;
                    });
                  },
                  items: _getCareerItems(),
                ),
                const SizedBox(height: 32),

                // Botón de guardar
                FilledButton.icon(
                  onPressed: _saveProfile,
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  icon: const Icon(Icons.save),
                  label: const Text('Guardar Cambios'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFacultyChip(String faculty) {
    final isSelected = _selectedFaculties.contains(faculty);
    return FilterChip(
      label: Text(faculty),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          if (selected) {
            _selectedFaculties.add(faculty);
          } else {
            _selectedFaculties.remove(faculty);
          }
        });
      },
    );
  }

  List<DropdownMenuItem<String>> _getCareerItems() {
    final careers = <String>[
      'Ingeniería de Sistemas',
      'Ingeniería Civil',
      'Medicina',
      'Derecho',
      'Psicología',
      'Administración de Empresas',
      'Economía',
      'Diseño Gráfico',
      'Arquitectura',
      'Comunicación Social',
    ];

    return careers.map((String value) {
      return DropdownMenuItem<String>(value: value, child: Text(value));
    }).toList();
  }
}
