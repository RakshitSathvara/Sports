import 'package:flutter/material.dart';

@immutable
class ExpandableFab extends StatefulWidget {
  const ExpandableFab({
    super.key,
    this.initialOpen,
    required this.distance,
    required this.child,
  });

  final bool? initialOpen;
  final double distance;
  final Widget child;

  @override
  State<ExpandableFab> createState() => _ExpandableFabState();
}

class _ExpandableFabState extends State<ExpandableFab> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _expandAnimation;
  bool _open = false;

  @override
  void initState() {
    super.initState();
    _open = widget.initialOpen ?? false;
    _controller = AnimationController(
      value: _open ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      curve: Curves.fastOutSlowIn,
      reverseCurve: Curves.easeOutQuad,
      parent: _controller,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() {
      _open = !_open;
      if (_open) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.distance,
      width: 56.0,
      child: Stack(
        alignment: Alignment.bottomCenter,
        clipBehavior: Clip.none,
        children: [
          _buildExpandingActionButton(),
          Positioned(
            bottom: 0,
            child: FloatingActionButton(
              onPressed: _toggle,
              mini: false,
              backgroundColor: Color(0xFF006590),
              disabledElevation: 0,
              elevation: 0,
              clipBehavior: Clip.none,
              foregroundColor: Color(0xFF006590),
              splashColor: Color(0xFF006590),
              autofocus: false,
              hoverColor: Color(0xFF006590),
              child: Image.asset(
                !_open ? 'assets/images/ic_bottom_shop.png' : 'assets/images/ic_bottom_close.png',
                width: 30,
                height: 30,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpandingActionButton() {
    return AnimatedBuilder(
      animation: _expandAnimation,
      builder: (context, child) {
        return Positioned(
          bottom: 10.0 + (_expandAnimation.value * widget.distance),
          child: IgnorePointer(
            ignoring: _open,
            child: FadeTransition(
              opacity: _expandAnimation,
              child: child,
            ),
          ),
        );
      },
      child: widget.child,
    );
  }
}
