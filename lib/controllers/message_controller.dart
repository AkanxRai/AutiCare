import 'package:auticare/services/api_services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class MessageController extends GetxController {
  var responseText = "".obs;
  var messages = <Map<String, dynamic>>[].obs;
  var isTypeing = false.obs;

  Future<void> sendMessage(String message) async {
    messages.add({
      'text': message,
      'isUser': true,
      'time': DateFormat('hh:mm a').format(DateTime.now())
    });

    isTypeing.value = true;
    update();

    String reply = await GoogleApiService.getApiResponse(message);

    messages.add({
      'text': reply,
      'isUser': false,
      'time': DateFormat('hh:mm a').format(DateTime.now())
    });

    isTypeing.value = false;
    update();
  }

  // Clear chat messages
  void clearMessages() {
    messages.clear();
    update();
  }

  // Restart chat explicitly
  void restartChat() {
    clearMessages();
    sendMessage("Restart"); // Send "Restart" to the bot
  }
}
