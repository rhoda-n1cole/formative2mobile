import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/constants.dart';
import '../../app/validators.dart';
import '../../models/incident.dart';
import '../../providers/auth_providers.dart';
import '../../providers/incident_providers.dart';
import '../../widgets/loading_button.dart';

class SubmitReportScreen extends ConsumerStatefulWidget {
  const SubmitReportScreen({super.key});

  @override
  ConsumerState<SubmitReportScreen> createState() => _SubmitReportScreenState();
}

class _SubmitReportScreenState extends ConsumerState<SubmitReportScreen> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _description = TextEditingController();
  final _location = TextEditingController();
  String? _category;
  bool _anonymous = false;
  bool _loading = false;

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    _location.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final user = ref.read(appUserProvider).value;
    if (user == null) return;

    setState(() => _loading = true);
    try {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New report')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                DropdownButtonFormField<String>(
                  value: _category,
                  decoration: const InputDecoration(labelText: 'Category'),
                  items: AppConstants.categories
                      .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                      .toList(),
                  onChanged: (v) => setState(() => _category = v),
                  validator: (v) => v == null ? 'Choose a category' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _title,
                  decoration: const InputDecoration(labelText: 'Title'),
                  validator: (v) => Validators.required(v, 'Title'),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _location,
                  decoration: const InputDecoration(
                    labelText: 'Location',
                    hintText: 'e.g. Block B, 2nd floor restroom',
                    prefixIcon: Icon(Icons.place_outlined),
                  ),
                  validator: (v) => Validators.required(v, 'Location'),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _description,
                  maxLines: 5,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    alignLabelWithHint: true,
                  ),
                  validator: (v) {
                    if (v == null || v.trim().length < 10) {
                      return 'Describe the issue (at least 10 characters)';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 8),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Report anonymously'),
                  subtitle: const Text('Staff will not see your name'),
                  value: _anonymous,
                  onChanged: (v) => setState(() => _anonymous = v),
                ),
                const SizedBox(height: 16),
                LoadingButton(
                  label: 'Submit report',
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
