import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:auticare/services/api_services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MessageController extends GetxController {
  var responseText = "".obs;
  var messages = <Map<String, dynamic>>[].obs;
  var isTyping = false.obs;

  // Boolean state providers
  var isQuestionProvider = false.obs;
  var canBeNotApplicableProvider = false.obs;

  // Observable for tracking the user's UUID
  var userUuid = "".obs;

  // Counter for questions
  var questionCounter = 0.obs;

  // Method to update the UUID and clear the chat if it changes
  void updateUserUuid(String newUuid) {
    if (userUuid.value != newUuid) {
      userUuid.value = newUuid;
      clearMessages(); // Clear chat messages for the new user
      questionCounter.value = 0; // Reset the question counter for the new user
    }
  }

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

      // Check if prediction exists and store it only once
      if (reply.containsKey("prediction")) {
        final prediction = reply["prediction"];

        // Add prediction to messages
        messages.add({
          'text': "Prediction: $prediction",
          'isUser': false,
          'time': DateFormat('hh:mm a').format(DateTime.now())
        });

        // Save prediction to Firebase only once
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          final predictionsCollection = FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .collection('predictions');

          // Check if the prediction already exists
          final existingPrediction = await predictionsCollection
              .where('prediction', isEqualTo: prediction)
              .limit(1)
              .get();

          if (existingPrediction.docs.isEmpty) {
            await predictionsCollection.add({
              'prediction': prediction,
              'timestamp': FieldValue.serverTimestamp(),
            });
          }
        }
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
        // Increment the counter first
        questionCounter.value++;

        final question = reply["question"];
        messages.add({
          'text': question,
          'isUser': false,
          'time': DateFormat('hh:mm a').format(DateTime.now())
        });

        isQuestionProvider.value = true;

        // Apply new logic
        const specificNumbers = [2, 6, 8, 14, 15, 18, 19, 20];
        canBeNotApplicableProvider.value =
            specificNumbers.contains(questionCounter.value);
      } else {
        // Reset providers if no question
        isQuestionProvider.value = false;
        canBeNotApplicableProvider.value = false;
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
    questionCounter.value = 0; // Reset back to 0
    sendMessage("Restart");
  }
}
