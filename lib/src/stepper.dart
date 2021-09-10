import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:onboarding_overlay/src/pagination.dart';

import 'hole_painter.dart';
import 'step.dart';

class OnboardingStepper extends StatefulWidget {
  OnboardingStepper({
    Key? key,
    this.initialIndex = 0,
    required this.steps,
    this.duration = const Duration(milliseconds: 350),
    this.onChanged,
    this.onEnd,
    this.stepIndexes = const <int>[],
  })  : assert(() {
          if (stepIndexes.isNotEmpty && !stepIndexes.contains(initialIndex)) {
            final List<DiagnosticsNode> information = <DiagnosticsNode>[
              ErrorSummary('stepIndexes should contain initialIndex'),
            ];

            throw FlutterError.fromParts(information);
          }
          return true;
        }()),
        super(key: key);

  /// is reqired
  final List<OnboardingStep> steps;

  /// By default, vali is 0
  final int initialIndex;

  /// By default stepIndexes os an empty array
  final List<int> stepIndexes;

  ///  `onChanged` is called everytime when the previous step has faded out,
  ///
  /// before the next step is shown with a value of the step index on which the user was
  final ValueChanged<int>? onChanged;

  /// `onEnd` is called when there are no more steps to transition to
  final ValueChanged<int>? onEnd;

  /// By default, the value is `Duration(milliseconds: 350)`
  final Duration duration;

  @override
  _OnboardingStepperState createState() => _OnboardingStepperState();
}

