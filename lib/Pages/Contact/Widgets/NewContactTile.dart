import 'package:flutter/material.dart';

class NewContactTile extends StatelessWidget {
  final String btnName ;
  final IconData icon;
  final VoidCallback onTap;
  const NewContactTile({super.key, required this.btnName, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          children: [
            Container(
              width:70,
              height:70,
              child: Icon(
                icon,
                color: Theme.of(context).colorScheme.onBackground,
                size: 35,
              ),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(100),
              ),
            ),
            SizedBox(width: 15),
            Text(
              btnName,
              style: Theme.of(context).textTheme.bodyLarge,
            )
          ],
        ),
      ),
    );
  }
}
