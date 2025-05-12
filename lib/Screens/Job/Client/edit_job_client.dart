// lib/screens/job/edit_job_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class EditJobScreen extends StatefulWidget {
  final String jobId;
  const EditJobScreen({Key? key, required this.jobId}) : super(key: key);

  @override
  State<EditJobScreen> createState() => _EditJobScreenState();
}

class _EditJobScreenState extends State<EditJobScreen> {
  final _formKey = GlobalKey<FormState>();
  String _title = '', _description = '', _category = 'Design';
  double _budget = 0;
  bool _loading = true, _saving = false;

  final List<String> _categories = [
    'Design',
    'Development',
    'Writing',
    'Marketing',
  ];

  @override
  void initState() {
    super.initState();
    _loadJob();
  }

  Future<void> _loadJob() async {
    final doc =
        await FirebaseFirestore.instance
            .collection('jobs')
            .doc(widget.jobId)
            .get();
    final data = doc.data()!;
    setState(() {
      _title = data['title'] ?? '';
      _description = data['description'] ?? '';
      _category = data['category'] ?? _category;
      _budget = (data['budget'] as num?)?.toDouble() ?? 0;
      _loading = false;
    });
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    await FirebaseFirestore.instance
        .collection('jobs')
        .doc(widget.jobId)
        .update({
          'title': _title.trim(),
          'description': _description.trim(),
          'category': _category,
          'budget': _budget,
        });
    setState(() => _saving = false);
    Navigator.pop(context);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Job updated')));
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Job')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                initialValue: _title,
                decoration: const InputDecoration(labelText: 'Job Title'),
                onChanged: (v) => _title = v,
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                initialValue: _description,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 3,
                onChanged: (v) => _description = v,
                validator: (v) => v!.length < 10 ? 'Min 10 chars' : null,
              ),
              TextFormField(
                initialValue: _budget.toString(),
                decoration: const InputDecoration(
                  labelText: 'Budget (USD)',
                  prefixText: '\$',
                ),
                keyboardType: TextInputType.number,
                onChanged: (v) => _budget = double.tryParse(v) ?? 0,
                validator:
                    (v) =>
                        (double.tryParse(v!) ?? 0) > 0 ? null : 'Enter valid',
              ),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Category'),
                value: _category,
                items:
                    _categories
                        .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                        .toList(),
                onChanged: (v) => setState(() => _category = v!),
              ),
              const Spacer(),
              _saving
                  ? const CircularProgressIndicator()
                  : SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _saveChanges,
                      child: const Text('Save Changes'),
                    ),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}
