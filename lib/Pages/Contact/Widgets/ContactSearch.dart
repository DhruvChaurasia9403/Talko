import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ContactSearch extends StatelessWidget {
  const ContactSearch({super.key});

  @override
  Widget build(BuildContext context) {
    RxBool isFocused = false.obs;  // Observable for focus state

    // FocusNode to manage the focus state
    final FocusNode _focusNode = FocusNode();

    // Add a listener to the FocusNode to update isFocused value
    _focusNode.addListener(() {
      isFocused.value = _focusNode.hasFocus;  // Update focus state
    });

    return Obx(
          () => Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: isFocused.value
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.onSurface,
          ),
          color: isFocused.value
              ? Theme.of(context).colorScheme.primaryContainer
              : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 6.0),
          child: TextField(
            focusNode: _focusNode,  // Assigning the FocusNode
            decoration: InputDecoration(
              hintText: 'Search...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: isFocused.value
                  ? Theme.of(context).colorScheme.primaryContainer
                  : Theme.of(context).colorScheme.surface,
            ),
            onTap: () {
              // Tapping will trigger the focus change but the listener handles the state
            },
          ),
        ),
      ),
    );
  }
}
