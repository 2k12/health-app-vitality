import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class PrimaryButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;

  const PrimaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
  });

  @override
  State<PrimaryButton> createState() => _PrimaryButtonState();
}

class _PrimaryButtonState extends State<PrimaryButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    if (!widget.isLoading && widget.onPressed != null) {
      if (mounted) {
        setState(() => _isPressed = true);
        _controller.forward();
      }
    }
  }

  void _onTapUp(TapUpDetails details) {
    if (!widget.isLoading && widget.onPressed != null) {
      if (mounted) {
        setState(() => _isPressed = false);
        _controller.reverse();
      }
      widget.onPressed!();
    }
  }

  void _onTapCancel() {
    if (!widget.isLoading && widget.onPressed != null) {
      if (mounted) {
        setState(() => _isPressed = false);
        _controller.reverse();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            width: double.infinity,
            height: 56,
            decoration: BoxDecoration(
              // Gradient for neon feel
              gradient: const LinearGradient(
                  colors: [AppTheme.primaryColor, AppTheme.secondaryColor],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  stops: [0.2, 1.0]),
              borderRadius: BorderRadius.circular(4), // Slightly rounded tech

              // Animated Glow Shadow
              boxShadow: [
                BoxShadow(
                  color:
                      AppTheme.primaryColor.withOpacity(_isPressed ? 0.8 : 0.4),
                  offset: const Offset(0, 0),
                  blurRadius: _isPressed ? 25 : 15,
                  spreadRadius: _isPressed ? 2 : 0,
                ),
                BoxShadow(
                    color: AppTheme.secondaryColor
                        .withOpacity(_isPressed ? 0.6 : 0.2),
                    offset: const Offset(4, 4),
                    blurRadius: 20,
                    spreadRadius: 1)
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTapDown: _onTapDown,
                onTapUp: _onTapUp,
                onTapCancel: _onTapCancel,
                // onTap is handled manually for animation purposes
                // but we need an onTap for accessibility if we wanted standard behavior.
                // However, GestureDetector logic is cleaner for custom press animations.
                onTap: () {},
                borderRadius: BorderRadius.circular(4),
                splashColor: Colors.white.withOpacity(0.2),
                highlightColor: Colors.transparent,
                child: Center(
                  child: widget.isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.black,
                          ),
                        )
                      : Text(
                          widget.text.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.black, // Dark text on bright neon
                            fontWeight: FontWeight.w900,
                            letterSpacing: 2.5,
                            fontSize: 16,
                            // Inherits Roboto from Theme
                          ),
                        ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
