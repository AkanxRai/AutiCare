import 'package:auticare/pages/sign_in_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  User? user;
  bool isLoading = true; // Track loading state

  @override
  void initState() {
    super.initState();
    user = FirebaseAuth.instance.currentUser;
    _assignRandomAvatarIfNeeded();
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

          // Profile Details Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Account Details",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Icon(Icons.person, color: Colors.blue),
                    const SizedBox(width: 10),
                    Text(
                      user?.displayName ?? "Not Set",
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Icon(Icons.email, color: Colors.blue),
                    const SizedBox(width: 10),
                    Text(
                      user?.email ?? "Not Set",
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
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
