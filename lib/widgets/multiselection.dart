import 'dart:collection';
import 'dart:io';
import 'package:flutter/material.dart';
import '../screens/products/MySubmitFormScreen.dart';

class GridItem extends StatefulWidget {
  final Key key;
  final dynamic item;
  final ValueChanged<bool> isSelected;

  GridItem({this.item, required this.isSelected, required this.key});

  @override
  _GridItemState createState() => _GridItemState();
}

class _GridItemState extends State<GridItem> {
  bool isSelected = false;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        setState(() {
          isSelected = !isSelected;
          widget.isSelected(isSelected);
        });
      },
      child: Stack(
        children: <Widget>[
          Image.file(
            File(widget.item), // Change this line
            color: Colors.black.withOpacity(isSelected ? 0.9 : 0),
            colorBlendMode: BlendMode.color,
          ),

          isSelected
              ? Align(
                  alignment: Alignment.bottomRight,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Icon(
                      Icons.check_circle,
                      color: Colors.blue,
                    ),
                  ),
                )
              : Container()
        ],
      ),
    );
  }
}
