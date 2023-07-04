import 'package:chat_app/components/my_textfield.dart';
import 'package:chat_app/components/my_button.dart';
import 'package:chat_app/services/authentication/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class RegisterPage extends StatefulWidget {
  final void Function()? onClick;
  const RegisterPage({super.key, required this.onClick});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final emailController = TextEditingController();

  final passwordController = TextEditingController();

  final confirmPasswordController = TextEditingController();

  void signUp() async {
    if (passwordController.text != confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Password does NOT match!")));
      return;
    } else {
      final authService = Provider.of<AuthService>(context, listen: false);
      try {
        await authService.registerWithEmailAndPassword(
            emailController.text, passwordController.text);
      } catch (e) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.toString())));
      }
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
                    "Let's create an account for you!",
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                ),
                //email textfield
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: MyTextfield(
                    controller: emailController,
                    hintText: 'Email',
                    obscureText: false,
                  ),
                ),
                //password textfield
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: MyTextfield(
                    controller: passwordController,
                    hintText: 'Password',
                    obscureText: true,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: MyTextfield(
                    controller: confirmPasswordController,
                    hintText: 'Confirm Password',
                    obscureText: true,
                  ),
                ),
                //button
                Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: MyButton(
                    buttonText: "Sign Up",
                    onTap: signUp,
                  ),
                ),
                //not a member ? register now
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  const Text("Already a member?"),
                  const SizedBox(
                    width: 10,
                  ),
                  GestureDetector(
                    onTap: widget.onClick,
                    child: const Text(
                      "Login now",
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
