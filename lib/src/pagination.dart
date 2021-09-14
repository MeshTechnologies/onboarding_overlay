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

  /// styles for dots
  static const DotsDecorator decorator = DotsDecorator(
    activeColor: Colors.white,
    activeShape: CircleBorder(),
  );

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Container(
        margin: const EdgeInsets.fromLTRB(10, 0, 20, 0),
        child: Row(
          // mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            Container(
              height: 35,
              width: 35,
              child: Material(
                borderRadius: BorderRadius.circular(100),
                color: Colors.white,
                clipBehavior: Clip.hardEdge,
                child: IconButton(
                  color: Colors.black,
                  icon: Icon(Icons.arrow_back),
                  onPressed: () {
                    setState(
                      () {
                        paginationController.back.value = true;
                      },
                    );
                  },
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.fromLTRB(10, 0, 10, 0),
              child: DotsIndicator(
                dotsCount: paginationController.totalDots,
                position: paginationController.currentPosition.value.toDouble(),
                axis: Axis.horizontal,
                decorator: decorator,
              ),
            ),
            Container(
              height: 35,
              width: 35,
              child: Material(
                borderRadius: BorderRadius.circular(100),
                color: Colors.white,
                clipBehavior: Clip.hardEdge,
                child: IconButton(
                  color: Colors.black,
                  icon: Icon(Icons.arrow_forward),
                  onPressed: () {
                    setState(
                      () {
                        paginationController.forward.value = true;
                      },
                    );
                  },
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class PaginationController extends GetxController {
  RxInt currentPosition = 0.obs;
  RxBool forward = false.obs;
  RxBool back = false.obs;
  //todo: possibly set this value depending on how many steps are present
  int totalDots = 5;
}
