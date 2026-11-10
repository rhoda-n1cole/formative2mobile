import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../app/category_style.dart';
import '../../app/constants.dart';
import '../../app/theme.dart';
import '../../app/validators.dart';
import '../../models/incident.dart';
import '../../providers/auth_providers.dart';
import '../../providers/incident_providers.dart';
import '../../widgets/loading_button.dart';

class SubmitReportScreen extends ConsumerStatefulWidget {
  const SubmitReportScreen({super.key, this.initialCategory});

  final String? initialCategory;

  @override
  ConsumerState<SubmitReportScreen> createState() => _SubmitReportScreenState();
}

class _SubmitReportScreenState extends ConsumerState<SubmitReportScreen> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _description = TextEditingController();
  final _location = TextEditingController();
  String? _category;
  bool _categoryError = false;
  bool _anonymous = false;
  bool _loading = false;
  XFile? _image;

  @override
  void initState() {
    super.initState();
    _category = widget.initialCategory;
  }

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    _location.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final picked = await ImagePicker().pickImage(
      source: source,
      imageQuality: 70,
      maxWidth: 1024,
    );
    if (picked != null) setState(() => _image = picked);
  }

  void _choosePhotoSource() {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Choose from gallery'),
              onTap: () {
                Navigator.pop(ctx);
                _pickImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: const Text('Take a photo'),
              onTap: () {
                Navigator.pop(ctx);
                _pickImage(ImageSource.camera);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    final formOk = _formKey.currentState!.validate();
    setState(() => _categoryError = _category == null);
    if (!formOk || _category == null) return;

    final user = ref.read(appUserProvider).value;
    if (user == null) return;

    setState(() => _loading = true);
    try {
      String? imageUrl;
      if (_image != null) {
        imageUrl = await ref
            .read(storageRepositoryProvider)
            .uploadIncidentImage(user.uid, _image!);
      }
      await ref
          .read(incidentRepositoryProvider)
          .create(
            Incident(
              id: '',
              title: _title.text.trim(),
              description: _description.text.trim(),
              category: _category!,
              status: 'Submitted',
              location: _location.text.trim(),
              imageUrl: imageUrl,
              reporterId: user.uid,
              reporterName: _anonymous ? 'Anonymous' : user.name,
              isAnonymous: _anonymous,
            ),
          );
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Report submitted')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Could not submit: $e')));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Widget _label(String text, {String? hint}) => Padding(
    padding: const EdgeInsets.only(bottom: 8, top: 16),
    child: Row(
      children: [
        Text(
          text,
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
        ),
        if (hint != null) ...[
          const SizedBox(width: 6),
          Text(
            hint,
            style: const TextStyle(color: Colors.black45, fontSize: 12),
          ),
        ],
      ],
    ),
  );

  @override
  Widget build(BuildContext context) {
    final tileWidth = (MediaQuery.of(context).size.width - 32 - 16) / 3;

    return Scaffold(
      appBar: AppBar(title: const Text('Report an Incident')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _label('Select a category'),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: AppConstants.categories.map((c) {
                    final selected = _category == c;
                    return GestureDetector(
                      onTap: () => setState(() {
                        _category = c;
                        _categoryError = false;
                      }),
                      child: Container(
                        width: tileWidth,
                        height: 76,
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          color: selected
                              ? AppColors.primary
                              : AppColors.primary.withValues(alpha: 0.07),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              categoryIcon(c),
                              color: selected
                                  ? Colors.white
                                  : AppColors.primary,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              c,
                              maxLines: 2,
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: selected ? Colors.white : Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
                if (_categoryError)
                  const Padding(
                    padding: EdgeInsets.only(top: 6, left: 4),
                    child: Text(
                      'Choose a category',
                      style: TextStyle(color: AppColors.danger, fontSize: 12),
                    ),
                  ),
                _label('Title'),
                TextFormField(
                  controller: _title,
                  decoration: const InputDecoration(
                    hintText: 'Briefly describe the issue...',
                  ),
                  validator: (v) => Validators.required(v, 'Title'),
                ),
                _label('Description'),
                TextFormField(
                  controller: _description,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    hintText: 'Provide more details about the issue...\ne.g. what happened, when, impact, etc.',
                    alignLabelWithHint: true,
                  ),
                  validator: (v) {
                    if (v == null || v.trim().length < 10) {
                      return 'Describe the issue (at least 10 characters)';
                    }
                    return null;
                  },
                ),
                _label('Location'),
                TextFormField(
                  controller: _location,
                  decoration: const InputDecoration(
                    hintText: 'e.g. Block B, Room 204',
                    prefixIcon: Icon(Icons.place_outlined),
                  ),
                  validator: (v) => Validators.required(v, 'Location'),
                ),
                _label('Add a photo', hint: '(optional)'),
                if (_image != null)
                  Stack(
                    alignment: Alignment.topRight,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(
                          File(_image!.path),
                          height: 150,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                      IconButton.filled(
                        icon: const Icon(Icons.close),
                        onPressed: () => setState(() => _image = null),
                      ),
                    ],
                  )
                else
                  GestureDetector(
                    onTap: _choosePhotoSource,
                    child: CustomPaint(
                      painter: _DashedBorder(
                        AppColors.primary.withValues(alpha: 0.4),
                      ),
                      child: Container(
                        height: 100,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.04),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.image_outlined,
                              color: AppColors.primary,
                              size: 30,
                            ),
                            SizedBox(height: 6),
                            Text(
                              'Tap to add photos',
                              style: TextStyle(
                                color: Colors.black54,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                const SizedBox(height: 8),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Report anonymously'),
                  subtitle: const Text('Staff will not see your name'),
                  value: _anonymous,
                  onChanged: (v) => setState(() => _anonymous = v),
                ),
                const SizedBox(height: 12),
                LoadingButton(
                  label: 'Submit Report',
                  loading: _loading,
                  onPressed: _submit,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DashedBorder extends CustomPainter {
  _DashedBorder(this.color);
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;
    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(12)),
      );
    for (final metric in path.computeMetrics()) {
      double d = 0;
      while (d < metric.length) {
        canvas.drawPath(metric.extractPath(d, d + 6), paint);
        d += 10;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
