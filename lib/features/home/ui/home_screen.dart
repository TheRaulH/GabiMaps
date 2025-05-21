import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Models
class LocationPlace {
  final String name;
  final String description;
  final String imageUrl;
  final double rating;

  LocationPlace({
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.rating,
  });
}

// Providers
final locationListProvider = StateProvider<List<LocationPlace>>((ref) {
  return [
    LocationPlace(
      name: 'Modulo 1',
      description: 'Primer Módulo Universitario',
      imageUrl:
          'https://i0.wp.com/monteronoticias.com/wp-content/uploads/2021/01/finor.jpg',
      rating: 5.0,
    ),
    LocationPlace(
      name: 'Biblioteca Central',
      description: 'Biblioteca Principal',
      imageUrl:
          'https://www.comunidadbaratz.com/wp-content/uploads/Existe-una-gran-variedad-de-tipologias-de-bibliotecas.jpg',
      rating: 4.5,
    ),
    LocationPlace(
      name: 'Cafetería',
      description: 'Cafetería Principal',
      imageUrl:
          'https://dynamic-media-cdn.tripadvisor.com/media/photo-o/28/cf/da/28/encuentranos-en-la-calle.jpg',
      rating: 4.0,
    ),
  ];
});

final selectedCategoryProvider = StateProvider<String>((ref) => 'Modulos');

// Main screen
class LocationHomeScreen extends ConsumerWidget {
  const LocationHomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedCategory = ref.watch(selectedCategoryProvider);
    final places = ref.watch(locationListProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surfaceContainerLowest,
      body: SafeArea(
        child: Column(
          children: [
            // Top navigation bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              color: colorScheme.surface,
              child: Row(
                children: [
                  Icon(Icons.location_on, color: colorScheme.primary, size: 20),
                  const SizedBox(width: 4),
                  Text(
                    'Ubicación más cercana',
                    style: TextStyle(
                      color: colorScheme.onSurface,
                      fontSize: 14,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: Icon(
                      Icons.notifications_none,
                      color: colorScheme.onSurface,
                    ),
                    onPressed: () {},
                    constraints: const BoxConstraints(),
                    padding: EdgeInsets.zero,
                    iconSize: 22,
                  ),
                  IconButton(
                    icon: CircleAvatar(
                      backgroundColor: colorScheme.primary,
                      radius: 12,
                      child: Icon(
                        Icons.person,
                        color: colorScheme.onPrimary,
                        size: 16,
                      ),
                    ),
                    onPressed: () {},
                    constraints: const BoxConstraints(),
                    padding: const EdgeInsets.only(left: 12),
                  ),
                ],
              ),
            ),

            // Greeting and search
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Hola User!',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        'Donde irás hoy?',
                        style: TextStyle(
                          fontSize: 18,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(Icons.waving_hand, color: Colors.amber, size: 20),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Search field
                  Container(
                    height: 40,
                    decoration: BoxDecoration(
                      color: colorScheme.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: colorScheme.outlineVariant),
                    ),
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Busca',
                        hintStyle: TextStyle(
                          color: colorScheme.onSurfaceVariant,
                        ),
                        prefixIcon: Icon(
                          Icons.search,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 10,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Category selection
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  _buildCategoryButton(
                    'Modulos',
                    selectedCategory,
                    ref,
                    colorScheme,
                  ),
                  const SizedBox(width: 8),
                  _buildCategoryButton(
                    'Comida',
                    selectedCategory,
                    ref,
                    colorScheme,
                  ),
                  const SizedBox(width: 8),
                  _buildCategoryButton(
                    'Baños',
                    selectedCategory,
                    ref,
                    colorScheme,
                  ),
                  const SizedBox(width: 8),
                  _buildCategoryButton(
                    'Tiendas',
                    selectedCategory,
                    ref,
                    colorScheme,
                  ),
                ],
              ),
            ),

            // Banner space
            Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                height: 100,
                decoration: BoxDecoration(
                  border: Border.all(color: colorScheme.outlineVariant),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Icon(
                    Icons.image,
                    color: colorScheme.outlineVariant,
                    size: 40,
                  ),
                ),
              ),
            ),

            // Mejores lugares
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Mejores lugares',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildLocationCard(places[0], colorScheme),
                ],
              ),
            ),

            const Spacer(),

             
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryButton(
    String category,
    String selectedCategory,
    WidgetRef ref,
    ColorScheme colorScheme,
  ) {
    final isSelected = category == selectedCategory;

    return ElevatedButton(
      onPressed: () {
        ref.read(selectedCategoryProvider.notifier).state = category;
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? colorScheme.primary : colorScheme.surface,
        foregroundColor:
            isSelected ? colorScheme.onPrimary : colorScheme.onSurface,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: isSelected ? Colors.transparent : colorScheme.outlineVariant,
          ),
        ),
      ),
      child: Row(
        children: [
          if (category == 'Modulos') Icon(Icons.school, size: 16),
          if (category == 'Comida') Icon(Icons.restaurant, size: 16),
          if (category == 'Baños') Icon(Icons.wc, size: 16),
          if (category == 'Tiendas') Icon(Icons.shopping_cart, size: 16),
          const SizedBox(width: 4),
          Text(category),
        ],
      ),
    );
  }

  Widget _buildLocationCard(LocationPlace place, ColorScheme colorScheme) {
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(8),
              bottomLeft: Radius.circular(8),
            ),
            child: Image.asset(
              'assets/images/modulo1.jpg',
              width: 100,
              height: 100,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 100,
                  height: 100,
                  color: colorScheme.primary.withOpacity(0.2),
                  child: Icon(Icons.image, color: colorScheme.primary),
                );
              },
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    place.name,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    place.description,
                    style: TextStyle(
                      color: colorScheme.onSurfaceVariant,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.location_city,
                        size: 16,
                        color: colorScheme.primary,
                      ),
                      const SizedBox(width: 4),
                      ...List.generate(
                        5,
                        (index) => Icon(
                          index < place.rating ? Icons.star : Icons.star_border,
                          size: 16,
                          color: Colors.amber,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(
    IconData icon,
    String label,
    bool isSelected,
    ColorScheme colorScheme,
  ) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          icon,
          color:
              isSelected ? colorScheme.primary : colorScheme.onSurfaceVariant,
          size: 24,
        ),
        Text(
          label,
          style: TextStyle(
            color:
                isSelected ? colorScheme.primary : colorScheme.onSurfaceVariant,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

// Main entry point to preview the screen
class LocationApp extends ConsumerWidget {
  const LocationApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'Location App',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: Theme.of(context).colorScheme,
      ),
      home: const LocationHomeScreen(),
    );
  }
}

void main() {
  runApp(const ProviderScope(child: LocationApp()));
}
