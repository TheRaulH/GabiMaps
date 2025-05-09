import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gabimaps/features/map/providers/location_provider.dart';

class SearchAndFilterWidget extends ConsumerWidget {
  final TextEditingController searchController;
  final Function(String) onSearchChanged;
  final Function(String) onFilterToggled;
  final Function() onSearchSubmitted;
  final Function() onMenuPressed;

  const SearchAndFilterWidget({
    super.key,
    required this.searchController,
    required this.onSearchChanged,
    required this.onFilterToggled,
    required this.onSearchSubmitted,
    required this.onMenuPressed,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Observar los filtros seleccionados para actualizar la UI de los chips
    final selectedFilters = ref.watch(selectedCategoriesProvider);

    // Definir la lista de filtros disponibles
    final List<String> availableFilters = [
      'Edificio',
      'Facultad',
      'Biblioteca',
      'Cafetería',
      'Deportes',
      'Estacionamiento',
      'Laboratorio',
      'Aula',
    ];

    return Column(
      children: [
        // Barra de búsqueda y botón de perfil
        
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Expanded(
                child: Container( 
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black,
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      hintText: 'Buscar ubicación',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          searchController.clear();
                          onSearchChanged('');
                        },
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onChanged: (value) => onSearchChanged(value),
                    onSubmitted: (_) => onSearchSubmitted(),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Botón para abrir el menú
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: Icon(
                    Icons.view_list_rounded,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                  onPressed: onMenuPressed,
                  tooltip: 'Menú',
                ),
              ),
            ],
          ),
        ),

        // Filtros horizontales
        Container(
          height: 40,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: availableFilters.length,
            itemBuilder: (context, index) {
              final filter = availableFilters[index];
              final isSelected = selectedFilters.contains(filter);

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: FilterChip(
                  label: Text(filter),
                  selected: isSelected,
                  onSelected: (_) => onFilterToggled(filter),
                  backgroundColor:
                      Theme.of(context).colorScheme.surfaceContainerHighest,
                  selectedColor:
                      Theme.of(context).colorScheme.secondaryContainer,
                  labelStyle: TextStyle(
                    color:
                        isSelected
                            ? Theme.of(context).colorScheme.onSecondaryContainer
                            : Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
