import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gabimaps/app/core/constants.dart';
import 'package:gabimaps/features/user/data/user_model.dart';
import 'package:gabimaps/features/user/providers/user_providers.dart';
import 'package:gabimaps/features/user/ui/widgets/editable_avatar.dart'; // Asumiendo que tienes tus constantes aquí

class EditProfileScreen extends ConsumerStatefulWidget {
  final UserModel user;
  const EditProfileScreen({super.key, required this.user});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  late final TextEditingController _nombreController;
  late final TextEditingController _apellidoController;
  late final TextEditingController _telefonoController;
  late final TextEditingController _direccionController;
  late final TextEditingController _carreraController;
  File? _imageFile;
  bool _isSaving = false;
  // Agrega estas variables a tu estado
  String? _selectedFaculty;
  String? _selectedCareer;
  List<String> _availableCareers = [];

  @override
  void initState() {
    super.initState();
    _nombreController = TextEditingController(text: widget.user.nombre);
    _apellidoController = TextEditingController(text: widget.user.apellido);
    _telefonoController = TextEditingController(text: widget.user.telefono);
    _direccionController = TextEditingController(text: widget.user.direccion);
    _carreraController = TextEditingController(text: widget.user.carrera);

    // Inicializar facultad y carrera si ya existen
    _initializeFacultyAndCareer();
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _apellidoController.dispose();
    _telefonoController.dispose();
    _direccionController.dispose();
    _carreraController.dispose();
    super.dispose();
  }

  void _initializeFacultyAndCareer() {
    if (widget.user.carrera?.isNotEmpty ?? false) {
      // Buscar la facultad correspondiente a la carrera guardada
      for (final faculty in AppConstants.faculties) {
        final careers = AppConstants.getCareersByFaculty(faculty);
        if (careers.contains(widget.user.carrera)) {
          _selectedFaculty = faculty;
          _selectedCareer = widget.user.carrera;
          _availableCareers = careers;
          break;
        }
      }
    }
  }

  Future<void> _handleImageChanged(String imagePath) async {
    setState(() => _imageFile = File(imagePath));
  }

  Future<void> _saveChanges() async {
    if (_isSaving) return;

    setState(() => _isSaving = true);

    try {
      String? newImageUrl;

      if (_imageFile != null) {
        final userRepo = ref.read(userRepositoryProvider);
        newImageUrl = await userRepo.uploadProfileImage(
          widget.user.uid,
          _imageFile!.path,
        );
        await userRepo.updateProfileImage(widget.user.uid, newImageUrl);
      }

      final updatedUser = widget.user.copyWith(
        nombre: _nombreController.text.trim(),
        apellido: _apellidoController.text.trim(),
        telefono: _telefonoController.text.trim(),
        direccion: _direccionController.text.trim(),
        carrera: _selectedCareer ?? _carreraController.text.trim(),
        facultad: _selectedFaculty,
        photoURL: newImageUrl ?? widget.user.photoURL,
      );

      await ref
          .read(userOperationProvider(UserOperationType.updateUser))
          .execute(user: updatedUser);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Perfil actualizado correctamente'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al actualizar: ${e.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  // Widget para selección de facultad
  Widget _buildFacultyDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedFaculty,
      decoration: InputDecoration(
        labelText: 'Facultad',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
      ),
      items:
          AppConstants.faculties.map((faculty) {
            return DropdownMenuItem(value: faculty, child: Text(faculty));
          }).toList(),
      onChanged: (String? newValue) {
        setState(() {
          _selectedFaculty = newValue;
          _selectedCareer = null;
          _availableCareers =
              newValue != null
                  ? AppConstants.getCareersByFaculty(newValue)
                  : [];
          _carreraController.clear();
        });
      },
      validator: (value) => value == null ? 'Seleccione una facultad' : null,
    );
  }

  // Widget para selección de carrera
  Widget _buildCareerDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedCareer,
      decoration: InputDecoration(
        labelText: 'Carrera',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
      ),
      items:
          _availableCareers.map((career) {
            return DropdownMenuItem(value: career, child: Text(career));
          }).toList(),
      onChanged: (String? newValue) {
        setState(() {
          _selectedCareer = newValue;
          _carreraController.text = newValue ?? '';
        });
      },
      validator: (value) => value == null ? 'Seleccione una carrera' : null,
    );
  }


  Widget _buildFormField({
    required TextEditingController controller,
    required String label,
    TextInputType? keyboardType,
    int? maxLines,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: Theme.of(context).colorScheme.outline,
            ),
          ),
          filled: true,
          fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Editar Perfil',
          style: textTheme.titleLarge?.copyWith(
            color: colorScheme.onPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: colorScheme.primary,
        iconTheme: IconThemeData(color: colorScheme.onPrimary),
        actions: [
          IconButton(
            icon:
                _isSaving
                    ? CircularProgressIndicator(
                      color: colorScheme.onPrimary,
                      strokeWidth: 2,
                    )
                    : const Icon(Icons.save),
            onPressed: _isSaving ? null : _saveChanges,
            tooltip: 'Guardar cambios',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Sección de avatar
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text(
                      'Foto de perfil',
                      style: textTheme.titleMedium?.copyWith(
                        color: colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    EditableAvatar(
                      imageUrl: widget.user.photoURL,
                      radius: 60,
                      onImageChanged: _handleImageChanged,
                    ),
                    if (_imageFile != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        'Nueva foto seleccionada',
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.primary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Sección de información personal
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Información Personal',
                      style: textTheme.titleMedium?.copyWith(
                        color: colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildFormField(
                      controller: _nombreController,
                      label: 'Nombre',
                    ),
                    _buildFormField(
                      controller: _apellidoController,
                      label: 'Apellido',
                    ),
                    _buildFormField(
                      controller: _telefonoController,
                      label: 'Teléfono',
                      keyboardType: TextInputType.phone,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Sección de información académica/dirección
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Información Académica',
                      style: textTheme.titleMedium?.copyWith(
                        color: colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildFacultyDropdown(),
                    const SizedBox(height: 16),
                    _buildCareerDropdown(),
                    const SizedBox(height: 16),
                    _buildFormField(
                      controller: _direccionController,
                      label: 'Dirección',
                      maxLines: 2,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Botón de guardar
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _saveChanges,
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.secondary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child:
                    _isSaving
                        ? const CircularProgressIndicator()
                        : Text(
                          'GUARDAR CAMBIOS',
                          style: textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onPrimary,
                          ),
                        ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
