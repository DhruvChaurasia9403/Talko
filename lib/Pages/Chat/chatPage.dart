import 'package:chatting/Config/images.dart';
import 'package:chatting/Controller/ChatController.dart';
import 'package:chatting/Model/UserModel.dart';
import 'package:chatting/Pages/Chat/Widgets/SenderChat.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../Model/ChatModel.dart';
class chatPage extends StatelessWidget {
  final UserModel userModel;
  const chatPage({super.key,required this.userModel});

  @override
  Widget build(BuildContext context) {
    ChatController chatController = Get.put(ChatController());
    TextEditingController messageController = TextEditingController();
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed:(){},
            icon:Icon(Icons.phone),
          ),
          IconButton(
            onPressed:(){},
            icon:Icon(Icons.videocam),
          )
        ],
        leading:IconButton(onPressed: (){}, icon: Icon(Icons.arrow_back_ios_new)),
        title:Row(
          mainAxisAlignment: MainAxisAlignment.start ,
          children: [
            Container(
              height:50,
              width:50,
              child: Image.asset(AssetsImage.boyPic)
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(userModel.name??"Unknown",style:Theme.of(context).textTheme.bodyLarge),
                  Text(
                    "Online",
                    style:Theme.of(context).textTheme.labelSmall,
                  )
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Container(
        margin:EdgeInsets.all(10),
        padding:EdgeInsets.symmetric(vertical: 5,horizontal: 5),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(100),
          border:Border.all(color:Theme.of(context).colorScheme.onPrimaryContainer),
          color:Theme.of(context).colorScheme.primaryContainer
        ),
        child:Row(
          children: [
            Container(
              height:50,
              width:50,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(100),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: SvgPicture.asset(
                  AssetsImage.micSVG,
                  width:25,
                ),
              ),
            ),
            Expanded(
              child:TextField(
                controller: messageController,
                decoration:InputDecoration(
                  filled:false,
                  hintText:"Type message ...",
                )
              )
            ),
            Container(
              height:50,
              width:50,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(100),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: SvgPicture.asset(AssetsImage.gallerySVG),
              ),
            ),
            InkWell(
              onTap: (){
                if(messageController.text.isNotEmpty){
                  chatController.sendMessage(userModel.id!, messageController.text);
                  messageController.clear();
                }
              },
              child: Container(
                width:50,
                height:50,
                decoration: BoxDecoration(

                  borderRadius: BorderRadius.circular(100),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SvgPicture.asset(AssetsImage.sendSVG,),
                ),
              ),
            ),
          ],
        )
      ),


      body:Container(
        margin: EdgeInsets.only(bottom: 70),
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                senderChat(
                  sms: "Hey! Dhruv this side. How are you ?",
                  isComing: true,
                  time: "time",
                  imageUrl: "",
                  status: "seen",
                ),
                senderChat(
                  sms: "hello Dhruv . I'm fine . What about you",
                  isComing: false,
                  time: "time",
                  imageUrl: "",
                  status: "seen",
                ),
                senderChat(
                  sms: "hey",
                  isComing: false,
                  time: "time",
                  imageUrl: "https://images.unsplash.com/photo-1721332155484-5aa73a54c6d2?w=1000&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDF8MHxmZWF0dXJlZC1waG90b3MtZmVlZHwxfHx8ZW58MHx8fHx8",
                  status: "seen",
                ),
                senderChat(
                  sms: "hey",
                  isComing: true,
                  time: "time",
                  imageUrl: "https://images.unsplash.com/photo-1721332155484-5aa73a54c6d2?w=1000&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDF8MHxmZWF0dXJlZC1waG90b3MtZmVlZHwxfHx8ZW58MHx8fHx8",
                  status: "seen",
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
