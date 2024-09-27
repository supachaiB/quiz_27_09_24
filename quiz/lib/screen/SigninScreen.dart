import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:quiz/main.dart'; // นำเข้า main.dart เพื่อไปยัง MyHomePage
import 'package:quiz/service/auth_service.dart';

class SigninScreen extends StatefulWidget {
  const SigninScreen({super.key});

  @override
  State<SigninScreen> createState() => _SigninScreenState();
}

class _SigninScreenState extends State<SigninScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String? _errorMessage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Income & Expenses"),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Center(
        child: Container(
          height: 320,
          width: 300,
          padding: const EdgeInsets.all(18),
          decoration: const BoxDecoration(
            boxShadow: [
              BoxShadow(
                offset: Offset(0.1, 1),
                blurRadius: 0.1,
                spreadRadius: 0.1,
                color: Colors.black,
              )
            ],
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(20)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "SignIn",
                style: TextStyle(fontSize: 40),
              ),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: "Email",
                  border: OutlineInputBorder(),
                  errorText: _errorMessage, // แสดงข้อความข้อผิดพลาด
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: "Password",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () async {
                      var res = await AuthService().reqistration(
                        email: _emailController.text,
                        password: _passwordController.text,
                        confirm: _passwordController.text, // ยืนยันรหัสผ่าน
                      );
                      if (res == 'success') {
                        // ไปที่หน้าล็อกอิน
                      }
                      print(res);
                    },
                    child: const Text("Sign up"),
                  ),
                  TextButton(
                    onPressed: () async {
                      var res = await AuthService().signin(
                        email: _emailController.text,
                        password: _passwordController.text,
                      );
                      if (res == 'success') {
                        // ไปที่หน้าแอปหลัก
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (context) =>
                                MyHomePage(title: 'Income & Expense Tracker'),
                          ),
                        );
                      } else {
                        // แสดงข้อผิดพลาด
                        setState(() {
                          _errorMessage = res; // อัปเดตข้อความข้อผิดพลาด
                        });
                      }
                      print(res);
                    },
                    child: const Text("Sign in"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
