// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';

// class EditJobScreen extends StatefulWidget {
//   final String jobId;
//   const EditJobScreen({super.key, required this.jobId});

//   @override
//   State<EditJobScreen> createState() => _EditJobScreenState();
// }

// class _EditJobScreenState extends State<EditJobScreen> {
//   final _formKey = GlobalKey<FormState>();
//   String _title = '', _description = '', _category = 'Design';
//   double _budget = 0;
//   bool _loading = true, _saving = false;

//   final List<String> _categories = [
//     'Design',
//     'Development',
//     'Writing',
//     'Marketing',
//   ];

//   @override
//   void initState() {
//     super.initState();
//     _loadJob();
//   }

//   Future<void> _loadJob() async {
//     final doc =
//         await FirebaseFirestore.instance
//             .collection('jobs')
//             .doc(widget.jobId)
//             .get();
//     final data = doc.data()!;
//     setState(() {
//       _title = data['title'] ?? '';
//       _description = data['description'] ?? '';
//       _category = data['category'] ?? _category;
//       _budget = (data['budget'] as num?)?.toDouble() ?? 0;
//       _loading = false;
//     });
//   }

//   Future<void> _saveChanges() async {
//     if (!_formKey.currentState!.validate()) return;
//     setState(() => _saving = true);
//     await FirebaseFirestore.instance
//         .collection('jobs')
//         .doc(widget.jobId)
//         .update({
//           'title': _title.trim(),
//           'description': _description.trim(),
//           'category': _category,
//           'budget': _budget,
//         });
//     setState(() => _saving = false);
//     Navigator.pop(context);
//     ScaffoldMessenger.of(
//       context,
//     ).showSnackBar(const SnackBar(content: Text('Job updated')));
//   }

//   @override
//   Widget build(BuildContext context) {
//         final theme = Theme.of(context);
//     final colorScheme = theme.colorScheme;
//     if (_loading) {
//       return const Scaffold(body: Center(child: CircularProgressIndicator()));
//     }
//     return Scaffold(
//       appBar: AppBar(
//         centerTitle: true,
//         backgroundColor: Colors.transparent,
//         flexibleSpace: Container(
//           decoration: BoxDecoration(
//             gradient: LinearGradient(
//               begin: Alignment.topCenter,
//               end: Alignment.bottomCenter,
//               colors: [colorScheme.primary, colorScheme.surface],
//             ),
//           ),
//         ),
//         title: const Text('Edit Job')),
//       body: Container(
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             begin: Alignment.topCenter,
//             end: Alignment.bottomCenter,
//             colors: [
//               colorScheme.primary.withOpacity(0.1),
//               colorScheme.background,
//             ],
//           ),
//         ),
//         child: Padding(
//           padding: const EdgeInsets.all(16),
//           child: Form(
//             key: _formKey,
//             child: Column(
//               children: [
//                 TextFormField(
//                   initialValue: _title,
//                   decoration: const InputDecoration(labelText: 'Job Title'),
//                   onChanged: (v) => _title = v,
//                   validator: (v) => v!.isEmpty ? 'Required' : null,
//                 ),
//                 TextFormField(
//                   initialValue: _description,
//                   decoration: const InputDecoration(labelText: 'Description'),
//                   maxLines: 3,
//                   onChanged: (v) => _description = v,
//                   validator: (v) => v!.length < 10 ? 'Min 10 chars' : null,
//                 ),
//                 TextFormField(
//                   initialValue: _budget.toString(),
//                   decoration: const InputDecoration(
//                     labelText: 'Budget (USD)',
//                     prefixText: '\$',
//                   ),
//                   keyboardType: TextInputType.number,
//                   onChanged: (v) => _budget = double.tryParse(v) ?? 0,
//                   validator:
//                       (v) =>
//                           (double.tryParse(v!) ?? 0) > 0 ? null : 'Enter valid',
//                 ),
//                 DropdownButtonFormField<String>(
//                   decoration: const InputDecoration(labelText: 'Category'),
//                   value: _category,
//                   items:
//                       _categories
//                           .map((c) => DropdownMenuItem(value: c, child: Text(c)))
//                           .toList(),
//                   onChanged: (v) => setState(() => _category = v!),
//                 ),
//                 const SizedBox(height: 50,),
//                 _saving
//                     ? const CircularProgressIndicator()
//                     : SizedBox(
//                       width: double.infinity,
//                       child: ElevatedButton(
//                         onPressed: _saveChanges,
//                         child: const Text('Save Changes'),
//                       ),
//                     ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }



