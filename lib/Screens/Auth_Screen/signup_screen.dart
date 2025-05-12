import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:job_board_freelance_marketplace/Services/auth_service.dart';
import 'package:job_board_freelance_marketplace/Services/theme_notifier.dart';

class SignupScreen extends ConsumerStatefulWidget {
  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _authService = AuthService();
  String _email = '', _password = '', _name = '';
  String _role = 'Freelancer';
  bool _loading = false;

  late AnimationController _controller;
  late Animation<double> _opacityAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.5, 1.0, curve: Curves.easeOut),
      ),
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
    setState(() => _loading = true);

    try {
      final cred = await _authService.signUp(_email, _password);
      final uid = cred.user!.uid;

      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'email': _email.trim(),
        'name': _name.trim(),
        'role': _role,
        'skills': [],
        'createdAt': FieldValue.serverTimestamp(),
      });

      Navigator.pushReplacementNamed(
        context,
        _role == 'client' ? '/client-dashboard' : '/freelancer-dashboard',
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Signup failed: ${e.toString()}')),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeNotifier = ref.watch(themeNotifierProvider);
    final isDark = themeNotifier.mode == ThemeMode.dark;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Create Account'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            icon: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: Icon(
                isDark ? Icons.light_mode : Icons.dark_mode,
                key: ValueKey(isDark),
              ),
            ),
            onPressed: () => themeNotifier.toggleTheme(),
          ),
        ],
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
                    ? [
                        Colors.deepPurple.shade900,
                        Colors.indigo.shade900,
                      ]
                    : [
                        Colors.blue.shade50,
                        Colors.purple.shade50,
                      ],
              ),
            ),
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: FadeTransition(
                opacity: _opacityAnimation,
                child: Padding(
                  padding: const EdgeInsets.only(top:20,bottom: 24,left: 24,right: 24),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        SlideTransition(
                          position: _slideAnimation,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            height: 180,
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: AssetImage(
                                  isDark
                                      ? 'assets/images/signupN.png'
                                      : 'assets/images/signupL.png',
                                ),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        _buildSignupForm(theme),
                      ],
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

  Widget _buildSignupForm(ThemeData theme) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: _loading
                    ? Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation(theme.primaryColor),
                        ),
                      )
                    : Column(
                        children: [
                          TextFormField(
                            decoration: InputDecoration(
                              labelText: 'Name',
                              prefixIcon: const Icon(Icons.person),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10)),
                              floatingLabelStyle: TextStyle(
                                color: theme.primaryColor),
                            ),
                            onChanged: (v) => _name = v,
                            validator: (v) => v!.isEmpty ? 'Enter your name' : null,
                          ),
                          const SizedBox(height: 20),
                          TextFormField(
                            decoration: InputDecoration(
                              labelText: 'Email',
                              prefixIcon: const Icon(Icons.email),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10)),
                              floatingLabelStyle: TextStyle(
                                color: theme.primaryColor),
                            ),
                            onChanged: (v) => _email = v,
                            validator: (v) =>
                                v!.contains('@') ? null : 'Valid email required',
                          ),
                          const SizedBox(height: 20),
                          TextFormField(
                            decoration: InputDecoration(
                              labelText: 'Password',
                              prefixIcon: const Icon(Icons.lock),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10)),
                              floatingLabelStyle: TextStyle(
                                color: theme.primaryColor),
                            ),
                            onChanged: (v) => _password = v,
                            obscureText: true,
                            validator: (v) =>
                                v!.length >= 6 ? null : '6+ chars required',
                          ),
                          const SizedBox(height: 20),
                          InputDecorator(
                            decoration: InputDecoration(
                              labelText: 'I am a',
                              prefixIcon: const Icon(Icons.work),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10)),
                              floatingLabelStyle: TextStyle(
                                color: theme.primaryColor),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _role,
                                isDense: true,
                                isExpanded: true,
                                items: ['Freelancer', 'Client']
                                    .map((r) => DropdownMenuItem(
                                          value: r,
                                          child: Text(r,
                                              style: theme.textTheme.bodyLarge),
                                        ))
                                    .toList(),
                                onChanged: (v) => setState(() => _role = v!),
                              ),
                            ),
                          ),
                          const SizedBox(height: 30),
                          Material(
                            borderRadius: BorderRadius.circular(10),
                            elevation: 4,
                            child: InkWell(
                              onTap: _submit,
                              borderRadius: BorderRadius.circular(10),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                height: 50,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  gradient: LinearGradient(
                                    colors: [
                                      theme.primaryColor,
                                      Colors.purple.shade400,
                                    ],
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    'Sign Up as $_role',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          TextButton(
                            onPressed: () => Navigator.pushReplacementNamed(
                                context, '/login'),
                              child: const Text('Already have an account? Log in'),
                            ),
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}