import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gabimaps/features/user/data/user_model.dart';
import 'package:gabimaps/features/user/ui/user_admin_screen.dart';
import 'package:gabimaps/features/user/ui/widgets/user_card.dart';
import 'package:gabimaps/features/user/providers/users_providers.dart';

// Provider para el término de búsqueda
final searchTermProvider = StateProvider<String>((ref) => '');

// ✅ Cambiamos el tipo de provider
final searchFilteredUsersProvider = Provider<AsyncValue<List<UserModel>>>((
  ref,
) {
  final filteredUsersAsync = ref.watch(filteredUsersProvider);
  final searchTerm = ref.watch(searchTermProvider).toLowerCase().trim();

  return filteredUsersAsync.whenData((users) {
    if (searchTerm.isEmpty) return users;

    return users.where((user) {
      final nameMatch =
          user.nombre?.toLowerCase().contains(searchTerm) ?? false;
      final emailMatch = user.email.toLowerCase().contains(searchTerm);
      return nameMatch || emailMatch;
    }).toList();
  });
});


class UsersListScreen extends ConsumerWidget {
  const UsersListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchFilteredUsersAsync = ref.watch(searchFilteredUsersProvider);
    final currentFilter = ref.watch(userListFilterProvider);
    final searchTerm = ref.watch(searchTermProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerLowest,
      appBar: AppBar(
        title: const Text('Gestión de Usuarios'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        elevation: 2,
        actions: [
          // Botón del filtro con indicador del filtro actual
          PopupMenuButton<String>(
            onSelected: (value) {
              ref.read(userListFilterProvider.notifier).state = value;
            },
            icon: Badge(
              isLabelVisible: currentFilter != 'all',
              child: const Icon(Icons.filter_list),
            ),
            tooltip: 'Filtrar usuarios',
            itemBuilder:
                (context) => [
                  _buildPopupMenuItem('all', 'Todos', currentFilter),
                  _buildPopupMenuItem(
                    'admin',
                    'Administradores',
                    currentFilter,
                  ),
                  _buildPopupMenuItem('user', 'Usuarios', currentFilter),
                  _buildPopupMenuItem(
                    'institutional',
                    'Institucionales',
                    currentFilter,
                  ),
                  _buildPopupMenuItem(
                    'entrepreneur',
                    'Emprendedores',
                    currentFilter,
                  ),
                ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Barra de búsqueda con estilo mejorado
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SearchBar(
              hintText: 'Buscar usuarios...',
              leading: const Icon(Icons.search),
              trailing:
                  searchTerm.isNotEmpty
                      ? [
                        IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            ref.read(searchTermProvider.notifier).state = '';
                          },
                        ),
                      ]
                      : null,
              onChanged: (value) {
                ref.read(searchTermProvider.notifier).state = value;
              },
            ),
          ),

          // Chip indicador del filtro actual
          if (currentFilter != 'all')
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: SizedBox(
                height: 32,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    Chip(
                      label: Text(_getFilterLabel(currentFilter)),
                      onDeleted: () {
                        ref.read(userListFilterProvider.notifier).state = 'all';
                      },
                    ),
                  ],
                ),
              ),
            ),

          // Resultado de la búsqueda
          Expanded(
            child: searchFilteredUsersAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error:
                  (error, stack) => Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 48,
                          color: Theme.of(context).colorScheme.error,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Error al cargar usuarios',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          error.toString(),
                          style: Theme.of(context).textTheme.bodyMedium,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
              data: (users) {
                if (users.isEmpty) {
                  return _buildEmptyState(context, searchTerm.isNotEmpty);
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    ref.invalidate(filteredUsersProvider);
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.all(8.0),
                    itemCount: users.length,
                    itemBuilder: (context, index) {
                      final user = users[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: UserCard(
                          user: user,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => UserAdminScreen(user: user),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
        onPressed: () {
          // Aquí iría la lógica para crear un nuevo usuario
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Funcionalidad para agregar usuario')),
          );
        },
        child: const Icon(Icons.person_add),
      ),
    );
  }

  PopupMenuItem<String> _buildPopupMenuItem(
    String value,
    String text,
    String currentFilter,
  ) {
    return PopupMenuItem<String>(
      value: value,
      child: Row(
        children: [
          if (value == currentFilter)
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Icon(Icons.check, size: 16, color: Colors.blue[700]),
            ),
          Text(text),
        ],
      ),
    );
  }

  String _getFilterLabel(String filter) {
    switch (filter) {
      case 'admin':
        return 'Administradores';
      case 'user':
        return 'Usuarios';
      case 'institutional':
        return 'Institucionales';
      case 'entrepreneur':
        return 'Emprendedores';
      default:
        return 'Todos';
    }
  }

  Widget _buildEmptyState(BuildContext context, bool isSearching) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isSearching ? Icons.search_off : Icons.people_outline,
            size: 64,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: 16),
          Text(
            isSearching
                ? 'No se encontraron usuarios'
                : 'No hay usuarios disponibles',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          if (isSearching)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Intenta con otra búsqueda o cambia los filtros',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ),
        ],
      ),
    );
  }
}
