import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:auticare/constant/api_constant.dart';

class GoogleApiService {
  static Future<String> getApiResponse(String userMessage) async {
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

        if (data.containsKey("message")) {
          return data["message"];
        } else if (data.containsKey("question")) {
          return data["question"];
        } else if (data.containsKey("error")) {
          return "API Error: ${data["error"]}";
        } else {
          return "Unexpected response format: $data";
        }
      } else {
        return "HTTP ${response.statusCode} - ${response.body}";
      }
    } catch (e) {
      return "Exception: $e";
    }
  }
}
