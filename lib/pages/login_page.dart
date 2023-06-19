import 'package:chat_app/components/login_textfield.dart';
import 'package:chat_app/components/my_button.dart';
import 'package:chat_app/services/authentication/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LoginPage extends StatefulWidget {
  final void Function()? onClick;
  const LoginPage({super.key, required this.onClick});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  //text controller
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  void login() async {
    //get the auth service
    final authService = Provider.of<AuthService>(context, listen: false);
    try {
      await authService.loginWithEmailAndPassword(
          emailController.text, passwordController.text);
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                //logo
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 25.0),
                  child: Icon(
                    Icons.message_outlined,
                    size: 80,
                    color: Colors.blueAccent,
                  ),
                ),
                //welcome back message
                const Padding(
                  padding: EdgeInsets.all(15.0),
                  child: Text(
                    "Welcome back you\ 've been missed!",
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                ),
                //email textfield
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: LoginTextfield(
                    controller: emailController,
                    hintText: 'Email',
                    obscureText: false,
                  ),
                ),
                //password textfield
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: LoginTextfield(
                    controller: passwordController,
                    hintText: 'Password',
                    obscureText: true,
                  ),
                ),
                //button
                Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: MyButton(
                    buttonText: "Login",
                    onTap: login,
                  ),
                ),
                //not a member ? register now
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  const Text("Not a member?"),
                  const SizedBox(
                    width: 10,
                  ),
                  GestureDetector(
                    onTap: widget.onClick,
                    child: const Text(
                      "Register now",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ])
              ],
            ),
          ),
        ),
      ),
    );
  }
}
