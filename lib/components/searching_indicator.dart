import 'package:flutter/material.dart';

class SearchingIndicator extends StatefulWidget {
  final Duration duration;
  final IconTheme? iconTheme;
  const SearchingIndicator({
    Key? key,
    this.duration = const Duration(milliseconds: 3000),
    this.iconTheme,
  }) : super(key: key);

  @override
  State<SearchingIndicator> createState() => SearchingIndicatorState();
}

class SearchingIndicatorState extends State<SearchingIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final CurvedAnimation _curvedAnimation;

  final _translateTween = TweenSequence(
    <TweenSequenceItem<Offset>>[
      TweenSequenceItem<Offset>(
        tween: Tween<Offset>(
          begin: Offset.zero,
          end: const Offset(3, 3),
        ).chain(
          CurveTween(
            curve: Curves.easeIn,
          ),
        ),
        weight: 1,
      ),
      TweenSequenceItem<Offset>(
        tween: Tween<Offset>(
          begin: const Offset(3, 3),
          end: const Offset(3, -3),
        ),
        weight: 1,
      ),
      TweenSequenceItem<Offset>(
        tween: Tween<Offset>(
          begin: const Offset(3, -3),
          end: const Offset(-3, -3),
        ),
        weight: 1,
      ),
      TweenSequenceItem<Offset>(
        tween: Tween<Offset>(
          begin: const Offset(-3, -3),
          end: const Offset(-3, 3),
        ),
        weight: 1,
      ),
      TweenSequenceItem<Offset>(
        tween: Tween<Offset>(
          begin: const Offset(-3, 3),
          end: Offset.zero,
        ).chain(
          CurveTween(
            curve: Curves.easeOut,
          ),
        ),
        weight: 1,
      ),
    ],
  );

  final _zRotationTween = TweenSequence(
    <TweenSequenceItem<double>>[
      TweenSequenceItem<double>(
        tween: Tween<double>(
          begin: 0,
          end: 0.3,
        ).chain(
          CurveTween(
            curve: Curves.easeInOut,
          ),
        ),
        weight: 1,
      ),
      TweenSequenceItem<double>(
        tween: Tween<double>(
          begin: 0.3,
          end: -0.2,
        ).chain(
          CurveTween(
            curve: Curves.easeInOut,
          ),
        ),
        weight: 1,
      ),
      TweenSequenceItem<double>(
        tween: Tween<double>(
          begin: -0.2,
          end: 0,
        ).chain(
          CurveTween(
            curve: Curves.easeInOut,
          ),
        ),
        weight: 1,
      ),
    ],
  );

  final _scaleTween = TweenSequence(
    <TweenSequenceItem<double>>[
      TweenSequenceItem<double>(
        tween: Tween<double>(
          begin: 0.99,
          end: 1.15,
        ).chain(
          CurveTween(
            curve: Curves.easeInOut,
          ),
        ),
        weight: 1,
      ),
      TweenSequenceItem<double>(
        tween: Tween<double>(
          begin: 1.15,
          end: 0.98,
        ).chain(
          CurveTween(
            curve: Curves.easeInOut,
          ),
        ),
        weight: 1,
      ),
    ],
  );

  @override
  void initState() {
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _curvedAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );

    _controller.repeat(reverse: true);
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    _curvedAnimation.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final translate = _translateTween.animate(
          _curvedAnimation,
        );

        final matrix = Matrix4.identity()
          ..translate(
            translate.value.dx,
            translate.value.dy,
          )
          ..scale(
            _scaleTween.animate(_curvedAnimation).value,
          )
          ..rotateZ(
            _zRotationTween.animate(_curvedAnimation).value,
          );

        return Transform(
          transform: matrix,
          child: child,
        );
      },
      child: const Icon(Icons.search),
    );
  }
}
