import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class AuthTextField extends StatefulWidget {
  final String label;
  final String hint;
  final IconData prefixIcon;
  final bool isPassword;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final TextInputAction textInputAction;
  final VoidCallback? onSubmitted;

  const AuthTextField({
    super.key,
    required this.label,
    required this.hint,
    required this.prefixIcon,
    required this.controller,
    this.isPassword = false,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.textInputAction = TextInputAction.next,
    this.onSubmitted,
  });

  @override
  State<AuthTextField> createState() => _AuthTextFieldState();
}

class _AuthTextFieldState extends State<AuthTextField> {
  bool _obscure = true;
  bool _isFocused = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.label, style: AppTextStyles.labelLarge),
        const SizedBox(height: AppSpacing.s2),
        Focus(
          onFocusChange: (focused) => setState(() => _isFocused = focused),
          child: TextFormField(
            controller: widget.controller,
            obscureText: widget.isPassword && _obscure,
            keyboardType: widget.keyboardType,
            textInputAction: widget.textInputAction,
            validator: widget.validator,
            onFieldSubmitted: (_) => widget.onSubmitted?.call(),
            style: AppTextStyles.bodyLarge,
            decoration: InputDecoration(
              hintText: widget.hint,
              prefixIcon: Icon(
                widget.prefixIcon,
                color: _isFocused ? AppColors.accent500 : AppColors.primary300,
                size: 20,
              ),
              suffixIcon: widget.isPassword
                  ? IconButton(
                      icon: Icon(
                        _obscure
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        color: AppColors.primary300,
                        size: 20,
                      ),
                      onPressed: () => setState(() => _obscure = !_obscure),
                    )
                  : null,
              enabledBorder: OutlineInputBorder(
                borderRadius: AppRadius.lgBorder,
                borderSide: BorderSide(
                  color: AppColors.primary400.withValues(alpha: 0.4),
                ),
              ),
              focusedBorder: const OutlineInputBorder(
                borderRadius: AppRadius.lgBorder,
                borderSide: BorderSide(color: AppColors.accent500, width: 1.5),
              ),
              errorBorder: const OutlineInputBorder(
                borderRadius: AppRadius.lgBorder,
                borderSide: BorderSide(color: AppColors.error500),
              ),
              focusedErrorBorder: const OutlineInputBorder(
                borderRadius: AppRadius.lgBorder,
                borderSide: BorderSide(color: AppColors.error500, width: 1.5),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
