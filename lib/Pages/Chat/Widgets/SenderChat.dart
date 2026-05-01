// File: Pages/Chat/Widgets/SenderChat.dart

import 'package:chatting/Config/images.dart';
import 'package:chatting/Controller/ChatController.dart';
import 'package:chatting/Controller/ProfileController.dart';
import 'package:chatting/Pages/Chat/Widgets/MessagesStatus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class SenderChat extends StatelessWidget {
  final String? sms;
  final bool isComing;
  final MessageStatus status;
  final String? imageUrl;
  final DateTime? timestamp;
  final int index;
  final String messageId;
  final String senderId;

  const SenderChat({
    super.key,
    this.sms,
    required this.isComing,
    required this.status,
    this.imageUrl,
    this.timestamp,
    required this.index,
    required this.messageId,
    required this.senderId,
  });

  @override
  Widget build(BuildContext context) {
    if ((sms == null || sms!.isEmpty) && (imageUrl == null || imageUrl!.isEmpty)) {
      return const SizedBox.shrink();
    }

    final chatController = Get.find<ChatController>();
    final isVoid = senderId == "VOID";
    final isMe = senderId == Get.find<ProfileController>().currentUser.value.id;

    final bubbleColor = isVoid
        ? Colors.black87
        : (isMe ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.primaryContainer);

    final textColor = isVoid
        ? Theme.of(context).colorScheme.primary
        : (isMe ? Colors.black87 : Colors.white);

    return Obx(() {
      bool isSelected = chatController.selectedMessageIds.contains(messageId);

      return GestureDetector(
        onLongPress: () {
          HapticFeedback.mediumImpact();
          chatController.toggleMessageSelection(messageId);
        },
        onTap: () {
          // If we are currently in selection mode, tapping selects more messages instead of doing nothing
          if (chatController.selectedMessageIds.isNotEmpty) {
            chatController.toggleMessageSelection(messageId);
          }
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(vertical: 4),
          color: isSelected ? Theme.of(context).colorScheme.secondary.withOpacity(0.2) : Colors.transparent,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              mainAxisAlignment: isVoid ? MainAxisAlignment.center : (isMe ? MainAxisAlignment.end : MainAxisAlignment.start),
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (isMe && !isVoid) const Spacer(),

                Flexible(
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        constraints: BoxConstraints(maxWidth: MediaQuery.sizeOf(context).width * (isVoid ? 0.9 : 0.75)),
                        decoration: BoxDecoration(
                          color: bubbleColor,
                          border: isVoid ? Border.all(color: Theme.of(context).colorScheme.primary.withOpacity(0.5), width: 1) : null,
                          boxShadow: [
                            BoxShadow(
                              color: isVoid ? Theme.of(context).colorScheme.primary.withOpacity(0.2) : Colors.black.withOpacity(0.1),
                              blurRadius: isVoid ? 10 : 5,
                              offset: const Offset(0, 2),
                            )
                          ],
                          borderRadius: BorderRadius.only(
                            topLeft: const Radius.circular(18),
                            topRight: const Radius.circular(18),
                            bottomLeft: isVoid ? const Radius.circular(18) : (isMe ? const Radius.circular(18) : const Radius.circular(4)),
                            bottomRight: isVoid ? const Radius.circular(18) : (isMe ? const Radius.circular(4) : const Radius.circular(18)),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 14.0),
                          child: Column(
                            crossAxisAlignment: isVoid ? CrossAxisAlignment.center : (isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start),
                            children: [
                              if (isVoid)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 6.0),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.smart_toy, size: 14, color: Theme.of(context).colorScheme.primary),
                                      const SizedBox(width: 4),
                                      Text(
                                        "V.O.I.D. SYSTEM",
                                        style: TextStyle(color: Theme.of(context).colorScheme.primary, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.2),
                                      )
                                    ],
                                  ),
                                ),

                              if (imageUrl != null && imageUrl!.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 8.0),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.network(imageUrl!, fit: BoxFit.cover),
                                  ),
                                ),

                              if (sms != null && sms!.isNotEmpty)
                                Text(
                                  sms!,
                                  textAlign: isVoid ? TextAlign.center : TextAlign.start,
                                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    color: textColor,
                                  ),
                                ),

                              const SizedBox(height: 4),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  if (timestamp != null)
                                    Text(
                                      DateFormat('hh:mm a').format(timestamp!),
                                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                        color: isMe ? Colors.black54 : Colors.white60,
                                        fontSize: 10,
                                      ),
                                    ),
                                  if (isMe) ...[
                                    const SizedBox(width: 4),
                                    SvgPicture.asset(
                                      status == MessageStatus.read
                                          ? AssetsImage.doubleBlueTickSVG
                                          : status == MessageStatus.delivered
                                          ? AssetsImage.doubleTickSVG
                                          : status == MessageStatus.sent
                                          ? AssetsImage.singleTickSVG
                                          : AssetsImage.errorSVG,
                                      height: 12,
                                      width: 12,
                                      colorFilter: status != MessageStatus.read
                                          ? const ColorFilter.mode(Colors.black54, BlendMode.srcIn)
                                          : null,
                                    ),
                                  ]
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Highlight Checkmark overlay when selected
                      if (isSelected)
                        Positioned(
                          left: isMe ? -10 : null,
                          right: !isMe ? -10 : null,
                          top: 0,
                          bottom: 0,
                          child: Center(
                            child: Container(
                              decoration: const BoxDecoration(
                                color: Colors.blueAccent,
                                shape: BoxShape.circle,
                              ),
                              padding: const EdgeInsets.all(4),
                              child: const Icon(Icons.check, color: Colors.white, size: 16),
                            ),
                          ),
                        )
                    ],
                  ),
                ),

                if (!isMe && !isVoid) const Spacer(),
              ],
            ),
          ),
        ),
      );
    });
  }
}