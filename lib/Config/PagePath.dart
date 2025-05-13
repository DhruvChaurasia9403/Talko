import 'package:chatting/AI/Features/Prompt/UI/create_prompt.dart';
import 'package:chatting/Pages/Auth/AuthPage.dart';
import 'package:chatting/Pages/Contact/ContactPage.dart';
import 'package:chatting/Pages/Home/HomePage.dart';
import 'package:get/get.dart';


var pagePath =[
  GetPage(
    name: "/authPage",
    page: ()=>const Authpage(),
    transition: Transition.fadeIn,
  ),
  GetPage(
    name: "/homePage",
    page: ()=>const HomePage(),
    transition: Transition.fadeIn,
  ),
  GetPage(
      name: "/aiPage",
      page: ()=>const CreatePromptScreen(),
      transitionDuration: const Duration(milliseconds: 100),
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
    page: ()=>const Contactpage(),
    transition: Transition.fadeIn,
  )
];
