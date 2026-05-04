import 'dart:ui';
import 'package:chatting/Config/images.dart';
import 'package:chatting/Controller/ChatController.dart';
import 'package:chatting/Controller/ProfileController.dart';
import 'package:chatting/Pages/Chat/Widgets/MessagesStatus.dart';
import 'package:chatting/Pages/Chat/Widgets/VideoPlayerItem.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../Controller/ThemeController.dart';

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
    final themeController = Get.find<ThemeController>();
    final isVoid = senderId == "VOID";
    final isMe = senderId == Get.find<ProfileController>().currentUser.value.id;
    final bool isVideo = imageUrl != null && (imageUrl!.toLowerCase().contains('.mp4') || imageUrl!.toLowerCase().contains('.mov'));

    return Obx(() {
      bool isSelected = chatController.selectedMessageIds.contains(messageId);

      // Dynamic Color Assignment
      Color bubbleColor;
      Color fontColor;

      if (isVoid) {
        bubbleColor = themeController.isDark ? Colors.black87 : Colors.grey.shade900;
        fontColor = themeController.primary;
      } else if (isMe) {
        bubbleColor = themeController.primary;
        fontColor = Colors.white;
      } else {
        bubbleColor = themeController.surface;
        fontColor = themeController.text;
      }

      // Asymmetrical Border Radius
      BorderRadius borderRadius = BorderRadius.only(
        topLeft: const Radius.circular(20),
        topRight: const Radius.circular(20),
        bottomLeft: isVoid ? const Radius.circular(20) : (isMe ? const Radius.circular(20) : const Radius.circular(4)),
        bottomRight: isVoid ? const Radius.circular(20) : (isMe ? const Radius.circular(4) : const Radius.circular(20)),
      );

      Widget chatBubble = AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        constraints: BoxConstraints(maxWidth: MediaQuery.sizeOf(context).width * (isVoid ? 0.9 : 0.75)),
        decoration: BoxDecoration(
          color: themeController.isGlass
              ? bubbleColor.withAlpha(isMe ? 220 : 150)
              : bubbleColor,
          borderRadius: borderRadius,
          border: themeController.isGlass
              ? Border.all(color: Colors.white.withAlpha(themeController.isDark ? 20 : 100), width: 1)
              : null,
          boxShadow: themeController.isGlass ? null : [
            BoxShadow(
              color: themeController.isDark ? Colors.black.withAlpha(150) : Colors.black.withAlpha(15),
              blurRadius: 8,
              offset: const Offset(2, 4),
            )
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
          child: Column(
            crossAxisAlignment: isVoid ? CrossAxisAlignment.center : (isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start),
            children: [
              if (isVoid)
                Padding(
                  padding: const EdgeInsets.only(bottom: 6.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.smart_toy, size: 14, color: themeController.primary),
                      const SizedBox(width: 6),
                      Text("V.O.I.D. SYSTEM", style: TextStyle(color: themeController.primary, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.2))
                    ],
                  ),
                ),

              if (imageUrl != null && imageUrl!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: isVideo
                      ? VideoPlayerItem(videoUrl: imageUrl!)
                      : ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(imageUrl!, fit: BoxFit.cover),
                  ),
                ),

              if (sms != null && sms!.isNotEmpty)
                Text(
                  sms!,
                  textAlign: isVoid ? TextAlign.center : TextAlign.start,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: fontColor),
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
                        color: isMe ? fontColor.withAlpha(200) : themeController.subText,
                        fontSize: 10,
                      ),
                    ),
                  if (isMe) ...[
                    const SizedBox(width: 6),
                    if (status == MessageStatus.unknown)
                      Icon(Icons.access_time, size: 12, color: fontColor.withAlpha(200))
                    else
                      SvgPicture.asset(
                        status == MessageStatus.read ? AssetsImage.doubleBlueTickSVG :
                        status == MessageStatus.delivered ? AssetsImage.doubleTickSVG :
                        status == MessageStatus.sent ? AssetsImage.singleTickSVG : AssetsImage.errorSVG,
                        height: 12, width: 12,
                        colorFilter: status != MessageStatus.read
                            ? ColorFilter.mode(fontColor.withAlpha(200), BlendMode.srcIn)
                            : null,
                      ),
                  ]
                ],
              ),
            ],
          ),
        ),
      );

      return GestureDetector(
        onLongPress: () {
          HapticFeedback.mediumImpact();
          chatController.toggleMessageSelection(messageId);
        },
        onTap: () {
          if (chatController.selectedMessageIds.isNotEmpty) chatController.toggleMessageSelection(messageId);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(vertical: 4),
          color: isSelected ? themeController.primary.withAlpha(50) : Colors.transparent,
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
                      // Apply deep blur if glassmorphism is active
                      themeController.isGlass ? ClipRRect(
                        borderRadius: borderRadius,
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                          child: chatBubble,
                        ),
                      ) : chatBubble,

                      if (isSelected)
                        Positioned(
                          left: isMe ? -10 : null, right: !isMe ? -10 : null,
                          top: 0, bottom: 0,
                          child: Center(
                            child: Container(
                              decoration: BoxDecoration(color: themeController.primary, shape: BoxShape.circle),
                              padding: const EdgeInsets.all(6),
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