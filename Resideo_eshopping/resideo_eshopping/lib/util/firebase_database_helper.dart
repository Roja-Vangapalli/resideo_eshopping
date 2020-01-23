import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:resideo_eshopping/model/product.dart';
import 'package:resideo_eshopping/model/User.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'package:resideo_eshopping/util/logger.dart' as logger;

class FirebaseDatabaseUtil  {
  static const String TAG ="FirebaseDatabaseUtil";
  DatabaseReference _dbRef;
  FirebaseDatabase database;
  User user;

  static final FirebaseDatabaseUtil _instance =
      new FirebaseDatabaseUtil.internal();

  FirebaseDatabaseUtil.internal();

  factory FirebaseDatabaseUtil() {
    return _instance;
  }

  void initState() {
    
    database= new FirebaseDatabase();
    _dbRef = database.reference();
    // database=FirebaseDatabase.instance;
    // database.setPersistenceEnabled(true);
    // int intValue = int.parse('1000');
    // database.setPersistenceCacheSizeBytes(intValue);
  }

  Future<bool> updateProduct(Product product) async {
    bool isUpdateSuccessful=false;
    int x;
    if(product != null) {
      x = product.id;
      await _dbRef.child('Products').child((x).toString()).update({
        "Inventory": product.quantity,
      }).then((_) {
        isUpdateSuccessful=true;
        logger.info(FirebaseDatabaseUtil.TAG, " Updating the inventory in the Firbase " );
      }).catchError((error){
        logger.error(TAG, "Error in the updating inventory " +error);
      });
    }  else
    logger.info(TAG, "Product argument passed in update product is null");
    return isUpdateSuccessful;
  }

  Future<bool> deleteProfilePicture(FirebaseUser user,User userInfo) async {
    bool _isImageDeleted = false;
    if(user != null && userInfo.imageUrl != null){
    StorageReference storageReference = FirebaseStorage.instance
        .ref()
        .child("profile pic" + user.uid.toString());
    await storageReference.delete().then((result) async {
      await updateData(user, null, null, true).then((result) {
        _isImageDeleted = true;
      });
    }).catchError((error) {
      logger.error(TAG, "Error in the deleting Profile Picture " +error);
    });
    }else
      logger.info(TAG, "Firebase user passed in deleteProfilePicture is null");
    return _isImageDeleted;
  }

  Future sendData(
      FirebaseUser user, User userInfo, String _uploadFileUrl) async {
    if(user != null && userInfo != null) {
      await _dbRef.child('Users').child(user.uid.toString()).set({
        'name': userInfo.name,
        'phone': userInfo.phone,
        'address': userInfo.address,
        'zipcode': userInfo.zipcode,
        'imageUrl': _uploadFileUrl
      }).then((result) {
        logger.info(FirebaseDatabaseUtil.TAG, " Profile data send successfully to the Firebase " );
      }).catchError((onError) {
        logger.error(FirebaseDatabaseUtil.TAG, " Error in sending the Data to  the Firbase " +onError);
      });
    }else
      logger.error(FirebaseDatabaseUtil.TAG, " passed argument in senddata method in firebase_database_helper file in null " );
  }

  Future updateData(FirebaseUser user, User userInfo, String _uploadFileUrl,
      bool _deleteProfilePicture) async {
    if(user != null) {
      if (_deleteProfilePicture) {
        await _dbRef
            .child('Users')
            .child(user.uid.toString())
            .update({'imageUrl': _uploadFileUrl}).then((result) {
              logger.info(FirebaseDatabaseUtil.TAG, " ImageUrl deleted successfully  " );
        }).catchError((onError) {
          logger.error(FirebaseDatabaseUtil.TAG, " Error in deleting the ImageUrl   " +onError);
        });
      } else if (userInfo != null) {
        if (_uploadFileUrl != null) {
          await _dbRef.child('Users').child(user.uid.toString()).update({
            'name': userInfo.name,
            'phone': userInfo.phone,
            'address': userInfo.address,
            'zipcode': userInfo.zipcode,
            'imageUrl': _uploadFileUrl
          }).then((result) {
            logger.info(FirebaseDatabaseUtil.TAG, " Profile Updated successfully in updateData " );
          }).catchError((onError) {
            logger.error(FirebaseDatabaseUtil.TAG, " Error in sending the data to the Firbase while updateData  " +onError);

          });
        } else {
          await _dbRef.child('Users').child(user.uid.toString()).update({
            'name': userInfo.name,
            'phone': userInfo.phone,
            'address': userInfo.address,
            'zipcode': userInfo.zipcode,
          }).then((result) {
            logger.info(FirebaseDatabaseUtil.TAG, "profile updated without profile picture" );
          }).catchError((onError) {
            logger.error(FirebaseDatabaseUtil.TAG, " Error in sending the Data to the Firbase  " +onError);
          });
        }
      }else
        logger.info(FirebaseDatabaseUtil.TAG, "passed UserInfo object in updatedata method in firebase_database_helper file in null" );
    }else
      logger.info(FirebaseDatabaseUtil.TAG, "passed user object in updatedata method in firebase_database_helper file in null");
 }

  Future<User> getUserData(FirebaseUser _user) async {
    try {
      if(_user != null) {
        await _dbRef
            .child('Users')
            .child(_user.uid.toString())
            .once()
            .then((DataSnapshot snapshot) {
          user = User.fromSnapshot(snapshot);
          logger.info(FirebaseDatabaseUtil.TAG, " Getting User data from the Firebase  " +_user.toString());
        }).catchError((error){
          logger.error(FirebaseDatabaseUtil.TAG, " Error in getting the data to the Firbase  " +error);
        });
      }else
        logger.error(FirebaseDatabaseUtil.TAG, "User passed in getUserData is null");
    } catch (e) {
      logger.error(FirebaseDatabaseUtil.TAG, " Error in getting the data to the Firbase  " +e);
    }
    return user;
  }

  Future<bool> updateUserProfile(
      FirebaseUser user, File image, User userInfo, bool isEdit) async {

    bool _isCreateUpdateSuccessfull = false;
    StorageReference storageReference;

    if (isEdit && image == null)
      await updateData(user, userInfo, null, false).then((result) {
        _isCreateUpdateSuccessfull = true;
      });
    else if (image == null)
      await sendData(user, userInfo, null).then((result) {
        _isCreateUpdateSuccessfull = true;
      });
    else {
      try {
        storageReference = FirebaseStorage.instance
            .ref()
            .child("profile pic" + user.uid.toString());
        StorageUploadTask uploadTask = storageReference.putFile(image);
        await uploadTask.onComplete;
        logger.info(FirebaseDatabaseUtil.TAG, " File Uploaded Succesfully to Firebase Storage  " );
      }catch(error)
    {
      logger.error(FirebaseDatabaseUtil.TAG, " Error in updating the profile pic to the Firbase  " +error);
    }
      await storageReference.getDownloadURL().then((fileURL) async {
        if (isEdit)
          await updateData(user, userInfo, fileURL, false).then((result) {
            _isCreateUpdateSuccessfull = true;
          });
        else
          await sendData(user, userInfo, fileURL).then((result) {
            _isCreateUpdateSuccessfull = true;
          });
      }).catchError((error){
        logger.error(FirebaseDatabaseUtil.TAG, " Error in updating the profile pic to the Firbase  " +error);
      });
    }
    return _isCreateUpdateSuccessfull;
  }
}