class _OnboardingStepperState extends State<OnboardingStepper>
    with SingleTickerProviderStateMixin {
  late int _index;
  late ColorTween _overlayColorTween;
  late AnimationController _controller;
  late Animation<double> _animation;
  late List<int> _stepIndexes;
  RectTween? _holeTween;
  Offset? _holeOffset;
  Rect? _widgetRect;

  @override
  void initState() {
    super.initState();
    _index = widget.initialIndex;
    _stepIndexes = List<int>.from(widget.stepIndexes);
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );
    _animation = const AlwaysStoppedAnimation<double>(0.0);
    _controller.addListener(() => setState(() {}));

    _holeTween = RectTween(
      begin: Rect.zero,
      end: Rect.zero,
    );
    _overlayColorTween = ColorTween(
      begin: const Color(0x00000000),
      end: const Color(0x00000000),
    );

    _proceed(
      init: true,
      fromIndex: widget.initialIndex,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _prepare(OnboardingStep step) {
    final RenderBox? box =
        step.focusNode.context?.findRenderObject() as RenderBox?;

    _holeOffset = box?.localToGlobal(Offset.zero);
    _widgetRect = box != null ? _holeOffset! & box.size : null;
    _holeTween = _widgetRect != null
        ? RectTween(
            begin: Rect.zero.shift(_widgetRect!.center),
            end: step.margin.inflateRect(_widgetRect!),
          )
        : null;
    _overlayColorTween = ColorTween(
      begin: step.overlayColor.withOpacity(_animation.value),
      end: step.overlayColor,
    );

    _animation = CurvedAnimation(curve: Curves.ease, parent: _controller);

    _controller.forward(from: 0.0);
  }

  Future<void> _proceed({bool init = false, int fromIndex = 0}) async {
    assert(() {
      if (widget.stepIndexes.isNotEmpty &&
          !widget.stepIndexes.contains(widget.initialIndex)) {
        final List<DiagnosticsNode> information = <DiagnosticsNode>[
          ErrorSummary('stepIndexes should contain initialIndex'),
        ];

        throw FlutterError.fromParts(information);
      }
      return true;
    }());
    if (widget.stepIndexes.isEmpty) {
      if (init) {
        _index = fromIndex != 0 ? fromIndex : 0;
      } else {
        await _controller.reverse();

        widget.onChanged?.call(_index);

        if (_index < widget.steps.length - 1) {
          _index++;
        } else {
          widget.onEnd?.call(_index);
          return;
        }
      }

      final OnboardingStep step = widget.steps[_index];
      if (_index > 0) {
        await Future<void>.delayed(step.delay);
      }
      if (_index < widget.steps.length && _index >= 0) {
        _prepare(step);
      }

      step.focusNode.requestFocus();
    } else {
      if (init) {
        _index = widget.initialIndex;
        _stepIndexes.removeAt(0);
      } else {
        await _controller.reverse();

        widget.onChanged?.call(_index);

        if (_stepIndexes.isEmpty) {
          widget.onEnd?.call(_index);
          return;
        }
        if (_stepIndexes.isNotEmpty) {
          _index = _stepIndexes.first;
          _stepIndexes.removeAt(0);
        }
      }

      // debugPrint('stepIndexes ${widget.stepIndexes} $_stepIndexes $_index');

      final OnboardingStep step = widget.steps[_index];
      if (!init) {
        await Future<void>.delayed(step.delay);
      }

      if (widget.stepIndexes.indexWhere((int el) => el == _index) != -1) {
        _prepare(step);
      }
      step.focusNode.requestFocus();
    }
  }

  double _getHorizontalPosition(OnboardingStep step, Size size) {
    final double boxWidth =
        step.fullscreen ? size.width * 0.8 : size.width * 0.55;
    if (_widgetRect != null) {
      // final Rect holeRect = step.margin.inflateRect(_widgetRect);
      if (step.fullscreen) {
        return (size.width - boxWidth) / 2;
      } else {
        if (_widgetRect!.center.dx > size.width / 2) {
          return _widgetRect!.right - boxWidth - 6;
        } else if (_widgetRect!.center.dx == size.width / 2) {
          return _widgetRect!.center.dx - boxWidth / 2;
        } else {
          return _widgetRect!.left + 10;
        }
      }
    } else {
      return size.width / 2 - boxWidth / 2;
    }
  }

  double _getVerticalPosition(OnboardingStep step, Size size) {
    final double boxHeight = size.height * 0.45;
    if (_widgetRect != null) {
      final Rect holeRect = step.margin.inflateRect(_widgetRect!);
      if (step.fullscreen) {
        if (holeRect.center.dy > size.height / 2) {
          return holeRect.top - boxHeight - step.margin.bottom * 2;
        } else {
          return holeRect.bottom + 16;
        }
      } else {
        if (_widgetRect!.center.dy > size.height / 2) {
          return _widgetRect!.top - boxHeight;
        } else {
          return _widgetRect!.bottom + step.margin.bottom;
        }
      }
    } else {
      return size.height / 2 - boxHeight / 2;
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final OnboardingStep step = widget.steps[_index];
    final double boxWidth =
        step.fullscreen ? size.width * 0.6 : size.width * 0.55;
    // final double boxHeight = size.width * 0.45;
    final TextTheme textTheme = Theme.of(context).textTheme;
    final TextStyle localTitleTextStyle =
        textTheme.headline5!.copyWith(color: step.titleTextColor);
    final TextStyle localBodyTextStyle =
        textTheme.bodyText1!.copyWith(color: step.bodyTextColor);

    //         final CupertinoTextThemeData textTheme =
    //     CupertinoTheme.of(context).textTheme;

    // final TextStyle localTitleTextStyle =
    //     textTheme.navLargeTitleTextStyle.copyWith(color: step.titleTextColor);
    // final TextStyle localBodyTextStyle =
    //     textTheme.textStyle.copyWith(color: step.bodyTextColor);
    //
    // double _currentPosition = 0.0;
    // void _updatePosition(double position) {
    //   setState(() => _currentPosition = _validPosition(position));
    // }
    //
    // const DotsDecorator decorator = DotsDecorator(
    //   activeColor: Colors.red,
    //   // activeSize: Size.round(50.0),
    //   activeShape: RoundedRectangleBorder(),
    // );
    //
    // List<DotsIndicator> paginationIndicators = [
    //   DotsIndicator(
    //       dotsCount: 4,
    //       position: _currentPosition,
    //       axis: Axis.vertical,
    //       decorator: decorator,
    // ];
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        _proceed();
      },
      child: Stack(
        children: <Widget>[
          CustomPaint(
            child: Container(),
            painter: HolePainter(
              fullscreen: step.fullscreen,
              shape: step.shape,
              overlayShape: step.overlayShape,
              center: _holeOffset,
              hole: _holeTween?.evaluate(_animation),
              animation: _animation.value,
              overlayColor: _overlayColorTween.evaluate(_animation),
            ),
          ),
          Positioned(
            left: _getHorizontalPosition(step, size),
            top: _getVerticalPosition(step, size),
            child: FadeTransition(
              opacity: _animation,
              child: Container(
                width: boxWidth,
                // height: boxHeight,
                padding: step.hasLabelBox ? step.labelBoxPadding : null,
                decoration: step.hasLabelBox ? step.labelBoxDecoration : null,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    if (step.image != null && step.image!.isNotEmpty)
                      Image.asset(step.image!,
                          width: step.imageWidth, height: step.imageHeight),
                    if (step.image != null && step.image!.isNotEmpty)
                      const SizedBox(
                        height: 15.0,
                        width: double.infinity,
                      ),
                    if (step.title != null)
                      Text(
                        step.title!,
                        style: step.titleTextStyle ?? localTitleTextStyle,
                        textAlign: TextAlign.left,
                      ),
                    const SizedBox(
                      height: 8.0,
                      width: double.infinity,
                    ),
                    if (step.bodyText != null)
                      Text(
                        step.bodyText!,
                        style: step.bodyTextStyle ?? localBodyTextStyle,
                      ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(child: Container(child: Pagination()))
        ],
      ),
    );
  }
}
