import 'package:chatting/Widgets/PrimaryButton.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
class Updateprofile extends StatelessWidget {
  const Updateprofile({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon:Icon(Icons.arrow_back_ios_new),
          onPressed: (){
            Get.offAllNamed('/profilePage');
          },
        ),
        title:Text("Update Profile"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color:Theme.of(context).colorScheme.primaryContainer,
              ),
              child: Row(
                children: [
                  Expanded(
                    child:Column(
                      children: [
                        Container(
                          width:200,
                          height:200,
                          child: Center(
                            child: Icon(Icons.camera_alt,size:50,color:Theme.of(context).colorScheme.onPrimaryContainer),
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(100),
                            color:Theme.of(context).colorScheme.background,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: [
                              Text("Personal Info.",style:Theme.of(context).textTheme.labelMedium),
                            ],
                          ),
                        ),
                        SizedBox(height:10),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: [
                              Text("Name",style:Theme.of(context).textTheme.labelLarge?.copyWith(color:Theme.of(context).colorScheme.primary)),
                            ],
                          ),
                        ),
                        TextFormField(
                          textInputAction: TextInputAction.next,
                          decoration: InputDecoration(
                            prefixIcon: Icon(Icons.person,color:Theme.of(context).colorScheme.onPrimaryContainer),
                            hintText: "Dhruv Chaurasia",
                            hintStyle: Theme.of(context).textTheme.labelMedium,
                          ),
                        ),
                        SizedBox(height:10),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: [
                              Text("Email",style:Theme.of(context).textTheme.labelLarge?.copyWith(color:Theme.of(context).colorScheme.primary)),
                            ],
                          ),
                        ),
                        TextFormField(
                          textInputAction: TextInputAction.next,
                          decoration: InputDecoration(
                            prefixIcon: Icon(Icons.alternate_email_outlined,color:Theme.of(context).colorScheme.onPrimaryContainer),
                            hintText: "example@gmail.com",
                            hintStyle: Theme.of(context).textTheme.labelMedium,
                          ),
                        ),
                        SizedBox(height:10),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: [
                              Text("Phone No.",style:Theme.of(context).textTheme.labelLarge?.copyWith(color:Theme.of(context).colorScheme.primary)),
                            ],
                          ),
                        ),
                        TextFormField(
                          textInputAction: TextInputAction.next,
                          keyboardType: TextInputType.phone,
                          decoration: InputDecoration(
                            prefixIcon: Icon(Icons.phone,color:Theme.of(context).colorScheme.onPrimaryContainer),
                            hintText: "1234567890",
                            hintStyle: Theme.of(context).textTheme.labelMedium,
                          ),
                        ),
                        SizedBox(height:20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Primarybutton(
                              btnName: "Save",
                              icon: Icons.save,
                              onTap: (){}
                            ),
                          ],
                        ),
                      ],
                    )
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
