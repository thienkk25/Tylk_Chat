import 'package:app_chat/controllers/user_controller.dart';
import 'package:app_chat/screens/login.dart';
import 'package:flutter/material.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();
  TextEditingController rePassword = TextEditingController();
// Regular expression for email validation
  final RegExp emailRegExp = RegExp(
      r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+");

  final GlobalKey<FormState> keyForm = GlobalKey<FormState>();
  @override
  void dispose() {
    email.dispose();
    password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height / 4,
            width: double.infinity,
            child: const Center(
              child: Text(
                "Register",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          SizedBox(
            width: MediaQuery.of(context).size.width / 1.5,
            child: Form(
                key: keyForm,
                child: Column(
                  children: [
                    TextFormField(
                      controller: email,
                      validator: (value) {
                        if (value == "" || value!.isEmpty) {
                          return "Please enter email";
                        } else if (!emailRegExp.hasMatch(value)) {
                          return "Email is not in correct format";
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.email),
                          border: OutlineInputBorder(
                            borderSide: const BorderSide(width: 1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          focusColor: Colors.black,
                          labelText: "Email",
                          labelStyle: const TextStyle(color: Colors.black),
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(width: 1),
                            borderRadius: BorderRadius.circular(20),
                          )),
                      cursorColor: Colors.black,
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    TextFormField(
                      controller: password,
                      validator: (value) {
                        if (value == "" || value!.isEmpty) {
                          return "Please enter pasword";
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.lock),
                          suffixIcon: const Icon(Icons.visibility),
                          border: OutlineInputBorder(
                            borderSide: const BorderSide(width: 1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          focusColor: Colors.black,
                          labelText: "Password",
                          labelStyle: const TextStyle(color: Colors.black),
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(width: 1),
                            borderRadius: BorderRadius.circular(20),
                          )),
                      cursorColor: Colors.black,
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    TextFormField(
                      controller: rePassword,
                      validator: (value) {
                        if (value == "" || value!.isEmpty) {
                          return "Please enter pasword";
                        } else if (value != rePassword.text) {
                          return "Passwords do not match";
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.lock),
                          suffixIcon: const Icon(Icons.visibility),
                          border: OutlineInputBorder(
                            borderSide: const BorderSide(width: 1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          focusColor: Colors.black,
                          labelText: "Re-password",
                          labelStyle: const TextStyle(color: Colors.black),
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(width: 1),
                            borderRadius: BorderRadius.circular(20),
                          )),
                      cursorColor: Colors.black,
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    InkWell(
                      onTap: () {
                        if (keyForm.currentState!.validate()) {
                          register(email.text, password.text);
                        }
                      },
                      child: Container(
                        height: 50,
                        width: MediaQuery.of(context).size.width / 3,
                        decoration: BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadius.circular(20)),
                        child: const Center(
                            child: Text(
                          "Register",
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        )),
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("You have account?"),
                        InkWell(
                          onTap: () {
                            Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => const Login()));
                          },
                          child: const Text(
                            "Login",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    )
                  ],
                )),
          ),
        ],
      ),
    );
  }

  Future<void> register(String email, String password) async {
    final data = await UserController().registerUser(email, password);
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(data['message'])));
  }
}
