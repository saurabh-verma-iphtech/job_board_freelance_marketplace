// lib/screens/freelancer_dashboard.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:job_board_freelance_marketplace/Screens/Auth_Screen/login_screen.dart';
import 'package:job_board_freelance_marketplace/Screens/Job/contract_list_screen.dart';

class FreelancerDashboard extends StatefulWidget {
  const FreelancerDashboard({Key? key}) : super(key: key);

  @override
  State<FreelancerDashboard> createState() => _FreelancerDashboardState();
}

class _FreelancerDashboardState extends State<FreelancerDashboard> {
    String? role;
  @override
  void initState() {
    super.initState();
    FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get()
        .then((doc) {
                final data = doc.data();
          if (doc.data()?['profileCompleted'] != true) {
            Navigator.pushReplacementNamed(context, '/freelancer-profile');
          }
          else {
            setState(() {
              role = data!['role']; // Store the role
            });
          }
        });
  }
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // leading: 
        actions: [
      IconButton(
        icon: const Icon(Icons.folder_shared),
        tooltip: 'My Contracts',
        onPressed: () {
           Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ContractsListScreen(role: role.toString()),
                ),
              );
        },
      ),
      
  
          IconButton(
            onPressed:
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => LoginScreen()),
                ),
            icon: Icon(Icons.logout),
          ),
        ],
        title: const Text('Freelancer Dashboard')
        ),
      body: const Center(
        child: Text('Welcome, Freelancer!', style: TextStyle(fontSize: 24)),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.search),
        onPressed: () => Navigator.pushNamed(context, '/job-feed'),
      ),
    );
  }
}
