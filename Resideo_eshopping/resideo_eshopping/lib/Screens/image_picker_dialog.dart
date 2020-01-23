import 'dart:async';
import 'package:flutter/material.dart';
import 'package:resideo_eshopping/controller/image_picker_handler.dart';

class ImagePickerDialog extends StatelessWidget {
  final ImagePickerHandler _listener;
  final AnimationController _controller;
  BuildContext context;
  final bool _deletePhotoButtonEnable;
  ImagePickerDialog(
      this._listener, this._controller, this._deletePhotoButtonEnable);
  Animation<double> _drawerContentsOpacity;
  Animation<Offset> _drawerDetailsPosition;

  void initState() {
    _drawerContentsOpacity = new CurvedAnimation(
      parent: new ReverseAnimation(_controller),
      curve: Curves.fastOutSlowIn,
    );
    _drawerDetailsPosition = new Tween<Offset>(
      begin: const Offset(0.0, 1.0),
      end: Offset.zero,
    ).animate(new CurvedAnimation(
      parent: _controller,
      curve: Curves.fastOutSlowIn,
    ));
  }

  getImage(BuildContext context) {
    if (_controller == null ||
        _drawerDetailsPosition == null ||
        _drawerContentsOpacity == null) {
      return;
    }
    _controller.forward();
    showDialog(
      context: context,
      builder: (BuildContext context) => new SlideTransition(
        position: _drawerDetailsPosition,
        child: new FadeTransition(
          opacity: new ReverseAnimation(_drawerContentsOpacity),
          child: this,
        ),
      ),
    );
  }

  void dispose() {
    _controller.dispose();
  }

  startTime() async {
    var _duration = new Duration(milliseconds: 200);
    return new Timer(_duration, navigationPage);
  }

  void navigationPage() {
    Navigator.pop(context);
  }

  dismissDialog() {
    _controller.reverse();
    startTime();
  }

  dynamic _enableDisableDeletePhotoButton() {
    if (_deletePhotoButtonEnable) {
      return new Column(children: <Widget>[
        GestureDetector(
          onTap: () => _listener.removePicture(),
          child: Image(image: AssetImage("assets/images/delete.png")),
        ),
        const SizedBox(
          height: 5,
        ),
        Text("Remove Photo", style: TextStyle(color: Colors.white)),
      ]);
    } else {
      return SizedBox(height: 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    this.context = context;
    return new Material(
        type: MaterialType.transparency,
        child: new Opacity(
          opacity: 1.0,
          child: new Container(
            padding: EdgeInsets.fromLTRB(30.0, 0.0, 30.0, 20.0),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                new GestureDetector(

            onTap: () => _listener.openCamera(),
            child: new CircleAvatar(
              radius: 30.0,
              backgroundColor: Colors.transparent,
              backgroundImage: AssetImage("assets/images/camera.png"),
            ),
          ),
          const SizedBox(
            height: 5,
          ),
          Text("Camera", style: TextStyle(color: Colors.white)),
          const SizedBox(
            height: 20,
          ),
          new GestureDetector(
            onTap: () => _listener.openGallery(),
            child: new CircleAvatar(
              radius: 30.0,
              backgroundColor: Colors.transparent,
              backgroundImage: AssetImage("assets/images/gallery.png"),
            ),
          ),
          const SizedBox(
            height: 5,
          ),
          Text("GAllery", style: TextStyle(color: Colors.white)),
          const SizedBox(
            height: 20,
          ),
          _enableDisableDeletePhotoButton(),
          const SizedBox(
            height: 20,
          ),
          new GestureDetector(
            onTap: () => dismissDialog(),
            child: new Padding(
              padding: EdgeInsets.fromLTRB(30.0, 0.0, 30.0, 0.0),
              child: Icon(Icons.cancel),
            ),
          ),
        ],
      ),
    ),
    ));
  }
}
