import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:chat_bubbles/chat_bubbles.dart';
import 'package:lottie/lottie.dart'; // Import the Lottie package
import '../controllers/message_controller.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final MessageController chatMessageController = Get.put(MessageController());
  final TextEditingController messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    chatMessageController.messages.listen((_) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Expanded(
            child: Obx(
              () {
                if (chatMessageController.messages.isEmpty) {
                  // Display Lottie animation when no messages are present
                  return Center(
                    child: Lottie.asset(
                      'assets/lottie/chat_screen_bot.json',
                      width: 200,
                      height: 200,
                      fit: BoxFit.contain,
                    ),
                  );
                } else {
                  // Display chat messages
                  return ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16.0),
                    itemCount: chatMessageController.messages.length,
                    itemBuilder: (context, index) {
                      final message = chatMessageController.messages[index];
                      final isUser = message['isUser'];
                      final time = message['time'];

                      return Align(
                        alignment: isUser
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Column(
                          crossAxisAlignment: isUser
                              ? CrossAxisAlignment.end
                              : CrossAxisAlignment.start,
                          children: [
                            BubbleSpecialTwo(
                              isSender: isUser,
                              color: isUser
                                  ? Colors.blue
                                  : const Color(0XFFE5E5E5),
                              text: message['text'],
                              tail: true,
                              textStyle: const TextStyle(
                                fontSize: 14.0,
                                color: Colors.black,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(
                                  right: 10, left: 20, top: 4, bottom: 10),
                              child: Text(
                                time,
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: Color(0XFF808080),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ),
          // Typing indicator
          Obx(
            () {
              if (chatMessageController.isTypeing.value) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    children: [
                      const SizedBox(width: 10),
                      const Text(
                        "AutiCare is typing",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Lottie.asset(
                        'assets/lottie/typing.json', // Replace with your typing indicator animation
                        width: 50,
                        height: 50,
                      ),
                    ],
                  ),
                );
              } else {
                return const SizedBox.shrink();
              }
            },
          ),
          // Buttons for "Yes," "No," and "Not Applicable"
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    chatMessageController.sendMessage("Yes");
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text("Yes"),
                ),
                ElevatedButton(
                  onPressed: () {
                    chatMessageController.sendMessage("No");
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text("No"),
                ),
                ElevatedButton(
                  onPressed: () {
                    chatMessageController.sendMessage("Not Applicable");
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text("Not Applicable"),
                ),
              ],
            ),
          ),
          // Text field for manual input
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: messageController,
                    decoration: InputDecoration(
                      hintText: "Type a message...",
                      hintStyle: const TextStyle(color: Colors.grey),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Colors.grey),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide:
                            const BorderSide(color: Colors.green, width: 2),
                      ),
                    ),
                    style: const TextStyle(color: Colors.black),
                  ),
                ),
                const SizedBox(width: 10),
                FloatingActionButton(
                  heroTag: "send_button",
                  onPressed: () {
                    if (messageController.text.isNotEmpty) {
                      chatMessageController
                          .sendMessage(messageController.text.trim());
                      messageController.clear();
                    }
                  },
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  child: const Icon(Icons.send),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
