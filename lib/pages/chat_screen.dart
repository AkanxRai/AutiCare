import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:chat_bubbles/chat_bubbles.dart';
import 'package:lottie/lottie.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
  String? displayName;

  @override
  void initState() {
    super.initState();

    // Get the current user's UUID and update it in the controller
    final user = FirebaseAuth.instance.currentUser;
    chatMessageController.updateUserUuid(user?.uid ?? "guest");

    // Listen for changes in the user's UUID
    FirebaseAuth.instance.authStateChanges().listen((user) {
      chatMessageController.updateUserUuid(user?.uid ?? "guest");
    });

    // Scroll to the bottom when new messages are added
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
    final user = FirebaseAuth.instance.currentUser;
    displayName = user?.displayName ?? "User";

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Expanded(
            child: Obx(
              () {
                if (chatMessageController.messages.isEmpty) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Lottie.asset(
                        'assets/lottie/chat_screen_bot.json',
                        width: 200,
                        height: 200,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "Hi, $displayName!",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  );
                } else {
                  return ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 100.0),
                    itemCount: chatMessageController.messages.length,
                    itemBuilder: (context, index) {
                      final message = chatMessageController.messages[index];
                      final isUser = message['isUser'];
                      final time = message['time'];
                      final text = message['text'] ?? "";

                      return Align(
                        alignment: isUser
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Column(
                          crossAxisAlignment: isUser
                              ? CrossAxisAlignment.end
                              : CrossAxisAlignment.start,
                          children: [
                            Container(
                              margin: const EdgeInsets.only(bottom: 6),
                              child: BubbleSpecialTwo(
                                isSender: isUser,
                                color: isUser
                                    ? Colors.blue
                                    : const Color(0XFFE5E5E5),
                                text: text,
                                tail: true,
                                textStyle: TextStyle(
                                  fontSize: 14.0,
                                  color: isUser ? Colors.white : Colors.black87,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(
                                  right: 10, left: 20, top: 2, bottom: 10),
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
          Obx(
            () {
              if (chatMessageController.isTyping.value) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    children: [
                      const SizedBox(width: 10),
                      const Text(
                        "AutiCare is typing...",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Lottie.asset(
                        'assets/lottie/typing.json', // Replace with your typing animation asset
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
          Obx(
            () {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15.0),
                child: Row(
                  children: [
                    if (chatMessageController.isQuestionProvider.value)
                      ElevatedButton(
                        onPressed: chatMessageController.isTyping.value
                            ? null
                            : () {
                                chatMessageController.sendMessage("Yes");
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text("Yes"),
                      ),
                    if (chatMessageController.isQuestionProvider.value)
                      const SizedBox(width: 8),
                    if (chatMessageController.isQuestionProvider.value)
                      ElevatedButton(
                        onPressed: chatMessageController.isTyping.value
                            ? null
                            : () {
                                chatMessageController.sendMessage("No");
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text("No"),
                      ),
                    if (chatMessageController.isQuestionProvider.value &&
                        chatMessageController.canBeNotApplicableProvider.value)
                      const SizedBox(width: 8),
                    if (chatMessageController.isQuestionProvider.value &&
                        chatMessageController.canBeNotApplicableProvider.value)
                      ElevatedButton(
                        onPressed: chatMessageController.isTyping.value
                            ? null
                            : () {
                                chatMessageController
                                    .sendMessage("Not Applicable");
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text("Not Applicable"),
                      ),
                    const SizedBox(width: 5),
                    Flexible(
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: IconButton(
                          onPressed: chatMessageController.isTyping.value
                              ? null
                              : () {
                                  chatMessageController.restartChat();
                                },
                          icon: const Icon(Icons.restart_alt),
                          color: Colors.blue,
                          tooltip: "Restart",
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Obx(
              () => Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: messageController,
                      enabled: !chatMessageController.isTyping.value,
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
                    onPressed: chatMessageController.isTyping.value
                        ? null
                        : () {
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
          ),
        ],
      ),
    );
  }
}
