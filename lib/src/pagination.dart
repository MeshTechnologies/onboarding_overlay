import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Pagination extends StatefulWidget {
  Pagination({
    Key? key,
  }) : super(key: key);

  // final List<DotsIndicator> indicators;

  @override
  _PaginationState createState() => _PaginationState();
}

class _PaginationState extends State<Pagination> {
  PaginationController paginationController = Get.put(PaginationController());

  double _currentPosition = 0.0;

  final _totalDots = 4;

  /// validates that we aren't trying to update the position to an index
  /// that is greater than total dots
  double _validPosition(double position) {
    if (position >= _totalDots) {
      /// end onboarding
      print('done');
    } else if (position < 0) {
      print("can't go back");
    }
    return position;
    // if (position > _totalDots == false && position < 0 == false) {
    //   return
    // }
  }

  /// updates the current position
  void _updatePosition(double position) {
    setState(() => _currentPosition = _validPosition(position));
  }

  /// styles for dots
  static const DotsDecorator decorator = DotsDecorator(
    activeColor: Colors.red,
    // activeSize: Size.round(50.0),
    activeShape: RoundedRectangleBorder(),
  );

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Material(
            child: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () {
                print('pressed back');
                _currentPosition--;
                paginationController.back.value = true;
                _updatePosition(_currentPosition);
              },
            ),
          ),

          // ...widget.indicators,s
          DotsIndicator(
            dotsCount: _totalDots,
            position: _currentPosition,
            axis: Axis.horizontal,
            decorator: decorator,
          ),

          Material(
            child: IconButton(
                icon: Icon(Icons.arrow_forward),
                onPressed: () {
                  _currentPosition++;
                  paginationController.forward.value = true;
                  _updatePosition(_currentPosition);
                }),
          )
        ],
      ),
    );
  }
}

/// on click forward change forward to true && at the end of function we call when we listen for it, change to false.

class PaginationController extends GetxController {
  RxBool forward = false.obs;
  RxBool back = false.obs;
}

// widget.indicators.map((DotsIndicator i) => i).toList()
