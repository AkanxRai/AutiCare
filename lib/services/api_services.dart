import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:auticare/constant/api_constant.dart';

class GoogleApiService {
  static Future<Map<String, dynamic>> getApiResponse(String userMessage) async {
    try {
      final url = Uri.parse("${ApiConstant.baseUrl}${ApiConstant.apiKey}");
      print("URL: $url");
      print("User Message: $userMessage");

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({"user_input": userMessage.trim()}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data; // Return the entire response as a Map
      } else {
        return {"error": "HTTP ${response.statusCode} - ${response.body}"};
      }
    } catch (e) {
      return {"error": "Exception: $e"};
    }
  }
}
