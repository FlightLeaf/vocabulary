import 'package:flutter/material.dart';
class CustomDropDownButton extends StatefulWidget {
  const CustomDropDownButton({Key? key}) : super(key: key);

  @override
  _CustomDropDownButtonState createState() => _CustomDropDownButtonState();
}

class _CustomDropDownButtonState extends State<CustomDropDownButton> {

  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: <Widget>[
        DropdownButton(items: [
          DropdownMenuItem(child: Text('北京')),
          DropdownMenuItem(child: Text('天津')),
          DropdownMenuItem(child: Text('河北'))
        ], onChanged: (value) {})
      ],
    );
  }
}