import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {

  final nameController     = TextEditingController();
  final emailController    = TextEditingController();
  final passwordController = TextEditingController();

  bool isLoading    = false;
  bool showPassword = false;
  String errorMessage  = '';
  String successMessage = '';

  Future<void> handleRegister() async {
    if (nameController.text.isEmpty ||
        emailController.text.isEmpty ||
        passwordController.text.isEmpty) {
      setState(() => errorMessage = 'Please fill in all fields');
      return;
    }

    setState(() {
      isLoading = true;
      errorMessage = '';
      successMessage = '';
    });

    final result = await ApiService.register(
      nameController.text.trim(),
      emailController.text.trim(),
      passwordController.text.trim(),
    );

    setState(() => isLoading = false);

    if (result['parentId'] != null) {
      setState(() {
        successMessage = 'Account created! You can now login.';
      });
      // Wait 2 seconds then go back to login
      await Future.delayed(Duration(seconds: 2));
      Navigator.pop(context);
    } else {
      setState(() {
        errorMessage = result['error'] ?? 'Registration failed. Try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF7F77DD),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              SizedBox(height: 20),

              // Back button
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Color(0xFF534AB7),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.arrow_back, color: Colors.white, size: 20),
                ),
              ),

              SizedBox(height: 24),

              // Logo
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        color: Color(0xFF534AB7),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Icon(Icons.play_circle_rounded, color: Colors.white, size: 42),
                    ),
                    SizedBox(height: 10),
                    Text('KidLearn', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                  ],
                ),
              ),

              SizedBox(height: 30),

              // Form card
              Container(
                padding: EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    Text('Create Account', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF3C3489))),
                    Text('Register as a parent to get started', style: TextStyle(fontSize: 12, color: Colors.grey)),

                    SizedBox(height: 24),

                    // Name
                    Text('Full Name', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFF3C3489))),
                    SizedBox(height: 6),
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        hintText: 'Enter your full name',
                        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
                        prefixIcon: Icon(Icons.person_outline, color: Color(0xFF7F77DD), size: 20),
                        filled: true,
                        fillColor: Color(0xFFF5F5F5),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      ),
                    ),

                    SizedBox(height: 16),

                    // Email
                    Text('Email', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFF3C3489))),
                    SizedBox(height: 6),
                    TextField(
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        hintText: 'Enter your email',
                        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
                        prefixIcon: Icon(Icons.email_outlined, color: Color(0xFF7F77DD), size: 20),
                        filled: true,
                        fillColor: Color(0xFFF5F5F5),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      ),
                    ),

                    SizedBox(height: 16),

                    // Password
                    Text('Password', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFF3C3489))),
                    SizedBox(height: 6),
                    TextField(
                      controller: passwordController,
                      obscureText: !showPassword,
                      decoration: InputDecoration(
                        hintText: 'Create a password',
                        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
                        prefixIcon: Icon(Icons.lock_outlined, color: Color(0xFF7F77DD), size: 20),
                        suffixIcon: GestureDetector(
                          onTap: () => setState(() => showPassword = !showPassword),
                          child: Icon(showPassword ? Icons.visibility_off : Icons.visibility, color: Colors.grey, size: 20),
                        ),
                        filled: true,
                        fillColor: Color(0xFFF5F5F5),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      ),
                    ),

                    SizedBox(height: 12),

                    // Error message
                    if (errorMessage.isNotEmpty)
                      Container(
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(color: Color(0xFFFFEBEB), borderRadius: BorderRadius.circular(8)),
                        child: Row(
                          children: [
                            Icon(Icons.error_outline, color: Colors.red, size: 16),
                            SizedBox(width: 8),
                            Expanded(child: Text(errorMessage, style: TextStyle(color: Colors.red, fontSize: 12))),
                          ],
                        ),
                      ),

                    // Success message
                    if (successMessage.isNotEmpty)
                      Container(
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(color: Color(0xFFE1F5EE), borderRadius: BorderRadius.circular(8)),
                        child: Row(
                          children: [
                            Icon(Icons.check_circle_outline, color: Color(0xFF1D9E75), size: 16),
                            SizedBox(width: 8),
                            Expanded(child: Text(successMessage, style: TextStyle(color: Color(0xFF085041), fontSize: 12))),
                          ],
                        ),
                      ),

                    SizedBox(height: 20),

                    // Register button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : handleRegister,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF1D9E75),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: isLoading
                            ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : Text('Create Account', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
                      ),
                    ),

                    SizedBox(height: 16),

                    Center(
                      child: GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: RichText(
                          text: TextSpan(
                            text: 'Already have an account? ',
                            style: TextStyle(color: Colors.grey, fontSize: 13),
                            children: [
                              TextSpan(
                                text: 'Login here',
                                style: TextStyle(color: Color(0xFF7F77DD), fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                  ],
                ),
              ),

              SizedBox(height: 30),

            ],
          ),
        ),
      ),
    );
  }
}