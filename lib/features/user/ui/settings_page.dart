// settings_page.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gabimaps/app/config/app_routes.dart';
import 'package:gabimaps/features/user/data/user_model.dart';  
import 'package:gabimaps/features/user/ui/profile_screen.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  

  @override
  Widget build(BuildContext context, WidgetRef ref) {
      
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    //funcion para traer el logout de auth provider
    final auth = ref.read(AuthProvider as ProviderListenable);
    //funcion para cerrar sesion
    void logout() {
      auth.logout();
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    }
    
    

    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuración'),
        centerTitle: true,
        backgroundColor: colorScheme.primaryContainer,
        foregroundColor: colorScheme.onPrimaryContainer,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Tarjeta de perfil del usuario 
              const SizedBox(height: 24),

               

              // Sección de permisos
              _buildSection(context, 'Permisos', [
                _buildActionButton(
                  context,
                  'Permisos de la aplicación',
                  Icons.security,
                  colorScheme.secondary,
                  () => _showPermissionsDialog(context),
                ),
              ]),
              const SizedBox(height: 16),

              // Sección de anuncios
              _buildSection(context, 'Anuncios', [
                _buildActionButton(
                  context,
                  'Configuración de anuncios',
                  Icons.campaign,
                  Colors.orange,
                  () => _showAdsSettingsDialog(context),
                ),
              ]),
              const SizedBox(height: 16),

              // Sección de configuración del mapa
              _buildSection(context, 'Mapa', [
                _buildActionButton(
                  context,
                  'Configuración del mapa',
                  Icons.map,
                  Colors.green,
                  () => _showMapSettingsDialog(context),
                ),
              ]),
              const SizedBox(height: 16),

              // Sección de administrador (solo visible para administradores)
            

              const SizedBox(height: 24),

              // Botón de cierre de sesión
              _buildLogoutButton(context, colorScheme, ref),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserProfileCard(
    BuildContext context,
    UserModel? user,
    ColorScheme colorScheme,
  ) {
    if (user == null) {
      return const Card(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 40,
              backgroundImage:
                  user.photoURL != null
                      ? NetworkImage(user.photoURL!) as ImageProvider
                      : const AssetImage('assets/default_avatar.png'),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${user.nombre ?? ''} ${user.apellido ?? ''}',
                    style: Theme.of(context).textTheme.titleLarge,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user.email,
                    style: Theme.of(context).textTheme.bodyMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color:
                          user.rol == 'admin'
                              ? colorScheme.primary
                              : colorScheme.secondary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      user.rol == 'admin' ? 'Administrador' : 'Usuario',
                      style: TextStyle(
                        color:
                            user.rol == 'admin'
                                ? colorScheme.onPrimary
                                : colorScheme.onSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(
    BuildContext context,
    String title,
    List<Widget> children,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
          child: Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 8),
        Card(
          elevation: 0,
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    String title,
    IconData icon,
    Color iconColor,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Row(
          children: [
            Icon(icon, color: iconColor),
            const SizedBox(width: 16),
            Expanded(
              child: Text(title, style: Theme.of(context).textTheme.bodyLarge),
            ),
            Icon(
              Icons.chevron_right,
              color: Theme.of(
                context,
              ).colorScheme.onSurfaceVariant.withOpacity(0.5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdminSection(BuildContext context, ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(thickness: 1),
        const SizedBox(height: 16),
        _buildSection(context, 'Administración', [
          _buildActionButton(
            context,
            'Gestión de ubicaciones',
            Icons.location_on,
            Colors.red,
            () => Navigator.pushNamed(context, '/admin/locations'),
          ),
          const Divider(height: 1, indent: 56),
          _buildActionButton(
            context,
            'Gestión de usuarios',
            Icons.people,
            Colors.indigo,
            () => Navigator.pushNamed(context, '/admin/users'),
          ),
          const Divider(height: 1, indent: 56),
          _buildActionButton(
            context,
            'Estadísticas de uso',
            Icons.bar_chart,
            Colors.purple,
            () => Navigator.pushNamed(context, '/admin/stats'),
          ),
        ]),
      ],
    );
  }

  Widget _buildLogoutButton(BuildContext context, ColorScheme colorScheme, WidgetRef ref,
  ) {
    return Center(
      child: OutlinedButton.icon(
        onPressed: () => _confirmLogout(context, ref),
        icon: const Icon(Icons.logout),
        label: const Text('Cerrar sesión'),
        style: OutlinedButton.styleFrom(
          foregroundColor: colorScheme.error,
          side: BorderSide(color: colorScheme.error),
          minimumSize: const Size(200, 48),
        ),
      ),
    );
  }

  void _showPermissionsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Permisos de la aplicación'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildPermissionItem(context, 'Ubicación', true),
                _buildPermissionItem(context, 'Cámara', false),
                _buildPermissionItem(context, 'Almacenamiento', true),
                _buildPermissionItem(context, 'Notificaciones', true),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cerrar'),
              ),
            ],
          ),
    );
  }

  Widget _buildPermissionItem(
    BuildContext context,
    String permission,
    bool isGranted,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(
            isGranted ? Icons.check_circle : Icons.cancel,
            color: isGranted ? Colors.green : Colors.red,
          ),
          const SizedBox(width: 12),
          Text(permission),
          const Spacer(),
          TextButton(
            onPressed: () {},
            child: Text(isGranted ? 'Revocar' : 'Permitir'),
          ),
        ],
      ),
    );
  }

  void _showAdsSettingsDialog(BuildContext context) {
    bool personalizedAds = true;

    showDialog(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder: (context, setState) {
              return AlertDialog(
                title: const Text('Configuración de anuncios'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SwitchListTile(
                      title: const Text('Anuncios personalizados'),
                      subtitle: const Text(
                        'Permitir anuncios basados en tus intereses',
                      ),
                      value: personalizedAds,
                      onChanged: (value) {
                        setState(() {
                          personalizedAds = value;
                        });
                      },
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Nota: Los anuncios ayudan a mantener la aplicación gratuita para todos los usuarios.',
                      style: TextStyle(
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancelar'),
                  ),
                  FilledButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Guardar'),
                  ),
                ],
              );
            },
          ),
    );
  }

  void _showMapSettingsDialog(BuildContext context) {
    String mapStyle = 'normal';
    bool showBuildings = true;
    bool show3DView = false;

    showDialog(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder: (context, setState) {
              return AlertDialog(
                title: const Text('Configuración del mapa'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Estilo del mapa'),
                    const SizedBox(height: 8),
                    SegmentedButton<String>(
                      segments: const [
                        ButtonSegment(value: 'normal', label: Text('Normal')),
                        ButtonSegment(
                          value: 'satellite',
                          label: Text('Satélite'),
                        ),
                        ButtonSegment(value: 'hybrid', label: Text('Híbrido')),
                      ],
                      selected: {mapStyle},
                      onSelectionChanged: (Set<String> selection) {
                        setState(() {
                          mapStyle = selection.first;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    SwitchListTile(
                      title: const Text('Mostrar edificios'),
                      value: showBuildings,
                      onChanged: (value) {
                        setState(() {
                          showBuildings = value;
                        });
                      },
                    ),
                    SwitchListTile(
                      title: const Text('Vista 3D'),
                      value: show3DView,
                      onChanged: (value) {
                        setState(() {
                          show3DView = value;
                        });
                      },
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancelar'),
                  ),
                  FilledButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Aplicar'),
                  ),
                ],
              );
            },
          ),
    );
  }

  void _confirmLogout(BuildContext originalContext, WidgetRef ref ) {
    showDialog(
      context: originalContext,
      builder:
          (context) => AlertDialog(
            title: const Text('¿Cerrar sesión?'),
            content: const Text('¿Estás seguro de que deseas cerrar sesión?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar'),
              ),
              FilledButton(
                onPressed: () async {
                  // Cerrar el diálogo primero
                  Navigator.pop(context);

                  // Ejecutar logout usando el authProvider
                  final auth = ref.read(AuthProvider as ProviderListenable);
                  await auth.logout();
                   

                  // Navegar a la pantalla de login y eliminar todas las rutas anteriores
                  Navigator.of(
                    originalContext,
                  ).pushNamedAndRemoveUntil(AppRoutes.login, (route) => false);
                },
                style: FilledButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.error,
                ),
                child: const Text('Cerrar sesión'),
              ),
            ],
          ),
    );
  }
}
