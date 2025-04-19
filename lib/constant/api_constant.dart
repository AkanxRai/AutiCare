import 'package:firebase_auth/firebase_auth.dart';

class ApiConstant {
  static String get apiKey {
    final user = FirebaseAuth.instance.currentUser;
    return "session_id=${user?.uid ?? "guest"}"; // Use UID or "guest" if not logged in
  }

  static const String baseUrl = "https://nipunkl-auticare.hf.space/chat/?";
}

