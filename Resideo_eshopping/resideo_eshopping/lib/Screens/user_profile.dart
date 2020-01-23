import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'package:resideo_eshopping/controller/image_picker_handler.dart';
import 'package:resideo_eshopping/model/User.dart';
import 'package:resideo_eshopping/model/user_repository.dart';
import 'package:resideo_eshopping/util/firebase_database_helper.dart';
import 'package:cached_network_image/cached_network_image.dart';

class SignUp extends StatefulWidget { 
  SignUp();
  @override 
  State<StatefulWidget> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp>
    with TickerProviderStateMixin, ImagePickerListener {
  final _formKeyValue = new GlobalKey<FormState>();
  File _image;
  AnimationController _controler;
  ImagePickerHandler imagePicker;
  FirebaseDatabaseUtil firebaseDatabaseUtil;
  String _imageUrl;
  String _buttonName = "";
  String _alertMessage = "";
  bool _isEdit = false;
  bool _deletePhotoButtonEnable=false;

  var _nameController = TextEditingController();
  var _phoneController = TextEditingController();
  var _addressController = TextEditingController();
  var _zipcodeController = TextEditingController();


  _fillUserDetail(UserRepository userRepository) {
    userRepository.getUserdetails();
    if (userRepository.userinfo != null) {
      _isEdit = true;
      _buttonName = "Update Profile";
      _alertMessage = "Updated";
      _nameController.text = userRepository.userinfo.name;
      _phoneController.text = userRepository.userinfo.phone;
      _addressController.text = userRepository.userinfo.address;
      _zipcodeController.text = userRepository.userinfo.zipcode;
      _imageUrl = userRepository.userinfo.imageUrl;
      if(_imageUrl != null)
        _deletePhotoButtonEnable=true;
    } else {
      _buttonName = "Create Profile";
      _alertMessage = "Created";
    }
  }

  showAlertDialog(BuildContext context) {
    // set up the buttons
    Widget cancelButton = FlatButton(
      child: Text("ok"),
      onPressed: () {
        Navigator.pop(context);
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Profile"),
      content: Text("Profile $_alertMessage Successful"),
      actions: [
        cancelButton,
        // continueButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  void _initializeImagePicker(UserRepository userRepository){
    imagePicker = ImagePickerHandler(this, this._controler, userRepository.user,_deletePhotoButtonEnable,userRepository.userinfo);
    imagePicker.init();
  }

  @override
     void initState() {
     super.initState();
     UserRepository user1 = Provider.of<UserRepository>(context,listen: false);
    _controler = AnimationController(
        vsync: this, duration: const Duration(microseconds: 500));
    _initializeImagePicker(user1);
    firebaseDatabaseUtil = FirebaseDatabaseUtil();
    firebaseDatabaseUtil.initState();
    _fillUserDetail(user1);
    
    
  }

  @override
  void dispose() {
    _controler.dispose();
    super.dispose();
  }

  @override
  userImage(File _image) {
    if(mounted){
    setState(() {
      this._image = _image;
      if (_image == null) {
        _imageUrl = null;
        _deletePhotoButtonEnable=false;
      }else
        {_deletePhotoButtonEnable = true;}
    });
  }
  }
  @override
  void didUpdateWidget(SignUp oldWidget) {
    super.didUpdateWidget(oldWidget);
    UserRepository user1 = Provider.of<UserRepository>(context,listen: false);
    _fillUserDetail(user1);
  }

  @override
  Widget build(BuildContext context) {
    UserRepository user1 = Provider.of<UserRepository>(context);
    return Scaffold(
      appBar: AppBar(
        title: Container(
          alignment: Alignment.center,
          child: Text("Resideo e-Shopping",
              style: TextStyle(
                color: Colors.white,
              )),
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKeyValue,
          autovalidate: true,
          child: Column(children: <Widget>[
            GestureDetector(
              onTap: () {_initializeImagePicker(user1);imagePicker.showDialog(context);},
              child: (_imageUrl != null && _image == null)
                  ? new Center(
                      child: Column(
                      children: <Widget>[
                        SizedBox(
                          height: 30,
                        ),
                        CachedNetworkImage(
                          imageUrl: _imageUrl,
                          imageBuilder: (context, imageProvider) => CircleAvatar(
                            radius: 80.0,
                            backgroundColor: Colors.transparent,
                            backgroundImage: imageProvider,
                          ),
                          placeholder: (context, url) => CircularProgressIndicator(),
                          errorWidget: (context, url, error) => Image.asset("assets/images/no_image_available.png"),
                        ),
                      ],
                    ))
                  : (_image == null
                      ? new Center(
                          child: Column(
                          children: <Widget>[
                            SizedBox(
                              height: 30,
                            ),
                            new CircleAvatar(
                              radius: 80.0,
                              backgroundColor: Colors.transparent,
                              backgroundImage:
                                  AssetImage("assets/images/user_profile.png"),
                            ),
                          ],
                        ))
                      : new Center(
                          child: Column(
                          children: <Widget>[
                            SizedBox(
                              height: 30,
                            ),
                            //Image.file(_image,height: 10,width: 10),
                            new CircleAvatar(
                              radius: 80.0,
                              backgroundColor: const Color(0xFF778899),
                              backgroundImage: FileImage(_image),
                            ),
                          ],
                        ))),
            ),
            SizedBox(
              height: 30,
            ),
            Flexible(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 15.0),
                children: <Widget>[
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      icon: const Icon(
                        FontAwesomeIcons.userCircle,
                        color: Colors.blue,
                      ),
                      hintText: 'Enter your Name',
                      labelText: 'Name',
                    ),
                    validator: (val) {
                      if (val.isEmpty) {
                        return 'Name field should not be empty';
                      } else {
                        return null;
                      }
                    },
                  ),
                  TextFormField(
                    controller: _phoneController,
                    decoration: const InputDecoration(
                      icon: const Icon(
                        FontAwesomeIcons.phone,
                        color: Colors.blue,
                      ),
                      hintText: 'Ex: 9700000000',
                      labelText: 'Phone',
                    ),
                    validator: (val) {
                      Pattern pattern = r'^(?:[+0]9)?[0-9]{10}$';
                      RegExp regex = new RegExp(pattern);
                      if (!regex.hasMatch(val))
                        return 'Enter Valid Phone Number';
                      else
                        return null;
                    },
                    keyboardType: TextInputType.number,
                  ),
                  TextFormField(
                    controller: _addressController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      icon: const Icon(
                        FontAwesomeIcons.home,
                        color: Colors.blue,
                      ),
                      labelText: 'Address',
                    ),
                    validator: (val) {
                      if (val.isEmpty)
                        return 'Address Field should not be empty';
                      else
                        return null;
                    },
                  ),
                  TextFormField(
                    controller: _zipcodeController,
                    decoration: const InputDecoration(
                      icon: const Icon(
                        FontAwesomeIcons.mapMarker,
                        color: Colors.blue,
                      ),
                      hintText: 'Ex: 500000',
                      labelText: 'Zip Code',
                    ),
                    validator: (val) {
                      Pattern pattern = r'^[1-9][0-9]{5}$';
                      RegExp regex = new RegExp(pattern);
                      if (!regex.hasMatch(val))
                        return 'Enter Valid ZipCode';
                      else
                        return null;
                    },
                    keyboardType: TextInputType.number,
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  RaisedButton(
                      color: Colors.blue,
                      textColor: Colors.white,
                      child: Padding(
                          padding: EdgeInsets.all(10.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: <Widget>[
                              Text(_buttonName,
                                  style: TextStyle(fontSize: 24.0)),
                            ],
                          )),
                      onPressed: () {
                        final form = _formKeyValue.currentState;
                        if (form.validate()) {
                          form.save();
                          user1.userInfo = User(
                              _nameController.text,
                              _phoneController.text,
                              _addressController.text,
                              _zipcodeController.text);
                          firebaseDatabaseUtil
                              .updateUserProfile(
                                  user1.user, _image, user1.userinfo, _isEdit)
                              .then((result) {
                            if (result) showAlertDialog(context);
                          });
                        }
                      },
                      shape: new RoundedRectangleBorder(
                          borderRadius: new BorderRadius.circular(30.0))),
                ],
              ),
            ),
            // Column(
            //   crossAxisAlignment: CrossAxisAlignment.stretch,
            //   children: <Widget>[
            //     Padding(
            //       padding: const EdgeInsets.all(8.0),
            //       child:
            //     ),
            //   ],
            // ),
          ]),
        ),
      ),
    );
  }
}
