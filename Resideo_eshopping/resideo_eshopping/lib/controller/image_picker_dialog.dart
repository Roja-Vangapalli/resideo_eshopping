
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:resideo_eshopping/controller/image_picker_handler.dart';

class ImagePickerDialog extends StatelessWidget {
  ImagePickerHandler _listener;
  AnimationController _controller;
  BuildContext context;
  ImagePickerDialog(this._controller);
  Animation<double> _drawerContentsOpacity;
  Animation<Offset> _drawerDetailsPosition;

 set listener(ImagePickerHandler listener){
   this._listener=listener;
 }

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
          
                  // child: roundedButton(
                  //     "Camera",
                  //     EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 0.0),
                  //     const Color(0xFF167F67),
                  //     const Color(0xFFFFFFFF)),
                ),
                const SizedBox(height: 5,),
                Text("Camera",style:TextStyle(color: Colors.white)),
                const SizedBox(height: 20,),
                new GestureDetector(
                  onTap: () => _listener.openGallery(),
                  child: new CircleAvatar(
                        radius: 30.0,
                        backgroundColor: Colors.transparent,
                        backgroundImage: AssetImage("assets/images/gallery.png"),
                      ),
                  // child: roundedButton(
                  //     "Gallery",
                  //     EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 0.0),
                  //     const Color(0xFF167F67),
                  //     const Color(0xFFFFFFFF)),
                ),
                const SizedBox(height: 5,),
                Text("GAllery",style: TextStyle(color: Colors.white)),
                const SizedBox(height: 20,),
                //const SizedBox(height: 15.0),
                 new GestureDetector(
                  onTap: () => _listener.removePicture(),
                  child: Image(image:AssetImage("assets/images/delete.png")),
                  // new CircleAvatar(
                  //       radius: 30.0,
                  //       backgroundColor: Colors.transparent,
                  //       backgroundImage: AssetImage("packages/resideo_eshopping/images/delete.png"),
                  //     ),
                  // // child: roundedButton(
                  //     "Gallery",
                  //     EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 0.0),
                  //     const Color(0xFF167F67),
                  //     const Color(0xFFFFFFFF)),
                ),
                const SizedBox(height: 5,),
                Text("Remove Photo",style: TextStyle(color: Colors.white)),
                const SizedBox(height: 20,),
                new GestureDetector(
                  onTap: () => dismissDialog(),
                  child: new Padding(
                    padding: EdgeInsets.fromLTRB(30.0, 0.0, 30.0, 0.0),
                    child: Icon(Icons.cancel),
                    //  child: new CircleAvatar(
                    //     radius: 20.0,
                    //     backgroundColor: const Color(0xFF778899),
                    //     backgroundImage: AssetImage("packages/resideo_eshopping/images/camera.png"),
                    //   ),
                    // child: roundedButton(
                    //     "Cancel",
                    //     EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 0.0),
                    //     const Color(0xFF167F67),
                    //     const Color(0xFFFFFFFF)),
                  ),
                ),
              ],
            ),
          ),
        ));
  }

  Widget roundedButton(
      String buttonLabel, EdgeInsets margin, Color bgColor, Color textColor) {
    var loginBtn = new Container(
      margin: margin,
      padding: EdgeInsets.all(15.0),
      alignment: FractionalOffset.center,
      decoration: new BoxDecoration(
        color: bgColor,
        borderRadius: new BorderRadius.all(const Radius.circular(100.0)),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: const Color(0xFF696969),
            offset: Offset(1.0, 6.0),
            blurRadius: 0.001,
          ),
        ],
      ),
      child: Text(
        buttonLabel,
        style: new TextStyle(
            color: textColor, fontSize: 20.0, fontWeight: FontWeight.bold),
      ),
    );
    return loginBtn;
  }
}