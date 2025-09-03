import 'dart:math';

import 'package:flutter/material.dart';

class UpdatePopup extends StatefulWidget {
  final VoidCallback no;
  final VoidCallback yes;
  final String title;
  final String description;

  const UpdatePopup({Key? key, required this.no, required this.yes, this.title = "Update Available", this.description = "Please update the application to continue."})
      : super(key: key);
  @override
  UpdatePopupState createState() => UpdatePopupState();
}

class UpdatePopupState extends State<UpdatePopup> {
  MediaQueryData get dimensions => MediaQuery.of(context);
  double get pixelRatio => dimensions.devicePixelRatio;
  Size get size => dimensions.size;
  double get height => size.height;
  double get width => size.width;
  double get radius => sqrt(pow(height, 2) + pow(width, 2));
  TextEditingController remarks = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: AlertDialog(
          contentPadding: EdgeInsets.zero,
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(15.0))),
          content: Container(
            height: 160,
            padding: const EdgeInsets.fromLTRB(0, 15, 0, 0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              color: Colors.white,
            ),
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(13, 0, 13, 0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Align(alignment: Alignment.center, child: Text(widget.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.black))),
                      const SizedBox(
                        height: 20,
                      ),
                      Text(
                        widget.description,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black),
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                    ],
                  ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: widget.no,
                          child: Container(
                            width: width,
                            height: 50,
                            decoration: BoxDecoration(
                                borderRadius: const BorderRadius.only(
                                  bottomLeft: Radius.circular(15),
                                ),
                                color: Colors.white,
                                border: Border.all(color: const Color(0xffDBDBDB), width: 1)),
                            child: const Center(
                              child: Text('Exit', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black)),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: widget.yes,
                          child: Container(
                            width: width,
                            height: 50,
                            decoration: BoxDecoration(
                                borderRadius: const BorderRadius.only(
                                  bottomRight: Radius.circular(15),
                                ),
                                color: Colors.white,
                                border: Border.all(color: const Color(0xffDBDBDB), width: 1)),
                            child: const Center(
                              child: Text('Update', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black)),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )),
    );
  }

  @override
  void initState() {
    super.initState();
  }
}