import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditJobScreen extends StatefulWidget {
  final String jobId;
  const EditJobScreen({Key? key, required this.jobId}) : super(key: key);

  @override
  State<EditJobScreen> createState() => _EditJobScreenState();
}

class _EditJobScreenState extends State<EditJobScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  String _title = '', _description = '', _category = 'Design';
  double _budget = 0;
  bool _loading = true, _saving = false;
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;
  late Animation<Offset> _slideAnimation;

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

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _opacityAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutQuad));

    _controller.forward();
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

  Widget _buildAnimatedField(Widget child, int index) {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _opacityAnimation,
        child: Padding(
          padding: EdgeInsets.only(bottom: 16, top: index == 0 ? 0 : 16),
          child: child,
        ),
      ),
    );
  }

  Widget _customTextField({
    required String label,
    required IconData icon,
    required TextEditingController controller,
    required String? Function(String?) validator,
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Colors.blueGrey),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.transparent,
          contentPadding: const EdgeInsets.all(16),
        ),
        validator: validator,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    if (_loading) {
      return Scaffold(
        body: Center(
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.5, end: 1.0),
            duration: const Duration(milliseconds: 800),
            builder: (context, value, child) {
              return Opacity(
                opacity: value,
                child: Transform.scale(
                  scale: value,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation(colorScheme.primary),
                  ),
                ),
              );
            },
          ),
        ),
      );
    }

    final titleController = TextEditingController(text: _title);
    final descController = TextEditingController(text: _description);
    final budgetController = TextEditingController(text: _budget.toString());

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        elevation: 4,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [colorScheme.primary, colorScheme.surface],
            ),
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colorScheme.onPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Edit Job',
          style: textTheme.headlineSmall?.copyWith(
            color: colorScheme.onPrimary,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              colorScheme.primary.withOpacity(0.05),
              colorScheme.background,
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    return SlideTransition(
                      position: _slideAnimation,
                      child: FadeTransition(
                        opacity: _opacityAnimation,
                        child: child,
                      ),
                    );
                  },
                  child: Column(
                    children: [
                      _customTextField(
                        label: 'Job Title',
                        icon: Icons.work_outline,
                        controller: titleController,
                        validator: (v) => v!.isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 20),
                      _customTextField(
                        label: 'Description',
                        icon: Icons.description_outlined,
                        controller: descController,
                        validator:
                            (v) => v!.length < 10 ? 'Min 10 chars' : null,
                        maxLines: 3,
                      ),
                      const SizedBox(height: 20),
                      _customTextField(
                        label: 'Budget (USD)',
                        icon: Icons.attach_money,
                        controller: budgetController,
                        validator:
                            (v) =>
                                (double.tryParse(v!) ?? 0) > 0
                                    ? null
                                    : 'Enter valid amount',
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 20),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: DropdownButtonFormField<String>(
                            decoration: InputDecoration(
                              labelText: 'Category',
                              border: InputBorder.none,
                              prefixIcon: Icon(
                                Icons.category_outlined,
                                color: Colors.blueGrey,
                              ),
                            ),
                            value: _category,
                            items:
                                _categories
                                    .map(
                                      (c) => DropdownMenuItem(
                                        value: c,
                                        child: Text(
                                          c,
                                          style: textTheme.bodyMedium,
                                        ),
                                      ),
                                    )
                                    .toList(),
                            onChanged: (v) => setState(() => _category = v!),
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
                      _saving
                          ? TweenAnimationBuilder<double>(
                            tween: Tween(begin: 0, end: 1),
                            duration: const Duration(milliseconds: 500),
                            builder: (context, value, child) {
                              return Opacity(
                                opacity: value,
                                child: Transform.scale(
                                  scale: value,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation(
                                      colorScheme.primary,
                                    ),
                                  ),
                                ),
                              );
                            },
                          )
                          : AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeOutQuad,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              gradient: LinearGradient(
                                colors: [
                                  colorScheme.primary,
                                  colorScheme.secondary,
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: colorScheme.primary.withOpacity(0.3),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ElevatedButton(
                              onPressed: _saveChanges,
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.all(18),
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(
                                'Save Changes',
                                style: textTheme.titleMedium?.copyWith(
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
