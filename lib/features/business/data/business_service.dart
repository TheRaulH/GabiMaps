import 'package:cloud_firestore/cloud_firestore.dart';
import 'business_model.dart';

class EmprendimientoService {
  final FirebaseFirestore _firestore;

  EmprendimientoService(this._firestore);

  // Obtener el emprendimiento de un usuario
  Future<Emprendimiento?> obtenerEmprendimientoUsuario(String userId) async {
    final snapshot =
        await _firestore
            .collection('emprendimientos')
            .where('propietarioId', isEqualTo: userId)
            .limit(1)
            .get();

    if (snapshot.docs.isEmpty) return null;
    return Emprendimiento.fromFirestore(snapshot.docs.first);
  }

  // Crear o actualizar emprendimiento
  // features/business/data/business_service.dart
  Future<void> guardarEmprendimiento(Emprendimiento emprendimiento) async {
    try {
      if (emprendimiento.id.isEmpty) {
        // Crear nuevo emprendimiento
        final docRef = await _firestore
            .collection('emprendimientos')
            .add(emprendimiento.toFirestore());

        // Verificar si el documento de usuario existe antes de actualizar
        final userDoc =
            await _firestore
                .collection('usuarios')
                .doc(emprendimiento.propietarioId)
                .get();

        if (userDoc.exists) {
          await userDoc.reference.update({'emprendimientoId': docRef.id});
        } else {
          // Si el documento no existe, lo creamos con los datos básicos
          await _firestore
              .collection('usuarios')
              .doc(emprendimiento.propietarioId)
              .set({
                'emprendimientoId': docRef.id,
                'uid': emprendimiento.propietarioId,
                // Agrega otros campos básicos del usuario si es necesario
              });
        }
      } else {
        // Actualizar emprendimiento existente
        await _firestore
            .collection('emprendimientos')
            .doc(emprendimiento.id)
            .update(emprendimiento.toFirestore());
      }
    } catch (e) {
      throw FirebaseException(
        plugin: 'cloud_firestore',
        message: 'Error al guardar el emprendimiento: ${e.toString()}',
      );
    }
  }

  // Actualizar disponibilidad
  Future<void> actualizarDisponibilidad(
    String emprendimientoId,
    bool disponible,
  ) async {
    await _firestore.collection('emprendimientos').doc(emprendimientoId).update(
      {'disponible': disponible},
    );
  }

  // Actualizar ubicación en tiempo real
  Future<void> actualizarUbicacion(
    String emprendimientoId,
    GeoPoint ubicacion,
  ) async {
    try {
      await _firestore
          .collection('emprendimientos')
          .doc(emprendimientoId)
          .update({'ubicacionActual': ubicacion});
    } catch (e) {
      print('Error actualizando ubicación: $e');
      // Aquí puedes emitir logs o alertas al usuario
    }
  }

  // Stream de emprendimientos disponibles
  Stream<List<Emprendimiento>> obtenerEmprendimientosDisponibles() {
    return _firestore
        .collection('emprendimientos')
        .where('disponible', isEqualTo: true)
        .where('ubicacionActual', isNotEqualTo: null)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map((doc) => Emprendimiento.fromFirestore(doc))
                  .toList(),
        );
  }
}
