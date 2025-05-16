import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:job_board_freelance_marketplace/Screens/Dashboard/Client/client_dashboard.dart';
import 'package:job_board_freelance_marketplace/Screens/Dashboard/Client/client_profile.dart';
import 'package:job_board_freelance_marketplace/Screens/Dashboard/Freelancer/freelancer_dashboard.dart';
import 'package:job_board_freelance_marketplace/Screens/Dashboard/Freelancer/freelancer_profile.dart';
import 'package:job_board_freelance_marketplace/Screens/Dashboard/Main%20Pages/job_feed_freelancer_screen.dart';
import 'package:job_board_freelance_marketplace/Screens/Dashboard/Main%20Pages/job_post_client_screen.dart';
import 'package:job_board_freelance_marketplace/Screens/Job/Client/client_job_detail.dart';
import 'package:job_board_freelance_marketplace/Screens/Job/Client/client_job_list.dart';
import 'package:job_board_freelance_marketplace/Screens/Job/Client/edit_job_client.dart';
import 'package:job_board_freelance_marketplace/Screens/Job/Client/list_proposal_screen.dart';
import 'package:job_board_freelance_marketplace/Screens/Job/Freelancer/job_detail_screen.dart';
import 'package:job_board_freelance_marketplace/Screens/Job/Freelancer/my_proposals.dart';
import 'package:job_board_freelance_marketplace/Screens/Job/Freelancer/submit_proposal_F.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:job_board_freelance_marketplace/Screens/Auth_Screen/login_screen.dart';
import 'package:job_board_freelance_marketplace/Screens/Auth_Screen/signup_screen.dart';
import 'package:job_board_freelance_marketplace/Services/theme_notifier.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show Supabase;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await Supabase.initialize(
    url: 'https://qpmddcybbzwioqzqxwfc.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InFwbWRkY3liYnp3aW9xenF4d2ZjIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDQxMTM1MzAsImV4cCI6MjA1OTY4OTUzMH0.bx6g7WEZMAtbH7hZGxPvYrLTgK5z1QU9Aa-19MDuHwk',
  );
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeNotifier = ref.watch(themeNotifierProvider);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.light, // ensure colorScheme brightness matches
        ),
        // no separate brightness here
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark, // explicitly dark
        ),
      ),
      themeMode: themeNotifier.mode,
      home: const AuthGate(), // 👈 Use a widget that checks auth state

      routes: {
        '/login': (_) => LoginScreen(),
        '/signup': (_) => SignupScreen(),
        '/freelancer-dashboard': (_) => const FreelancerDashboard(),
        '/client-dashboard': (_) => const ClientDashboard(),
        '/freelancer-profile': (_) => const FreelancerProfileScreen(),
        '/client-profile': (_) => const ClientProfileScreen(),
        '/job-feed': (_) => const JobFeedScreen(),
        '/post-job': (_) => const PostJobScreen(),
        '/job-detail': (_) => JobDetailScreen(jobId: ''),
        '/submit-proposal': (_) => const SubmitProposalScreen(),
        // '/contracts': (_) => const ContractsListScreen(),
        '/client-jobs': (_) => const ClientJobsScreen(),
        '/my-proposals': (_) =>  MyProposalsScreen(),
        '/client-proposals': (_) => ClientProposalsScreen(),
        '/edit-job':
            (ctx) => EditJobScreen(
              jobId: ModalRoute.of(ctx)!.settings.arguments as String,
            ),
        '/client-job-detail':
            (ctx) => ClientJobDetailScreen(
              jobId: ModalRoute.of(ctx)!.settings.arguments as String,
            ),
      },
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  Future<String?> getUserRole(String uid) async {
    final doc =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();
    return doc.data()?['role'] as String?;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasData) {
          final uid = snapshot.data!.uid;

          // 🔍 Fetch user role
          return FutureBuilder<String?>(
            future: getUserRole(uid),
            builder: (context, roleSnapshot) {
              if (roleSnapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }

              final role = roleSnapshot.data?.toLowerCase();

              if (role == 'client') {
                return const ClientDashboard();
              } else if (role == 'freelancer') {
                return const FreelancerDashboard();
              } else {
                return const Scaffold(
                  body: Center(child: Text('Unknown user role')),
                );
              }
            },
          );
        } else {
          return const LoginScreen();
        }
      },
    );
  }
}
