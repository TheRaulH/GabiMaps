import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider); // 🔹 Observar el estado del usuario

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Screen'),
        actions: [
          IconButton(
            onPressed: () => ref.read(authProvider.notifier).logout(),
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Center(
        child:
            user == null
                ? const Text("No hay usuario autenticado")
                : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Usuario: ${user.email ?? 'Sin email'}"),
                    const SizedBox(height: 10),
                    if (user.displayName != null)
                      Text("Nombre: ${user.displayName}"),
                    if (user.photoURL != null) ...[
                      const SizedBox(height: 10),
                      CircleAvatar(
                        radius: 40,
                        backgroundImage: NetworkImage(user.photoURL!),
                      ),
                    ],
                  ],
                ),
      ),
    );
  }
}
