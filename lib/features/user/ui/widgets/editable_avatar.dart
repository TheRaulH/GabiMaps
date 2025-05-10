import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class EditableAvatar extends StatefulWidget {
  final String? imageUrl;
  final double radius;
  final Function(String) onImageChanged;

  const EditableAvatar({
    super.key,
    this.imageUrl,
    this.radius = 40,
    required this.onImageChanged,
  });

  @override
  State<EditableAvatar> createState() => _EditableAvatarState();
}

class _EditableAvatarState extends State<EditableAvatar> {
  File? _localImage;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _localImage = File(pickedFile.path);
      });
      widget.onImageChanged(pickedFile.path);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _pickImage,
      child: Stack(
        children: [
          CircleAvatar(
            radius: widget.radius,
            backgroundImage:
                _localImage != null
                    ? FileImage(_localImage!)
                    : widget.imageUrl != null
                    ? NetworkImage(widget.imageUrl!)
                    : null,
            child:
                _localImage == null && widget.imageUrl == null
                    ? Icon(Icons.person, size: widget.radius)
                    : null,
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: const Icon(Icons.edit, size: 16, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
