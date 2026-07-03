import 'dart:math' as math;
import 'package:flutter/material.dart';

/// ─── Public API ─────────────────────────────────────────────────────────────
///
/// Usage:
///   CustomAlert.show(context, isSuccess: true);
///   CustomAlert.show(context, isSuccess: false);
///
class CustomAlert {
  static void show(BuildContext context, {required bool isSuccess}) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (_, __, ___) => const SizedBox.shrink(),
      transitionBuilder: (ctx, a1, a2, _) {
        final curve = Curves.easeOutBack.transform(a1.value);
        return Transform.scale(
          scale: curve,
          child: Opacity(
            opacity: a1.value.clamp(0.0, 1.0),
            child: AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              contentPadding: EdgeInsets.zero,
              content: _AlertContent(isSuccess: isSuccess),
            ),
          ),
        );
      },
    );
  }
}

/// ─── Alert content ──────────────────────────────────────────────────────────
class _AlertContent extends StatelessWidget {
  final bool isSuccess;
  const _AlertContent({required this.isSuccess});

  @override
  Widget build(BuildContext context) {
    const successColor = Color(0xFF2DD36F);
    const successTextColor = Color(0xFF1E7B3B);
    const failColor = Color(0xFFFF4949);
    const failTextColor = Color(0xFFA11D1D);

    final primaryColor = isSuccess ? successColor : failColor;
    final textColor = isSuccess ? successTextColor : failTextColor;
    final titleText = isSuccess ? 'Berhasil' : 'Gagal';
    final centerIcon =
        isSuccess ? Icons.check_rounded : Icons.close_rounded;

    return Container(
      width: 250,
      height: 280,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _AnimatedIcon(color: primaryColor, iconData: centerIcon),
          const SizedBox(height: 30),
          Text(
            titleText,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: textColor,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

/// ─── Spinning broken circle + scale-in icon ──────────────────────────────────
class _AnimatedIcon extends StatefulWidget {
  final Color color;
  final IconData iconData;
  const _AnimatedIcon({required this.color, required this.iconData});

  @override
  State<_AnimatedIcon> createState() => _AnimatedIconState();
}

class _AnimatedIconState extends State<_AnimatedIcon>
    with TickerProviderStateMixin {
  late final AnimationController _rotCtrl;
  late final AnimationController _scaleCtrl;
  late final Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();

    _rotCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();

    _scaleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _scaleAnim = CurvedAnimation(
      parent: _scaleCtrl,
      curve: Curves.elasticOut,
    );

    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _scaleCtrl.forward();
    });
  }

  @override
  void dispose() {
    _rotCtrl.dispose();
    _scaleCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 100,
      height: 100,
      child: Stack(
        alignment: Alignment.center,
        children: [
          RotationTransition(
            turns: _rotCtrl,
            child: CustomPaint(
              size: const Size(100, 100),
              painter: _BrokenCirclePainter(color: widget.color),
            ),
          ),
          ScaleTransition(
            scale: _scaleAnim,
            child: Icon(widget.iconData, size: 60, color: widget.color),
          ),
        ],
      ),
    );
  }
}

/// ─── CustomPainter for broken rotating circle ────────────────────────────────
class _BrokenCirclePainter extends CustomPainter {
  final Color color;
  const _BrokenCirclePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 8.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final radius = size.width / 2;
    final center = Offset(radius, radius);

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      math.pi / 4,       // start angle
      math.pi * 1.7,     // sweep angle (gap = 2π - 1.7π)
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}
