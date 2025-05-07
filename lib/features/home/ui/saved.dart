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
      imagenUrl:
          'https://i0.wp.com/monteronoticias.com/wp-content/uploads/2021/01/finor.jpg',
      descripcion:
          'Edificio principal de la facultad, cerca de la entrada norte.',
    ),
    LugarGuardado(
      nombre: 'Cafetería Central',
      tipo: 'Cafetería',
      imagenUrl:
          'https://dynamic-media-cdn.tripadvisor.com/media/photo-o/28/cf/da/28/encuentranos-en-la-calle.jpg',
      descripcion:
          'Cafetería con variedad de opciones económicas y menú del día.',
    ),
    LugarGuardado(
      nombre: 'Biblioteca UAGRM',
      tipo: 'Edificio',
      imagenUrl:
          'https://www.comunidadbaratz.com/wp-content/uploads/Existe-una-gran-variedad-de-tipologias-de-bibliotecas.jpg',
      descripcion:
          'Biblioteca central con acceso a internet y zona de estudio.',
    ),
  ];

  GuardadosPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.indigo,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('Negocios UAGRM'),
        centerTitle: false,
      ),
      body:  ListView(
        children: [Container(height: 200,),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(topRight:Radius.circular(32) ,topLeft: Radius.circular(32))
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 50,),
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Text('Negocios de Comida',style: TextStyle(color: Colors.black,fontSize: 24,),),
                ),
                SizedBox(
                  height: 400, // Altura total del carrusel horizontal
                  child: ListView.builder(
                    padding: EdgeInsets.zero,
                    scrollDirection: Axis.horizontal,
                    itemCount: lugaresGuardados.length,
                    itemBuilder: (context, index) {
                      final lugar = lugaresGuardados[index];
                      return SizedBox(
                        width: 325, // Ancho de cada tarjeta horizontal
                        child: Card(
                          clipBehavior: Clip.hardEdge,
                          margin: EdgeInsets.only(right: 10,left: 10),
                          child: Column(
                            children: [
                              SizedBox(
                                height: 200,
                                width: double.infinity,
                                child: Image.network(
                                  lugar.imagenUrl,
                                  fit: BoxFit.fill,
                                  loadingBuilder: (
                                      BuildContext context,
                                      Widget child,
                                      ImageChunkEvent? loadingProgress,
                                      ) {
                                    if (loadingProgress == null) {
                                      return child;
                                    } else {
                                      return const Center(child: CircularProgressIndicator());
                                    }
                                  },
                                ),
                              ),
                              ListTile(
                                onTap: (){},
                                title: Text(
                                  lugar.nombre,
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                subtitle: Text(lugar.tipo),
                                // trailing: IconButton(
                                //   icon: Icon(Icons.navigation),
                                //   onPressed: () {
                                //     ScaffoldMessenger.of(context).showSnackBar(
                                //       SnackBar(
                                //         content: Text('Navegando a ${lugar.nombre}...'),
                                //       ),
                                //     );
                                //   },
                                // ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                child: Text(lugar.descripcion),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Text('Negocios Estudiantiles',style: TextStyle(color: Colors.black,fontSize: 24),),
                ),
                SizedBox(
                  height: 400, // Altura total del carrusel horizontal
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: lugaresGuardados.length,
                    itemBuilder: (context, index) {
                      final lugar = lugaresGuardados[index];
                      return SizedBox(
                        width: 325, // Ancho de cada tarjeta horizontal
                        child: Card(
                          clipBehavior: Clip.hardEdge,
                          margin: EdgeInsets.all(10),
                          child: Column(
                            children: [
                              SizedBox(
                                height: 200,
                                width: double.infinity,
                                child: Image.network(
                                  lugar.imagenUrl,
                                  fit: BoxFit.fill,
                                  loadingBuilder: (
                                      BuildContext context,
                                      Widget child,
                                      ImageChunkEvent? loadingProgress,
                                      ) {
                                    if (loadingProgress == null) {
                                      return child;
                                    } else {
                                      return const Center(child: CircularProgressIndicator());
                                    }
                                  },
                                ),
                              ),
                              ListTile(

                                title: Text(
                                  lugar.nombre,
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                subtitle: Text(lugar.tipo),
                                // trailing: IconButton(
                                //   icon: Icon(Icons.navigation),
                                //   onPressed: () {
                                //     ScaffoldMessenger.of(context).showSnackBar(
                                //       SnackBar(
                                //         content: Text('Navegando a ${lugar.nombre}...'),
                                //       ),
                                //     );
                                //   },
                                // ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                child: Text(lugar.descripcion),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Text('Zonas recreativas',style: TextStyle(color: Colors.black,fontSize: 24),),
                ),
                SizedBox(
                  height: 400, // Altura total del carrusel horizontal
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: lugaresGuardados.length,
                    itemBuilder: (context, index) {
                      final lugar = lugaresGuardados[index];
                      return SizedBox(
                        width: 325, // Ancho de cada tarjeta horizontal
                        child: Card(
                          clipBehavior: Clip.hardEdge,
                          margin: EdgeInsets.all(10),
                          child: Column(
                            children: [
                              SizedBox(
                                height: 200,
                                width: double.infinity,
                                child: Image.network(
                                  lugar.imagenUrl,
                                  fit: BoxFit.fill,
                                  loadingBuilder: (
                                      BuildContext context,
                                      Widget child,
                                      ImageChunkEvent? loadingProgress,
                                      ) {
                                    if (loadingProgress == null) {
                                      return child;
                                    } else {
                                      return const Center(child: CircularProgressIndicator());
                                    }
                                  },
                                ),
                              ),
                              ListTile(
                                title: Text(
                                  lugar.nombre,
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                subtitle: Text(lugar.tipo),
                                // trailing: IconButton(
                                //   icon: Icon(Icons.navigation),
                                //   onPressed: () {
                                //     ScaffoldMessenger.of(context).showSnackBar(
                                //       SnackBar(
                                //         content: Text('Navegando a ${lugar.nombre}...'),
                                //       ),
                                //     );
                                //   },
                                // ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                child: Text(lugar.descripcion),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
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
