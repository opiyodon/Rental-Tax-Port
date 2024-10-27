import 'package:flutter/material.dart';

class CustomTextField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final IconData prefixIcon;
  final bool isPassword;
  final TextInputType? keyboardType;
  final FocusNode? focusNode;
  final FocusNode? nextFocusNode;
  final String? Function(String?)? validator;
  final int maxLength;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.prefixIcon,
    this.isPassword = false,
    this.keyboardType,
    this.focusNode,
    this.nextFocusNode,
    this.validator,
    this.maxLength = 100,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool _obscureText = true;
  bool _isFocused = false;
  final _formFieldKey = GlobalKey<FormFieldState>();

  @override
  void initState() {
    super.initState();
    widget.focusNode?.addListener(_handleFocusChange);
  }

  @override
  void dispose() {
    widget.focusNode?.removeListener(_handleFocusChange);
    super.dispose();
  }

  void _handleFocusChange() {
    if (mounted) {
      setState(() {
        _isFocused = widget.focusNode?.hasFocus ?? false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      key: _formFieldKey,
      controller: widget.controller,
      focusNode: widget.focusNode,
      obscureText: widget.isPassword ? _obscureText : false,
      keyboardType: widget.keyboardType,
      maxLength: widget.maxLength,
      onChanged: (value) {
        if (_formFieldKey.currentState != null) {
          _formFieldKey.currentState!.validate();
        }
      },
      decoration: InputDecoration(
        labelText: widget.label,
        prefixIcon: Icon(widget.prefixIcon),
        suffixIcon: widget.isPassword
            ? IconButton(
                icon: Icon(
                  _obscureText ? Icons.visibility : Icons.visibility_off,
                  color: _isFocused
                      ? Theme.of(context).colorScheme.primary
                      : Colors.grey,
                ),
                onPressed: () {
                  setState(() {
                    _obscureText = !_obscureText;
                  });
                },
              )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.error,
          ),
        ),
        filled: true,
        fillColor: Theme.of(context).cardColor,
        counterText: '', // Hide character counter
      ),
      validator: widget.validator ??
          (value) {
            if (value == null || value.isEmpty) {
              return '${widget.label} is required';
            }
            if (widget.isPassword && value.length < 8) {
              return 'Password must be at least 8 characters';
            }
            return null;
          },
      onFieldSubmitted: (_) {
        if (widget.nextFocusNode != null) {
          FocusScope.of(context).requestFocus(widget.nextFocusNode);
        }
      },
    );
  }
}
