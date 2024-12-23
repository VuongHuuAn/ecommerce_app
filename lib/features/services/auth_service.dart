import 'dart:convert';
import 'package:amazon_shop_on/common/widgets/bottom_bar.dart';
import 'package:amazon_shop_on/constants/error_handling.dart';
import 'package:amazon_shop_on/constants/global_variables.dart';
import 'package:amazon_shop_on/constants/utils.dart';
import 'package:amazon_shop_on/features/admin/screens/admin_screen.dart';

import 'package:amazon_shop_on/features/auth/screens/auth_screen.dart';

import 'package:amazon_shop_on/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );

  // Helper function để hiển thị SnackBar
  void _showSnackBar(BuildContext context, String message,
      {bool isError = false}) {
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // Đăng ký người dùng
  void signUpUser({
    required BuildContext context,
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      // Encode user data
      final userJson = jsonEncode({
        'name': name,
        'email': email,
        'password': password,
      });

      http.Response res = await http.post(
        Uri.parse('$uri/api/signup'),
        body: userJson,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (!context.mounted) return;

      httpErrorHandle(
        response: res,
        context: context,
        onSuccess: () {
          // Chỉ hiển thị thông báo thành công
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Đăng ký tài khoản thành công!'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
      );
    } catch (e) {
      showSnackBar(context, e.toString());
    }
  }

  // Đăng nhập thông thường
  Future<void> signInUser({
    required BuildContext context,
    required String email,
    required String password,
  }) async {
    try {
      if (email.isEmpty || password.isEmpty) {
        _showSnackBar(context, 'Vui lòng nhập email và mật khẩu',
            isError: true);
        return;
      }

      final response = await http.post(
        Uri.parse('$uri/api/signin'),
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
      );

      if (!context.mounted) return;

      if (response.statusCode == 200) {
        await _handleAuthSuccess(context, response.body);
      } else {
        final errorMsg =
            jsonDecode(response.body)['error'] ?? 'Đăng nhập thất bại';
        _showSnackBar(context, errorMsg, isError: true);
      }
    } catch (e) {
      _showSnackBar(context, e.toString(), isError: true);
    }
  }

  // Xử lý sau khi đăng nhập thành công
  Future<void> _handleAuthSuccess(
      BuildContext context, String responseBody) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonResponse = jsonDecode(responseBody);

      if (jsonResponse['token'] == null) {
        throw Exception('Token không hợp lệ');
      }

      // Cập nhật UserProvider
      if (!context.mounted) return;
      Provider.of<UserProvider>(context, listen: false).setUser(responseBody);

      // Lưu token
      await prefs.setString('x-auth-token', jsonResponse['token']);

      if (!context.mounted) return;

      // Hiển thị thông báo thành công
      _showSnackBar(context, 'Đăng nhập thành công!');

      // Delay một chút để hiển thị thông báo
      await Future.delayed(const Duration(milliseconds: 500));

      if (!context.mounted) return;

      // Điều hướng dựa vào loại user
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final routeName = userProvider.user.type == 'admin'
          ? AdminScreen.routeName
          : BottomBar.routeName;

      Navigator.pushNamedAndRemoveUntil(
        context,
        routeName,
        (route) => false,
      );
    } catch (e) {
      showSnackBar(context, e.toString());
    }
  }

  // Đăng nhập với Google
  Future<void> signInWithGoogle({required BuildContext context}) async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return;

      final googleAuth = await googleUser.authentication;
      final idToken = googleAuth.idToken;

      if (idToken == null) {
        throw Exception('Không thể lấy token từ Google');
      }

      final response = await http.post(
        Uri.parse('$uri/api/google-signin'),
        body: jsonEncode({
          'email': googleUser.email,
          'name': googleUser.displayName ?? '',
          'googleId': googleUser.id,
          'token': idToken,
        }),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
      );

      if (!context.mounted) return;

      if (response.statusCode == 200) {
        await _handleAuthSuccess(context, response.body);
      } else {
        final errorMsg =
            jsonDecode(response.body)['error'] ?? 'Đăng nhập Google thất bại';
        _showSnackBar(context, errorMsg, isError: true);
      }
    } catch (e) {
      _showSnackBar(context, e.toString(), isError: true);
    }
  }

  // Kiểm tra token và lấy dữ liệu user
  Future<void> getUserData(BuildContext context) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('x-auth-token');

      if (token == null) return;

      final tokenResponse = await http.post(
        Uri.parse('$uri/tokenIsValid'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'x-auth-token': token,
        },
      );

      final isValid = jsonDecode(tokenResponse.body);

      if (isValid == true) {
        final userResponse = await http.get(
          Uri.parse('$uri/'),
          headers: {
            'Content-Type': 'application/json; charset=UTF-8',
            'x-auth-token': token,
          },
        );

        if (!context.mounted) return;
        Provider.of<UserProvider>(context, listen: false)
            .setUser(userResponse.body);
      }
    } catch (e) {
      if (context.mounted) {
        _showSnackBar(context, e.toString(), isError: true);
      }
    }
  }

  // Đăng xuất
  Future<void> signOut(BuildContext context) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      await _googleSignIn.signOut();

      if (!context.mounted) return;

      Navigator.pushNamedAndRemoveUntil(
        context,
        '/auth-screen',
        (route) => false,
      );

      _showSnackBar(context, 'Đã đăng xuất thành công');
    } catch (e) {
      _showSnackBar(context, e.toString(), isError: true);
    }
  }

  // Thêm phương thức reset password
// Thêm phương thức quên mật khẩu
  Future<void> resetPassword({
    required BuildContext context,
    required String email,
    required String newPassword,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$uri/api/forgot-password'), // Sửa endpoint
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({
          'email': email,
          'newPassword': newPassword,
        }),
      );

      if (!context.mounted) return;

      if (response.statusCode == 200) {
        _showSnackBar(context, 'Đặt lại mật khẩu thành công!');
        Navigator.pushNamedAndRemoveUntil(
          context,
          AuthScreen.routeName,
          (route) => false,
        );
      } else {
        final errorMsg =
            jsonDecode(response.body)['msg'] ?? 'Đặt lại mật khẩu thất bại';
        _showSnackBar(context, errorMsg, isError: true);
      }
    } catch (e) {
      _showSnackBar(context, e.toString(), isError: true);
    }
  }
}
