import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color backgroundColor;
  final Color textColor;
  final double height;
  final double borderRadius;
  final double fontSize;
  final FontWeight fontWeight;
  final double letterSpacing;
  final Widget? prefixIcon;
  final bool isLoading;

  /// New, optional — defaults keep old buttons visually similar
  /// while enabling the gradient look used across the app.
  final bool enabled;
  final bool showArrow;
  final Widget? suffixIcon;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.backgroundColor = const Color(0xffFF6B00),
    this.textColor = Colors.white,
    this.height = 50,
    this.borderRadius = 35,
    this.fontSize = 14,
    this.fontWeight = FontWeight.bold,
    this.letterSpacing = 1.5,
    this.prefixIcon,
    this.isLoading = false,
    this.enabled = true,
    this.showArrow = true,
    this.suffixIcon,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDisabled = isLoading || !enabled;

    // Lighter shade of backgroundColor for the gradient's tail end.
    final Color lightShade = Color.lerp(
      backgroundColor,
      Colors.white,
      0.25,
    )!;

    return SizedBox(
      width: double.infinity,
      height: height,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: isDisabled
                ? [
              Colors.grey.shade300,
              Colors.grey.shade300,
            ]
                : [
              backgroundColor,
              backgroundColor,
              lightShade,
            ],
            stops: isDisabled ? null : const [0.0, 0.72, 1.0],
          ),
          borderRadius: BorderRadius.circular(borderRadius),
          boxShadow: isDisabled
              ? []
              : [
            BoxShadow(
              color: backgroundColor.withOpacity(0.22),
              blurRadius: 12,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: isDisabled ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            disabledBackgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(borderRadius),
            ),
          ),
          child: isLoading
              ? const SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.white,
            ),
          )
              : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (prefixIcon != null) ...[
                prefixIcon!,
                const SizedBox(width: 8),
              ],
              Text(
                text,
                style: TextStyle(
                  color: textColor,
                  fontSize: fontSize,
                  fontWeight: fontWeight,
                  letterSpacing: letterSpacing,
                ),
              ),
              if (suffixIcon != null) ...[
                const SizedBox(width: 9),
                suffixIcon!,
              ] else if (showArrow) ...[
                const SizedBox(width: 9),
                Icon(
                  Icons.arrow_forward_rounded,
                  color: textColor,
                  size: 16,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}