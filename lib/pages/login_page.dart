import 'package:chat_app/constants.dart';
import 'package:chat_app/helpers/show_snak_bar.dart';
import 'package:chat_app/pages/chat_page.dart';
import 'package:chat_app/pages/register_page.dart';
import 'package:chat_app/widgets/custom_button.dart';
import 'package:chat_app/widgets/custom_text_field.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  static String id = 'loginPage';
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String? email;
  String? password;
  bool isLoading = false;

  GlobalKey<FormState> formKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      inAsyncCall: isLoading,
      child: Scaffold(
        backgroundColor: kPrimaryColor,
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Form(
            key: formKey,
            child: ListView(
              children: [
                const SizedBox(height: 75),
                Image.asset(kLogo, height: 100),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Text(
                      'Scholar Chat',
                      style: TextStyle(
                        fontSize: 32,
                        fontFamily: 'Pacifico',
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 75),
                const Text(
                  'Sign In',
                  style: TextStyle(fontSize: 24, color: Colors.white),
                ),
                const SizedBox(height: 22),
                CustomTextFormField(
                  onChanged: (data) => email = data,
                  hintText: 'Email',
                ),
                const SizedBox(height: 12),
                CustomTextFormField(
                  onChanged: (data) => password = data,
                  hintText: 'Password',
                  obscureText: true,
                ),
                const SizedBox(height: 22),
                CustomButton(
                  onTap: () async {
                    if (formKey.currentState!.validate()) {
                      isLoading = true;
                      setState(() {});
                      try {
                        await loginUser();
                        Navigator.pushNamed(
                          context,
                          ChatPage.id,
                          arguments: email,
                        );
                      } on FirebaseAuthException catch (e) {
                        String message;
                        if (e.code == 'user-not-found') {
                          message = 'No user found with this email ❌';
                        } else if (e.code == 'wrong-password') {
                          message = 'Wrong password ❌';
                        } else if (e.code == 'invalid-email') {
                          message = 'Invalid email address ❌';
                        } else if (e.code == 'user-disabled') {
                          message = 'This account has been disabled ❌';
                        } else if (e.code == 'invalid-credential') {
                          message = 'Invalid email or password ❌';
                        } else {
                          message = e.message ?? 'Authentication error ❌';
                        }

                        showSnakBar(context, message);
                      } catch (e) {
                        print(e);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Unexpected error: $e")),
                        );
                      }
                      isLoading = false;
                      setState(() {});
                    }
                  },
                  action: 'Sign In',
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Don\'t have an account?',
                      style: TextStyle(color: Colors.white),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, RegisterPage.id);
                      },
                      child: const Text(
                        '  Sign Up',
                        style: TextStyle(color: Color(0xffC7EDE6)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> loginUser() async {
    var auth = FirebaseAuth.instance;
    await auth.signInWithEmailAndPassword(email: email!, password: password!);
  }
}
