import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Pagination extends StatefulWidget {
  Pagination({
    Key? key,
  }) : super(key: key);

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
          children: <Widget>[
            /// sizes our icon button
            Container(
              height: 25,
              width: 25,
              child: paginationController.currentPosition.value != 0
                  ? Material(
                      borderRadius: BorderRadius.circular(100),
                      color: Colors.white,
                      clipBehavior: Clip.hardEdge,
                      child: IconButton(
                        iconSize: 10,
                        color: Colors.black,
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () {
                          setState(
                            () {
                              paginationController.back.value = true;
                            },
                          );
                        },
                      ),
                    )
                  : null,
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

            /// sizes our icon button
            Container(
              height: 25,
              width: 25,
              child: Material(
                borderRadius: BorderRadius.circular(100),
                color: Colors.white,
                clipBehavior: Clip.hardEdge,
                child: IconButton(
                  iconSize: 10,
                  color: Colors.black,
                  icon: paginationController.currentPosition.value == 4
                      ? const Icon(Icons.check_rounded)
                      : const Icon(Icons.arrow_forward),
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
  /// the active page / dot within the totalDots
  RxInt currentPosition = 0.obs;

  /// is checked on icon button clicks and proceed() method within stepper.
  RxBool forward = false.obs;

  /// is checked on icon button clicks and proceed() method within stepper.
  RxBool back = false.obs;

  //todo: possibly set this value depending on how many steps are present
  int totalDots = 5;
}
