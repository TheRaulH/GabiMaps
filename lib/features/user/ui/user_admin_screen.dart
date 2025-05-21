import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gabimaps/features/user/data/user_model.dart';
import 'package:gabimaps/features/user/providers/user_providers.dart';

class UserAdminScreen extends ConsumerStatefulWidget {
  final UserModel user;
  const UserAdminScreen({super.key, required this.user});

  @override
  ConsumerState<UserAdminScreen> createState() => _UserAdminScreenState();
}

class _UserAdminScreenState extends ConsumerState<UserAdminScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isEditing = false;
  late UserModel _editableUser;


  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
      _editableUser = widget.user; // hacemos la copia inicial

  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;


    return Scaffold(
      backgroundColor: colorScheme.surfaceContainerLowest,
      appBar: AppBar(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        elevation: 2,
        title: Text(
          '${_editableUser.nombre} ${_editableUser.apellido}',
          style: theme.textTheme.titleLarge?.copyWith(
            color: colorScheme.onPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.close : Icons.edit),
            tooltip: _isEditing ? 'Cancelar edición' : 'Editar usuario',
            onPressed: () {
              setState(() {
                _isEditing = !_isEditing;
              });
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: colorScheme.onPrimary,
          unselectedLabelColor: colorScheme.onPrimary.withOpacity(0.7),
          indicatorColor: colorScheme.onPrimary,
          tabs: const [
            Tab(icon: Icon(Icons.person), text: 'Perfil'),
            Tab(icon: Icon(Icons.admin_panel_settings), text: 'Administración'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildProfileTab(context), _buildAdminTab(context)],
      ),
      floatingActionButton:
          _isEditing
              ? FloatingActionButton.extended(
                backgroundColor: colorScheme.primaryContainer,
                foregroundColor: colorScheme.onPrimaryContainer,
                icon: const Icon(Icons.save),
                label: const Text('Guardar cambios'),
                onPressed: () {
                  // Implementar lógica para guardar cambios
                  setState(() {
                    _isEditing = false;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Cambios guardados correctamente'),
                    ),
                  );
                },
              )
              : null,
    );
  }

  Widget _buildProfileTab(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Encabezado de perfil con foto y nombre
           
          Card(
            elevation: 2,
            color: colorScheme.surfaceContainerLow,
            margin: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.0),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  // Avatar del usuario
                  Hero(
                    tag: 'user-avatar-${_editableUser.uid}',
                    child: CircleAvatar(
                      radius: 50,
                      backgroundColor: colorScheme.primaryContainer,
                      backgroundImage:
                          _editableUser.photoURL != null
                              ? NetworkImage(_editableUser.photoURL!)
                              : null,
                      child:
                          _editableUser.photoURL == null
                              ? Text(
                                _editableUser.nombre
                                        ?.substring(0, 1)
                                        .toUpperCase() ??
                                    'U',
                                style: theme.textTheme.displayMedium?.copyWith(
                                  color: colorScheme.onPrimaryContainer,
                                ),
                              )
                              : null,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Nombre completo
                  Text(
                    '${_editableUser.nombre} ${_editableUser.apellido}',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  // Email
                  Text(
                    _editableUser.email,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.secondary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Chip de rol
                  _buildRoleChip(_editableUser.rol, colorScheme),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Sección de información personal
          _buildSectionTitle(
            'Información personal',
            Icons.info_outline,
            colorScheme,
          ),
          const SizedBox(height: 8),
          Card(
            elevation: 1,
            color: colorScheme.surfaceContainerLow,
            margin: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: Column(
              children: [
                _buildInfoTile(
                  'Facultad',
                  _editableUser.facultad ?? 'No especificada',
                  Icons.school,
                  colorScheme,
                ),
                const Divider(height: 1),
                _buildInfoTile(
                  'Carrera',
                  _editableUser.carrera ?? 'No especificada',
                  Icons.book,
                  colorScheme,
                ),
                const Divider(height: 1),
                _buildInfoTile(
                  'Teléfono',
                  _editableUser.telefono ?? 'No especificado',
                  Icons.phone,
                  colorScheme,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Sección de actividad
          _buildSectionTitle(
            'Actividad reciente',
            Icons.access_time,
            colorScheme,
          ),
          const SizedBox(height: 8),
          Card(
            elevation: 1,
            color: colorScheme.surfaceContainerLow,
            margin: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: Padding(
              padding: const EdgeInsets.all(
                5.0,
              ), // Increased padding for better aesthetics and to prevent overflow
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 12),
                  Text('Fecha de registro:', style: theme.textTheme.labelLarge),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          _editableUser.fechaRegistro?.toString() ??
                              'No disponible',
                          style: theme.textTheme.bodyMedium,
                          overflow:
                              TextOverflow
                                  .ellipsis, // Optional: handle very long dates by adding ellipsis
                          maxLines:
                              2, // Optional: allow the text to wrap to a maximum of 2 lines
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildAdminTab(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isActive = _editableUser.isActive ?? true;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle(
            'Gestión de permisos',
            Icons.security,
            colorScheme,
          ),
          const SizedBox(height: 8),
          Card(
            elevation: 1,
            color: colorScheme.surfaceContainerLow,
            margin: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Rol del usuario', style: theme.textTheme.titleMedium),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: _editableUser.rol,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide: BorderSide(color: colorScheme.outline),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide: BorderSide(color: colorScheme.outline),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide: BorderSide(
                          color: colorScheme.primary,
                          width: 2.0,
                        ),
                      ),
                      filled: true,
                      fillColor: colorScheme.surfaceContainerHighest,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 16.0,
                      ),
                    ),
                    items: [
                      _buildDropdownItem(
                        'admin',
                        'Administrador',
                        Icons.admin_panel_settings,
                      ),
                      _buildDropdownItem('user', 'Usuario', Icons.person),
                      _buildDropdownItem(
                        'institutional',
                        'Institucional',
                        Icons.business,
                      ),
                      _buildDropdownItem(
                        'entrepreneur',
                        'Emprendedor',
                        Icons.trending_up,
                      ),
                    ],
                    onChanged:
                        _isEditing
                            ? (newRole) {
                              if (newRole != null) {
                                ref
                                    .read(
                                      userAdminOperationProvider(
                                        UserAdminOperationType.updateRole,
                                      ),
                                    )
                                    .execute(
                                      uid: _editableUser.uid,
                                      role: newRole,
                                    );
                              }
                            }
                            : null,
                  ),
                  if (!_isEditing)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        'Activa el modo edición para cambiar el rol',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.outline,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          _buildSectionTitle(
            'Acciones administrativas',
            Icons.admin_panel_settings,
            colorScheme,
          ),
          const SizedBox(height: 8),
          Card(
            elevation: 1,
            color: colorScheme.surfaceContainerLow,
            margin: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: Icon(Icons.refresh, color: colorScheme.primary),
                  title: const Text('Restablecer contraseña'),
                  subtitle: const Text(
                    'Enviar correo para restablecer contraseña',
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    // Implementar lógica para restablecer contraseña
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Correo de restablecimiento enviado'),
                      ),
                    );
                  },
                ),
                
              ],
            ),
          ),
          const SizedBox(height: 24),
          _buildSectionTitle(
            'Estado de la cuenta',
            Icons.verified_user,
            colorScheme,
          ),
          const SizedBox(height: 8),
          Card(
            elevation: 1,
            color: colorScheme.surfaceContainerLow,
            margin: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: Icon(
                    isActive ? Icons.check_circle : Icons.remove_circle,
                    color: isActive ? Colors.green : Colors.red,
                  ),
                  title: Text(
                    isActive ? 'Cuenta activa' : 'Cuenta inactiva',
                    style: theme.textTheme.titleMedium,
                  ),
                  subtitle: Text(
                    isActive
                        ? 'El usuario puede acceder a la aplicación'
                        : 'El usuario no puede iniciar sesión',
                  ),
                ),
                const Divider(height: 1),
                SwitchListTile(
                  
                  title: Text(
                    isActive ? 'Desactivar cuenta' : 'Activar cuenta',
                    style: theme.textTheme.titleMedium,
                  ),
                  subtitle: Text(
                    isActive
                        ? 'Impedir el acceso del usuario'
                        : 'Permitir el acceso del usuario',
                  ),
                  value: isActive,
                  activeColor: colorScheme.primary,
                  inactiveTrackColor: colorScheme.outline,
                  onChanged:
                      _isEditing
                          ? (value) async {
                            final confirmed = await _showConfirmationDialog(
                              context,
                              value ? 'Activar cuenta' : 'Desactivar cuenta',
                              value
                                  ? '¿Estás seguro de activar esta cuenta?'
                                  : '¿Estás seguro de desactivar esta cuenta?',
                            );

                            if (confirmed) {
                              try {
                                await ref
                                    .read(
                                      userAdminOperationProvider(
                                        UserAdminOperationType.updateStatus,
                                      ),
                                    )
                                    .execute(
                                      uid: _editableUser.uid,
                                      isActive: value,
                                    );

                                 setState(() {
                                  _editableUser = _editableUser.copyWith(
                                    isActive: value,
                                  );
                                });
 

                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      value
                                          ? 'Cuenta activada correctamente'
                                          : 'Cuenta desactivada correctamente',
                                    ),
                                  ),
                                );
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Error al actualizar estado: ${e.toString()}',
                                    ),
                                  ),
                                );
                              }
                            }
                          }
                          : null,
                ),
                if (!_isEditing)
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'Activa el modo edición para cambiar el estado',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.outline,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  DropdownMenuItem<String> _buildDropdownItem(
    String value,
    String label,
    IconData icon,
  ) {
    return DropdownMenuItem<String>(
      value: value,
      child: Row(
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 12),
          Text(label),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(
    String title,
    IconData icon,
    ColorScheme colorScheme,
  ) {
    return Row(
      children: [
        Icon(icon, size: 20, color: colorScheme.secondary),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: colorScheme.secondary,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoTile(
    String label,
    String value,
    IconData icon,
    ColorScheme colorScheme,
  ) {
    return ListTile(
      leading: Icon(icon, color: colorScheme.primary),
      title: Text(
        label,
        style: TextStyle(
          fontWeight: FontWeight.w500,
          color: colorScheme.onSurface,
        ),
      ),
      subtitle: Text(
        value,
        style: TextStyle(color: colorScheme.onSurfaceVariant),
      ),
      trailing: _isEditing ? const Icon(Icons.edit, size: 20) : null,
      onTap:
          _isEditing
              ? () {
                // Implementar lógica para editar este campo
              }
              : null,
    );
  }

  Widget _buildRoleChip(String role, ColorScheme colorScheme) {
    Color chipColor;
    String roleLabel;
    IconData roleIcon;

    switch (role.toLowerCase()) {
      case 'admin':
        chipColor = colorScheme.error;
        roleLabel = 'Administrador';
        roleIcon = Icons.admin_panel_settings;
        break;
      case 'entrepreneur':
        chipColor = Colors.amber.shade800;
        roleLabel = 'Emprendedor';
        roleIcon = Icons.trending_up;
        break;
      case 'institutional':
        chipColor = Colors.green.shade700;
        roleLabel = 'Institucional';
        roleIcon = Icons.business;
        break;
      default:
        chipColor = colorScheme.primary;
        roleLabel = 'Usuario';
        roleIcon = Icons.person;
    }

    return Chip(
      avatar: Icon(roleIcon, size: 18, color: Colors.white),
      label: Text(
        roleLabel,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
      ),
      backgroundColor: chipColor,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
    );
  }

  // Método auxiliar para mostrar diálogo de confirmación
  Future<bool> _showConfirmationDialog(
    BuildContext context,
    String title,
    String message,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(title),
            content: Text(message),
            actions: [
              TextButton(
                child: const Text('Cancelar'),
                onPressed: () => Navigator.of(context).pop(false),
              ),
              TextButton(
                child: const Text('Confirmar'),
                onPressed: () => Navigator.of(context).pop(true),
              ),
            ],
          ),
    );

    return confirmed ?? false;
  } 
}
