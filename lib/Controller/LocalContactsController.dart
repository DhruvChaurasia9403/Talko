// File: Controller/LocalContactsController.dart

import 'package:chatting/Model/UserModel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:get/get.dart';

class LocalContactsController extends GetxController {
  final db = FirebaseFirestore.instance;
  final auth = FirebaseAuth.instance;

  RxBool isLoading = false.obs;
  RxList<UserModel> registeredContacts = <UserModel>[].obs;
  RxList<Contact> unregisteredContacts = <Contact>[].obs; // <-- NEW: Hold other contacts

  @override
  void onInit() {
    super.onInit();
    syncContacts();
  }

  Future<void> syncContacts() async {
    isLoading.value = true;
    try {
      final status = await FlutterContacts.permissions.request(PermissionType.read);
      if (status != PermissionStatus.granted) {
        print("Contact permission denied.");
        isLoading.value = false;
        return;
      }
      await Future.delayed(const Duration(milliseconds: 300));
      List<Contact> localContacts = await FlutterContacts.getAll(properties: {ContactProperty.phone});

      // Map local phone numbers to their Contact object for easy lookup
      Map<String, Contact> localPhoneMap = {};
      for (var contact in localContacts) {
        for (var phone in contact.phones) {
          String cleanPhone = phone.number.replaceAll(RegExp(r'\D'), '');
          if (cleanPhone.length >= 10) {
            cleanPhone = cleanPhone.substring(cleanPhone.length - 10);
            localPhoneMap[cleanPhone] = contact;
          }
        }
      }

      final snapshot = await db.collection("users").get();
      List<UserModel> allUsers = snapshot.docs.map((doc) => UserModel.fromJson(doc.data())).toList();

      List<UserModel> matchedUsers = [];
      Set<String> matchedPhones = {}; // Track who is already registered

      for (var user in allUsers) {
        if (user.phoneNumber != null && user.phoneNumber!.isNotEmpty) {
          String cleanFbPhone = user.phoneNumber!.replaceAll(RegExp(r'\D'), '');
          if (cleanFbPhone.length >= 10) {
            cleanFbPhone = cleanFbPhone.substring(cleanFbPhone.length - 10);
            if (user.id == auth.currentUser!.uid) {
              matchedPhones.add(cleanFbPhone);
              continue;
            }
            if (localPhoneMap.containsKey(cleanFbPhone)) {
              matchedUsers.add(user);
              matchedPhones.add(cleanFbPhone);
            }
          }
        }
      }

      // Filter out anyone who isn't registered into the new list
      List<Contact> unreg = [];
      for (var entry in localPhoneMap.entries) {
        if (!matchedPhones.contains(entry.key)) {
          unreg.add(entry.value);
        }
      }

      // Make sure we don't have duplicate unreg contacts if they have multiple numbers
      final uniqueUnreg = unreg.toSet().toList();

      uniqueUnreg.sort((a, b) => (a.displayName ?? "").compareTo(b.displayName ?? ""));

      registeredContacts.value = matchedUsers;
      unregisteredContacts.value = uniqueUnreg;

      registeredContacts.refresh();
      unregisteredContacts.refresh();

    } catch (e) {
      print("Error syncing contacts: $e");
    } finally {
      isLoading.value = false;
    }
  }
}