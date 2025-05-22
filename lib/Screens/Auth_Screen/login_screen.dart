// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:job_board_freelance_marketplace/Services/auth_service.dart';
// import 'package:job_board_freelance_marketplace/Services/theme_notifier.dart';
// import 'package:provider/provider.dart';

// class LoginScreen extends StatefulWidget {
//   const LoginScreen({super.key});

//   @override
//   State<LoginScreen> createState() => _LoginScreenState();
// }

// class _LoginScreenState extends State<LoginScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final _authService = AuthService();
//   String _email = '', _password = '';
//   bool _loading = false;

//   Future<void> _submit() async {
//     if (!_formKey.currentState!.validate()) return;
//     setState(() => _loading = true);

//     try {
//       // 1️⃣ Sign in
//       final cred = await _authService.signIn(_email, _password);
//       final uid = cred.user!.uid;

//       // 2️⃣ Fetch the user's role from Firestore
//       final doc =
//           await FirebaseFirestore.instance.collection('users').doc(uid).get();

//       if (!doc.exists || doc.data()!['role'] == null) {
//         throw FirebaseAuthException(
//           code: 'no-role',
//           message: 'User role not found. Please complete your profile.',
//         );
//       }

//       final role = doc.data()!['role'] as String;

//       // 3️⃣ Navigate based on role
//       final route =
//           (role == 'Client') ? '/client-dashboard' : '/freelancer-dashboard';

//       Navigator.pushReplacementNamed(context, route);
//     } on FirebaseAuthException catch (e) {
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(SnackBar(content: Text(e.message ?? 'Login failed')));
//     } catch (e) {
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
//     } finally {
//       setState(() => _loading = false);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final themeToggle = Provider.of<ThemeNotifier>(context);
//     return Scaffold(
//       appBar: AppBar(
//         automaticallyImplyLeading: false,
//         title: const Text('Login'),
//         actions: [
//           IconButton(
//             icon: Icon(
//               themeToggle.mode == ThemeMode.light
//                   ? Icons.dark_mode
//                   : Icons.light_mode,
//             ),
//             onPressed: () => themeToggle.toggleTheme(),
//           ),
//         ],
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.start,
//           children: [
//             const Icon(Icons.login_sharp, size: 200),
//             Form(
//               key: _formKey,
//               child: Column(
//                 children: [
//                   // — Email —
//                   TextFormField(
//                     decoration: const InputDecoration(labelText: 'Email'),
//                     onChanged: (v) => _email = v.trim(),
//                     validator:
//                         (v) =>
//                             v != null && v.contains('@')
//                                 ? null
//                                 : 'Enter a valid email',
//                   ),

//                   // — Password —
//                   TextFormField(
//                     decoration: const InputDecoration(labelText: 'Password'),
//                     onChanged: (v) => _password = v,
//                     obscureText: true,
//                     validator:
//                         (v) =>
//                             v != null && v.length >= 6
//                                 ? null
//                                 : '6+ chars required',
//                   ),

//                   const SizedBox(height: 20),

//                   // — Submit —
//                   _loading
//                       ? const CircularProgressIndicator()
//                       : ElevatedButton(
//                         onPressed: _submit,
//                         child: const Text('Log In'),
//                       ),

//                   TextButton(
//                     onPressed:
//                         () =>
//                             Navigator.pushReplacementNamed(context, '/signup'),
//                     child: const Text("Don't have an account? Sign Up"),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:job_board_freelance_marketplace/Services/auth_service.dart';
import 'package:job_board_freelance_marketplace/Services/theme_notifier.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen>
    with SingleTickerProviderStateMixin {
    final _formKey = GlobalKey<FormState>();
    final _authService = AuthService();
    String _email = '', _password = '';
    bool _loading = false;

    Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (!mounted) return;
    setState(() => _loading = true);

    try {
      final cred = await _authService.signIn(_email, _password);
      final uid = cred.user!.uid;

      final doc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();

      if (!doc.exists || doc.data()!['role'] == null) {
        throw FirebaseAuthException(
          code: 'no-role',
          message: 'User role not found. Please complete your profile.',
        );
      }

      final role = doc.data()!['role'] as String;
      final route =
          (role == 'Client') ? '/client-dashboard' : '/freelancer-dashboard';

      if (!mounted) return;
      Navigator.pushReplacementNamed(context, route);
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.message ?? 'Login failed')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
      }
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }


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
      CurvedAnimation(parent: _controller, curve: Curves.fastOutSlowIn),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context,) {
       final theme = Theme.of(context);
    final themeNotifier = ref.watch(themeNotifierProvider);
    final isDark = themeNotifier.mode == ThemeMode.dark;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Login'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.blue.shade50,
        actions: [
          IconButton(
            icon: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: Icon(
                isDark ? Icons.light_mode : Icons.dark_mode,
                key: ValueKey(isDark),
              ),
            ),
            onPressed: () {
              themeNotifier.toggleTheme();
            },
          ),
        ],
      ),
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Container(
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors:
                    isDark
                        ? [Colors.deepPurple.shade900, Colors.indigo.shade900]
                        : [Colors.blue.shade50, Colors.purple.shade50],
              ),
            ),
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: FadeTransition(
                opacity: _opacityAnimation,
                child: Padding(
                  padding: const EdgeInsets.only(
                    top: 30,
                    bottom: 24,
                    left: 24,
                    right: 24,
                  ),
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
                                  // isDark
                                  //     ? 'assets/images/loginN.png'
                                  //     : 'assets/images/loginD.png',
                                  "assets/images/L.png"
                                ),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),
                        _buildLoginForm(theme),
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

  Widget _buildLoginForm(ThemeData theme) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child:
                    _loading
                        ? Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation(
                              theme.primaryColor,
                            ),
                          ),
                        )
                        : Column(
                          children: [
                            TextFormField(
                              decoration: InputDecoration(
                                labelText: 'Email',
                                prefixIcon: const Icon(Icons.email),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                floatingLabelStyle: TextStyle(
                                  color: theme.primaryColor,
                                ),
                              ),
                              onChanged: (v) => _email = v.trim(),
                              validator:
                                  (v) =>
                                      v != null && v.contains('@')
                                          ? null
                                          : 'Enter a valid email',
                            ),
                            const SizedBox(height: 20),
                            TextFormField(
                              decoration: InputDecoration(
                                labelText: 'Password',
                                prefixIcon: const Icon(Icons.lock),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                floatingLabelStyle: TextStyle(
                                  color: theme.primaryColor,
                                ),
                              ),
                              onChanged: (v) => _password = v,
                              obscureText: true,
                              validator:
                                  (v) =>
                                      v != null && v.length >= 6
                                          ? null
                                          : '6+ chars required',
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
                                  child: const Center(
                                    child: Text(
                                      'Log In',
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
                            const SizedBox(height: 20),
                            TextButton(
                              onPressed:
                                  () => Navigator.pushReplacementNamed(
                                    context,
                                    '/signup',
                                  ),
                              child: const Text(
                                "Don't have an account? Sign Up",
                              ),
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
