import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class LocationDetailsWidget extends StatelessWidget {
  final dynamic location;
  final MapController mapController;

  const LocationDetailsWidget({
    super.key,
    required this.location,
    required this.mapController,
  });

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.3,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return SingleChildScrollView(
          controller: scrollController,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDragHandle(),
                _buildTitle(context),
                _buildCategories(context),
                _buildAddress(context),
                _buildDescription(context),
                _buildRating(context),
                _buildUpdatedAt(context),
                _buildCoordinates(context),
                _buildImage(context),
                _buildActionButtons(context),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDragHandle() {
    return Center(
      child: Container(
        height: 5,
        width: 40,
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  Widget _buildTitle(BuildContext context) {
    return Text(
      location.name,
      style: Theme.of(
        context,
      ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
    );
  }

  Widget _buildCategories(BuildContext context) {
    if (location.categories == null || location.categories!.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        const SizedBox(height: 8),
        if (location.categories != null && location.categories!.isNotEmpty)
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children:
                location.categories!
                    .whereType<String>() // Filtra solo elementos String
                    .map<Widget>(
                      // Especifica el tipo de retorno
                      (category) => Chip(
                        label: Text(category),
                        backgroundColor:
                            Theme.of(context).colorScheme.secondaryContainer,
                        labelStyle: TextStyle(
                          color:
                              Theme.of(
                                context,
                              ).colorScheme.onSecondaryContainer,
                        ),
                      ),
                    )
                    .toList(),
          ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildAddress(BuildContext context) {
    if (location.address == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Dirección:', style: Theme.of(context).textTheme.titleMedium),
        Text(location.address!),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildDescription(BuildContext context) {
    if (location.description == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Descripción:', style: Theme.of(context).textTheme.titleMedium),
        Text(location.description!),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildRating(BuildContext context) {
    if (location.rating == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Valoración:', style: Theme.of(context).textTheme.titleMedium),
        Row(
          children: [
            Text('${location.rating} '),
            const Icon(Icons.star, color: Colors.amber, size: 18),
            if (location.reviewCount != null)
              Text(' (${location.reviewCount} reseñas)'),
          ],
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildUpdatedAt(BuildContext context) {
    if (location.updatedAt == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Última actualización:',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        Text(
          '${location.updatedAt!.day}/${location.updatedAt!.month}/${location.updatedAt!.year}',
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildCoordinates(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Coordenadas:', style: Theme.of(context).textTheme.titleMedium),
        Text('${location.latitude}, ${location.longitude}'),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildImage(BuildContext context) {
    if (location.imageUrl == null) return const SizedBox.shrink();

    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.network(
            location.imageUrl!,
            height: 200,
            width: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                height: 200,
                width: double.infinity,
                color: Colors.grey[300],
                child: const Center(
                  child: Icon(Icons.error, color: Colors.grey),
                ),
              );
            },
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Container(
                height: 200,
                width: double.infinity,
                color: Colors.grey[200],
                child: const Center(child: CircularProgressIndicator()),
              );
            },
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ElevatedButton.icon(
          onPressed: () {
            mapController.move(
              LatLng(location.latitude, location.longitude),
              18.0, // Zoom fijo en 18.0
            );
            Navigator.pop(context);
          },
          icon: const Icon(Icons.center_focus_strong),
          label: const Text('Centrar en mapa'),
        ),
        ElevatedButton.icon(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Funcionalidad de compartir en desarrollo'),
              ),
            );
          },
          icon: const Icon(Icons.share),
          label: const Text('Compartir'),
        ),
      ],
    );
  }
}
