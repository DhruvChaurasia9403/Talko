// File: Pages/Contact/Widgets/ContactSearch.dart

import 'package:flutter/material.dart';

class ContactSearch extends StatelessWidget {
  final Function(String) onChanged; // <-- Add this callback

  const ContactSearch({super.key, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Theme.of(context).colorScheme.primary.withOpacity(0.3)),
      ),
      child: TextField(
        onChanged: onChanged, // <-- Call it here
        autofocus: true,
        style: const TextStyle(color: Colors.white),
        decoration: const InputDecoration(
          hintText: 'Search contacts...',
          prefixIcon: Icon(Icons.search, color: Colors.white54),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 15),
        ),
      ),
    );
  }
}