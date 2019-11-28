import 'package:flutter/widgets.dart';
import 'dart:io';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:async';
import 'package:resideo_eshopping/controller/image_picker_dialog.dart';

class ImagePickerHandler{

  AnimationController _controler;
  ImagePickerListener _listener;
  ImagePickerDialog imagePicker;
  ImagePickerHandler _ipl;

  set listener(ImagePickerListener listener){
    this._listener=listener;
  }
  set ipl(ImagePickerHandler ipl){
    this._ipl=ipl;
  }
  
  //ImagePickerHandler();
  ImagePickerHandler(this._controler);
  
   openCamera() async {
    imagePicker.dismissDialog();
    var image = await ImagePicker.pickImage(source: ImageSource.camera);
    cropImage(image);
  }

  openGallery() async {
    imagePicker.dismissDialog();
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);
    cropImage(image);
  }

  removePicture() async{
    imagePicker.dismissDialog();
      _listener.userImage(null);
  }

   Future cropImage(File image) async {
    File croppedFile = await ImageCropper.cropImage(
      sourcePath: image.path,
     // ratioX: 1.0,
     // ratioY: 1.0,
     // maxWidth: 512,
      //maxHeight: 512,
      aspectRatioPresets: [
        CropAspectRatioPreset.square,
        CropAspectRatioPreset.ratio3x2,
        CropAspectRatioPreset.original,
        CropAspectRatioPreset.ratio4x3,
        CropAspectRatioPreset.ratio16x9
      ],
      androidUiSettings: AndroidUiSettings(
          toolbarTitle: 'Cropper',
         // toolbarColor: Colors.deepOrange,
          //toolbarWidgetColor: Colors.white,
          initAspectRatio: CropAspectRatioPreset.original,
          lockAspectRatio: false),
    );
    _listener.userImage(croppedFile);
  }

  void init(){
   imagePicker= ImagePickerDialog(this._controler);
   imagePicker.listener=_ipl;
   imagePicker.initState();
  }

  void showDialog(BuildContext context){
   imagePicker.getImage(context);
  }

  
}
abstract class ImagePickerListener{
  userImage(File _image);
}