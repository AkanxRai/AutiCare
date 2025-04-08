import 'dart:convert';
import 'package:auticare/constant/api_constant.dart';
import 'package:http/http.dart' as http;


class GoogleApiService {
  static String apiKey = ApiConstant.apiKey;
  static String baseUrl = ApiConstant.baseUrl;

  static Future<String> getApiResponse(String message) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl$apiKey"),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "contents": [
            {
              "parts": [
                {"text": message}
              ]
            }
          ]
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data.containsKey("candidates") &&
            data["candidates"].isNotEmpty &&
            data["candidates"][0]["content"]["parts"].isNotEmpty) {
          return data["candidates"][0]["content"]["parts"][0]["text"] ??
              "AI response was empty.";
        }
        return "AI did not return any content.";
      } else {
        return "Error: ${response.statusCode} - ${response.body}";
      }
    } catch (e) {
      return "Error: $e";
    }
  }
}
