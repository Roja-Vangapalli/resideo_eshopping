import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'dart:io';
import 'package:resideo_eshopping/controller/image_picker_handler.dart';

class SignUp extends StatefulWidget{
  _SignUpState obj;
  @override
  State<StatefulWidget> createState() {
    obj=_SignUpState();
    return obj;
  }

}

class _SignUpState extends State<SignUp> with TickerProviderStateMixin,ImagePickerListener{
  static GlobalKey<FormState> _formKeyValue = new GlobalKey<FormState>();
  
  File _image;
  AnimationController _controler;
  ImagePickerHandler imagePicker;

  final _nameController =TextEditingController();
  final _emailController =TextEditingController();
  final _phoneController =TextEditingController();
  final _addressController =TextEditingController();
  final _zipcodeController =TextEditingController();
  final _passwordController =TextEditingController();
  
  showAlertDialog(BuildContext context) {
    // set up the buttons
    Widget cancelButton = FlatButton(
      child: Text("No"),
      onPressed: () {
        Navigator.pop(context);
      },
    );
    Widget continueButton = FlatButton(
      child: Text("Yes"),
      onPressed: () {}
      );
     

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Order Confrimation"),
      content: Text("Do you want to place order?"),
      actions: [
        cancelButton,
        continueButton,
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
  void initState()
  {
    super.initState();
    _controler=AnimationController(vsync: this,
    duration: const Duration(microseconds: 500));
    imagePicker=ImagePickerHandler(this._controler);
    imagePicker.listener=widget.obj;
    imagePicker.ipl=imagePicker;
    imagePicker.init();
  }

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
           _image == null
              ? new Center(
                child: Column(
                  children: <Widget>[
                    SizedBox(height: 30,),
                      new CircleAvatar(
    
                        radius: 80.0,
                        backgroundColor: Colors.transparent,
                        backgroundImage: AssetImage("packages/resideo_eshopping/images/user_profile.jpg"),
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
                      controller: _emailController,
                      decoration: const InputDecoration(
                        icon: const Icon(
                          FontAwesomeIcons.envelopeOpen,
                          color: Colors.blue,
                        ),
                        hintText: 'Ex: abc@xyz.com',
                        labelText: 'Email',
                      ),
                      validator: (val) {
                        Pattern pattern = r'^([a-zA-Z0-9_\-\.]+)@([a-zA-Z0-9_\-\.]+)\.([a-zA-Z]{2,5})$';
                        RegExp regex = new RegExp(pattern);
                        if (!regex.hasMatch(val))
                          return 'Enter Valid Email Id';
                        else
                          return null;
                      },
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
                    TextFormField(
                      controller: _passwordController,
                      decoration: const InputDecoration(
                        icon: const Icon(
                          FontAwesomeIcons.key,
                          color: Colors.blue,
                        ),
                       // hintText: 'Ex: 500000',
                        labelText: 'Password',
                      ),
                      validator: (val) {
                        if(val.isEmpty)
                        return 'Enter Valid Password';
                        else
                        if (val.length <= 8)
                          return 'Password must be atleast 8 charecters or longer';
                        else
                          return null;
                      },
                    ),
                    TextFormField(
                      decoration: const InputDecoration(
                        icon: const Icon(
                          FontAwesomeIcons.check,
                          color: Colors.blue,
                        ),
                       // hintText: 'Ex: 500000',
                        labelText: 'Confirm Password',
                      ),
                      validator: (val) {
                        if(val.isEmpty)
                        return 'Enter Password Again';
                        else
                        if (val != _passwordController.text)
                          return 'Password is not matching';
                        else
                          return null;
                      },
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: RaisedButton(
                        color: Colors.blue,
                        textColor: Colors.white,
                        child: Padding(
                            padding: EdgeInsets.all(10.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: <Widget>[
                                Text("Proceed",
                                    style: TextStyle(fontSize: 24.0)),
                              ],
                            )),
                        onPressed: () {
                          if (_formKeyValue.currentState.validate()) {
                           
                            showAlertDialog(context);                            
                          }
                        },
                        shape: new RoundedRectangleBorder(
                            borderRadius: new BorderRadius.circular(30.0))),
                  ),
                ],
              ),
            ]
        ),
        ),
      ),
    );
  }
}
