import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gabimaps/features/posts/data/post_model.dart';
import 'package:gabimaps/features/posts/provider/posts_provider.dart';

class CreatePostButton extends StatelessWidget {
  final bool isOfficial;
  final Color? iconColor;

  const CreatePostButton({super.key, this.isOfficial = false, this.iconColor});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return IconButton(
      icon: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color:
              isOfficial
                  ? theme.colorScheme.primary
                  : theme.colorScheme.secondary,
          shape: BoxShape.circle,
          boxShadow: [
            if (!isDarkMode)
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
          ],
        ),
        child: Icon(
          Icons.add,
          color: iconColor ?? theme.colorScheme.onPrimary,
          size: 24,
        ),
      ),
      tooltip: 'Crear publicación',
      onPressed: () => _showPostTypeDialog(context),
    );
  }

  void _showPostTypeDialog(BuildContext context) {
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(
              'Crear nueva publicación',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            content: SizedBox(
              width: double.maxFinite,
              child: ListView(
                shrinkWrap: true,
                children:
                    PostType.values
                        .where((type) => type != PostType.comment)
                        .map(
                          (type) => Card(
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                              side: BorderSide(
                                color: theme.dividerColor.withOpacity(0.2),
                                width: 1,
                              ),
                            ),
                            child: ListTile(
                              leading: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primary.withOpacity(
                                    0.1,
                                  ),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  _getIconForType(type),
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                              title: Text(
                                type.displayName,
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              trailing: const Icon(Icons.chevron_right),
                              onTap: () {
                                Navigator.pop(context);
                                _showPostForm(context, type);
                              },
                            ),
                          ),
                        )
                        .toList(),
              ),
            ),
          ),
    );
  }

  void _showPostForm(BuildContext context, PostType type) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.background,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
            ),
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
      builder:
          (context, child) => Theme(
            data: Theme.of(context).copyWith(
              colorScheme: ColorScheme.light(
                primary: Theme.of(context).colorScheme.primary,
                onPrimary: Theme.of(context).colorScheme.onPrimary,
                surface: Theme.of(context).colorScheme.surface,
                onSurface: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            child: child!,
          ),
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al publicar: $e'),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    }
  }

  Widget _buildTitleField(String label) {
    return TextFormField(
      controller: _titleController,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
      validator: (value) => value == null || value.isEmpty ? 'Requerido' : null,
    );
  }

  Widget _buildDateField(String label) {
    return TextFormField(
      controller: _dateController,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        suffixIcon: IconButton(
          icon: const Icon(Icons.calendar_today),
          onPressed: () => _selectDate(context),
        ),
      ),
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
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Nuevo ${widget.type.displayName}',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
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
                          child: Text(
                            visibility.toString().split('.').last,
                            style: theme.textTheme.bodyMedium,
                          ),
                        ),
                      )
                      .toList(),
              onChanged:
                  (visibility) => setState(() => _visibility = visibility!),
              decoration: InputDecoration(
                labelText: 'Visibilidad',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              style: theme.textTheme.bodyMedium,
              dropdownColor: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(10),
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _contentController,
              decoration: InputDecoration(
                labelText: 'Contenido',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                alignLabelWithHint: true,
              ),
              maxLines: 4,
              validator:
                  (value) =>
                      value == null || value.isEmpty ? 'Requerido' : null,
            ),
            const SizedBox(height: 24),

            ElevatedButton(
              onPressed: _submit,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('Publicar'),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
