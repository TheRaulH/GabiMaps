// map/ui/locations_list_screen.dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gabimaps/features/map/data/location.dart';
import 'package:gabimaps/features/map/providers/location_provider.dart';
import 'package:gabimaps/features/map/ui/location_edit_screen.dart';

class LocationsListScreen extends ConsumerStatefulWidget {
  const LocationsListScreen({super.key});

  @override
  ConsumerState<LocationsListScreen> createState() =>
      _LocationsListScreenState();
}

class _LocationsListScreenState extends ConsumerState<LocationsListScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  bool _isFilterExpanded = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      ref.read(locationSearchProvider.notifier).state = _searchController.text;
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Observa el estado filtrado para obtener las ubicaciones filtradas
    final locationsState = ref.watch(locationsProvider);
    final filteredLocations = ref.watch(filteredLocationsProvider);
    final searchQuery = ref.watch(locationSearchProvider);
    final selectedCategories = ref.watch(selectedCategoriesProvider);

    // Obtenemos todas las categorías disponibles
    List<String> allCategories = [];
    if (locationsState is LocationsLoaded) {
      // Recopilamos todas las categorías únicas de todas las ubicaciones
      final locCategories =
          locationsState.locations
              .where(
                (loc) => loc.categories != null && loc.categories!.isNotEmpty,
              )
              .expand((loc) => loc.categories!)
              .toSet()
              .toList();

      allCategories = locCategories..sort();
    }

    return Scaffold(
      appBar: _buildAppBar(searchQuery),
      floatingActionButton: FloatingActionButton(
        onPressed:
            () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const LocationEditScreen(),
              ),
            ),
        tooltip: 'Añadir ubicación',
        child: const Icon(Icons.add_location_alt),
      ),
      body: Column(
        children: [
          // Panel de filtros
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: _isFilterExpanded ? null : 0,
            child:
                _isFilterExpanded
                    ? _buildFilterPanel(allCategories, selectedCategories)
                    : const SizedBox.shrink(),
          ),

          // Chips de categorías seleccionadas
          if (selectedCategories.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              width: double.infinity,
              child: Wrap(
                spacing: 8,
                runSpacing: 4,
                children:
                    selectedCategories.map((category) {
                      return Chip(
                        label: Text(category),
                        deleteIcon: const Icon(Icons.close, size: 16),
                        onDeleted: () {
                          final newSet = Set<String>.from(selectedCategories);
                          newSet.remove(category);
                          ref.read(selectedCategoriesProvider.notifier).state =
                              newSet;
                        },
                      );
                    }).toList(),
              ),
            ),

          // Estadísticas
          if (locationsState is LocationsLoaded)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total: ${locationsState.locations.length} ubicaciones',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  if (filteredLocations.length !=
                      locationsState.locations.length)
                    Text(
                      'Mostrando: ${filteredLocations.length}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                ],
              ),
            ),

          // Lista de ubicaciones
          Expanded(
            child: _buildLocationsList(
              locationsState,
              filteredLocations.isEmpty && searchQuery.isNotEmpty
                  ? []
                  : filteredLocations,
            ),
          ),
        ],
      ),
    );
  }

  AppBar _buildAppBar(String searchQuery) {
    return AppBar(
      title:
          _isSearching
              ? TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Buscar ubicaciones...',
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: Colors.grey[400]),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _searchController.clear();
                      setState(() {}); // Para actualizar el botón de cancelar
                    },
                  ),
                ),
                style: const TextStyle(color: Colors.white),
                autofocus: true,
              )
              : const Text('Ubicaciones'),
      actions: [
        // Botón de búsqueda
        IconButton(
          icon: Icon(_isSearching ? Icons.close : Icons.search),
          tooltip: _isSearching ? 'Cancelar búsqueda' : 'Buscar',
          onPressed: () {
            setState(() {
              if (_isSearching) {
                _searchController.clear();                 
                ref.read(locationSearchProvider.notifier).state = '';
              }
              _isSearching = !_isSearching;
            });
          },
        ),
        // Botón de filtro
        IconButton(
          icon: Icon(
            Icons.filter_list,
            color:
                ref.watch(selectedCategoriesProvider).isNotEmpty
                    ? Theme.of(context).colorScheme.primary
                    : null,
          ),
          tooltip: 'Filtros',
          onPressed: () {
            setState(() {
              _isFilterExpanded = !_isFilterExpanded;
            });
          },
        ),
        // Botón de recarga
        IconButton(
          icon: const Icon(Icons.refresh),
          tooltip: 'Recargar',
          onPressed: () {
            ref.read(locationsProvider.notifier).loadLocations();
          },
        ),
        // Menú de opciones
        PopupMenuButton<String>(
          onSelected: (value) {
            switch (value) {
              case 'clear_filters':
                ref.read(selectedCategoriesProvider.notifier).state = {};
                ref.read(locationSearchProvider.notifier).state = '';
                _searchController.clear();
                setState(() {
                  _isSearching = false;
                  _isFilterExpanded = false;
                });
                break;
              case 'sort_name':
                // Puedes implementar la ordenación aquí
                break;
              case 'sort_date':
                // Puedes implementar la ordenación aquí
                break;
            }
          },
          itemBuilder: (BuildContext context) {
            return [
              const PopupMenuItem<String>(
                value: 'clear_filters',
                child: Text('Limpiar filtros'),
              ),
              const PopupMenuItem<String>(
                value: 'sort_name',
                child: Text('Ordenar por nombre'),
              ),
              const PopupMenuItem<String>(
                value: 'sort_date',
                child: Text('Ordenar por fecha'),
              ),
            ];
          },
        ),
      ],
    );
  }

  Widget _buildFilterPanel(
    List<String> allCategories,
    Set<String> selectedCategories,
  ) { 
    return Container(
      padding: const EdgeInsets.all(16),
      color: Theme.of(context).colorScheme.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Filtrar por categorías',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              TextButton(
                onPressed: () {
                  ref.read(selectedCategoriesProvider.notifier).state = {};
                },
                child: const Text('Limpiar filtros'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 0,
            children:
                allCategories.map((category) {
                  final isSelected = selectedCategories.contains(category);
                  return FilterChip(
                    label: Text(category),
                    selected: isSelected,
                    onSelected: (selected) {
                      final newSet = Set<String>.from(selectedCategories);
                      if (selected) {
                        newSet.add(category);
                      } else {
                        newSet.remove(category);
                      }
                      ref.read(selectedCategoriesProvider.notifier).state =
                          newSet;
                    },
                  );
                }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationsList(
    LocationsState state,
    List<Location> filteredLocations,
  ) {
    if (state is LocationsLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is LocationsError) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(state.message),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed:
                  () => ref.read(locationsProvider.notifier).loadLocations(),
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    if (filteredLocations.isEmpty &&
        ref.watch(locationSearchProvider).isNotEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.search_off, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              'No se encontraron resultados para "${ref.watch(locationSearchProvider)}"',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    if (filteredLocations.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.location_off, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'No hay ubicaciones registradas',
              style: TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed:
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LocationEditScreen(),
                    ),
                  ),
              icon: const Icon(Icons.add_location),
              label: const Text('Añadir nueva ubicación'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(locationsProvider.notifier).loadLocations(),
      child: ListView.builder(
        itemCount: filteredLocations.length,
        padding: const EdgeInsets.only(bottom: 80), // Para dar espacio al FAB
        itemBuilder: (context, index) {
          final location = filteredLocations[index];
          return _buildLocationCard(location);
        },
      ),
    );
  }

  Widget _buildLocationCard(Location location) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Imagen superior si está disponible
          if (location.imageUrl != null)
            SizedBox(
              width: double.infinity,
              height: 120,
              child: Image.network(
                location.imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[300],
                    child: const Icon(
                      Icons.broken_image,
                      size: 48,
                      color: Colors.grey,
                    ),
                  );
                },
              ),
            ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Encabezado con nombre y capa
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        location.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Capa ${location.layer}',
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // Detalles: Dirección y coordenadas
                if (location.address != null && location.address!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.location_on,
                          size: 16,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            location.address!,
                            style: const TextStyle(color: Colors.grey),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),

                Row(
                  children: [
                    const Icon(Icons.gps_fixed, size: 16, color: Colors.grey),
                    const SizedBox(width: 8),
                    Text(
                      '${location.latitude.toStringAsFixed(6)}, ${location.longitude.toStringAsFixed(6)}',
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // Descripción
                if (location.description != null &&
                    location.description!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8, bottom: 8),
                    child: Text(
                      location.description!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),

                // Categorías
                if (location.categories != null &&
                    location.categories!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children:
                          location.categories!.map((category) {
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                category,
                                style: const TextStyle(fontSize: 12),
                              ),
                            );
                          }).toList(),
                    ),
                  ),

                // Información adicional
                if (location.rating != null || location.reviewCount != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Row(
                      children: [
                        if (location.rating != null) ...[
                          Icon(Icons.star, size: 16, color: Colors.amber[700]),
                          const SizedBox(width: 4),
                          Text(
                            location.rating!.toStringAsFixed(1),
                            style: const TextStyle(fontSize: 14),
                          ),
                        ],
                        if (location.rating != null &&
                            location.reviewCount != null)
                          const SizedBox(width: 16),
                        if (location.reviewCount != null) ...[
                          const Icon(
                            Icons.rate_review,
                            size: 16,
                            color: Colors.grey,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${location.reviewCount} ${location.reviewCount == 1 ? 'reseña' : 'reseñas'}',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                // Botones de acción
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      OutlinedButton.icon(
                        icon: const Icon(Icons.edit, size: 18),
                        label: const Text('Editar'),
                        onPressed:
                            () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) =>
                                        LocationEditScreen(location: location),
                              ),
                            ),
                      ),
                      const SizedBox(width: 8),
                      OutlinedButton.icon(
                        icon: const Icon(Icons.delete, size: 18),
                        label: const Text('Eliminar'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                        ),
                        onPressed: () => _showDeleteDialog(location.id),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showDeleteDialog(String locationId) async {
    return showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Eliminar ubicación'),
            content: const Text(
              '¿Estás seguro de que quieres eliminar esta ubicación? Esta acción no se puede deshacer.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () async {
                  Navigator.pop(context);
                  // Mostrar indicador de carga
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder:
                        (context) =>
                            const Center(child: CircularProgressIndicator()),
                  );

                  try {
                    await ref
                        .read(locationsProvider.notifier)
                        .deleteLocation(locationId);

                    if (context.mounted) {
                      // Cerrar el diálogo de carga
                      Navigator.pop(context);
                      // Mostrar mensaje de éxito
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Ubicación eliminada correctamente'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      // Cerrar el diálogo de carga
                      Navigator.pop(context);
                      // Mostrar mensaje de error
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error al eliminar: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Eliminar'),
              ),
            ],
          ),
    );
  }
}
