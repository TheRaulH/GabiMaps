import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gabimaps/data/models/user_model.dart';
import 'package:gabimaps/presentation/providers/user_provider.dart';

class UserManagementPage extends ConsumerWidget {
  const UserManagementPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final users = ref.watch(userListProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('Gestión de Usuarios', style: textTheme.headlineSmall),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.refresh(userListProvider),
            tooltip: 'Actualizar lista',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Card(
          color: Colors.transparent,
          
           
          child:
              users.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            
                            Text(
                              'Usuarios',
                              style: textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Spacer(),
                            SizedBox(
                              width: 200,
                              child: SearchBar(
                                hintText: 'Buscar usuarios',
                                leading: const Icon(Icons.search),
                                elevation: WidgetStateProperty.all(0),
                                shape: WidgetStateProperty.all(
                                  const StadiumBorder(),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Divider(height: 1),
                      Expanded(
                        child: ListView.separated(
                          itemCount: users.length,
                          separatorBuilder:
                              (context, index) => const Divider(
                                height: 1,
                                indent: 16,
                                endIndent: 16,
                              ),
                          itemBuilder: (context, index) {
                            final user = users[index];
                            return ListTile(
                              leading: CircleAvatar(
                                backgroundImage:
                                    user.photoURL != null
                                        ? NetworkImage(user.photoURL!)
                                        : null,
                                child:
                                    user.photoURL == null
                                        ? Text(
                                          user.nombre?.substring(0, 1) ?? '?',
                                        )
                                        : null,
                              ),
                              title: Text(
                                '${user.nombre ?? ''} ${user.apellido ?? ''}',
                                style: textTheme.bodyLarge,
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(user.email),
                                  const SizedBox(height: 4),
                                  Chip(
                                    label: Text(
                                      user.rol.toUpperCase(),
                                      style: textTheme.labelSmall?.copyWith(
                                        color: colorScheme.onPrimaryContainer,
                                      ),
                                    ),
                                    backgroundColor:
                                        user.rol == 'admin'
                                            ? colorScheme.primaryContainer
                                            : user.rol == 'institutional'
                                            ? colorScheme.secondaryContainer
                                            : colorScheme.tertiaryContainer,
                                    shape: const StadiumBorder(),
                                    visualDensity: VisualDensity.compact,
                                  ),
                                ],
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit_outlined),
                                    onPressed: () => _showEditDialog(ref, user),
                                    tooltip: 'Editar usuario',
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline),
                                    onPressed:
                                        () =>
                                            _confirmDelete(ref, context, user),
                                    tooltip: 'Eliminar usuario',
                                  ),
                                ],
                              ),
                              onTap: () => _showUserDetails(context, user),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddDialog(ref, context),
        icon: const Icon(Icons.person_add),
        label: const Text('Agregar Usuario'),
      ),
    );
  }

  void _showAddDialog(WidgetRef ref, BuildContext context) {
    showDialog(context: context, builder: (context) => const UserFormDialog());
  }

  void _showEditDialog(WidgetRef ref, UserModel user) {
    showDialog(
      context: ref.context,
      builder: (context) => UserFormDialog(user: user),
    );
  }

  void _confirmDelete(WidgetRef ref, BuildContext context, UserModel user) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Confirmar eliminación'),
            content: Text('¿Estás seguro de eliminar a ${user.nombre}?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () {
                  ref.read(userListProvider.notifier).deleteUser(user.uid);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${user.nombre} eliminado'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                child: const Text(
                  'Eliminar',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );
  }

  void _showUserDetails(BuildContext context, UserModel user) {
    showModalBottomSheet(
      context: context,
      builder:
          (context) => Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: CircleAvatar(
                    radius: 40,
                    backgroundImage:
                        user.photoURL != null
                            ? NetworkImage(user.photoURL!)
                            : null,
                    child:
                        user.photoURL == null
                            ? Text(
                              user.nombre?.substring(0, 1) ?? '?',
                              style: Theme.of(context).textTheme.headlineMedium,
                            )
                            : null,
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: Text(
                    '${user.nombre ?? ''} ${user.apellido ?? ''}',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                Center(
                  child: Text(
                    user.email,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
                const SizedBox(height: 24),
                _buildDetailRow(Icons.work_outline, 'Rol', user.rol),
                if (user.facultad != null && user.facultad!.isNotEmpty)
                  _buildDetailRow(
                    Icons.school_outlined,
                    'Facultad',
                    user.facultad!.join(', '),
                  ),
                if (user.carrera != null)
                  _buildDetailRow(
                    Icons.menu_book_outlined,
                    'Carrera',
                    user.carrera!,
                  ),
                if (user.telefono != null)
                  _buildDetailRow(
                    Icons.phone_outlined,
                    'Teléfono',
                    user.telefono!,
                  ),
                if (user.direccion != null)
                  _buildDetailRow(
                    Icons.location_on_outlined,
                    'Dirección',
                    user.direccion!,
                  ),
                const SizedBox(height: 16),
              ],
            ),
          ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 12),
              ),
              Text(value, style: const TextStyle(fontSize: 14)),
            ],
          ),
        ],
      ),
    );
  }
}

