import 'package:chatting/Pages/Auth/LoginForm.dart';
import 'package:chatting/Pages/Auth/SignUpForm.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AuthCard extends StatelessWidget {
  final RxBool isLogin = true.obs;

  AuthCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16.0),
          padding: const EdgeInsets.all(20.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Theme.of(context).colorScheme.primaryContainer,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Obx(
                    () => Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    InkWell(
                      onTap: () {
                        isLogin.value = true;
                      },
                      child: Column(
                        children: [
                          Text(
                            "Login",
                            style: isLogin.value
                                ? Theme.of(context).textTheme.bodyLarge
                                : Theme.of(context).textTheme.labelLarge,
                          ),
                          const SizedBox(height: 5),
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: isLogin.value ? 120 : 0,
                            height: 3,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(50),
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        isLogin.value = false;
                      },
                      child: Column(
                        children: [
                          Text(
                            "Sign Up",
                            style: isLogin.value
                                ? Theme.of(context).textTheme.labelLarge
                                : Theme.of(context).textTheme.bodyLarge,
                          ),
                          const SizedBox(height: 5),
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: isLogin.value ? 0 : 120,
                            height: 3,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(50),
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20), // Add space between tabs and forms
              Obx(
                    () => isLogin.value
                    ? AuthLoginForm()
                    : AuthSignUpForm(),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
