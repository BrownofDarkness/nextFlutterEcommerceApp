import 'package:flutter/material.dart';

/// Applies a horizontal shimmer sweep to any child.
///
/// Technique: a repeating [AnimationController] drives a [ShaderMask] with a
/// [LinearGradient]. The `BlendMode.srcIn` blend means the shader's colors
/// replace the opaque pixels of the child — so a white [SkeletonBox] gets
/// painted with the sweeping gradient.
///
/// Wrap MULTIPLE [SkeletonBox]es in a single [Shimmer]: they will all pulse
/// in sync (one animation controller total, way cheaper and visually cleaner).
class Shimmer extends StatefulWidget {
  const Shimmer({required this.child, super.key});

  final Widget child;

  @override
  State<Shimmer> createState() => _ShimmerState();
}

class _ShimmerState extends State<Shimmer>
    with SingleTickerProviderStateMixin {
  // Calibrated for the dark theme: subtle contrast, no white flash.
  static const Color _base = Color(0xFF1D1D28);
  static const Color _highlight = Color(0xFF32323F);

  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      // `child` is passed through so it's not rebuilt on every animation tick.
      child: widget.child,
      builder: (context, child) {
        return ShaderMask(
          blendMode: BlendMode.srcIn,
          shaderCallback: (bounds) => LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: const [_base, _highlight, _base],
            stops: const [0.35, 0.5, 0.65],
            transform:
                _SlidingGradientTransform(slidePercent: _controller.value),
          ).createShader(bounds),
          child: child,
        );
      },
    );
  }
}

/// Translates the gradient horizontally as the animation progresses.
///
/// At 0.0 the highlight band sits just off-screen left; at 1.0 just off-screen
/// right. Multiplying by 2 and subtracting 1 remaps [0..1] to [-1..+1].
class _SlidingGradientTransform extends GradientTransform {
  const _SlidingGradientTransform({required this.slidePercent});

  final double slidePercent;

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) {
    return Matrix4.translationValues(
      bounds.width * (slidePercent * 2 - 1),
      0,
      0,
    );
  }
}

/// A filled rounded rectangle used as a shimmer placeholder for text lines,
/// image blocks, avatars, etc. Its own color is white and gets replaced by
/// the parent [Shimmer]'s shader.
class SkeletonBox extends StatelessWidget {
  const SkeletonBox({
    this.width,
    this.height,
    this.borderRadius = 8,
    super.key,
  });

  final double? width;
  final double? height;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }
}
