import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:job_board_freelance_marketplace/Services/theme_notifier.dart';

class PostJobScreen extends ConsumerStatefulWidget {
  const PostJobScreen({super.key});

  @override
  _PostJobScreenState createState() => _PostJobScreenState();
}

class _PostJobScreenState extends ConsumerState<PostJobScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final List<String> categories = ['Design', 'Development', 'Writing', 'Marketing'];
  String _title = '', _description = '', _category = 'Design';
  double _budget = 0;
  bool _saving = false;

  late AnimationController _controller;
  late Animation<double> _opacityAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
    )
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.5, 1.0, curve: Curves.easeOut),
    )
    );

    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.fastOutSlowIn,
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;
      await FirebaseFirestore.instance.collection('jobs').add({
        'title': _title.trim(),
        'description': _description.trim(),
        'budget': _budget,
        'category': _category,
        'status': 'open',
        'createdBy': uid,
        'createdAt': FieldValue.serverTimestamp(),
      });

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error posting job: $e'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10)),
        ),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeNotifier = ref.watch(themeNotifierProvider);
    final isDark = themeNotifier.mode == ThemeMode.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Post a Job'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: isDark
                    ? [Colors.deepPurple.shade900, Colors.indigo.shade900]
                    : [Colors.blue.shade50, Colors.purple.shade50],
              ),
            ),
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: FadeTransition(
                opacity: _opacityAnimation,
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Card(
                      elevation: 8,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Form(
                          key: _formKey,
                          child: ListView(
                            children: [
                              _buildFormField(
                                icon: Icons.title,
                                label: 'Job Title',
                                onChanged: (v) => _title = v,
                                validator: (v) => v!.isEmpty ? 'Required' : null,
                              ),
                              const SizedBox(height: 20),
                              _buildFormField(
                                icon: Icons.description,
                                label: 'Description',
                                onChanged: (v) => _description = v,
                                validator: (v) => v!.length < 10 ? 'Min 10 chars' : null,
                                maxLines: 5,
                              ),
                              const SizedBox(height: 20),
                              _buildFormField(
                                icon: Icons.attach_money,
                                label: 'Budget (USD)',
                                prefixText: '\$ ',
                                keyboardType: TextInputType.number,
                                onChanged: (v) => _budget = double.tryParse(v) ?? 0,
                                validator: (v) => (double.tryParse(v!) ?? 0) > 0
                                    ? null
                                    : 'Enter valid amount',
                              ),
                              const SizedBox(height: 20),
                              InputDecorator(
                                decoration: InputDecoration(
                                  labelText: 'Category',
                                  prefixIcon: const Icon(Icons.category),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(15)),
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    value: _category,
                                    isExpanded: true,
                                    icon: const Icon(Icons.arrow_drop_down),
                                    items: categories.map((String value) {
                                      return DropdownMenuItem<String>(
                                        value: value,
                                        child: Text(value,
                                            style: theme.textTheme.bodyLarge),
                                      );
                                    }).toList(),
                                    onChanged: (v) => setState(() => _category = v!),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 30),
                              Material(
                                borderRadius: BorderRadius.circular(15),
                                elevation: 4,
                                child: InkWell(
                                  onTap: _saving ? null : _submit,
                                  borderRadius: BorderRadius.circular(15),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    height: 50,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(15),
                                      gradient: LinearGradient(
                                        colors: [
                                          theme.primaryColor,
                                          Colors.purple.shade400,
                                        ],
                                      ),
                                    ),
                                    child: Center(
                                      child: _saving
                                          ? const CircularProgressIndicator(
                                              color: Colors.white,
                                            )
                                          : const Text(
                                              'Post Job',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFormField({
    required IconData icon,
    required String label,
    required Function(String) onChanged,
    required String? Function(String?) validator,
    String? prefixText,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        prefixText: prefixText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15)),
        floatingLabelStyle: TextStyle(color: Theme.of(context).primaryColor),
      ),
      keyboardType: keyboardType,
      maxLines: maxLines,
      onChanged: onChanged,
      validator: validator,
    );
  }
}