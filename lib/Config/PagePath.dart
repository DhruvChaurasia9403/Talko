import 'package:chatting/Pages/Auth/AuthPage.dart';
import 'package:chatting/Pages/Chat/chatPage.dart';
import 'package:chatting/Pages/Contact/ContactPage.dart';
import 'package:chatting/Pages/Home/HomePage.dart';
import 'package:get/get.dart';

import '../Pages/SenderProfile/UpdateProfile.dart';
import '../Pages/SenderProfile/senderProfilePage.dart';

var pagePath =[
  GetPage(
    name: "/authPage",
    page: ()=>Authpage(),
    transition: Transition.fadeIn,
  ),
  GetPage(
    name: "/homePage",
    page: ()=>HomePage(),
    transition: Transition.fadeIn,
  ),
  // GetPage(
  //   name: "/chatPage",
  //   page: ()=>chatPage(),
  //   transition: Transition.fadeIn,
  // ),
  // GetPage(
  //   name:"/profilePage",
  //   page:()=>profilePage(),
  //   transition: Transition.fadeIn,
  // ),
  // GetPage(
  //   transitionDuration: Duration(milliseconds: 100),
  //   name:"/updateProfile",
  //   page:()=>Updateprofile(),
  //   transition: Transition.fadeIn,
  // ),
  GetPage(
    name: "/contactPage",
    page: ()=>Contactpage(),
    transition: Transition.fadeIn,
  )
];
