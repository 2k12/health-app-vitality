import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class InfoCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color? iconColor;
  final VoidCallback? onTap;

  const InfoCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    this.iconColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Determine active color for this card
    final activeColor = iconColor ?? AppTheme.primaryColor;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: BackdropFilter(
            filter:
                ImageFilter.blur(sigmaX: 10, sigmaY: 10), // The Glass Effect
            child: Container(
              decoration: BoxDecoration(
                color: AppTheme.cardColor
                    .withOpacity(0.5), // Semi-transparent background
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: activeColor.withOpacity(0.2), // Subtle colored border
                  width: 1,
                ),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppTheme.cardColor.withOpacity(0.7),
                    AppTheme.cardColor.withOpacity(0.2),
                  ],
                ),
              ),
              child: Stack(
                children: [
                  // Decorative "Cyber" Corner
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        border: Border(
                          top: BorderSide(
                              color: activeColor.withOpacity(0.5), width: 2),
                          right: BorderSide(
                              color: activeColor.withOpacity(0.5), width: 2),
                        ),
                      ),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Row(
                      children: [
                        // Holographic Icon Container
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: activeColor.withOpacity(0.3),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: activeColor.withOpacity(0.1),
                                  blurRadius: 15,
                                  spreadRadius: -2,
                                ),
                              ]),
                          child: Icon(
                            icon,
                            color: activeColor,
                            size: 28,
                            shadows: [
                              Shadow(
                                color: activeColor.withOpacity(0.8),
                                blurRadius: 12,
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(width: 20),

                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                title.toUpperCase(),
                                style: TextStyle(
                                  color: Colors.grey[400],
                                  letterSpacing: 1.5,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Roboto',
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                value,
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20, // Slightly smaller but bolder
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.5,
                                    fontFamily: 'Roboto',
                                    // Add subtle text shadow for "screen" effect
                                    shadows: [
                                      Shadow(
                                        color: activeColor.withOpacity(0.5),
                                        blurRadius: 10,
                                      )
                                    ]),
                              ),
                            ],
                          ),
                        ),

                        if (onTap != null)
                          Icon(Icons.arrow_forward_ios_rounded,
                              color: activeColor.withOpacity(0.5), size: 16),
                      ],
                    ),
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
