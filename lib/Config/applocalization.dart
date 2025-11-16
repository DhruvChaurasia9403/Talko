// File: Config/AppLocalization.dart

import 'package:get/get.dart';

class AppLocalization extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
    'en_US': {
      // App
      'appName': 'SAMPARK',

      // Welcome Page (from your old Strings.dart)
      'welcomeNowYouAre': 'Now You Are',
      'welcomeConnected': 'Connected',
      'welcomeDescription': 'Perfect solution to connect with anyone easily and securely',
      'welcomeSlideToStart': 'Slide to Start Now',

      // Auth
      'login': 'Login',
      'signUp': 'Sign Up',
      'email': 'Email',
      'password': 'Password',
      'name': 'Name',
      'authLoginSuccess': 'Login Successful',
      'authLoginUserNotFound': 'No user found for that email.',
      'authLoginWrongPassword': 'Wrong password provider for that user.',
      'authSignUpSuccess': 'Successfully created account',
      'authSignUpWeakPassword': 'The password provided is too weak',
      'authSignUpEmailInUse': 'The account already exists for that email',

      // Home Page
      'homeChats': 'Chats',
      'homeGroup': 'Group',
      'homeCalls': 'Calls',
      'homeSearch': 'Search',
      'homeSearchBy': 'Search by name',
      'homeCancel': 'Cancel',
      'homeAiTooltip': 'Go to AI page',
      'homeContactTooltip': 'Add a new contact',
      'homeTab2': 'Tab 2 Content',
      'homeTab3': 'Tab 3 Content',

      // Contact Page
      'contactSelect': 'Select Contact',
      'contactNew': 'New Contact',
      'contactNewGroup': 'New Group',
      'contactOnApp': 'Contacts on @appName', // @appName will be replaced
      'contactYou': 'You',
      'contactOnline': 'online',
      'contactDefaultName': 'Name',
      'contactDefaultAbout': 'hey there',
      'contactSearchHint': 'Search...',

      // Chat Page
      'chatLoading': 'Loading...',
      'chatError': 'Error',
      'chatOffline': 'Offline',
      'chatUnknownUser': 'Unknown',
      'chatTypeMessage': 'Type message ...',
      'chatErrorOccurred': 'An error occurred. Please try again.',
      'chatNoMessages': 'No messages found.',
      'chatNewMessageFrom': 'New Message from @name', // @name will be replaced

      // Profile Page
      'profile': 'Profile',
      'profileAbout': 'About',
      'profilePhoneNumber': 'Phone Number',
      'profileSave': 'Save',
      'profileEdit': 'Edit',
      'profileSenderTitle': "@name's Profile", // @name will be replaced
      'profileSenderDefaultUser': 'User',
      'profileSenderDefaultEmail': '***@gmail.com',
      'profileInfoCall': 'Call',
      'profileInfoVideo': 'Video',
      'profileInfoChat': 'Chat',

      // Notification
      'notificationTitle': 'Reminder Alert',
      'notificationBody': 'Your scheduled notification is here!',
    }
  };
}