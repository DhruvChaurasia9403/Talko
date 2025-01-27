import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ContactSearch extends StatelessWidget {
  const ContactSearch({super.key});

  @override
  Widget build(BuildContext context) {
    RxBool isFocused = false.obs;

    return Obx(()=>
        Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: isFocused.value
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.onSurface,
            ),
            color: isFocused.value
                ? Theme.of(context).colorScheme.primaryContainer
                : Theme.of(context).colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 6.0),
              child:TextField(
                    focusNode: FocusNode()..addListener(() {
                      isFocused.value = isFocused.value;
                    }),
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
                          : Theme.of(context).colorScheme.primaryContainer,
                    ),
                    onTap: () {
                      isFocused.value = !isFocused.value;
                    },
                  ),
              )
          ),
    );
  }
}
