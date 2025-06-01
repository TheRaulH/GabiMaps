import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gabimaps/features/business/data/business_model.dart';
import 'package:gabimaps/features/business/data/business_service.dart'; 

// Provider para la instancia de FirebaseFirestore
final firestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

// Provider principal para el servicio de emprendimientos
final emprendimientoServiceProvider = Provider<EmprendimientoService>((ref) {
  final firestore = ref.watch(firestoreProvider);
  return EmprendimientoService(firestore);
});

// Provider para el emprendimiento del usuario actual
final userEmprendimientoProvider = FutureProvider.autoDispose
    .family<Emprendimiento?, String>((ref, userId) async {
      final service = ref.watch(emprendimientoServiceProvider);
      return await service.obtenerEmprendimientoUsuario(userId);
    });

// Provider para los emprendimientos disponibles en tiempo real
final emprendimientosDisponiblesProvider =
    StreamProvider.autoDispose<List<Emprendimiento>>((ref) {
      final service = ref.watch(emprendimientoServiceProvider);
      return service.obtenerEmprendimientosDisponibles();
    });

// Provider para el estado de disponibilidad
final disponibilidadProvider =
    StateNotifierProvider<DisponibilidadNotifier, bool>(
      (ref) => DisponibilidadNotifier(ref),
    );

class DisponibilidadNotifier extends StateNotifier<bool> {
  final Ref ref;
  DisponibilidadNotifier(this.ref) : super(false);

  Future<void> toggleDisponibilidad(
    String emprendimientoId,
    bool disponible,
  ) async {
    final service = ref.read(emprendimientoServiceProvider);
    await service.actualizarDisponibilidad(emprendimientoId, disponible);
    state = disponible;
  }
}

// Provider para la ubicación en tiempo real
final ubicacionProvider =
    StateNotifierProvider<UbicacionNotifier, GeoPoint?>(
      (ref) => UbicacionNotifier(ref),
    );

class UbicacionNotifier extends StateNotifier<GeoPoint?> {
  final Ref ref;
  UbicacionNotifier(this.ref) : super(null);

  Future<void> actualizarUbicacionEmprendimiento(
    String emprendimientoId,
    GeoPoint ubicacion,
  ) async {
    final service = ref.read(emprendimientoServiceProvider);
    await service.actualizarUbicacion(emprendimientoId, ubicacion);
    state = ubicacion;
  }
}
