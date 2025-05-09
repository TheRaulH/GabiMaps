import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gabimaps/features/auth/providers/auth_providers.dart';
import 'package:gabimaps/features/user/data/user_model.dart';
import 'package:gabimaps/features/user/providers/user_providers.dart';
import 'package:gabimaps/features/user/ui/edit_profile_screen.dart';
import 'package:gabimaps/features/user/ui/profile_detail_screen.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userModelProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Perfil'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await ref
                  .read(authOperationProvider(AuthOperationType.signOut))
                  .execute();
            },
          ),
        ],
      ),
      body: userAsync.when(
        data: (user) {
          if (user == null) {
            return const Center(child: Text('No estás autenticado'));
          }

          return Column(
            children: [
              // Header con avatar e info básica
              _ProfileHeader(user: user),

              // Opciones del perfil
              Expanded(
                child: ListView(
                  children: [
                    _ProfileOption(
                      icon: Icons.edit,
                      title: 'Editar Perfil',
                      onTap:
                          () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => EditProfileScreen(user: user),
                            ),
                          ),
                    ),
                    _ProfileOption(
                      icon: Icons.visibility,
                      title: 'Ver Detalles Completos',
                      onTap:
                          () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => ProfileDetailScreen(user: user),
                            ),
                          ),
                    ),
                    _ProfileOption(
                      icon: Icons.notifications,
                      title: 'Notificaciones',
                      onTap: () {}, // Implementar navegación
                    ),
                    _ProfileOption(
                      icon: Icons.color_lens,
                      title: 'Tema de la App',
                      onTap: () {}, // Implementar cambio de tema
                    ),
                    _ProfileOption(
                      icon: Icons.help,
                      title: 'Ayuda y Soporte',
                      onTap: () {}, // Implementar navegación
                    ),
                    _ProfileOption(
                      icon: Icons.contact_mail,
                      title: 'Contáctanos',
                      onTap: () {}, // Implementar navegación
                    ),
                  ],
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  final UserModel user;

  const _ProfileHeader({required this.user});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
        border: Border(
          bottom: BorderSide(color: Theme.of(context).dividerColor, width: 1),
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundImage:
                user.photoURL != null ? NetworkImage(user.photoURL!) : null,
            child:
                user.photoURL == null
                    ? const Icon(Icons.person, size: 40)
                    : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${user.nombre ?? ''} ${user.apellido ?? ''}'.trim(),
                  style: Theme.of(context).textTheme.titleLarge,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  user.email,
                  style: Theme.of(context).textTheme.bodyMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  user.rol.toUpperCase(),
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _ProfileOption({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
