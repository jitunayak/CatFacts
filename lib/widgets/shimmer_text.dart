import 'package:flutter/material.dart';

class ShimmerText extends StatefulWidget {
  final String text;
  const ShimmerText({super.key, required this.text});

  @override
  State<ShimmerText> createState() => _ShimmerTextState();
}

class _ShimmerTextState extends State<ShimmerText>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    );
    _animation = CurveTween(curve: Easing.linear).animate(controller);
    controller.forward();
    controller.repeat();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode =
        MediaQuery.of(context).platformBrightness == Brightness.dark;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (Rect bounds) {
            return LinearGradient(
              colors: isDarkMode
                  ? const [
                      Colors.transparent,
                      Colors.white,
                      Colors.transparent,
                      Colors.white,
                      Colors.transparent,
                    ]
                  : [
                      Colors.grey,
                      Colors.transparent,
                      Colors.grey,
                      Colors.transparent,
                      Colors.grey,
                    ],
              stops: [
                (_animation.value - 0.6).clamp(0.0, 1.0),
                (_animation.value - 0.3).clamp(0.0, 1.0),
                (_animation.value).clamp(0.0, 1.0),
                (_animation.value + 0.3).clamp(0.0, 1.0),
                (_animation.value + 0.6).clamp(0.0, 1.0),
              ],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ).createShader(bounds);
          },
          blendMode: BlendMode.srcATop,
          child: Text(
            widget.text,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        );
      },
    );
  }
}
