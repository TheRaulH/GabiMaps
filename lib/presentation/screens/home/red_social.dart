import 'package:flutter/material.dart';

void main() => runApp(UAGRMRedSocialApp());

class UAGRMRedSocialApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Red Social UAGRM',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      home: RedSocialUAGRM(),
    );
  }
}

class RedSocialUAGRM extends StatelessWidget {
  final List<Post> posts = [
    Post(
      username: "Facultad Ingeniería",
      userAvatar: "https://t4.ftcdn.net/jpg/03/64/21/11/360_F_364211147_1qgLVxv1Tcq0Ohz3FawUfrtONzz8nq3e.jpg",
      imageUrl: "https://construccioncivil.uc.cl/wp-content/uploads/2022/07/4.-Rodrigo-Richmagui-scaled.jpg",
      description: "Charlas técnicas en el auditorio principal 🔧📘",
    ),
    Post(
      username: "Estudiantes Medicina",
      userAvatar: "https://images.ctfassets.net/h6goo9gw1hh6/2sNZtFAWOdP1lmQ33VwRN3/e40b6ea6361a1abe28f32e7910f63b66/1-intro-photo-final.jpg?w=1200&h=992&fl=progressive&q=70&fm=jpg",
      imageUrl: "https://www.uab.cat/Imatge/1000/257/IMG_voluntariattornaVallHebronG.png",
      description: "Voluntariado en hospitales 🏥❤️",
    ),
    Post(
      username: "UAGRM Oficial",
      userAvatar: "https://d2qp0siotla746.cloudfront.net/img/use-cases/profile-picture/template_3.jpg",
      imageUrl: "https://files.uagrm.edu.bo/entidad/66/image/9.png",
      description: "Acto de bienvenida para nuevos estudiantes 👨‍🎓👩‍🎓",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
       
      body: ListView.builder(
        itemCount: posts.length,
        itemBuilder: (context, index) {
          return PostWidget(post: posts[index]);
        },
      ),
       
    );
  }
}

class Post {
  final String username;
  final String userAvatar;
  final String imageUrl;
  final String description;

  Post({
    required this.username,
    required this.userAvatar,
    required this.imageUrl,
    required this.description,
  });
}

class PostWidget extends StatelessWidget {
  final Post post;

  const PostWidget({Key? key, required this.post}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          leading: CircleAvatar(backgroundImage: NetworkImage(post.userAvatar)),
          title: Text(
            post.username,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          trailing: Icon(Icons.more_vert),
        ),
        Image.network(post.imageUrl, fit: BoxFit.cover, width: double.infinity),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          child: Row(
            children: [
              Icon(Icons.favorite_border),
              SizedBox(width: 16),
              Icon(Icons.comment_outlined),
              SizedBox(width: 16),
              Icon(Icons.share_outlined),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Text(post.description),
        ),
        SizedBox(height: 10),
        Divider(),
      ],
    );
  }
}
