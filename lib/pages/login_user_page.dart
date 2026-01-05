import 'package:flutter/material.dart';
import 'package:serbisyo_mobileapp/pages/home_page.dart';
import 'package:serbisyo_mobileapp/pages/provider_homepage.dart';
import 'package:serbisyo_mobileapp/pages/signup_provider.dart';
import 'package:serbisyo_mobileapp/pages/signup_user_page.dart';
import 'package:serbisyo_mobileapp/services/auth_service.dart';
import 'package:serbisyo_mobileapp/widgets/login_user_page_widget/login_user_button.dart';
import 'package:serbisyo_mobileapp/widgets/login_user_page_widget/login_user_field.dart';
import 'package:serbisyo_mobileapp/widgets/login_user_page_widget/login_user_logo_widget.dart';

class LoginUserPage extends StatefulWidget {
  const LoginUserPage({super.key});

  @override
  State<LoginUserPage> createState() => _LoginUserPageState();
}

class _LoginUserPageState extends State<LoginUserPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _auth = AuthService();

  bool _isLoading = false;
  bool _isUserMode = true;
  String? _loginError;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_isLoading) return;
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    if (email.isEmpty || password.isEmpty) {
      setState(() => _loginError = 'Enter email and password');
      return;
    }

    setState(() {
      _isLoading = true;
      _loginError = null;
    });
    try {
      await _auth.signInWithEmailPasswordCheckedRole(
        email: email,
        password: password,
        isProvider: !_isUserMode,
      );
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) =>
              _isUserMode ? const HomePage() : const ProviderHomepage(),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      final msg = authErrorMessage(e);
      setState(() {
        _loginError = (msg.trim().isEmpty || msg == 'Authentication failed.')
            ? 'Incorrect email or password.'
            : msg;
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _signUp() async {
    if (!_isUserMode) {
      Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (_) => const SignupProvider()));
      return;
    }

    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const SignupUserPage()));
  }

  Future<void> _forgotPassword() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Enter your email first')));
      return;
    }
    try {
      await _auth.sendPasswordResetEmail(email: email);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password reset email sent')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(authErrorMessage(e))));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              children: [
                SizedBox(height: MediaQuery.of(context).size.height * 0.12),
                LoginUserLogoWidget(
                  initialIsUser: _isUserMode,
                  onChanged: (isUser) => setState(() => _isUserMode = isUser),
                ),
                SizedBox(height: 24),
                if ((_loginError ?? '').trim().isNotEmpty) ...[
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      _loginError!,
                      style: const TextStyle(
                        color: Colors.red,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
                LoginUserFields(
                  emailController: _emailController,
                  passwordController: _passwordController,
                  onForgotPassword: _forgotPassword,
                ),
                LoginUserButton(
                  isLoading: _isLoading,
                  onLogin: _login,
                  onSignUp: _signUp,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
