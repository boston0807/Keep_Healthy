import 'package:flutter/material.dart';
import 'package:keep_healthy/pages/menu_page.dart';
import 'package:keep_healthy/services/auth_service.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {

  final AuthService authService = AuthService();

  final emailController = TextEditingController();
  final usernameController = TextEditingController();
  final firstNameController = TextEditingController();
  final surNameController = TextEditingController();
  final passwordController = TextEditingController();
  final passwordConfirmController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    usernameController.dispose();
    firstNameController.dispose();
    surNameController.dispose();
    passwordController.dispose();
    passwordConfirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),

      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [

            const SizedBox(height: 70),

            Image.asset(
              "assets/images/keep_healthy(nobg).png",
              width: 225,
            ),

            const SizedBox(height: 30),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: TextField(
                controller: emailController,
                textAlign: TextAlign.center,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: "Enter Email",
                ),
              ),
            ),

            const SizedBox(height: 20),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: TextField(
                controller: usernameController,
                textAlign: TextAlign.center,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: "Username",
                ),
              ),
            ),

            const SizedBox(height: 40),

            Row(
              children: [

                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: TextField(
                      controller: firstNameController,
                      textAlign: TextAlign.center,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: "First Name",
                      ),
                    ),
                  ),
                ),

                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: TextField(
                      controller: surNameController,
                      textAlign: TextAlign.center,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: "Surname",
                      ),
                    ),
                  ),
                ),

              ],
            ),

            const SizedBox(height: 40),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: TextField(
                controller: passwordController,
                obscureText: true,
                textAlign: TextAlign.center,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: "Password",
                ),
              ),
            ),

            const SizedBox(height: 40),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: TextField(
                controller: passwordConfirmController,
                obscureText: true,
                textAlign: TextAlign.center,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: "Confirm Your Password",
                ),
              ),
            ),

            const SizedBox(height: 20),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(

                  onPressed: () async{

                    final email = emailController.text;
                    final username = usernameController.text;
                    final firstName = firstNameController.text;
                    final surName = surNameController.text;
                    final password = passwordController.text;
                    final passwordConfirm = passwordConfirmController.text;

                    try{
                      
                      await authService.register(
                      email,
                      username,
                      firstName,
                      surName,
                      password,
                      passwordConfirm,
                    );
                    
                      Navigator.pushNamedAndRemoveUntil(context, '/main-screen', (_) => false);
                    }catch (e) {
                      
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(e.toString()))
                      );
                    }
                  },

                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[200],
                    foregroundColor: Colors.black,
                  ),

                  child: const Text(
                    "Register",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                    ),
                  ),

                ),
              ),
            ),

          ],
        ),
      ),

    );
  }
}
