import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Pagination extends StatefulWidget {
  Pagination({
    Key? key,
  }) : super(key: key);

  // final List<DotsIndicator> indicators;

  @override
  _PaginationState createState() => _PaginationState();
}

class _PaginationState extends State<Pagination> {
  double _currentPosition = 0.0;

  final _totalDots = 4;

  /// validates that we aren't trying to update the position to an index
  /// that is greater than total dots
  double _validPosition(double position) {
    if (position >= _totalDots) {
      return 0;
    }
    if (position < 0) {
      return _totalDots - 1.0;
    }
    return position;
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
          IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              print('pressed back');
              _updatePosition;
            },
          ),
          // ...widget.indicators,
          DotsIndicator(
            dotsCount: _totalDots,
            position: _currentPosition,
            axis: Axis.vertical,
            decorator: decorator,
          ),
          DotsIndicator(
            dotsCount: _totalDots,
            position: _currentPosition,
            axis: Axis.vertical,
            decorator: decorator,
          ),
          DotsIndicator(
            dotsCount: _totalDots,
            position: _currentPosition,
            axis: Axis.vertical,
            decorator: decorator,
          ),
          DotsIndicator(
            dotsCount: _totalDots,
            position: _currentPosition,
            axis: Axis.vertical,
            decorator: decorator,
          ),
          IconButton(
              icon: Icon(Icons.arrow_forward),
              onPressed: () {
                print('pressed forward');
                _updatePosition;
              })
        ],
      ),
    );
  }
}

// widget.indicators.map((DotsIndicator i) => i).toList()
