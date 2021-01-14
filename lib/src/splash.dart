import 'package:flutter/material.dart';

class Splash extends StatefulWidget {
  /// Creates a splash effect onTap, surrounding its [child] widget.
  ///
  /// The [child] parameter can not be null.
  /// The tap is disabled if the [onTap] parameter is null.
  Splash({
    Key key,
    @required this.child,
    this.splashColor,
    this.minRadius = defaultMinRadius,
    this.maxRadius = defaultMaxRadius,
  })  : assert(minRadius != null),
        assert(maxRadius != null),
        assert(minRadius > 0),
        assert(minRadius < maxRadius),
        super(key: key);

  /// Child widget. Could be anything that should be surrounded by the splash.
  ///
  /// The bigger the child the bigger the splash effect - which is constrained
  /// by the [minRadius] and [maxRadius]
  final Widget child;

  /// The color of the splash effect. The default [splashColor] is black.
  final Color splashColor;

  /// The minimum radius of the splash effect.
  /// Should be set if the [child] widget is very small to create a
  /// more desired effect.
  ///
  /// The default minimum radius is set to [defaultMinRadius]
  final double minRadius;

  /// The maximum radius of the splash effect.
  /// Regardless of how big the child widget is, the splash will not extend
  /// the [maxRadius]. Should be set if a larger splash effect is desired.
  ///
  /// The default maximum radius is set to [defaultMaxRadius]
  final double maxRadius;

  static const double defaultMinRadius = 50;
  static const double defaultMaxRadius = 120;

  @override
  _SplashState createState() => _SplashState();
}

class _SplashState extends State<Splash> with SingleTickerProviderStateMixin {
  AnimationController controller;
  Tween<double> radiusTween;
  Tween<double> borderWidthTween;
  Animation<double> radiusAnimation;
  Animation<double> borderWidthAnimation;
  AnimationStatus status;
  Offset _tapPosition;

  @override
  void initState() {
    controller =
        AnimationController(vsync: this, duration: Duration(milliseconds: 350))
          ..addStatusListener((AnimationStatus listener) {
            status = listener;
          });
    radiusTween = Tween<double>(begin: 0, end: 50);
    radiusAnimation = radiusTween
        .animate(CurvedAnimation(curve: Curves.ease, parent: controller));

    borderWidthTween = Tween<double>(begin: 25, end: 1);
    borderWidthAnimation = borderWidthTween.animate(
        CurvedAnimation(curve: Curves.fastOutSlowIn, parent: controller));

    super.initState();
  }

  void _animate() {
    controller.forward(from: 0);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void _handleTap(PointerUpEvent tapDetails) {
    final RenderBox renderBox = context.findRenderObject();
    _tapPosition = renderBox.globalToLocal(tapDetails.position);
    final double radius = (renderBox.size.width > renderBox.size.height)
        ? renderBox.size.width
        : renderBox.size.height;

    double constraintRadius;
    if (radius > widget.maxRadius) {
      constraintRadius = widget.maxRadius;
    } else if (radius < widget.minRadius) {
      constraintRadius = widget.minRadius;
    } else {
      constraintRadius = radius;
    }

    radiusTween.end = constraintRadius * 0.6;
    borderWidthTween.begin = radiusTween.end / 5;
    borderWidthTween.end = radiusTween.end * 0.01;
    _animate();
  }

  bool show = false;
  Offset lastVal = Offset(0, 0);

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
        animation: controller,
        builder: (_, child) {
          return CustomPaint(
            foregroundPainter: _SplashPaint(
              radius: radiusAnimation.value,
              borderWidth: borderWidthAnimation.value,
              status: status,
              tapPosition: _tapPosition,
              color: widget.splashColor ?? Colors.black,
            ),
            child: Listener(
              behavior: HitTestBehavior.opaque,
              child: widget.child,
              onPointerUp: show ? _handleTap : null,
              onPointerMove: (event) {
                if (event.position.dy != lastVal.dy ||
                    event.position.dx != lastVal.dx) {
                  show = false;
                  setState(() {

                  });
                }
              },
              onPointerDown: (event) {
                show = true;
                lastVal = event.position;
                setState(() {});
              },
            ),
          );
        });
  }
}

class _SplashPaint extends CustomPainter {
  _SplashPaint({
    @required this.radius,
    @required this.borderWidth,
    @required this.status,
    @required this.tapPosition,
    @required this.color,
  }) : blackPaint = Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = borderWidth;

  final double radius;
  final double borderWidth;
  final AnimationStatus status;
  final Offset tapPosition;
  final Color color;
  final Paint blackPaint;

  @override
  void paint(Canvas canvas, Size size) {
    if (status == AnimationStatus.forward) {
      canvas.drawCircle(tapPosition, radius, blackPaint);
    }
  }

  @override
  bool shouldRepaint(_SplashPaint oldDelegate) {
    if (radius != oldDelegate.radius) {
      return true;
    } else {
      return false;
    }
  }
}
