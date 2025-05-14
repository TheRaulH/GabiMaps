import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../posts/provider/posts_provider.dart';
import '../../data/post_model.dart';

class NewPostForm extends ConsumerStatefulWidget {
  final String? parentId;
  final int depth;
  final bool isReply;
  final PostType? initialType;

  const NewPostForm({
    super.key,
    this.parentId,
    this.depth = 0,
    this.isReply = false,
    this.initialType,
  });

  @override
  ConsumerState<NewPostForm> createState() => _NewPostFormState();
}

class _NewPostFormState extends ConsumerState<NewPostForm> {
  final _formKey = GlobalKey<FormState>();
  final _contentController = TextEditingController();
  final _titleController = TextEditingController();
  final _locationController = TextEditingController();
  final _eventDateController = TextEditingController();
  final _scholarshipDeadlineController = TextEditingController();

  bool isOfficial = false;
  PostType _selectedType = PostType.general;
  PostVisibility _selectedVisibility = PostVisibility.public;
  DateTime? _eventDate;
  DateTime? _scholarshipDeadline;

  @override
  void initState() {
    super.initState();
    _selectedType = widget.initialType ?? PostType.general;
  }

  @override
  void dispose() {
    _contentController.dispose();
    _titleController.dispose();
    _locationController.dispose();
    _eventDateController.dispose();
    _scholarshipDeadlineController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, bool isEventDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        if (isEventDate) {
          _eventDate = picked;
          _eventDateController.text =
              "${picked.day}/${picked.month}/${picked.year}";
        } else {
          _scholarshipDeadline = picked;
          _scholarshipDeadlineController.text =
              "${picked.day}/${picked.month}/${picked.year}";
        }
      });
    }
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final postsNotifier = ref.read(postsNotifierProvider.notifier);

    final content = _contentController.text.trim();
    final title =
        _titleController.text.trim().isEmpty
            ? null
            : _titleController.text.trim();
    final location =
        _locationController.text.trim().isEmpty
            ? null
            : _locationController.text.trim();

    // Construir campos personalizados según el tipo
    Map<String, dynamic>? customFields;

    switch (_selectedType) {
      case PostType.event:
        customFields = {
          'eventDate': _eventDate?.toIso8601String(),
          'location': location,
        };
        break;
      case PostType.scholarship:
        customFields = {'deadline': _scholarshipDeadline?.toIso8601String()};
        break;
      case PostType.internship:
      case PostType.agreement:
        customFields = {'location': location};
        break;
      default:
        customFields = null;
    }

    try {
      if (widget.parentId == null) {
        // Crear post raíz
        await postsNotifier.createPost(
          type: _selectedType,
          title: title ?? "Sin título",
          content: content,
          visibility: _selectedVisibility,
          isOfficial: isOfficial,
          locationId: location,
          customFields: customFields,
        );
      } else if (widget.isReply) {
        // Crear respuesta
        await postsNotifier.createReply(
          parentCommentId: widget.parentId!,
          content: content,
          isOfficial: isOfficial,
        );
      } else {
        // Crear comentario
        await postsNotifier.createComment(
          parentPostId: widget.parentId!,
          content: content,
          isOfficial: isOfficial,
        );
      }

      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error al publicar: $e')));
      }
    }
  }

  Widget _buildGeneralFields() {
    return Column(
      children: [
        TextFormField(
          controller: _titleController,
          decoration: const InputDecoration(labelText: 'Título'),
          validator:
              (value) => value == null || value.isEmpty ? 'Requerido' : null,
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildEventFields() {
    return Column(
      children: [
        TextFormField(
          controller: _titleController,
          decoration: const InputDecoration(labelText: 'Nombre del Evento'),
          validator:
              (value) => value == null || value.isEmpty ? 'Requerido' : null,
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _eventDateController,
          decoration: const InputDecoration(
            labelText: 'Fecha del Evento',
            suffixIcon: Icon(Icons.calendar_today),
          ),
          onTap: () => _selectDate(context, true),
          readOnly: true,
          validator:
              (value) => value == null || value.isEmpty ? 'Requerido' : null,
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _locationController,
          decoration: const InputDecoration(labelText: 'Ubicación/Lugar'),
        ),
      ],
    );
  }

  Widget _buildScholarshipFields() {
    return Column(
      children: [
        TextFormField(
          controller: _titleController,
          decoration: const InputDecoration(labelText: 'Nombre de la Beca'),
          validator:
              (value) => value == null || value.isEmpty ? 'Requerido' : null,
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _scholarshipDeadlineController,
          decoration: const InputDecoration(
            labelText: 'Fecha Límite',
            suffixIcon: Icon(Icons.calendar_today),
          ),
          onTap: () => _selectDate(context, false),
          readOnly: true,
          validator:
              (value) => value == null || value.isEmpty ? 'Requerido' : null,
        ),
      ],
    );
  }

  Widget _buildInternshipFields() {
    return Column(
      children: [
        TextFormField(
          controller: _titleController,
          decoration: const InputDecoration(labelText: 'Nombre de la Pasantía'),
          validator:
              (value) => value == null || value.isEmpty ? 'Requerido' : null,
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _locationController,
          decoration: const InputDecoration(labelText: 'Empresa/Organización'),
        ),
      ],
    );
  }

  Widget _buildAgreementFields() {
    return Column(
      children: [
        TextFormField(
          controller: _titleController,
          decoration: const InputDecoration(labelText: 'Nombre del Convenio'),
          validator:
              (value) => value == null || value.isEmpty ? 'Requerido' : null,
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _locationController,
          decoration: const InputDecoration(
            labelText: 'Institución/Organización',
          ),
        ),
      ],
    );
  }

  Widget _buildTypeSpecificFields() {
    if (widget.parentId != null)
      return const SizedBox(); // No mostrar para comentarios/respuestas

    switch (_selectedType) {
      case PostType.event:
        return _buildEventFields();
      case PostType.scholarship:
        return _buildScholarshipFields();
      case PostType.internship:
        return _buildInternshipFields();
      case PostType.agreement:
        return _buildAgreementFields();
      case PostType.class_notice:
        return _buildGeneralFields();
      default:
        return _buildGeneralFields();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isCommentOrReply = widget.parentId != null;

    return AlertDialog(
      title: Text(
        isCommentOrReply
            ? widget.isReply
                ? 'Responder comentario'
                : 'Nuevo comentario'
            : 'Nueva publicación',
      ),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!isCommentOrReply) ...[
                DropdownButtonFormField<PostType>(
                  value: _selectedType,
                  items:
                      PostType.values
                          .where((type) => type != PostType.comment)
                          .map(
                            (type) => DropdownMenuItem(
                              value: type,
                              child: Text(type.displayName),
                            ),
                          )
                          .toList(),
                  onChanged: (type) => setState(() => _selectedType = type!),
                  decoration: const InputDecoration(
                    labelText: 'Tipo de Publicación',
                  ),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<PostVisibility>(
                  value: _selectedVisibility,
                  items:
                      PostVisibility.values
                          .map(
                            (visibility) => DropdownMenuItem(
                              value: visibility,
                              child: Text(
                                visibility.toString().split('.').last,
                              ),
                            ),
                          )
                          .toList(),
                  onChanged:
                      (visibility) =>
                          setState(() => _selectedVisibility = visibility!),
                  decoration: const InputDecoration(labelText: 'Visibilidad'),
                ),
                const SizedBox(height: 8),
              ],

              _buildTypeSpecificFields(),

              const SizedBox(height: 8),
              TextFormField(
                controller: _contentController,
                decoration: const InputDecoration(labelText: 'Contenido'),
                maxLines: 4,
                validator:
                    (value) =>
                        value == null || value.isEmpty ? 'Escribe algo' : null,
              ),
              const SizedBox(height: 8),
              CheckboxListTile(
                title: const Text('Publicación oficial'),
                value: isOfficial,
                onChanged: (val) {
                  setState(() => isOfficial = val ?? false);
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(onPressed: _submit, child: const Text('Publicar')),
      ],
    );
  }
}
