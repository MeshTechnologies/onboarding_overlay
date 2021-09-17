import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:onboarding_overlay/src/pagination.dart';

import 'hole_painter.dart';
import 'step.dart';

class OnboardingStepper extends StatefulWidget {
  OnboardingStepper({
    Key? key,
    this.initialIndex = 0,
    required this.steps,
    this.duration = const Duration(milliseconds: 200),
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

  /// is required
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

  PaginationController paginationController = Get.put(PaginationController());

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

    /// Listens for changes of the forward value on the paginationController
    paginationController.forward.listen(
      (bool p0) {
        if (p0 == true) {
          EasyDebounce.debounce(
            'proceed back',
            const Duration(milliseconds: 500),
            () async => await proceed(),
          );
        }
      },
    );

    /// Listens for changes of the forward value on the paginationController
    paginationController.back.listen(
      (bool p0) {
        if (p0 == true) {
          if (paginationController.currentPosition.value != 0) {
            EasyDebounce.debounce(
              'proceed forwards',
              const Duration(milliseconds: 500),
              () async => await proceed(),
            );
          }
        }
      },
    );
    _holeTween = RectTween(
      begin: Rect.zero,
      end: Rect.zero,
    );
    _overlayColorTween = ColorTween(
      begin: const Color(0x00000000),
      end: const Color(0x00000000),
    );

    proceed(
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

  Future<void> proceed({bool init = false, int fromIndex = 0}) async {
    /// This mode variable is used to detect which direction we are moving for
    /// logic later on since we are setting our forward/back values to false right out the gate
    /// so that we don't need to separate the logic.
    String _mode = '';

    /// checks to see if user is proceeding or receding
    if (paginationController.back.value == true) {
      /// set the back value to false to reset.
      paginationController.back.value = false;

      /// ensures the currentPosition isn't set to negative number.
      if (paginationController.currentPosition.value != 0) {
        /// set the currentPosition to the previous position.
        paginationController.currentPosition.value = _index - 1;

        /// sets the mode to reverse
        _mode = 'reverse';
      }
    }

    /// checks to see if user is proceeding or receding
    if (paginationController.forward.value == true) {
      if (paginationController.currentPosition.value !=
          paginationController.totalDots - 1) {
        /// set the currentPosition to the next position
        paginationController.currentPosition.value++;

        /// set the forward value to false to reset.
        paginationController.forward.value = false;
      }

      /// sets the mode to forward
      _mode = 'forward';
    }
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

        /// moves our index to the next index to show the next screen when
        /// function is called and in forward mode
        if (_mode == 'forward') {
          if (_index < widget.steps.length - 1) {
            _index++;
          } else {
            /// ends  the onboarding when last screen is shown and forward is clicked
            widget.onEnd?.call(_index);
            return;
          }
        } else if (_mode == 'reverse') {
          /// moves our index to the previous index to show the previous screen when
          /// function is called and in reverse mode
          if (_index > 0) {
            _index--;
          }
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

      final OnboardingStep step = widget.steps[_index];
      if (!init) {
        await Future<void>.delayed(step.delay);
      }

      if (widget.stepIndexes.indexWhere(
              (int el) => el == paginationController.currentPosition.value) !=
          -1) {
        _prepare(step);
      }
      step.focusNode.requestFocus();
    }
  }

  double _getHorizontalPosition(OnboardingStep step, Size size) {
    final double boxWidth =
        step.fullscreen ? size.width * 0.8 : size.width * 0.55;
    if (_widgetRect != null) {
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
          return holeRect.bottom + 35;
        }
      } else {
        if (_widgetRect!.center.dy > size.height / 2) {
          return _widgetRect!.top - boxHeight;
        } else {
          return _widgetRect!.bottom + step.margin.bottom;
        }
      }
    } else {
      return size.height / 2 - boxHeight / 1.3;
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

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      // !I left this out bc if a user mis hits the back button it will go forward
      // onTap: () {
      //
      //   /// sets our forward value to true
      //   paginationController.forward.value = true;
      //   proceed();
      // },
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
          Positioned(top: 530, left: 530, child: Container(child: Pagination()))
        ],
      ),
    );
  }
}
