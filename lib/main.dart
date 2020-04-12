import 'dart:io';

import 'package:cam_stack/video_cam.dart';
import 'package:flutter/material.dart';

void main() => runApp(Home());

class Home extends StatelessWidget {
  const Home({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: "Camera",
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      home: Homie(),
    );
  }
}

class Homie extends StatefulWidget {
  Homie({Key key, this.imagePath}) : super(key: key);
  final String imagePath;

  @override
  _HomieState createState() => _HomieState();
}

class _HomieState extends State<Homie> {
  Future _navigateToCamera() {
    return Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CameraApp(),
      ),
    );
  }

  Widget _buttonHelper() {
    return Center(
      child: Container(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              height: 50,
              margin: EdgeInsets.only(right: 20),
              child: RaisedButton(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0)),
                color: Colors.redAccent,
                onPressed: () {},
                child: const Text('Record video',
                    style: TextStyle(fontSize: 20, color: Colors.white)),
              ),
            ),
            Container(
              height: 50,
              child: RaisedButton(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0)),
                color: Colors.redAccent,
                onPressed: () async {
                  await _navigateToCamera();
                },
                child: const Text('Capture image',
                    style: TextStyle(fontSize: 20, color: Colors.white)),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _showImage() {
    return Container(
      width: 100,
      child:
          widget.imagePath == null ? null : Image.file(File(widget.imagePath)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Capture the beauty"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            _showImage(),
            _buttonHelper(),
          ],
        ),
      ),
    );
  }
}
