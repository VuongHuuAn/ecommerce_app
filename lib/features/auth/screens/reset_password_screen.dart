import 'package:amazon_shop_on/common/widgets/custom_button.dart';
import 'package:amazon_shop_on/common/widgets/custom_textfield.dart';
import 'package:amazon_shop_on/constants/global_variables.dart';
import 'package:amazon_shop_on/features/services/auth_service.dart';
import 'package:flutter/material.dart';

class ResetPasswordScreen extends StatefulWidget {
  static const String routeName = '/reset-password';
  const ResetPasswordScreen({Key? key}) : super(key: key);

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final AuthService authService = AuthService();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  bool _isLoading = false;
  bool _showNewPassword = false;
  bool _showConfirmPassword = false;

  @override
  void dispose() {
    _emailController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _resetPassword() async {
    if (_formKey.currentState!.validate()) {
      if (_newPasswordController.text != _confirmPasswordController.text) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Passwords do not match!'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      setState(() => _isLoading = true);

      await authService.resetPassword(
        context: context,
        email: _emailController.text,
        newPassword: _newPasswordController.text,
      );

      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: AppBar(
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: GlobalVariables.appBarGradient,
            ),
          ),
          title: const Text(
            'Forgot Password',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 20),
                  CustomTextfield(
                    controller: _emailController,
                    hintText: 'Email',
                    prefixIcon:
                        Icon(Icons.email_outlined, color: Colors.grey[600]),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  CustomTextfield(
                    controller: _newPasswordController,
                    hintText: 'New Password',
                    obscureText: !_showNewPassword,
                    prefixIcon:
                        Icon(Icons.lock_outline, color: Colors.grey[600]),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _showNewPassword
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: Colors.grey[600],
                      ),
                      onPressed: () =>
                          setState(() => _showNewPassword = !_showNewPassword),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter new password';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  CustomTextfield(
                    controller: _confirmPasswordController,
                    hintText: 'Confirm New Password',
                    obscureText: !_showConfirmPassword,
                    prefixIcon:
                        Icon(Icons.lock_outline, color: Colors.grey[600]),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _showConfirmPassword
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: Colors.grey[600],
                      ),
                      onPressed: () => setState(
                          () => _showConfirmPassword = !_showConfirmPassword),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please confirm new password';
                      }
                      if (value != _newPasswordController.text) {
                        return 'Passwords do not match';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  CustomButton(
                    text: _isLoading ? 'Processing...' : 'Reset Password',
                    onTap: () {
                      if (!_isLoading) {
                        _resetPassword();
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
