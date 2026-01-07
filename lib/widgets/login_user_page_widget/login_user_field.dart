import 'package:flutter/material.dart';

class LoginUserField extends StatefulWidget {
  final String hintText;
  final bool isPassword;
  final TextInputType keyboardType;
  final TextEditingController? controller;
  final TextInputAction? textInputAction;

  LoginUserField({
    super.key,
    required this.hintText,
    this.isPassword = false,
    this.keyboardType = TextInputType.text,
    this.controller,
    this.textInputAction,
  });

  @override
  State<LoginUserField> createState() => _LoginUserFieldState();
}

class _LoginUserFieldState extends State<LoginUserField> {
  bool _obscure = true;

  @override
  void initState() {
    super.initState();
    if (!widget.isPassword) _obscure = false;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: widget.controller,
              keyboardType: widget.keyboardType,
              textInputAction: widget.textInputAction,
              obscureText: _obscure,
              decoration: InputDecoration(
                hintText: widget.hintText,
                hintStyle: TextStyle(color: Color(0xFF9CA3AF)),
                border: InputBorder.none,
              ),
            ),
          ),
          if (widget.isPassword)
            IconButton(
              icon: Icon(
                _obscure
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: Color(0xFF9CA3AF),
              ),
              onPressed: () => setState(() => _obscure = !_obscure),
            )
          else
            Icon(Icons.mail_outline, color: Color(0xFF9CA3AF)),
        ],
      ),
    );
  }
}

class LoginUserFields extends StatefulWidget {
  final TextEditingController emailController;
  final TextEditingController passwordController;

  const LoginUserFields({
    super.key,
    required this.emailController,
    required this.passwordController,
  });
  @override
  State<LoginUserFields> createState() => _LoginUserFieldsState();
}

class _LoginUserFieldsState extends State<LoginUserFields> {
  bool _remember = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(height: 8),
        LoginUserField(
          hintText: 'Email Address',
          isPassword: false,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          controller: widget.emailController,
        ),
        SizedBox(height: 16),
        LoginUserField(
          hintText: 'Password',
          isPassword: true,
          textInputAction: TextInputAction.done,
          controller: widget.passwordController,
        ),
        SizedBox(height: 12),
      
        SizedBox(
          height: 56,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                height: 22,
                width: 22,
                child: Checkbox(
                  value: _remember,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                  activeColor: Color(0xFF2D6B7A),
                  checkColor: Colors.white,
                  onChanged: (v) => setState(() => _remember = v ?? false),
                ),
              ),
              SizedBox(width: 8),
              Text(
                'Remember Me',
                style: TextStyle(fontSize: 13, color: Color(0xFF374151)),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
