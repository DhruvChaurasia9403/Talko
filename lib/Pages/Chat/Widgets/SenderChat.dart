import 'package:chatting/Config/images.dart';
import 'package:chatting/Pages/Chat/Widgets/MessagesStatus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';

class SenderChat extends StatefulWidget {
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
  _SenderChatState createState() => _SenderChatState();
}

class _SenderChatState extends State<SenderChat> {
  bool isSelected = false;
  final GlobalKey _messageKey = GlobalKey();

  void _copyMessage() {
    Clipboard.setData(ClipboardData(text: widget.sms ?? ""));
    Get.snackbar(
      "Success",
      "Message copied to clipboard",
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 1),
    );
  }

  void _deleteMessage() {
    // Implement delete message logic here
  }

  void _deleteMessageForBoth() {
    // Implement delete message for both sides logic here
  }

  void _showPopupMenu() {
    final RenderBox renderBox = _messageKey.currentContext!.findRenderObject() as RenderBox;
    final Offset offset = renderBox.localToGlobal(Offset.zero);
    final Size size = renderBox.size;

    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(
        offset.dx,
        offset.dy,
        offset.dx + size.width,
        offset.dy + size.height,
      ),
      items: [
        const PopupMenuItem<String>(
          value: 'Copy',
          child: Text('Copy'),
        ),
        const PopupMenuItem<String>(
          value: 'Delete',
          child: Text('Delete'),
        ),
        if (widget.senderId == 'currentUserId') // Replace 'currentUserId' with actual current user ID
          const PopupMenuItem<String>(
            value: 'Delete for both',
            child: Text('Delete for both'),
          ),
      ],
    ).then((value) {
      if (value != null) {
        switch (value) {
          case 'Copy':
            _copyMessage();
            break;
          case 'Delete':
            _deleteMessage();
            break;
          case 'Delete for both':
            if (widget.senderId == 'currentUserId') { // Replace 'currentUserId' with actual current user ID
              _deleteMessageForBoth();
            }
            break;
        }
      }
      setState(() {
        isSelected = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if ((widget.sms == null || widget.sms!.isEmpty) && (widget.imageUrl == null || widget.imageUrl!.isEmpty)) {
      return const SizedBox.shrink();
    }

    // List of colors to cycle through for sent messages
    final List<Color> colors = [
      Colors.blue,
      Colors.green,
      Colors.red,
      Colors.orange,
      Colors.purple,
    ];

    // Select color based on the index for sent messages
    final Color containerColor = widget.isComing ? Colors.grey.shade200 : colors[widget.index % colors.length];

    return GestureDetector(
      onLongPress: () {
        setState(() {
          isSelected = true;
        });
        _showPopupMenu();
      },
      onTap: () {
        if (isSelected) {
          setState(() {
            isSelected = false;
          });
        }
      },
      child: Container(
        key: _messageKey,
        color: Colors.transparent,
        child: Row(
          mainAxisAlignment: widget.isComing ? MainAxisAlignment.start : MainAxisAlignment.end,
          children: [
            if (!widget.isComing) const Spacer(),
            Flexible(
              child: Column(
                crossAxisAlignment: widget.isComing ? CrossAxisAlignment.start : CrossAxisAlignment.end,
                children: [
                  if (widget.imageUrl != null && widget.imageUrl!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                          widget.imageUrl!,
                          fit: BoxFit.cover,
                          width: MediaQuery.sizeOf(context).width / 1.5,
                          height: 200,
                          errorBuilder: (context, error, stackTrace) => Container(
                            color: Colors.grey.shade200,
                            child: const Center(child: Text("Image not found")),
                          ),
                        ),
                      ),
                    ),
                  if (widget.sms != null && widget.sms!.isNotEmpty)
                    Container(
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.sizeOf(context).width / 1.3,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.grey : containerColor,
                        borderRadius: BorderRadius.only(
                          topLeft: const Radius.circular(10),
                          topRight: const Radius.circular(10),
                          bottomLeft: widget.isComing ? Radius.zero : const Radius.circular(10),
                          bottomRight: widget.isComing ? const Radius.circular(10) : Radius.zero,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              widget.sms!,
                              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                color: widget.isComing ? Colors.black : Colors.white,
                              ),
                            ),
                            if (widget.timestamp != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 4.0),
                                child: Text(
                                  DateFormat('hh:mm a').format(widget.timestamp!),
                                  style: Theme.of(context).textTheme.labelSmall,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  const SizedBox(height: 1),
                  if (widget.sms != null || (widget.imageUrl != null && widget.imageUrl!.isNotEmpty))
                    widget.isComing
                        ? Padding(
                      padding: const EdgeInsets.only(left: 4.0),
                    )
                        : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(right: 4.0),
                        ),
                        SvgPicture.asset(
                          widget.status == MessageStatus.read
                              ? AssetsImage.doubleBlueTickSVG
                              : widget.status == MessageStatus.delivered
                              ? AssetsImage.doubleTickSVG
                              : widget.status == MessageStatus.sent
                              ? AssetsImage.singleTickSVG
                              : AssetsImage.errorSVG,
                          height: 10,
                          width: 10,
                        ),
                      ],
                    ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
            if (widget.isComing) const Spacer(),
          ],
        ),
      ),
    );
  }
}