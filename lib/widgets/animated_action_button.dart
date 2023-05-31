import 'package:flutter/material.dart';

class AnimatedActionButton extends StatefulWidget {
  const AnimatedActionButton({Key? key, required this.action})
      : super(key: key);

  final dynamic action;

  @override
  AnimatedActionButtonState createState() => AnimatedActionButtonState();
}

class AnimatedActionButtonState extends State<AnimatedActionButton>
    with SingleTickerProviderStateMixin {
  AnimationController? _animationController;
  Animation<Color?>? _animateColor;
  Animation<double>? _animateIcon;
  final Curve _curve = Curves.easeOut;

  @override
  initState() {
    _animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500))
      ..addListener(() {
        setState(() {});
      });
    _animateIcon =
        Tween<double>(begin: 0.0, end: 1.0).animate(_animationController!);
    _animateColor = ColorTween(
      begin: Colors.indigo,
      end: Colors.red,
    ).animate(CurvedAnimation(
      parent: _animationController!,
      curve: Interval(
        0.00,
        1.00,
        curve: _curve,
      ),
    ));
    super.initState();
  }

  @override
  dispose() {
    _animationController!.dispose();
    super.dispose();
  }

  void animateForward() {
    _animationController!.forward();
  }

  void animateReverse() {
    _animationController!.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      backgroundColor: _animateColor!.value,
      onPressed: widget.action,
      child: AnimatedIcon(
        icon: AnimatedIcons.menu_close,
        progress: _animateIcon!,
      ),
    );
  }
}