class UserFormDialog extends ConsumerStatefulWidget {
  final UserModel? user;

  const UserFormDialog({super.key, this.user});

  @override
  _UserFormDialogState createState() => _UserFormDialogState();
}

class _UserFormDialogState extends ConsumerState<UserFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nombreController;
  late TextEditingController _apellidoController;
  late TextEditingController _emailController;
  late TextEditingController _telefonoController;
  late TextEditingController _direccionController;
  late TextEditingController _carreraController;
  String _rol = 'usuario';
  List<String> _facultades = [];

  @override
  void initState() {
    super.initState();
    _nombreController = TextEditingController(text: widget.user?.nombre ?? '');
    _apellidoController = TextEditingController(
      text: widget.user?.apellido ?? '',
    );
    _emailController = TextEditingController(text: widget.user?.email ?? '');
    _telefonoController = TextEditingController(
      text: widget.user?.telefono ?? '',
    );
    _direccionController = TextEditingController(
      text: widget.user?.direccion ?? '',
    );
    _carreraController = TextEditingController(
      text: widget.user?.carrera ?? '',
    );
    _rol = widget.user?.rol ?? 'usuario';
    _facultades = widget.user?.facultad?.toList() ?? [];
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AlertDialog(
      icon: Icon(
        widget.user == null ? Icons.person_add : Icons.edit,
        color: colorScheme.primary,
      ),
      title: Text(widget.user == null ? 'Agregar Usuario' : 'Editar Usuario'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nombreController,
                decoration: const InputDecoration(
                  labelText: 'Nombre',
                  prefixIcon: Icon(Icons.person_outline),
                ),
                validator:
                    (value) => value?.isEmpty ?? true ? 'Requerido' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _apellidoController,
                decoration: const InputDecoration(
                  labelText: 'Apellido',
                  prefixIcon: Icon(Icons.person_outline),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty)
                    return 'El email es requerido';
                  if (!value.contains('@')) return 'Email inválido';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _rol,
                items:
                    ['usuario', 'admin', 'institutional']
                        .map(
                          (rol) => DropdownMenuItem(
                            value: rol,
                            child: Text(rol.capitalize()),
                          ),
                        )
                        .toList(),
                onChanged: (value) {
                  if (value != null) setState(() => _rol = value);
                },
                decoration: const InputDecoration(
                  labelText: 'Rol',
                  prefixIcon: Icon(Icons.work_outline),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _telefonoController,
                decoration: const InputDecoration(
                  labelText: 'Teléfono',
                  prefixIcon: Icon(Icons.phone_outlined),
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _direccionController,
                decoration: const InputDecoration(
                  labelText: 'Dirección',
                  prefixIcon: Icon(Icons.location_on_outlined),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _carreraController,
                decoration: const InputDecoration(
                  labelText: 'Carrera',
                  prefixIcon: Icon(Icons.school_outlined),
                ),
              ),
              const SizedBox(height: 12),
              InputChip(
                label: const Text('Agregar facultad'),
                onPressed: () => _showAddFacultadDialog(),
              ),
              if (_facultades.isNotEmpty) ...[
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children:
                      _facultades.map((facultad) {
                        return Chip(
                          label: Text(facultad),
                          onDeleted: () {
                            setState(() {
                              _facultades.remove(facultad);
                            });
                          },
                        );
                      }).toList(),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () async {
            if (_formKey.currentState!.validate()) {
              final uid =
                  widget.user?.uid ??
                  DateTime.now().millisecondsSinceEpoch.toString();
              final newUser = UserModel(
                uid: uid,
                nombre: _nombreController.text,
                apellido: _apellidoController.text,
                email: _emailController.text,
                rol: _rol,
                facultad: _facultades.isNotEmpty ? _facultades : null,
                carrera:
                    _carreraController.text.isEmpty
                        ? null
                        : _carreraController.text,
                telefono:
                    _telefonoController.text.isEmpty
                        ? null
                        : _telefonoController.text,
                direccion:
                    _direccionController.text.isEmpty
                        ? null
                        : _direccionController.text,
              );

              await ref.read(userListProvider.notifier).updateUser(newUser);
              if (mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Usuario ${widget.user == null ? 'creado' : 'actualizado'}',
                    ),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            }
          },
          child: Text(widget.user == null ? 'Crear' : 'Guardar'),
        ),
      ],
    );
  }

  Future<void> _showAddFacultadDialog() async {
    final facultadController = TextEditingController();
    await showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Agregar Facultad'),
            content: TextFormField(
              controller: facultadController,
              decoration: const InputDecoration(
                labelText: 'Nombre de la facultad',
                hintText: 'Ingrese el nombre de la facultad',
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar'),
              ),
              FilledButton(
                onPressed: () {
                  if (facultadController.text.isNotEmpty) {
                    setState(() {
                      _facultades.add(facultadController.text);
                    });
                    Navigator.pop(context);
                  }
                },
                child: const Text('Agregar'),
              ),
            ],
          ),
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}
