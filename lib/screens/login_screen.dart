import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'home_screen.dart';
import 'child_profile_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  final emailController    = TextEditingController();
  final passwordController = TextEditingController();

  bool isLoading    = false;
  bool showPassword = false;
  bool isLogin      = true;
  String errorMessage = '';

  Future<void> handleLogin() async {
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      setState(() => errorMessage = 'Please fill in all fields');
      return;
    }

    setState(() { isLoading = true; errorMessage = ''; });

    final result = await ApiService.login(
      emailController.text.trim(),
      passwordController.text.trim(),
    );

    setState(() => isLoading = false);

    if (result['token'] != null) {
      final parentId = result['parent']['id'];
      final children = await ApiService.getChildren(parentId);

      if (children.isEmpty) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ChildProfileScreen(parentId: parentId),
          ),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      }
    } else {
      setState(() {
        errorMessage = result['error'] ?? 'Login failed. Try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: Color(0xFF3C3489),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [

                // ── TOP SECTION ──
                Padding(
                  padding: EdgeInsets.fromLTRB(24, 36, 24, 24),
                  child: Column(
                    children: [

                      // Logo
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          color: Color(0xFFE24B4A),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Icon(
                          Icons.play_circle_rounded,
                          color: Colors.white,
                          size: 40,
                        ),
                      ),

                      SizedBox(height: 14),

                      Text(
                        'KidLearn',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),

                      Text(
                        'Safe videos for your child',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFFAFA9EC),
                        ),
                      ),

                      SizedBox(height: 20),

                      // Tab switcher
                      Container(
                        decoration: BoxDecoration(
                          color: Color(0xFF26215C),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: EdgeInsets.all(4),
                        child: Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () => setState(() {
                                  isLogin = true;
                                  errorMessage = '';
                                  emailController.clear();
                                  passwordController.clear();
                                }),
                                child: Container(
                                  padding: EdgeInsets.symmetric(vertical: 9),
                                  decoration: BoxDecoration(
                                    color: isLogin
                                        ? Color(0xFFE24B4A)
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(9),
                                  ),
                                  child: Text(
                                    'Login',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                      color: isLogin
                                          ? Colors.white
                                          : Color(0xFFAFA9EC),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const RegisterScreen(),
                                    ),
                                  );
                                },
                                child: Container(
                                  padding: EdgeInsets.symmetric(vertical: 9),
                                  decoration: BoxDecoration(
                                    color: Colors.transparent,
                                    borderRadius: BorderRadius.circular(9),
                                  ),
                                  child: Text(
                                    'Register',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Color(0xFFAFA9EC),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                    ],
                  ),
                ),

                // ── FORM CARD ──
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(28),
                      topRight: Radius.circular(28),
                    ),
                  ),
                  padding: EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      Text(
                        'Welcome back!',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF26215C),
                        ),
                      ),

                      Text(
                        'Sign in to your parent account',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),

                      SizedBox(height: 24),

                      // Email
                      Text('Email', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: Color(0xFF3C3489))),
                      SizedBox(height: 6),
                      TextField(
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          hintText: 'Enter your email',
                          hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
                          prefixIcon: Icon(Icons.email_outlined, color: Color(0xFFE24B4A), size: 20),
                          filled: true,
                          fillColor: Color(0xFFF5F5F5),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        ),
                      ),

                      SizedBox(height: 14),

                      // Password
                      Text('Password', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: Color(0xFF3C3489))),
                      SizedBox(height: 6),
                      TextField(
                        controller: passwordController,
                        obscureText: !showPassword,
                        decoration: InputDecoration(
                          hintText: 'Enter your password',
                          hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
                          prefixIcon: Icon(Icons.lock_outlined, color: Color(0xFFE24B4A), size: 20),
                          suffixIcon: GestureDetector(
                            onTap: () => setState(() => showPassword = !showPassword),
                            child: Icon(
                              showPassword ? Icons.visibility_off : Icons.visibility,
                              color: Colors.grey, size: 20,
                            ),
                          ),
                          filled: true,
                          fillColor: Color(0xFFF5F5F5),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        ),
                      ),

                      SizedBox(height: 8),

                      // Forgot password
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          'Forgot password?',
                          style: TextStyle(fontSize: 11, color: Color(0xFFE24B4A)),
                        ),
                      ),

                      SizedBox(height: 6),

                      // Error message
                      if (errorMessage.isNotEmpty)
                        Container(
                          margin: EdgeInsets.only(bottom: 12),
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Color(0xFFFFEBEB),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.error_outline, color: Colors.red, size: 16),
                              SizedBox(width: 8),
                              Expanded(child: Text(errorMessage, style: TextStyle(color: Colors.red, fontSize: 12))),
                            ],
                          ),
                        ),

                      SizedBox(height: 8),

                      // Gradient Login Button
                      GestureDetector(
                        onTap: isLoading ? null : handleLogin,
                        child: Container(
                          width: double.infinity,
                          height: 52,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Color(0xFFE24B4A), Color(0xFF3C3489)],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Center(
                            child: isLoading
                                ? SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                                : Text(
                              'Login to KidLearn',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: 20),

                      Center(
                        child: GestureDetector(
                          onTap: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const RegisterScreen(),
                              ),
                            );
                          },
                          child: RichText(
                            text: TextSpan(
                              text: "Don't have an account? ",
                              style: TextStyle(color: Colors.grey, fontSize: 13),
                              children: [
                                TextSpan(
                                  text: 'Register here',
                                  style: TextStyle(
                                    color: Color(0xFFE24B4A),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: 20),

                    ],
                  ),
                ),

              ],
            ),
          ),
        ),
      ),
    );
  }
}

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

    setState(() { isLoading = true; errorMessage = ''; successMessage = ''; });

    final result = await ApiService.register(
      nameController.text.trim(),
      emailController.text.trim(),
      passwordController.text.trim(),
    );

    setState(() => isLoading = false);

    if (result['parentId'] != null) {
      setState(() => successMessage = 'Account created! You can now login.');
      await Future.delayed(Duration(seconds: 2));
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    } else {
      setState(() {
        errorMessage = result['error'] ?? 'Registration failed. Try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: Color(0xFF3C3489),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [

                Padding(
                  padding: EdgeInsets.fromLTRB(24, 36, 24, 24),
                  child: Column(
                    children: [

                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          color: Color(0xFFE24B4A),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Icon(Icons.play_circle_rounded, color: Colors.white, size: 40),
                      ),

                      SizedBox(height: 14),

                      Text('KidLearn', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white)),
                      Text('Safe videos for your child', style: TextStyle(fontSize: 12, color: Color(0xFFAFA9EC))),

                      SizedBox(height: 20),

                      // Tab switcher
                      Container(
                        decoration: BoxDecoration(
                          color: Color(0xFF26215C),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: EdgeInsets.all(4),
                        child: Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () => Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                                ),
                                child: Container(
                                  padding: EdgeInsets.symmetric(vertical: 9),
                                  decoration: BoxDecoration(
                                    color: Colors.transparent,
                                    borderRadius: BorderRadius.circular(9),
                                  ),
                                  child: Text('Login', textAlign: TextAlign.center,
                                      style: TextStyle(fontSize: 13, color: Color(0xFFAFA9EC))),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Container(
                                padding: EdgeInsets.symmetric(vertical: 9),
                                decoration: BoxDecoration(
                                  color: Color(0xFFE24B4A),
                                  borderRadius: BorderRadius.circular(9),
                                ),
                                child: Text('Register', textAlign: TextAlign.center,
                                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.white)),
                              ),
                            ),
                          ],
                        ),
                      ),

                    ],
                  ),
                ),

                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(28),
                      topRight: Radius.circular(28),
                    ),
                  ),
                  padding: EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      Text('Create account', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF26215C))),
                      Text('Register as a parent to get started', style: TextStyle(fontSize: 12, color: Colors.grey)),

                      SizedBox(height: 24),

                      Text('Full name', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: Color(0xFF3C3489))),
                      SizedBox(height: 6),
                      TextField(
                        controller: nameController,
                        decoration: InputDecoration(
                          hintText: 'Enter your full name',
                          hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
                          prefixIcon: Icon(Icons.person_outline, color: Color(0xFFE24B4A), size: 20),
                          filled: true,
                          fillColor: Color(0xFFF5F5F5),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        ),
                      ),

                      SizedBox(height: 14),

                      Text('Email', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: Color(0xFF3C3489))),
                      SizedBox(height: 6),
                      TextField(
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          hintText: 'Enter your email',
                          hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
                          prefixIcon: Icon(Icons.email_outlined, color: Color(0xFFE24B4A), size: 20),
                          filled: true,
                          fillColor: Color(0xFFF5F5F5),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        ),
                      ),

                      SizedBox(height: 14),

                      Text('Password', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: Color(0xFF3C3489))),
                      SizedBox(height: 6),
                      TextField(
                        controller: passwordController,
                        obscureText: !showPassword,
                        decoration: InputDecoration(
                          hintText: 'Create a password',
                          hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
                          prefixIcon: Icon(Icons.lock_outlined, color: Color(0xFFE24B4A), size: 20),
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

                      SizedBox(height: 16),

                      if (errorMessage.isNotEmpty)
                        Container(
                          margin: EdgeInsets.only(bottom: 12),
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

                      if (successMessage.isNotEmpty)
                        Container(
                          margin: EdgeInsets.only(bottom: 12),
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

                      // Gradient Register Button
                      GestureDetector(
                        onTap: isLoading ? null : handleRegister,
                        child: Container(
                          width: double.infinity,
                          height: 52,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Color(0xFFE24B4A), Color(0xFF3C3489)],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Center(
                            child: isLoading
                                ? SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                : Text('Create Account', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
                          ),
                        ),
                      ),

                      SizedBox(height: 20),

                      Center(
                        child: GestureDetector(
                          onTap: () => Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => const LoginScreen()),
                          ),
                          child: RichText(
                            text: TextSpan(
                              text: 'Already have an account? ',
                              style: TextStyle(color: Colors.grey, fontSize: 13),
                              children: [
                                TextSpan(
                                  text: 'Login here',
                                  style: TextStyle(color: Color(0xFFE24B4A), fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: 20),

                    ],
                  ),
                ),

              ],
            ),
          ),
        ),
      ),
    );
  }
}