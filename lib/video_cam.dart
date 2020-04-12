import 'dart:async';
import 'dart:io';
import 'package:cam_stack/main.dart';
import 'package:cam_stack/notif.dart';
import 'package:cam_stack/video_timer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:path/path.dart' show join;
import 'package:path_provider/path_provider.dart';

import 'components/display_image.dart';

class CameraApp extends StatefulWidget {
  const CameraApp({Key key}) : super(key: key);
  @override
  _CameraAppState createState() => _CameraAppState();
}

class _CameraAppState extends State<CameraApp>
    with AutomaticKeepAliveClientMixin {
  List<CameraDescription> cameras;
  Notifications notif;
  CameraController controller;
  Future<void> _initializeControllerFuture;
  DisplayPictureScreen san;
  int i = 0;
  int stopTimer = 0;
  Timer _timer;
  bool _isRecording = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final _timerKey = GlobalKey<VideoTimerState>();
  String path;

  @override
  void initState() {
    notif = Notifications();
    notif.initializing();
    _initializeControllerFuture = _initCamera();
    super.initState();
  }

  @override
  void dispose() {
    controller?.dispose();
    _timer.cancel();
    super.dispose();
  }

  Future<void> _initCamera() async {
    cameras = await availableCameras();
    controller = CameraController(cameras[1], ResolutionPreset.high);
    _initializeControllerFuture = controller.initialize();
  }

  void _scheduler() {
    const seconds = const Duration(seconds: 10);
    _timer = Timer.periodic(seconds, (timer) {
      if (stopTimer >= 5) {
        notif = Notifications(
            notifId: 2, notifDesc: "From Scheduler", notifTitle: "Close");
        notif.showNotifications();
        return timer.cancel();
      }
      notif = Notifications(
          notifId: 1,
          notifDesc: "From Scheduler ${stopTimer + 1} times",
          notifTitle: "Helo");
      notif.showNotifications();

      setState(() {
        stopTimer++;
      });
    });
  }

  String _timestamp() => DateTime.now().millisecondsSinceEpoch.toString();

  void _captureImage() async {
    if (controller.value.isInitialized) {
      final Directory extDir = await getApplicationDocumentsDirectory();
      final String dirPath = '${extDir.path}/media';
      await Directory(dirPath).create(recursive: true);
      final String filePath = '$dirPath/${_timestamp()}.jpeg';
      await controller.takePicture(filePath);
      setState(() {});
    }
  }

  Future<String> takePicture() async {
    cameras = await availableCameras();

    if (!controller.value.isInitialized) {
      return null;
    }
    final Directory extDir = await getApplicationDocumentsDirectory();
    final String dirPath = '${extDir.path}/Pictures/flutter_test';
    await Directory(dirPath).create(recursive: true);
    final String filePath = '$dirPath/${_timestamp()}.jpg';

    if (controller.value.isTakingPicture) {
      return null;
    }

    try {
      await controller.takePicture(filePath);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Homie(
            imagePath: path,
          ),
        ),
      );
    } on CameraException catch (e) {
      print(e);
      return null;
    }
    return filePath;
  }

  Future<String> startVideoRecording() async {
    print('startVideoRecording');
    if (!controller.value.isInitialized) {
      return null;
    }
    setState(() {
      _isRecording = true;
    });
    _timerKey.currentState.startTimer();
    //_timerKey.currentState.startTimer();

    final Directory extDir = await getApplicationDocumentsDirectory();
    final String dirPath = '${extDir.path}/media';
    await Directory(dirPath).create(recursive: true);
    final String filePath = '$dirPath/${_timestamp()}.mp4';

    if (controller.value.isRecordingVideo) {
      // A recording is already started, do nothing.
      setState(() {
        path = filePath;
      });
      return null;
    }

    try {
      await controller.startVideoRecording(filePath);
    } on CameraException catch (e) {
      return null;
    }
    print(filePath);
    return filePath;
  }

  Future<void> stopVideoRecording() async {
    print("Video recording stopped");
    if (!controller.value.isRecordingVideo) {
      return null;
    }
    _timerKey.currentState.stopTimer();
    setState(() {
      _isRecording = false;
    });

    try {
      await controller.stopVideoRecording();
    } on CameraException catch (e) {
      print(e);
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Capture the beauty"),
      ),
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            // If the Future is complete, display the preview.
            return Stack(
              alignment: FractionalOffset.center,
              children: <Widget>[
                Positioned.fill(
                  child: AspectRatio(
                      aspectRatio: controller.value.aspectRatio,
                      child: CameraPreview(controller)),
                ),
                Positioned.fill(
                  child: Opacity(
                    opacity: 0.3,
                    child: Image.asset(
                      'images/selfi_ktp_trans.png',
                      fit: BoxFit.fill,
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  child: Container(
                    color: Colors.white,
                    width: MediaQuery.of(context).size.width,
                    height: 0.2 * MediaQuery.of(context).size.height,
                    alignment: Alignment.center,
                    child: ClipOval(
                      child: Material(
                        color: Colors.black, // button color
                        child: InkWell(
                          splashColor: Colors.red, // inkwell color
                          child: SizedBox(
                            width: 56,
                            height: 56,
                            child: Icon(
                              _isRecording ? Icons.stop : Icons.videocam,
                              color: Colors.white,
                            ),
                          ),
                          onTap: () {
                            if (_isRecording) {
                              stopVideoRecording();
                            } else {
                              startVideoRecording();
                            }
                            print("Button tapped");
                            // _scheduler();
                            // notif = Notifications(
                            //     notifId: 1,
                            //     notifTitle: "Hello",
                            //     notifDesc: "You firing notif for $i times");
                            // notif.showNotifications();
                            setState(() {
                              i++;
                            });
                          },
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  top: 20.0,
                  child: VideoTimer(
                    key: _timerKey,
                  ),
                ),
              ],
            );
          } else {
            // Otherwise, display a loading indicator.
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
