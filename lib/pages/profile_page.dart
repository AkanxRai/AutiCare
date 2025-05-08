import 'package:auticare/pages/sign_in_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  User? user;
  bool isLoading = true; // Track loading state
  List<Map<String, dynamic>> predictions = []; // Store predictions

  @override
  void initState() {
    super.initState();
    user = FirebaseAuth.instance.currentUser;
    _assignRandomAvatarIfNeeded();
    _fetchPredictions();
  }

  Future<void> _assignRandomAvatarIfNeeded() async {
    if (user != null && user!.photoURL == null) {
      // Generate a random avatar URL using the updated DiceBear API with PNG format
      final randomAvatarUrl =
          "https://api.dicebear.com/9.x/avataaars/png?seed=${user!.displayName ?? user!.uid}";

      try {
        // Update the user's photoURL in Firebase
        await user!.updatePhotoURL(randomAvatarUrl);
        await user!.reload(); // Reload the user to reflect changes
        setState(() {
          user = FirebaseAuth.instance.currentUser; // Refresh the user object
          isLoading = false; // Stop loading
        });
      } catch (e) {
        debugPrint("Error assigning random avatar: $e");
        setState(() {
          isLoading = false; // Stop loading even if there's an error
        });
      }
    } else {
      setState(() {
        isLoading = false; // Stop loading if photoURL already exists
      });
    }
  }

  Future<void> _fetchPredictions() async {
    if (user != null) {
      try {
        final snapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(user!.uid)
            .collection('predictions')
            .orderBy('timestamp', descending: true)
            .get();

        setState(() {
          predictions = snapshot.docs
              .map((doc) => {
                    'prediction': doc['prediction'],
                    'timestamp': doc['timestamp']?.toDate(),
                  })
              .toList();
        });
      } catch (e) {
        debugPrint("Error fetching predictions: $e");
      }
    }
  }

  void _logout(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut(); // Sign out from Firebase
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const SignInPage()),
        ); // Navigate to login page
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error logging out: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Profile",
          style: TextStyle(fontSize: 22, color: Colors.white),
        ),
        backgroundColor: Colors.blue,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Profile Header Section
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 20),
            decoration: const BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 50,
                  child: isLoading
                      ? const Center(
                          child:
                              CircularProgressIndicator(), // Show loading indicator
                        )
                      : ClipOval(
                          child: user?.photoURL != null
                              ? Image.network(
                                  user!.photoURL!,
                                  fit: BoxFit.cover,
                                  width: 100,
                                  height: 100,
                                  errorBuilder: (context, error, stackTrace) {
                                    debugPrint("Error loading image: $error");
                                    return const Icon(
                                      Icons.person,
                                      size: 50,
                                      color: Colors.white,
                                    );
                                  },
                                )
                              : const Icon(
                                  Icons.person,
                                  size: 50,
                                  color: Colors.white,
                                ),
                        ),
                ),
                const SizedBox(height: 10),
                Text(
                  user?.displayName ?? "User Name",
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  user?.email ?? "user@example.com",
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Predictions Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Predictions",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 10),
                predictions.isEmpty
                    ? const Text(
                        "No predictions available.",
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: predictions.length,
                        itemBuilder: (context, index) {
                          final prediction = predictions[index];
                          return ListTile(
                            leading:
                                const Icon(Icons.analytics, color: Colors.blue),
                            title: Text(
                              prediction['prediction'] ?? "Unknown",
                              style: const TextStyle(fontSize: 16),
                            ),
                            subtitle: Text(
                              prediction['timestamp'] != null
                                  ? DateFormat('yyyy-MM-dd HH:mm:ss')
                                      .format(prediction['timestamp'])
                                  : "Unknown time",
                              style: const TextStyle(
                                  fontSize: 14, color: Colors.grey),
                            ),
                          );
                        },
                      ),
              ],
            ),
          ),
          const Spacer(),

          // Logout Button
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () => _logout(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text("Logout"),
            ),
          ),
        ],
      ),
    );
  }
}
