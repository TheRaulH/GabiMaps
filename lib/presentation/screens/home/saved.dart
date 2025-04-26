import 'package:flutter/material.dart';

void main() => runApp(UAGRMMapaApp());

class UAGRMMapaApp extends StatelessWidget {
  const UAGRMMapaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'UAGRM Mapa',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.green),
      home: GuardadosPage(),
    );
  }
}

class LugarGuardado {
  final String nombre;
  final String tipo;
  final String imagenUrl;
  final String descripcion;

  LugarGuardado({
    required this.nombre,
    required this.tipo,
    required this.imagenUrl,
    required this.descripcion,
  });
}

class GuardadosPage extends StatelessWidget {
  final List<LugarGuardado> lugaresGuardados = [
    LugarGuardado(
      nombre: 'Facultad de Ciencias Exactas',
      tipo: 'Facultad',
      imagenUrl: 'https://i0.wp.com/monteronoticias.com/wp-content/uploads/2021/01/finor.jpg',
      descripcion:
          'Edificio principal de la facultad, cerca de la entrada norte.',
    ),
    LugarGuardado(
      nombre: 'Cafetería Central',
      tipo: 'Cafetería',
      imagenUrl: 'https://dynamic-media-cdn.tripadvisor.com/media/photo-o/28/cf/da/28/encuentranos-en-la-calle.jpg',
      descripcion:
          'Cafetería con variedad de opciones económicas y menú del día.',
    ),
    LugarGuardado(
      nombre: 'Biblioteca UAGRM',
      tipo: 'Edificio',
      imagenUrl: 'https://www.comunidadbaratz.com/wp-content/uploads/Existe-una-gran-variedad-de-tipologias-de-bibliotecas.jpg',
      descripcion:
          'Biblioteca central con acceso a internet y zona de estudio.',
    ),
  ];

  GuardadosPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Guardados - Mapa UAGRM'), centerTitle: true),
      body: ListView.builder(
        itemCount: lugaresGuardados.length,
        itemBuilder: (context, index) {
          final lugar = lugaresGuardados[index];
          return Card(
            margin: EdgeInsets.all(10),
            child: Column(
              children: [
                Image.network(lugar.imagenUrl),
                ListTile(
                  title: Text(
                    lugar.nombre,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(lugar.tipo),
                  trailing: IconButton(
                    icon: Icon(Icons.navigation),
                    onPressed: () {
                      // Aquí iría la lógica para navegar al lugar en el mapa
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Navegando a ${lugar.nombre}...'),
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Text(lugar.descripcion),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
