import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gabimaps/features/posts/data/post_model.dart';
import 'package:gabimaps/features/posts/provider/posts_provider.dart';  

class CreatePostButton extends StatelessWidget {
  final bool isOfficial;

  const CreatePostButton({super.key, this.isOfficial = false});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () => _showPostTypeDialog(context),
      child: const Icon(Icons.add),
    );
  }

  void _showPostTypeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Crear nueva publicación'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children:
                  PostType.values
                      .where(
                        (type) => type != PostType.comment,
                      ) // Excluimos comentarios
                      .map(
                        (type) => ListTile(
                          leading: Icon(_getIconForType(type)),
                          title: Text(type.displayName),
                          onTap: () {
                            Navigator.pop(context);
                            _showPostForm(context, type);
                          },
                        ),
                      )
                      .toList(),
            ),
          ),
    );
  }

  void _showPostForm(BuildContext context, PostType type) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder:
          (context) => Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: _PostFormContent(type: type, isOfficial: isOfficial),
          ),
    );
  }

  IconData _getIconForType(PostType type) {
    switch (type) {
      case PostType.event:
        return Icons.event;
      case PostType.scholarship:
        return Icons.school;
      case PostType.internship:
        return Icons.work;
      case PostType.agreement:
        return Icons.handshake;
      case PostType.class_notice:
        return Icons.announcement;
      default:
        return Icons.post_add;
    }
  }
}

class _PostFormContent extends ConsumerStatefulWidget {
  final PostType type;
  final bool isOfficial;

  const _PostFormContent({required this.type, required this.isOfficial});

  @override
  ConsumerState<_PostFormContent> createState() => _PostFormContentState();
}

class _PostFormContentState extends ConsumerState<_PostFormContent> {
  final _formKey = GlobalKey<FormState>();
  final _contentController = TextEditingController();
  final _titleController = TextEditingController();
  final _locationController = TextEditingController();
  final _dateController = TextEditingController();

  PostVisibility _visibility = PostVisibility.public;
  DateTime? _selectedDate;

  @override
  void dispose() {
    _contentController.dispose();
    _titleController.dispose();
    _locationController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = "${picked.day}/${picked.month}/${picked.year}";
      });
    }
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final postsNotifier = ref.read(postsNotifierProvider.notifier);

    final content = _contentController.text.trim();
    final title = _titleController.text.trim();
    final location = _locationController.text.trim();

    // Construir campos personalizados según el tipo
    Map<String, dynamic>? customFields;

    if (widget.type == PostType.event && _selectedDate != null) {
      customFields = {
        'eventDate': _selectedDate?.toIso8601String(),
        'location': location.isNotEmpty ? location : null,
      };
    } else if (widget.type == PostType.scholarship && _selectedDate != null) {
      customFields = {'deadline': _selectedDate?.toIso8601String()};
    }

    try {
      await postsNotifier.createPost(
        type: widget.type,
        title: title,
        content: content,
        visibility: _visibility,
        isOfficial: widget.isOfficial,
        locationId: location.isNotEmpty ? location : null,
        customFields: customFields,
      );

      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error al publicar: $e')));
      }
    }
  }

  Widget _buildTitleField(String label) {
    return TextFormField(
      controller: _titleController,
      decoration: InputDecoration(labelText: label),
      validator: (value) => value == null || value.isEmpty ? 'Requerido' : null,
    );
  }

  Widget _buildDateField(String label) {
    return TextFormField(
      controller: _dateController,
      decoration: InputDecoration(
        labelText: label,
        suffixIcon: Icon(Icons.calendar_today),
      ),
      onTap: () => _selectDate(context),
      readOnly: true,
      validator:
          widget.type == PostType.event || widget.type == PostType.scholarship
              ? (value) => value == null || value.isEmpty ? 'Requerido' : null
              : null,
    );
  }

  Widget _buildLocationField(String label) {
    return TextFormField(
      controller: _locationController,
      decoration: InputDecoration(labelText: label),
    );
  }

  @override
  Widget build(BuildContext context) {
    String titleLabel;
    String? dateLabel;
    String? locationLabel;

    switch (widget.type) {
      case PostType.event:
        titleLabel = 'Nombre del Evento';
        dateLabel = 'Fecha del Evento';
        locationLabel = 'Ubicación';
        break;
      case PostType.scholarship:
        titleLabel = 'Nombre de la Beca';
        dateLabel = 'Fecha Límite';
        break;
      case PostType.internship:
        titleLabel = 'Nombre de la Pasantía';
        locationLabel = 'Empresa/Organización';
        break;
      case PostType.agreement:
        titleLabel = 'Nombre del Convenio';
        locationLabel = 'Institución/Organización';
        break;
      case PostType.class_notice:
        titleLabel = 'Título del Aviso';
        break;
      default:
        titleLabel = 'Título';
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Nuevo ${widget.type.displayName}',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),

            _buildTitleField(titleLabel),
            const SizedBox(height: 16),

            if (dateLabel != null) ...[
              _buildDateField(dateLabel),
              const SizedBox(height: 16),
            ],

            if (locationLabel != null) ...[
              _buildLocationField(locationLabel),
              const SizedBox(height: 16),
            ],

            DropdownButtonFormField<PostVisibility>(
              value: _visibility,
              items:
                  PostVisibility.values
                      .map(
                        (visibility) => DropdownMenuItem(
                          value: visibility,
                          child: Text(visibility.toString().split('.').last),
                        ),
                      )
                      .toList(),
              onChanged:
                  (visibility) => setState(() => _visibility = visibility!),
              decoration: const InputDecoration(labelText: 'Visibilidad'),
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _contentController,
              decoration: const InputDecoration(labelText: 'Contenido'),
              maxLines: 4,
              validator:
                  (value) =>
                      value == null || value.isEmpty ? 'Requerido' : null,
            ),
            const SizedBox(height: 24),

            ElevatedButton(onPressed: _submit, child: const Text('Publicar')),
          ],
        ),
      ),
    );
  }
}
