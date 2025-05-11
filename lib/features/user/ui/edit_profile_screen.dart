import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gabimaps/features/user/data/user_model.dart';
import 'package:gabimaps/features/user/providers/user_providers.dart';
import 'package:gabimaps/features/user/ui/widgets/editable_avatar.dart';

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

  Future<void> _handleImageChanged(String imagePath) async {
    setState(() {
      _imageFile = File(imagePath);
    });
  }

  Future<void> _saveChanges() async {
    try {
      String? newImageUrl;

      // Subir nueva imagen si hay una seleccionada
      if (_imageFile != null) {
        final userRepo = ref.read(userRepositoryProvider);
        newImageUrl = await userRepo.uploadProfileImage(
          widget.user.uid,
          _imageFile!.path,
        );
        await userRepo.updateProfileImage(widget.user.uid, newImageUrl);
      }

      final updatedUser = widget.user.copyWith(
        nombre: _nombreController.text,
        apellido: _apellidoController.text,
        telefono: _telefonoController.text,
        direccion: _direccionController.text,
        carrera: _carreraController.text,
        photoURL: newImageUrl ?? widget.user.photoURL,
      );

      await ref
          .read(userOperationProvider(UserOperationType.updateUser))
          .execute(user: updatedUser);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Perfil actualizado correctamente')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error al actualizar: $e')));
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _nombreController = TextEditingController(text: widget.user.nombre);
    _apellidoController = TextEditingController(text: widget.user.apellido);
    _telefonoController = TextEditingController(text: widget.user.telefono);
    _direccionController = TextEditingController(text: widget.user.direccion);
    _carreraController = TextEditingController(text: widget.user.carrera);
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

   

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Perfil'),
        actions: [
          IconButton(icon: const Icon(Icons.save), onPressed: _saveChanges),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Center(
              child: EditableAvatar(
                imageUrl: widget.user.photoURL,
                radius: 50,
                onImageChanged: _handleImageChanged,
              ),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _nombreController,
              decoration: const InputDecoration(labelText: 'Nombre'),
            ),
            TextFormField(
              controller: _apellidoController,
              decoration: const InputDecoration(labelText: 'Apellido'),
            ),
            TextFormField(
              controller: _telefonoController,
              decoration: const InputDecoration(labelText: 'Teléfono'),
              keyboardType: TextInputType.phone,
            ),
            TextFormField(
              controller: _direccionController,
              decoration: const InputDecoration(labelText: 'Dirección'),
            ),
            TextFormField(
              controller: _carreraController,
              decoration: const InputDecoration(labelText: 'Carrera'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveChanges,
              child: const Text('Guardar Cambios'),
            ),
          ],
        ),
      ),
    );
  }
}
