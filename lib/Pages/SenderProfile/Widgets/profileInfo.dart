import 'package:chatting/Config/images.dart';
import 'package:chatting/Controller/ProfileController.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
class Profileinfo extends StatelessWidget {
  const Profileinfo({super.key});

  @override
  Widget build(BuildContext context) {
    ProfileController profileController = Get.put(ProfileController());

    return Container(
          decoration:BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color:Theme.of(context).colorScheme.primaryContainer,
          ),
          child:Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment:MainAxisAlignment.center,
                        children: [
                          Image.asset(AssetsImage.boyPic),

                        ],
                      ),
                    ),
                    SizedBox(height:10),
                    Row(
                      mainAxisAlignment:MainAxisAlignment.center,
                      children: [
                        Obx(() {
                          return Text(
                            profileController.currentUser.value.name?.isEmpty ?? true
                                ? "User"
                                : profileController.currentUser.value.name!,
                            style: Theme.of(context).textTheme.bodyLarge,
                          );
                        })


                      ],
                    ),
                    SizedBox(height:10),
                    Row(
                      mainAxisAlignment:MainAxisAlignment.center,
                      children: [
                        Obx(()=>Text(profileController.currentUser.value.email!,style:Theme.of(context).textTheme.labelLarge),)
                      ],
                    ),
                    SizedBox(height:15),
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children:[
                          Container(
                            child: Row(
                              children:[
                                Container(
                                    padding: EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(15),
                                      color: Theme.of(context).colorScheme.background,
                                    ),
                                    child:Row(
                                      children: [
                                        Icon(Icons.phone,color: Theme.of(context).colorScheme.secondary,),
                                        SizedBox(width:10),
                                        Text("Call",style:Theme.of(context).textTheme.labelLarge)
                                      ],
                                    )
                                )
                              ],
                            ),
                          ),


                          Container(
                            child: Row(
                              children:[
                                Container(
                                    padding: EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(15),
                                      color: Theme.of(context).colorScheme.background,
                                    ),
                                    child:Row(
                                      children: [
                                        Icon(Icons.videocam,color: Theme.of(context).colorScheme.primary,),
                                        SizedBox(width:10),
                                        Text("Video",style:Theme.of(context).textTheme.labelLarge)
                                      ],
                                    )
                                )
                              ],
                            ),
                          ),


                          Container(
                            child: Row(
                              children:[
                                Container(
                                    padding: EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(15),
                                      color: Theme.of(context).colorScheme.background,
                                    ),
                                    child:Row(
                                      children: [
                                        Icon(Icons.chat),
                                        SizedBox(width:10),
                                        Text("Chat",style:Theme.of(context).textTheme.labelLarge)
                                      ],
                                    )
                                )
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              )
            ],
          )
      );
  }
}
