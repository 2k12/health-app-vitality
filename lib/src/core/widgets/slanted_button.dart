import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class SlantedButton extends StatefulWidget {
  final String text;
  final IconData? icon;
  final VoidCallback? onPressed;
  final bool isLoading;

  const SlantedButton({
    super.key,
    required this.text,
    this.icon,
    required this.onPressed,
    this.isLoading = false,
  });

  @override
  State<SlantedButton> createState() => _SlantedButtonState();
}

class _SlantedButtonState extends State<SlantedButton>
    with TickerProviderStateMixin {
  late AnimationController _pressController;
  late AnimationController _pulseController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _pulseAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _pressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _pressController, curve: Curves.easeInOut),
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pressController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = AppTheme.primaryColor;
    final Color secondaryColor = AppTheme.secondaryColor;

    return GestureDetector(
      onTapDown: (_) {
        setState(() => _isPressed = true);
        _pressController.forward();
      },
      onTapUp: (_) {
        setState(() => _isPressed = false);
        _pressController.reverse();
        if (widget.onPressed != null) widget.onPressed!();
      },
      onTapCancel: () {
        setState(() => _isPressed = false);
        _pressController.reverse();
      },
      child: AnimatedBuilder(
        animation: Listenable.merge([_pressController, _pulseController]),
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: SizedBox(
              height: 120,
              width: double.infinity,
              child: Stack(
                children: [
                  // Dynamic Glow Area
                  Positioned.fill(
                    child: CustomPaint(
                      painter: _GlowPainter(
                        primaryColor: primaryColor,
                        secondaryColor: secondaryColor,
                        pulseValue: _pulseAnimation.value,
                        isPressed: _isPressed,
                      ),
                    ),
                  ),

                  // The Rounded Rectangle Shape
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      gradient: LinearGradient(
                        colors: [
                          primaryColor.withOpacity(_isPressed ? 1.0 : 0.9),
                          secondaryColor.withOpacity(_isPressed ? 1.0 : 0.85),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      border: Border.all(
                        color: Colors.black.withOpacity(0.3),
                        width: 1.0,
                      ),
                      boxShadow: [
                        // Subtle internal shadow for depth
                        BoxShadow(
                          color: Colors.white.withOpacity(0.1),
                          offset: const Offset(0, 2),
                          blurRadius: 0,
                          spreadRadius: -1,
                        )
                      ],
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      alignment: Alignment.center,
                      child: widget.isLoading
                          ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if (widget.icon != null) ...[
                                  Icon(
                                    widget.icon,
                                    color: Colors.white,
                                    size: 32, // Slightly larger icon
                                  ),
                                  const SizedBox(width: 20),
                                ],
                                Text(
                                  widget.text.toUpperCase(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight
                                        .normal, // As requested by user
                                    letterSpacing: 2.0,
                                    fontSize: 18,
                                    shadows: [
                                      Shadow(
                                        color: Colors.black26,
                                        offset: Offset(0, 2),
                                        blurRadius: 4,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _GlowPainter extends CustomPainter {
  final Color primaryColor;
  final Color secondaryColor;
  final double pulseValue;
  final bool isPressed;

  _GlowPainter({
    required this.primaryColor,
    required this.secondaryColor,
    required this.pulseValue,
    required this.isPressed,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final RRect rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      const Radius.circular(24),
    );

    if (isPressed) {
      final glowPaint = Paint()
        ..color = primaryColor.withOpacity(0.4)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 25);
      canvas.drawRRect(rrect, glowPaint);
    } else {
      // Periodic Pulse Glow
      final pulsePaint = Paint()
        ..color = secondaryColor.withOpacity(0.2 * pulseValue)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, 15 * pulseValue);
      canvas.drawRRect(rrect, pulsePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _GlowPainter oldDelegate) {
    return oldDelegate.pulseValue != pulseValue ||
        oldDelegate.isPressed != isPressed;
  }
}
