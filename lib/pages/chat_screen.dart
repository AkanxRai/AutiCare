import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:chat_bubbles/chat_bubbles.dart';
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
              () => ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(16.0),
                itemCount: chatMessageController.messages.length,
                itemBuilder: (context, index) {
                  final message = chatMessageController.messages[index];
                  final isUser = message['isUser'];
                  final time = message['time'];

                  return Align(
                    alignment:
                        isUser ? Alignment.centerRight : Alignment.centerLeft,
                    child: Column(
                      crossAxisAlignment: isUser
                          ? CrossAxisAlignment.end
                          : CrossAxisAlignment.start,
                      children: [
                        BubbleSpecialTwo(
                          isSender: isUser,
                          color: isUser ? Colors.blue : const Color(0XFFE5E5E5),
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
              ),
            ),
          ),
          Obx(
            () => chatMessageController.isTypeing.value
                ? const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      children: [
                        SizedBox(
                          height: 30,
                          width: 40,
                          child: Row(
                            children: [
                              CircleAvatar(
                                  radius: 3, backgroundColor: Colors.grey),
                              SizedBox(width: 4),
                              CircleAvatar(
                                  radius: 3, backgroundColor: Colors.grey),
                              SizedBox(width: 4),
                              CircleAvatar(
                                  radius: 3, backgroundColor: Colors.grey),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )
                : const SizedBox.shrink(),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
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
