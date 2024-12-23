import 'package:amazon_shop_on/features/auth/screens/reset_password_screen.dart';
import 'package:flutter/material.dart';
import 'package:amazon_shop_on/common/widgets/custom_button.dart';
import 'package:amazon_shop_on/common/widgets/custom_textfield.dart';
import 'package:amazon_shop_on/constants/global_variables.dart';
import 'package:amazon_shop_on/features/services/auth_service.dart';

enum Auth {
  signin,
  signup,
}

class AuthScreen extends StatefulWidget {
  static const String routeName = '/auth-screen';
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  Auth _auth = Auth.signin;
  final _signUpFormKey = GlobalKey<FormState>();
  final _signInFormKey = GlobalKey<FormState>();
  final AuthService authService = AuthService();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  bool _showPassword = false;

  @override
  void dispose() {
    super.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
  }

  void signUpUser() {
    authService.signUpUser(
      context: context,
      email: _emailController.text,
      password: _passwordController.text,
      name: _nameController.text,
    );
  }

  void signInUser() {
    authService.signInUser(
      context: context,
      email: _emailController.text,
      password: _passwordController.text,
    );
  }

  void signInWithGoogle() {
    authService.signInWithGoogle(context: context);
  }

  Widget _buildTabButton(String text, Auth authType) {
    final isSelected = _auth == authType;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _auth = authType),
        child: Column(
          children: [
            Text(
              text,
              style: TextStyle(
                fontSize: 16,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? GlobalVariables.secondaryColor : Colors.black54,
              ),
            ),
            const SizedBox(height: 4),
            Container(
              height: 2,
              decoration: BoxDecoration(
                color: isSelected ? GlobalVariables.secondaryColor : Colors.transparent,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              children: [
                // Logo Amazon
                Padding(
                  padding: const EdgeInsets.only(top: 20, bottom: 32),
                  child: Image.asset(
                    'assets/images/amazon_in.png',
                    height: 45,
                  ),
                ),

                // Toggle Login/Signup
                Row(
                  children: [
                    _buildTabButton('Login', Auth.signin),
                    _buildTabButton('Sign-up', Auth.signup),
                  ],
                ),

                const SizedBox(height: 32),

                // Login Form
                if (_auth == Auth.signin)
                  Form(
                    key: _signInFormKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        CustomTextfield(
                          controller: _emailController,
                          hintText: 'Email ID or phone number',
                          prefixIcon: Icon(Icons.email_outlined, color: Colors.grey[600]),
                        ),
                        const SizedBox(height: 16),
                        CustomTextfield(
                          controller: _passwordController,
                          hintText: 'Password',
                          obscureText: !_showPassword,
                          prefixIcon: Icon(Icons.lock_outline, color: Colors.grey[600]),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _showPassword ? Icons.visibility : Icons.visibility_off,
                              color: Colors.grey[600],
                            ),
                            onPressed: () => setState(() => _showPassword = !_showPassword),
                          ),
                        ),
                        Align(
  alignment: Alignment.centerRight,
  child: TextButton(
    onPressed: () {
      Navigator.pushNamed(context, ResetPasswordScreen.routeName);
    },
    style: TextButton.styleFrom(
      foregroundColor: Colors.grey[700],
    ),
    child: const Text(
      'Forgot password?',
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w500,
      ),
    ),
  ),
),
                        const SizedBox(height: 16),
                        CustomButton(
                          text: 'Login',
                          onTap: () {
                            if (_signInFormKey.currentState!.validate()) {
                              signInUser();
                            }
                          },
                        ),
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            Expanded(child: Divider(color: Colors.grey[300])),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: Text(
                                'Or',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            Expanded(child: Divider(color: Colors.grey[300])),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(25),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.1),
                                spreadRadius: 1,
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(25),
                              onTap: signInWithGoogle,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Image.asset(
                                      'assets/images/google_logo.png',
                                      height: 24,
                                    ),
                                    const SizedBox(width: 12),
                                    const Text(
                                      'Sign in with Google',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                // Signup Form
                if (_auth == Auth.signup)
                  Form(
                    key: _signUpFormKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        CustomTextfield(
                          controller: _nameController,
                          hintText: 'Full name',
                          prefixIcon: Icon(Icons.person_outline, color: Colors.grey[600]),
                        ),
                        const SizedBox(height: 16),
                        CustomTextfield(
                          controller: _emailController,
                          hintText: 'Email ID or phone number',
                          prefixIcon: Icon(Icons.email_outlined, color: Colors.grey[600]),
                        ),
                        const SizedBox(height: 16),
                        CustomTextfield(
                          controller: _passwordController,
                          hintText: 'Password',
                          obscureText: !_showPassword,
                          prefixIcon: Icon(Icons.lock_outline, color: Colors.grey[600]),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _showPassword ? Icons.visibility : Icons.visibility_off,
                              color: Colors.grey[600],
                            ),
                            onPressed: () => setState(() => _showPassword = !_showPassword),
                          ),
                        ),
                        const SizedBox(height: 24),
                        CustomButton(
                          text: 'Sign Up',
                          onTap: () {
                            if (_signUpFormKey.currentState!.validate()) {
                              signUpUser();
                            }
                          },
                        ),
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