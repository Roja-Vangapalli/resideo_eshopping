import 'package:resideo_eshopping/util/logger.dart' as logger;import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'dart:io';
import 'package:resideo_eshopping/controller/image_picker_handler.dart';
import 'package:resideo_eshopping/model/User.dart';
import 'package:resideo_eshopping/util/crud_operations.dart';
import 'package:after_layout/after_layout.dart';
import 'package:resideo_eshopping/util/logger.dart' as logger;


class SignUp extends StatefulWidget{
  SignUp(this.user,this.profile,this.userInfo);
  final FirebaseUser user;
  final VoidCallback profile;
  final User userInfo;
  @override
  State<StatefulWidget> createState() => _SignUpState();

}

class _SignUpState extends State<SignUp> with TickerProviderStateMixin,ImagePickerListener,AfterLayoutMixin<SignUp>{
  final _formKeyValue = new GlobalKey<FormState>();
  
  File _image;
  AnimationController _controler;
  ImagePickerHandler imagePicker;
  FirebaseDatabaseUtil firebaseDatabaseUtil;
  String _imageUrl;
  String _buttonName="";
  String _alertMessage="";
  bool _isEdit=false;
  User user;

  var _nameController =TextEditingController();
  var _phoneController =TextEditingController();
  var _addressController =TextEditingController();
  var _zipcodeController =TextEditingController();


  _fillUserDetail(){
    if(widget.userInfo != null)
      {
        _isEdit=true;
        _buttonName="Update Profile";
        _alertMessage="Updated";
        _nameController.text=widget.userInfo.name;
        _phoneController.text=widget.userInfo.phone;
        _addressController.text=widget.userInfo.address;
        _zipcodeController.text=widget.userInfo.zipcode;
        _imageUrl=widget.userInfo.imageUrl;
      }else {
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
  @override
  void afterFirstLayout(BuildContext context) {
    // Calling the same function "after layout" to resolve the issue.
    _controler=AnimationController(vsync: this,
    duration: const Duration(microseconds: 500));
    imagePicker=ImagePickerHandler(this,this._controler);
    imagePicker.init();
    firebaseDatabaseUtil = FirebaseDatabaseUtil();
    firebaseDatabaseUtil.initState();
    _fillUserDetail();
    
  }

  // @override
  // void initState()
  // {
  //   super.initState();
  //   _controler=AnimationController(vsync: this,
  //   duration: const Duration(microseconds: 500));
  //   imagePicker=ImagePickerHandler(this,this._controler);
  //   imagePicker.init();
  //   firebaseDatabaseUtil = FirebaseDatabaseUtil();
  //   firebaseDatabaseUtil.initState();
  //   _fillUserDetail();
  // }

  @override
  void dispose(){
    _controler.dispose();
    super.dispose();
  }

  @override
  userImage(File _image) {
   setState(() {
     this._image=_image;
   });
  }
  
  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      appBar: AppBar(
        title: Container(
          alignment: Alignment.center,
          child: Text("Resideo e-Shopping",
              style: TextStyle(
                color: Colors.white,
              )),
        ),
        actions: <Widget>[
           new IconButton(
             icon: new Icon(Icons.close),
            onPressed: () => widget.profile(),
           ),
         ],
        leading: new Container(),
      ),
      body: SafeArea(  
          child:Form(
          key: _formKeyValue,
          autovalidate: true,
          child: Column(
            children: <Widget>[
              GestureDetector(
        onTap: ()=> imagePicker.showDialog(context),
        child:
        (_imageUrl != null && _image == null)
              ? new Center(
                child: Column(
                  children: <Widget>[
                    SizedBox(height: 30,),
                      new CircleAvatar(
    
                        radius: 80.0,
                        backgroundColor: Colors.transparent,
                        backgroundImage: NetworkImage(_imageUrl),
                      ),
                  ],
                )
              )
              :(_image == null?
              new Center(
                  child: Column(
                    children: <Widget>[
                      SizedBox(height: 30,),
                      new CircleAvatar(

                        radius: 80.0,
                        backgroundColor: Colors.transparent,
                        backgroundImage: AssetImage("assets/images/user_profile.png"),
                      ),
                    ],
                  )
              )
              :
               new Center(
               child: Column(
               children: <Widget>[
                 SizedBox(height: 30,),
                //Image.file(_image,height: 10,width: 10),
                 new CircleAvatar(
                 radius: 80.0,
                 backgroundColor: const Color(0xFF778899),
                 backgroundImage: FileImage(_image),
               ),
              ],
             )
           )
      ),
              ),
       SizedBox(height: 30,),
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
                    SizedBox(height: 20,),
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
                          final  form=_formKeyValue.currentState;
                          if (form.validate()) {
                              form.save();
                              user=User(_nameController.text,_phoneController.text,_addressController.text,_zipcodeController.text);
                              if(_image != null)
                              firebaseDatabaseUtil.updateUserProfile(widget.user,_image,user,_isEdit).then((result){showAlertDialog(context);});
                              else
                                if(_isEdit)
                              firebaseDatabaseUtil.updateData(widget.user, user,null).then((result){showAlertDialog(context);});
                                else
                                  firebaseDatabaseUtil.sendData(widget.user, user,null).then((result){showAlertDialog(context);});

                          }
                        },
                        shape: new RoundedRectangleBorder(
                            borderRadius: new BorderRadius.circular(30.0))
                        ),
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
            ]
        ),
        ),
      ),
    );
   
  }
}
