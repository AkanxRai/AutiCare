import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'package:auticare/services/api_services.dart';

class MessageController extends GetxController {
  var responseText = "".obs;
  var messages = <Map<String, dynamic>>[].obs;
  var isTyping = false.obs;

  Future<void> sendMessage(String message) async {
    messages.add({
      'text': message,
      'isUser': true,
      'time': DateFormat('hh:mm a').format(DateTime.now())
    });

    isTyping.value = true;
    update();

    try {
      Map<String, dynamic> reply =
          await GoogleApiService.getApiResponse(message);

      // Display "prediction" if present
      if (reply.containsKey("prediction")) {
        messages.add({
          'text': "Prediction: ${reply["prediction"]}",
          'isUser': false,
          'time': DateFormat('hh:mm a').format(DateTime.now())
        });
      }

      // Session expired handling
      if (reply.containsKey("message") &&
          reply["message"]
              .toString()
              .toLowerCase()
              .contains("session has expired")) {
        messages.add({
          'text': reply["message"],
          'isUser': false,
          'time': DateFormat('hh:mm a').format(DateTime.now())
        });
        isTyping.value = false;
        update();
        return;
      }

      // Display "message" and "question"
      if (reply.containsKey("message")) {
        messages.add({
          'text': reply["message"],
          'isUser': false,
          'time': DateFormat('hh:mm a').format(DateTime.now())
        });
      }

      if (reply.containsKey("question")) {
        messages.add({
          'text': reply["question"],
          'isUser': false,
          'time': DateFormat('hh:mm a').format(DateTime.now())
        });
      }

      // Handle special formatting keys
      if (reply.containsKey("next_steps") && reply["next_steps"] is List) {
        String steps =
            (reply["next_steps"] as List).map((step) => "• $step").join("\n");
        messages.add({
          'text': "📝 Next Steps:\n$steps",
          'isUser': false,
          'time': DateFormat('hh:mm a').format(DateTime.now())
        });
      }

      if (reply.containsKey("local_resources")) {
        messages.add({
          'text':
              "📍 Local Resources:\n${reply["local_resources"] ?? 'Not available'}",
          'isUser': false,
          'time': DateFormat('hh:mm a').format(DateTime.now())
        });
      }

      if (reply.containsKey("self_help_strategies")) {
        messages.add({
          'text':
              "💡 Self-Help Strategies:\n${reply["self_help_strategies"] ?? 'Not available'}",
          'isUser': false,
          'time': DateFormat('hh:mm a').format(DateTime.now())
        });
      }

      // Fallback for other keys
      reply.forEach((key, value) {
        if ([
          "message",
          "question",
          "prediction",
          "doctors",
          "doctor_info",
          "next_steps",
          "local_resources",
          "self_help_strategies"
        ].contains(key)) return;

        messages.add({
          'text': "$value",
          'isUser': false,
          'time': DateFormat('hh:mm a').format(DateTime.now())
        });
      });

      // Handle doctor_info
      if (reply.containsKey("doctor_info") &&
          reply["doctor_info"] is Map &&
          reply["doctor_info"]["doctors"] is List) {
        for (var doctor in reply["doctor_info"]["doctors"]) {
          if (doctor is Map) {
            messages.add({
              'text':
                  "👨‍⚕️ ${doctor['serial_number'] ?? 'N/A'}. Doctor Info:\n"
                      "• Name: ${doctor['name'] ?? 'N/A'}\n"
                      "• Specialization: ${doctor['specialization'] ?? 'N/A'}\n"
                      "• Hospital: ${doctor['hospital'] ?? 'N/A'}\n"
                      "• Contact: ${doctor['contact'] ?? 'N/A'}",
              'isUser': false,
              'time': DateFormat('hh:mm a').format(DateTime.now())
            });
          }
        }
      }
    } catch (e) {
      messages.add({
        'text': "An error occurred: ${e.toString()}",
        'isUser': false,
        'time': DateFormat('hh:mm a').format(DateTime.now())
      });
    }

    isTyping.value = false;
    update();
  }

  void clearMessages() {
    messages.clear();
    update();
  }

  void restartChat() {
    clearMessages();
    sendMessage("Restart");
  }
}
