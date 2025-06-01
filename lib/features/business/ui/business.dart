import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:gabimaps/features/business/data/business_model.dart';
import 'package:gabimaps/features/business/providers/business_provider.dart';
import 'package:gabimaps/features/user/providers/user_providers.dart';

class EmprendimientoScreen extends ConsumerStatefulWidget {
  const EmprendimientoScreen({super.key});

  @override
  ConsumerState<EmprendimientoScreen> createState() =>
      _EmprendimientoScreenState();
}

class _EmprendimientoScreenState extends ConsumerState<EmprendimientoScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController nombreController;
  late final TextEditingController descripcionController;
  late final TextEditingController contactoController;
  late final TextEditingController horarioController;
  late final TextEditingController categoriaController;
  StreamSubscription<Position>? _positionSubscription;

  @override
  void initState() {
    super.initState();
    nombreController = TextEditingController();
    descripcionController = TextEditingController();
    contactoController = TextEditingController();
    horarioController = TextEditingController();
    categoriaController = TextEditingController();
  }

  @override
  void dispose() {
    _positionSubscription?.cancel();
    nombreController.dispose();
    descripcionController.dispose();
    contactoController.dispose();
    horarioController.dispose();
    categoriaController.dispose();
    super.dispose();
  }

  Future<void> _startLocationStream(String emprendimientoId) async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        await Geolocator.openLocationSettings();
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission != LocationPermission.whileInUse &&
            permission != LocationPermission.always) {
          return;
        }
      }

      _positionSubscription = Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 10,
        ),
      ).listen((position) {
        ref
            .read(ubicacionProvider.notifier)
            .actualizarUbicacionEmprendimiento(
              emprendimientoId,
              GeoPoint(position.latitude, position.longitude),
            );
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error en ubicación: ${e.toString()}')),
      );
    }
  }

  void _stopLocationStream() {
    _positionSubscription?.cancel();
    _positionSubscription = null;
  }

  Future<void> _crearNuevoEmprendimiento(String userId) async {
    try {
      final service = ref.read(emprendimientoServiceProvider);

      final nuevoEmprendimiento = Emprendimiento(
        id: '',
        nombre: 'Mi Emprendimiento',
        descripcion: '',
        propietarioId: userId,
        ubicacionActual: null,
        disponible: false,
        categoria: 'General',
        imagenUrl: null,
        horario: 'L-V 9:00-18:00',
        contacto: '',
        fechaCreacion: DateTime.now(),
        productosServicios: [],
      );

      // 🔧 Crear el emprendimiento y obtener ID
      final docRef = await FirebaseFirestore.instance
          .collection('emprendimientos')
          .add(nuevoEmprendimiento.toFirestore());

      // 🔄 Actualizar usuario con ese ID
      final userModel = ref.read(userModelProvider).value;
      if (userModel != null) {
        final actualizado = userModel.copyWith(emprendimientoId: docRef.id);
        await ref
            .read(userOperationProvider(UserOperationType.updateUser))
            .execute(user: actualizado);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Emprendimiento creado exitosamente')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al crear emprendimiento: $e')),
      );
    }
  }

  Future<void> _guardarCambios(Emprendimiento emprendimiento) async {
    if (_formKey.currentState?.validate() ?? false) {
      try {
        final actualizado = emprendimiento.copyWith(
          nombre: nombreController.text,
          descripcion: descripcionController.text,
          contacto: contactoController.text,
          horario: horarioController.text,
          categoria: categoriaController.text,
        );

        await ref
            .read(emprendimientoServiceProvider)
            .guardarEmprendimiento(actualizado);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cambios guardados correctamente')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al guardar: ${e.toString()}')),
        );
      }
    }
  }

  bool _disponibilidadInicializada = false;

  Widget _buildForm(Emprendimiento emprendimiento) {
    final disponible = ref.watch(disponibilidadProvider);

    if (!_disponibilidadInicializada) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(disponibilidadProvider.notifier).state =
            emprendimiento.disponible;
      });
      _disponibilidadInicializada = true;
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: ListView(
          children: [
            TextFormField(
              controller: nombreController,
              decoration: const InputDecoration(labelText: 'Nombre'),
              validator: (value) => value?.isEmpty ?? true ? 'Requerido' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: descripcionController,
              decoration: const InputDecoration(labelText: 'Descripción'),
              maxLines: 3,
              validator: (value) => value?.isEmpty ?? true ? 'Requerido' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: contactoController,
              decoration: const InputDecoration(labelText: 'Contacto'),
              validator: (value) => value?.isEmpty ?? true ? 'Requerido' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: horarioController,
              decoration: const InputDecoration(labelText: 'Horario'),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: categoriaController,
              decoration: const InputDecoration(labelText: 'Categoría'),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Disponible'),
              value: disponible,
              onChanged: (value) async {
                await ref
                    .read(disponibilidadProvider.notifier)
                    .toggleDisponibilidad(emprendimiento.id, value);

                if (value) {
                  await _startLocationStream(emprendimiento.id);
                } else {
                  _stopLocationStream();
                }
              },
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => _guardarCambios(emprendimiento),
              child: const Text('Guardar Cambios'),
            ),
          ],
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userModelProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Control de Emprendimiento')),
      body: user.when(
        data: (user) {
          if (user == null) {
            return const Center(child: Text('Usuario no autenticado'));
          }

          if (user.emprendimientoId == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('No tienes un emprendimiento registrado'),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => _crearNuevoEmprendimiento(user.uid),
                    child: const Text('Crear Emprendimiento'),
                  ),
                ],
              ),
            );
          }

          final emprendimiento = ref.watch(
            userEmprendimientoProvider(user.uid),
          );

          return emprendimiento.when(
            data: (emprendimiento) {
              if (emprendimiento == null) {
                return const Center(
                  child: Text('Error al cargar emprendimiento'),
                );
              }

              // Inicializar controladores con los valores actuales
              if (nombreController.text.isEmpty) {
                nombreController.text = emprendimiento.nombre;
                descripcionController.text = emprendimiento.descripcion;
                contactoController.text = emprendimiento.contacto;
                horarioController.text = emprendimiento.horario;
                categoriaController.text = emprendimiento.categoria;
              }

              return _buildForm(emprendimiento);
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => Center(child: Text('Error: $error')),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }
}
