import 'package:flutter/widgets.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:resideo_eshopping/model/User.dart';
import 'package:resideo_eshopping/util/logger.dart' as logger;
import 'package:resideo_eshopping/util/firebase_database_helper.dart';

enum Status { Uninitialized, Authenticated, Authenticating, Unauthenticated }

class UserRepository with ChangeNotifier {
  UserRepository(this._auth);

  FirebaseAuth _auth;
  FirebaseUser _user;
  String _userId;
  Status _status = Status.Uninitialized;
  FirebaseDatabaseUtil firebaseDatabaseUtil = FirebaseDatabaseUtil();
  static const String TAG ="UserRepository";
  User userInfo;
  String _name = "";
  String _imageUrl = "";

  UserRepository.instance() : _auth = FirebaseAuth.instance {
    _auth.onAuthStateChanged.listen(_onAuthStateChanged);
  }

  Status get status => _status;
  FirebaseUser get user => _user;
  FirebaseAuth get auth => _auth;
  String get userId => _userId;
  User get userinfo => userInfo;
  String get name => _name;
  String get imageUrl => _imageUrl;

  Future<String> signIn(String email, String password) async {
      await _auth.signInWithEmailAndPassword(email: email, password: password).then((result){
        if(result != null) {
          _userId = result.user.uid;
          print(_userId);
          _status = Status.Authenticating;
          notifyListeners();
        }
        else{
          _userId=null;
          _status = Status.Unauthenticated;
          notifyListeners();
        }
      });
    return _userId;
  }

  Future<String> signUp(String email, String password) async {
    await _auth.createUserWithEmailAndPassword(
        email: email, password: password).then((result){
      if(result != null) {
        _userId = result.user.uid;
      }
      else
        _userId=null;
    }).catchError((error){
      print(error);
    });
    return _userId;
  }

  Future<void> signOut() async {
    await _auth.signOut();
    _name ="";
    _imageUrl ="";
  }

  Future<void> _onAuthStateChanged(FirebaseUser firebaseUser) async {
    if (firebaseUser == null) {
      _user = null;
      _status = Status.Unauthenticated;
    } else {
      _user = firebaseUser;
      _status = Status.Authenticated;
    }
    notifyListeners();
  }
  Future<void>getUserdetails() async{
    if(_user!= null) {
      logger.info(
          TAG, " Getting the User details from API  :");
      firebaseDatabaseUtil.getUserData(_user).then((result) {
        print("User details are fetched");
        userInfo = result;
        if (userInfo != null) {

          logger.info(TAG,
              " Getting the User INFO details from API  are not null :");
          _name = userInfo.name;
          _imageUrl = userInfo.imageUrl;
        } else {
          logger.info(TAG,
              " Getting the User INFO details from API  are null :");
        }
      }).catchError((error) {
        logger.error(TAG,
            " Error in the getting user details from API  :" + error);
      });
    } else {
      logger.info(TAG, " widget user are null :");
    }
    notifyListeners();
  }


}