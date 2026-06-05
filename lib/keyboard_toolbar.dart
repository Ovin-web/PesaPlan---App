import 'package:flutter/material.dart';
import 'package:keyboard_visibility/keyboard_visibility.dart';

class KeyboardToolbarPage extends StatefulWidget {
  @override
  _KeyboardToolbarPageState createState() => _KeyboardToolbarPageState();
}

class _KeyboardToolbarPageState extends State<KeyboardToolbarPage> {
  KeyboardVisibilityNotification _keyboardVisibility = KeyboardVisibilityNotification();
  bool _keyboardVisible = false;

  @override
  void initState() {
    super.initState();
    _keyboardVisibility.addNewListener(onChange: (bool visible) {
      setState(() {
        _keyboardVisible = visible;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Keyboard Toolbar")),
      body: Column(
        children: [
          _keyboardVisible
              ? Text('Keyboard is visible, showing custom toolbar...')
              : Text('Showing default toolbar'),
          ElevatedButton(
            onPressed: () {
              // Toggle between keyboard and custom toolbar
            },
            child: Text('Toggle Toolbar'),
          ),
        ],
      ),
    );
  }
}
