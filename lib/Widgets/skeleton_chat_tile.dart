import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class SkeletonChatTile extends StatelessWidget {
  const SkeletonChatTile({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade800,
      highlightColor: Colors.grey.shade700,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          color: Colors.grey.shade900,
        ),
        child: Row(
          children: [
            // Avatar
            Container(
              height: 58,
              width: 58,
              decoration: BoxDecoration(
                color: Colors.grey,
                borderRadius: BorderRadius.circular(30),
              ),
            ),

            const SizedBox(width: 14),

            // Texts
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 14,
                  width: 120,
                  color: Colors.grey,
                ),
                const SizedBox(height: 10),
                Container(
                  height: 12,
                  width: 180,
                  color: Colors.grey,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}