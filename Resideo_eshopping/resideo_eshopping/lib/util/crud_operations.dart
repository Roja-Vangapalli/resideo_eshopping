import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:resideo_eshopping/model/product.dart';
import 'package:resideo_eshopping/model/User.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'package:resideo_eshopping/model/User.dart';
import 'package:after_layout/after_layout.dart';
import 'package:resideo_eshopping/util/logger.dart' as logger;

class FirebaseDatabaseUtil {
  static const String TAG ="FirebaseDatabaseUtil";
  DatabaseReference _productDBRef;
  DatabaseReference _userDBRef;

  FirebaseDatabase database = new FirebaseDatabase();
  DatabaseError error;
  Product product;
  User user;

  static final FirebaseDatabaseUtil _instance =
      new FirebaseDatabaseUtil.internal();

  FirebaseDatabaseUtil.internal();

  factory FirebaseDatabaseUtil() {
    return _instance;
  }

  void initState() {
    _productDBRef = database.reference().child("Products");
    _userDBRef = database.reference().child("Users");
    database.reference().child("Products").once().then((DataSnapshot snapshot) {
      logger.info(FirebaseDatabaseUtil.TAG, " Connected to second database and read " +snapshot.value );
//      print('Connected to second database and read ${snapshot.value}');
    });
    database.setPersistenceEnabled(true);
    database.setPersistenceCacheSizeBytes(10000000);
  }

  DatabaseError getError() {
    return error;
  }

  DatabaseReference getProductDB() {
    return _productDBRef;
  }

  void deleteProduct(Product product) async {
    await _productDBRef.child(product.id.toString()).remove().then((_) {
      logger.info(FirebaseDatabaseUtil.TAG, " Deleting the Product details in the Firbase " );

    });
  }

  updateProduct(Product product) async {
    int x = product.id;
    await _productDBRef.child((x - 1).toString()).update({
      "Inventory": product.quantity,
    }).then((_) {
      logger.info(FirebaseDatabaseUtil.TAG, " Updating the inventory in the Firbase " );

    });
  }

  Future sendData(FirebaseUser user,User userInfo,String _uploadFileUrl) async
  {
    await _userDBRef.child(user.uid.toString()).set({
      'name' : userInfo.name,
      'phone' : userInfo.phone,
      'address' : userInfo.address,
      'zipcode' : userInfo.zipcode,
      'imageUrl' : _uploadFileUrl
    }).then((result){
//      print("profile updated");
      logger.info(FirebaseDatabaseUtil.TAG, " Profile data send successfully to the Firebase " );
    }).catchError((onError){
      logger.error(FirebaseDatabaseUtil.TAG, " Error in sending the Data to  the Firbase " +onError);
//      print(onError);
    });
  }

  Future updateData(FirebaseUser user,User userInfo,String _uploadFileUrl) async
  {
    if(_uploadFileUrl != null) {
      await _userDBRef.child(user.uid.toString()).update({
        'name': userInfo.name,
        'phone': userInfo.phone,
        'address': userInfo.address,
        'zipcode': userInfo.zipcode,
        'imageUrl': _uploadFileUrl
      }).then((result) {
        logger.info(FirebaseDatabaseUtil.TAG, " Profile Updated successfully in updateData " );
//        print("profile updated");
      }).catchError((onError) {
        logger.error(FirebaseDatabaseUtil.TAG, " Error in sending the data to the Firbase while updateData  " +onError);
//        print(onError);
      });
    }else
      {
        await _userDBRef.child(user.uid.toString()).update({
          'name': userInfo.name,
          'phone': userInfo.phone,
          'address': userInfo.address,
          'zipcode': userInfo.zipcode,
        }).then((result) {
//          print("profile updated");
          logger.info(FirebaseDatabaseUtil.TAG, " Profile Updated successfully  " );
        }).catchError((onError) {
          logger.error(FirebaseDatabaseUtil.TAG, " Error in sending the Data to the Firbase  " +onError);
        });
      }
  }

  Future<User> getUserData(FirebaseUser _user) async
  {
    try{
    await _userDBRef.child(_user.uid.toString()).once().then((DataSnapshot snapshot){
      user=User.fromSnapshot(snapshot);
      logger.info(FirebaseDatabaseUtil.TAG, " Getting User data from the Firebase  " +_user.toString());
    });
    }catch(e){logger.error(FirebaseDatabaseUtil.TAG, " Error in getting the data to the Firbase  " +e);
//     print(e);
    }
    return user;
  }
 
 Future updateUserProfile(FirebaseUser user,File image,User userInfo,bool isEdit) async {
   StorageReference storageReference = FirebaseStorage.instance.ref().child("profile pic"+user.uid.toString());
   StorageUploadTask uploadTask = storageReference.putFile(image);   
   await uploadTask.onComplete;  
//   print('File Uploaded');
   logger.info(FirebaseDatabaseUtil.TAG, " File Uploaded Succesfully to Firebase Storage  " );
   storageReference.getDownloadURL().then((fileURL) {
     if(isEdit)
       updateData(user, userInfo, fileURL);
     else
       sendData(user, userInfo, fileURL);
   });    
 } 

}

 
