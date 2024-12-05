import 'package:chatting/Model/UserModel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class AuthController extends GetxController{
  final auth = FirebaseAuth.instance;
  final db = FirebaseFirestore.instance;
  RxBool isLoading = false.obs;


  //for login
  Future<void> login(String email,String password)async{
    isLoading.value=true;
    try{
      await auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      Get.offAllNamed('/homePage');
      print("Login  Sucessfull");
    }on FirebaseAuthException catch(e){
      if(e.code == 'user-not-found'){
        print('TNo user found for that email.');
      }
      else if(e.code == 'wrong-password'){
        print('Wrong password provider for that user.');
      }
    }catch(e){
      print(e);
    }
    isLoading.value=false;
  }
  
  
  Future <void> createUser(String email,String password,String name)async{
    isLoading.value = true;
    try{
      await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await initUser(email,name);
      Get.offAllNamed('/homePage');
      print("Sucessfully!! created account ");
    }on FirebaseAuthException catch(e){
      if(e.code=='weak-password'){
        print('The password provided is too weak');
      }
      else if(e.code=='email-already-in-use'){
        print('The account already exists for that email');
      }
    }catch(e){
      print(e);
    }
    isLoading.value = false;
  }


  Future<void> logOutUser()async{
    await auth.signOut();
    Get.offAllNamed('/authPage');
  }




  Future<void> initUser(String email,String name) async {
    var newUser = UserModel(
      id: auth.currentUser!.uid,
      name: name,
      email: email,
      profileImage: "",
      phoneNumber: "",
      // createdAt: DateTime.now().toString(),
    );
    try{
      await db.collection("users").doc(auth.currentUser!.uid).set(newUser.toJson());
    }
    catch(e){
      print (e);
    }
  }

}