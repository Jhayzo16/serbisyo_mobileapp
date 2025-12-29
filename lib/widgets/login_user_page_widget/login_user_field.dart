import 'package:flutter/material.dart';

class LoginUserField extends StatefulWidget {
  final String hintText;
  final bool isPassword;
  final TextInputType keyboardType;

  const LoginUserField({
    super.key,
    required this.hintText,
    this.isPassword = false,
    this.keyboardType = TextInputType.text,
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
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              keyboardType: widget.keyboardType,
              obscureText: _obscure,
              decoration: InputDecoration(
                hintText: widget.hintText,
                hintStyle: const TextStyle(color: Color(0xFF9CA3AF)),
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
                color: const Color(0xFF9CA3AF),
              ),
              onPressed: () => setState(() => _obscure = !_obscure),
            )
          else
            const Icon(Icons.mail_outline, color: Color(0xFF9CA3AF)),
        ],
      ),
    );
  }
}

class LoginUserFields extends StatefulWidget {
  const LoginUserFields({super.key});

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
        const SizedBox(height: 8),
        const LoginUserField(
          hintText: 'Email Address',
          isPassword: false,
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 16),
        const LoginUserField(hintText: 'Password', isPassword: true),
        const SizedBox(height: 12),
        // Keep the row height equal to the field so checkbox aligns vertically
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
                  activeColor: const Color(0xFF2D6B7A),
                  checkColor: Colors.white,
                  onChanged: (v) => setState(() => _remember = v ?? false),
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'Remember Me',
                style: TextStyle(fontSize: 13, color: Color(0xFF374151)),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () {
                  // TODO: navigate to forgot password
                },
                child: const Text(
                  'Forgot Password?',
                  style: TextStyle(fontSize: 13, color: Color(0xFF25607A)),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
