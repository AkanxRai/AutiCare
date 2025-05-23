import 'package:auticare/pages/profile_page.dart';
import 'package:flutter/material.dart';
import 'package:auticare/pages/chat_screen.dart';
import 'package:auticare/pages/Fmri_pred.dart'; // Add this import

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  // List of pages for navigation
  final List<Widget> _pages = [
    const ChatScreen(),
    const FMRIPredictionPage(), // Add fMRI Prediction page
    const ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        centerTitle: true,
        title: Text(
          "AutiCare Connect",
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(fontSize: 22, color: Colors.white),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.science), // Use a science icon for fMRI
            label: 'fMRI Pred',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        onTap: (index) {
          setState(() {
            _currentIndex = index; // Update the current index
          });
        },
      ),
      body: _pages[_currentIndex], // Display the selected page
    );
  }
}
