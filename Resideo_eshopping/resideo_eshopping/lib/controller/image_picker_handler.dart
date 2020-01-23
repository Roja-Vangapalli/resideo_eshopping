import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:resideo_eshopping/Screens/image_picker_dialog.dart';
import 'package:resideo_eshopping/util/firebase_database_helper.dart';
import 'package:resideo_eshopping/model/User.dart';
import 'package:resideo_eshopping/util/logger.dart' as logger;


class ImagePickerHandler{
  static const String TAG ="ImagePickerHandler";
  AnimationController _controler;
  ImagePickerListener _listener;
  ImagePickerDialog imagePicker;
  FirebaseUser _user;
  FirebaseDatabaseUtil _firebaseDatabaseUtil;
  User _userInfo;
  bool _deletePhotoButtonEnable;
  ImagePickerHandler(this._listener,this._controler,this._user,this._deletePhotoButtonEnable,this._userInfo);
  
   openCamera() async {
    imagePicker.dismissDialog();
    await ImagePicker.pickImage(source: ImageSource.camera).then((image){
      _listener.userImage(image);
    }).catchError((error){
      logger.error(TAG, " Error in opening the camera : " + error);
    });

  }

  openGallery() async {
    imagePicker.dismissDialog();
    await ImagePicker.pickImage(source: ImageSource.gallery).then((image){
      _listener.userImage(image);
    }).catchError((error){
      logger.error(TAG, " Error in opening the gallery : " + error);
    });
  }

  removePicture() async{
    imagePicker.dismissDialog();
    await _firebaseDatabaseUtil.deleteProfilePicture(_user,_userInfo).then((result){
      if(result)
      _listener.userImage(null);
    }).catchError((error){
      logger.error(TAG, " Error in removing the image : " + error);
    });
  }

//   Future cropImage(File image) async {
//    await ImageCropper.cropImage(
//      sourcePath: image.path,
//      aspectRatioPresets: [
//        CropAspectRatioPreset.square,
//        CropAspectRatioPreset.ratio3x2,
//        CropAspectRatioPreset.original,
//        CropAspectRatioPreset.ratio4x3,
//        CropAspectRatioPreset.ratio16x9
//      ],
//      androidUiSettings: AndroidUiSettings(
//          toolbarTitle: 'Cropper',
//          initAspectRatio: CropAspectRatioPreset.original,
//          lockAspectRatio: false),
//    ).then((croppedFile){
//      _listener.userImage(croppedFile);
//    }).then((error){
//      logger.error(TAG, " Error in croping the image : " + error);
//    });
//
//  }

  void init(){
   _firebaseDatabaseUtil = FirebaseDatabaseUtil();
   imagePicker= ImagePickerDialog(this,this._controler,this._deletePhotoButtonEnable);
   imagePicker.initState();
  }

  void showDialog(BuildContext context){
   imagePicker.getImage(context);
  }

  
}
abstract class ImagePickerListener{
  userImage(File _image);
}