import 'dart:ffi';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:resideo_eshopping/Screens/login_signup_page.dart';
import 'package:resideo_eshopping/Screens/product_list_page.dart';
import 'package:resideo_eshopping/services/authentication.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:after_layout/after_layout.dart';
import 'package:resideo_eshopping/util/logger.dart' as logger;
class RootPage extends StatefulWidget {
  RootPage({this.auth});
  final BaseAuth auth;
  @override
  State<StatefulWidget> createState() => new _RootPageState();
}

enum AuthStatus {
  NOT_DETERMINED,
  NOT_LOGGED_IN,
  LOGGED_IN,
}

class _RootPageState extends State<RootPage> with AfterLayoutMixin<RootPage>{
  AuthStatus authStatus = AuthStatus.NOT_DETERMINED;
  String _userId = "";
  bool _logInButtonPress=false;
  FirebaseUser _user;
  
  @override
  void afterFirstLayout(BuildContext context) {
    // Calling the same function "after layout" to resolve the issue.
    widget.auth.getCurrentUser().then((user) {
      setState(() {
        if (user != null) {
          _user=user;
          _userId = user?.uid;
        }
        authStatus =
            user?.uid == null ? AuthStatus.NOT_LOGGED_IN : AuthStatus.LOGGED_IN;
      });
    });
  }
  // @override
  // void initState()  {
  //   super.initState();
  //   widget.auth.getCurrentUser().then((user) {
  //     setState(() {
  //       if (user != null) {
  //         _user=user;
  //         _userId = user?.uid;
  //       }
  //       authStatus =
  //           user?.uid == null ? AuthStatus.NOT_LOGGED_IN : AuthStatus.LOGGED_IN;
  //     });
  //   });
  // }
  
  void _onlogInButtonPress(){
    setState(() {
      _logInButtonPress=true;
    });
  }

  void _onLoggedIn() {
    widget.auth.getCurrentUser().then((user){
      setState(() {
        _user=user;
        _userId = user.uid.toString();
      });
    });
    setState(() {
      authStatus = AuthStatus.LOGGED_IN;
     
    });
  }

  void _onSignedOut() {
    setState(() {
      authStatus = AuthStatus.NOT_LOGGED_IN;
      _logInButtonPress=false;
      _userId = "";
      _user=null;
    });
  }

  Widget _buildWaitingScreen() {
    return Scaffold(
      body: Container(
        alignment: Alignment.center,
        child: CircularProgressIndicator(),
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    switch (authStatus) {
      case AuthStatus.NOT_DETERMINED:
        return _buildWaitingScreen();
        break;
      case AuthStatus.NOT_LOGGED_IN:
      {
        if(_logInButtonPress)
        {
          return new LoginSignUpPage(
          auth: widget.auth,
          onSignedIn: _onLoggedIn);
        
        }else
        {
         return new ProductsListPage(_user,_onlogInButtonPress,_onSignedOut,widget.auth);
          
        }    
      }   
      break;
      case AuthStatus.LOGGED_IN:
        if (_userId != null && _userId.length > 0) {
          return new ProductsListPage(_user,_onlogInButtonPress,_onSignedOut,widget.auth);
        } else return _buildWaitingScreen();
        break;
      default:
        return _buildWaitingScreen();
    }
  }
}
