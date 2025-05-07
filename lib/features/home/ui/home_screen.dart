// home_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/providers/auth_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  //funcion logout que hace logout y navega a login
  void _logout(BuildContext context, WidgetRef ref) {
    ref.read(authProvider.notifier).logout();
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Screen'),
        actions: [
          IconButton(
            //navegar a login luego de hacer logout
            onPressed: () => _logout(context, ref),
            tooltip: 'Cerrar sesión',
            // Cambia el icono a uno que represente cerrar sesión        

            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (user == null)
              const Text("No hay usuario autenticado")
            else ...[
              Text("Usuario: ${user.email ?? 'Sin email'}"),
              const SizedBox(height: 10),
              if (user.displayName != null) Text("Nombre: ${user.displayName}"),
              if (user.photoURL != null) ...[
                const SizedBox(height: 10),
                CircleAvatar(
                  radius: 40,
                  backgroundImage: NetworkImage(user.photoURL!),
                ),
              ],
            ],
            const SizedBox(height: 20),
             
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/locationDetails'),
              child: const Text('Detalles de Ubicación'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/profile'),
              child: const Text('Perfil'),
            ),
          ],
        ),
      ),
    );
  }
}
