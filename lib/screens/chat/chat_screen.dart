import 'package:flutter/material.dart';
import 'package:oqdo_mobile_app/utils/colorsUtils.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: _buildChatMessages(),
            ),
            _buildBottomSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: ColorsUtils.chatPrimary,
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back, color: ColorsUtils.white),
            onPressed: () => Navigator.pop(context),
          ),
          CircleAvatar(
            radius: 20,
            backgroundColor: ColorsUtils.greyCircle,
            child: Icon(Icons.person, color: ColorsUtils.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Josh John',
                  style: TextStyle(
                    color: ColorsUtils.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'STAG CHAMP Table Tennis Kit',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Text(
            'S\$ 50',
            style: TextStyle(
              color: ColorsUtils.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatMessages() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildMessageBubble(
          message: "Hey",
          isSentByMe: true,
          time: "22/01 1:03",
        ),
        _buildMessageBubble(
          message: "Hello",
          isSentByMe: false,
          time: "22/01 1:04",
        ),
        _buildMessageBubble(
          message: "Let's catch up!",
          isSentByMe: true,
          time: "22/01 1:05",
        ),
      ],
    );
  }

  Widget _buildMessageBubble({
    required String message,
    required bool isSentByMe,
    required String time,
  }) {
    return Align(
      alignment: isSentByMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSentByMe
              ? ColorsUtils.chatPrimary
              : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                message,
                style: TextStyle(
                color: isSentByMe ? Colors.white : ColorsUtils.chipText,
                fontSize: 16,
              ),
              ),
              const SizedBox(height: 4),
              Text(
                time,
              style: TextStyle(
                color: isSentByMe ? Colors.white70 : ColorsUtils.greyText,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: ColorsUtils.chatPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'Offer Price',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: ColorsUtils.chatPrimary,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Ok, Done',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.more_vert),
                onPressed: () {},
              ),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(color: ColorsUtils.buddiesBorder),
                  ),
                  child: TextFormField(
                    controller: _messageController,
                    cursorColor: ColorsUtils.greyText,
                    style: TextStyle(
                        color:
                            Theme.of(context).colorScheme.onBackground),
                    decoration: InputDecoration(
                      hintText: 'Message',
                      hintStyle: TextStyle(color: ColorsUtils.greyText),
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.send),
                color: ColorsUtils.chatPrimary,
                onPressed: () {
                  if (_messageController.text.isNotEmpty) {
                    // Handle send message
                    _messageController.clear();
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }
} 