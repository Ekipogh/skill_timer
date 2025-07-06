import 'package:flutter/material.dart';

class DialogTitleRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color? iconColor;
  final Color? backgroundColor;

  const DialogTitleRow({
    required this.icon,
    required this.title,
    this.iconColor,
    this.backgroundColor,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: backgroundColor ?? (iconColor ?? Colors.blue).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: iconColor ?? Colors.blue,
            size: 24,
          ),
        ),
        const SizedBox(width: 12),
        Text(title),
      ],
    );
  }
}

class InfoContainer extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;

  const InfoContainer({
    required this.icon,
    required this.text,
    required this.color,
    this.padding,
    this.borderRadius,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: borderRadius ?? BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: color.withOpacity(0.8),
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class WarningContainer extends InfoContainer {
  const WarningContainer({
    required String text,
    EdgeInsetsGeometry? padding,
    BorderRadius? borderRadius,
    super.key,
  }) : super(
          icon: Icons.warning,
          text: text,
          color: Colors.red,
          padding: padding,
          borderRadius: borderRadius,
        );
}

class TipContainer extends InfoContainer {
  const TipContainer({
    required String text,
    EdgeInsetsGeometry? padding,
    BorderRadius? borderRadius,
    super.key,
  }) : super(
          icon: Icons.lightbulb,
          text: text,
          color: Colors.blue,
          padding: padding,
          borderRadius: borderRadius,
        );
}

class SuccessContainer extends InfoContainer {
  const SuccessContainer({
    required String text,
    EdgeInsetsGeometry? padding,
    BorderRadius? borderRadius,
    super.key,
  }) : super(
          icon: Icons.check_circle,
          text: text,
          color: Colors.green,
          padding: padding,
          borderRadius: borderRadius,
        );
}
