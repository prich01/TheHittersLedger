import 'package:flutter/material.dart';
import '../services/cloud_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _isLogin = true; // This tracks if we are in Login or Register mode

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _handleForgotPassword() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      _showError("Please enter your email to reset password");
      return;
    }

    setState(() => _isLoading = true);
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      _showSuccess("Reset link sent! Check your inbox.");
    } catch (e) {
      _showError("Could not send reset link. Check the email address.");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleAuth() async {
    // Basic validation
    if (_emailController.text.trim().isEmpty || _passwordController.text.trim().isEmpty) {
      _showError("Please fill in all fields");
      return;
    }

    setState(() => _isLoading = true);
    try {
      if (_isLogin) {
        // Mode 1: Existing User
        await CloudService().login(
          _emailController.text.trim(),
          _passwordController.text.trim(),
        );
      } else {
        // Mode 2: New User
        await CloudService().register(
          _emailController.text.trim(),
          _passwordController.text.trim(),
        );
      }
    } catch (e) {
      _showError(e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1113),
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topCenter,
            radius: 1.5,
            colors: [
              Color(0xFF1A1D21),
              Color(0xFF0F1113),
            ],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // App Logo/Title
                const Icon(Icons.sports_baseball, size: 80, color: Color(0xFFD4AF37)),
                const SizedBox(height: 20),
                const Text(
                  "THE HITTER'S LEDGER",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFFD4AF37),
                    fontWeight: FontWeight.w900,
                    fontSize: 28,
                    letterSpacing: 3,
                  ),
                ),
                Text(
                  _isLogin ? "SECURE CLOUD ACCESS" : "CREATE YOUR LEDGER",
                  style: const TextStyle(color: Colors.white38, fontSize: 12, letterSpacing: 1),
                ),
                const SizedBox(height: 50),

                // Email Field
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  style: const TextStyle(color: Colors.white),
                  decoration: _buildInputDecoration("EMAIL ADDRESS", Icons.email_outlined),
                ),
                const SizedBox(height: 20),

                // Password Field
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  style: const TextStyle(color: Colors.white),
                  decoration: _buildInputDecoration("PASSWORD", Icons.lock_outline),
                ),

                // Forgot Password - Only shows in Login mode
                if (_isLogin)
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: _isLoading ? null : _handleForgotPassword,
                      child: const Text(
                        "Forgot Password?",
                        style: TextStyle(color: Colors.white38, fontSize: 12),
                      ),
                    ),
                  ),

                const SizedBox(height: 20),

                // Action Buttons
                if (_isLoading)
                  const CircularProgressIndicator(color: Color(0xFFD4AF37))
                else ...[
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD4AF37),
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        elevation: 5,
                      ),
                      onPressed: _handleAuth,
                      child: Text(
                        _isLogin ? "LOGIN" : "CREATE ACCOUNT", 
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _isLogin = !_isLogin; // Flips the mode
                      });
                    },
                    child: Text(
                      _isLogin ? "CREATE NEW ACCOUNT" : "ALREADY HAVE AN ACCOUNT? LOGIN",
                      style: const TextStyle(
                        color: Color(0xFFD4AF37), 
                        fontWeight: FontWeight.w400
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white38, fontSize: 12),
      prefixIcon: Icon(icon, color: const Color(0xFFD4AF37), size: 20),
      filled: true,
      fillColor: Colors.white.withOpacity(0.05),
      enabledBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.white10),
        borderRadius: BorderRadius.circular(8),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Color(0xFFD4AF37)),
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}