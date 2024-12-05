import 'package:chatting/Config/images.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class senderChat extends StatelessWidget {
  final String? sms; // Nullable to handle cases with no message
  final bool isComing;
  final String time;
  final String status;
  final String? imageUrl; // Nullable to handle cases with no image

  const senderChat({
    super.key,
    this.sms,
    required this.isComing,
    required this.time,
    required this.status,
    this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    // Do not render anything if both message and image are null
    if ((sms == null || sms!.isEmpty) && (imageUrl == null || imageUrl!.isEmpty)) {
      return const SizedBox.shrink(); // Returns an empty widget
    }

    return Row(
      mainAxisAlignment: isComing ? MainAxisAlignment.start : MainAxisAlignment.end,
      children: [
        if (!isComing) const Spacer(),
        Flexible(
          child: Column(
            crossAxisAlignment: isComing ? CrossAxisAlignment.start : CrossAxisAlignment.end,
            children: [
              if (imageUrl != null && imageUrl!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      imageUrl!,
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
              if (sms != null && sms!.isNotEmpty)
                Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.sizeOf(context).width / 1.3,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(10),
                      topRight: const Radius.circular(10),
                      bottomLeft: isComing ? Radius.zero : const Radius.circular(10),
                      bottomRight: isComing ? const Radius.circular(10) : Radius.zero,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Text(
                      sms!,
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                  ),
                ),
              const SizedBox(height: 1),
              // Message time and status
              if (sms != null || (imageUrl != null && imageUrl!.isNotEmpty))
                isComing
                    ? Padding(
                  padding: const EdgeInsets.only(left: 4.0),
                  child: Text(
                    time,
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                )
                    : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 4.0),
                      child: Text(
                        time,
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                    ),
                    SvgPicture.asset(
                      AssetsImage.doubleTickSVG, // Replace with your actual path
                      height: 10,
                      width: 10,
                    ),
                  ],
                ),
              const SizedBox(height:10),
            ],
          ),
        ),
        if (isComing) const Spacer(), // Push incoming messages to the left
      ],
    );
  }
}
