import 'dart:io';
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:resideo_eshopping/Screens/signup.dart';
import 'package:resideo_eshopping/model/product.dart';
import 'package:resideo_eshopping/controller/product_controller.dart';
import 'package:resideo_eshopping/util/crud_operations.dart';
import 'package:resideo_eshopping/widgets/products_tile.dart';
import 'package:resideo_eshopping/services/authentication.dart';
import 'package:resideo_eshopping/model/User.dart';
import 'package:after_layout/after_layout.dart';
import 'package:resideo_eshopping/util/logger.dart' as logger;


class ProductsListPage extends StatefulWidget {
 ProductsListPage(this.user,this.online,this.offline,this.auth);
 final FirebaseUser user;
 final VoidCallback online;
 final VoidCallback offline;
 final BaseAuth auth;
 static const String TAG ="PoductsListPage";
  @override
  _ProductsListPageState createState() => _ProductsListPageState();
}

class _ProductsListPageState extends State<ProductsListPage> 
    with SingleTickerProviderStateMixin ,AfterLayoutMixin<ProductsListPage> {
  ProductController productController=ProductController();
  FirebaseDatabaseUtil firebaseDatabaseUtil;
  String dropdownValue = 'Categories';
  List<Product> currentList = <Product>[];
  bool _isProgressBarShown = true;
  AnimationController controller;
  Animation<double> animation;
  User userInfo;
  String _name="";
  String _email="";
  String _imageUrl="";
  bool isProfile=false;

  void _closeUserProfile(){
   setState(() {
     isProfile=false;
     _getUserDetail();
   });
  }
  
  void _setProfile(){
    if(widget.user == null)
    {
      _name="";
      _email="";
      _imageUrl="";
    }else
      {
        _email=widget.user.email.toString();
      }
  }

  _getUserDetail(){
    if(widget.user != null){
      logger.info(ProductsListPage.TAG, " Getting the User details from API  :" );
     firebaseDatabaseUtil.getUserData(widget.user).then((result){
            userInfo=result;
            if(userInfo != null)
            {
            setState(() {

                      _name=userInfo.name;
                      _imageUrl=userInfo.imageUrl;

            });
            }
          });
    }
  }

  _getProduct(String value){
  productController.getProductList(value).then((result){setState((){currentList=result;
  logger.info(ProductsListPage.TAG, " Getting the Products details from API  :" + value);
  _isProgressBarShown = false;
  });});
  }
  
  @override
  Widget build(BuildContext context) {
    var key = GlobalKey<ScaffoldState>();
    Widget widget1;
    _setProfile();
  if(_isProgressBarShown){
    widget1 = Center(
      child: Padding(
        padding: const EdgeInsets.only(left: 16.0, right: 16.0),
        child: PlatformCircularProgressIndicator(
          android: (_) => MaterialProgressIndicatorData(),
          ios: (_) => CupertinoProgressIndicatorData(),
        ),
      )
    );
  }
  else{
    widget1 = ListView.builder(
      shrinkWrap: true,
      padding: const EdgeInsets.all(0.0),

      itemCount: currentList.length,
      itemBuilder: (context, index) => ProductsTile(currentList[index],widget.user,widget.online,widget.offline,widget.auth),
    );
  }
   if(isProfile)
   {
     return SignUp(widget.user,_closeUserProfile,userInfo);
   }else{
    return Scaffold(
      key: key,
      drawer: Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          Container(
                child: _imageUrl != ""?
                 UserAccountsDrawerHeader(
                  accountName: Text(_name),
                  accountEmail: Text(_email),
                  currentAccountPicture: CircleAvatar(
                    backgroundImage: NetworkImage(_imageUrl),
                    backgroundColor:
                        Theme.of(context).platform == TargetPlatform.iOS
                            ? Colors.blue
                            : Colors.white,
                 
                  ),
                )
                :
                 UserAccountsDrawerHeader(
                  accountName: Text(_name),
                  accountEmail: Text(_email),
                  currentAccountPicture: CircleAvatar(
                    //backgroundImage: NetworkImage(_imageUrl),
                    backgroundColor:
                        Theme.of(context).platform == TargetPlatform.iOS
                            ? Colors.blue
                            : Colors.white,
                    child: Text(
                      "P",
                      style: TextStyle(fontSize: 40.0),
                    ),
                  ),
                )
              ),
              
          ExpansionTile(
            title: Text("Filter"),
            children: <Widget>[
              _createDrawerItem(icon: FontAwesomeIcons.male, text: 'All',onTap: () => _getProduct('All')),
              _createDrawerItem(icon: FontAwesomeIcons.male, text: 'Men',onTap: () => _getProduct('Men')),
              _createDrawerItem(icon: FontAwesomeIcons.female, text: 'Women', onTap: () => _getProduct('Women')),
              _createDrawerItem(icon: FontAwesomeIcons.child, text: 'Kids', onTap: () => _getProduct('Kid')),
            ],
          ),
          Divider(),
          _createDrawerItem(icon: FontAwesomeIcons.user, text: 'My Account',onTap: (){setState(() {isProfile=true;});}),
          _loginSignupButton(),
        ],
      ),
    ),
      appBar: AppBar(
          title: PlatformText("Resideo eShopping"),
          ),
      body: widget1,
    );
   }
  }


  Widget _loginSignupButton(){
       if(widget.user != null)
          {
            return PlatformButton(
            onPressed: () async{
             try {
                   await widget.auth.signOut();
                  widget.offline();
                  } catch (e) {
                   print(e);
                  }
            },
            child: PlatformText('LOG OUT'),
            color: Color.fromRGBO(255, 0, 0, 1.0),
            android: (_) => MaterialRaisedButtonData(),
            ios: (_) => CupertinoButtonData()
          );
          }
          else
          {
          return PlatformButton(
            onPressed: (){
            widget.online();
            },
            child: PlatformText('LOG In'),
            color: Color.fromRGBO(255, 0, 0, 1.0),
            android: (_) => MaterialRaisedButtonData(),
            ios: (_) => CupertinoButtonData()
          );
          }
  }

  Widget _createDrawerItem(
      {IconData icon, String text, String value, GestureTapCallback onTap}) {
    return ListTile(
      title: Row(
        children: <Widget>[
          Icon(icon),
          Padding(
            padding: EdgeInsets.only(left: 8.0),
            child: Text(text),
          )
        ],
      ),
      onTap: onTap,

    );
  }
  @override
  void afterFirstLayout(BuildContext context) {
    // Calling the same function "after layout" to resolve the issue.
    
    firebaseDatabaseUtil=FirebaseDatabaseUtil();
    firebaseDatabaseUtil.initState();
    _getUserDetail();
    Timer.run(() {
      try {
        InternetAddress.lookup('google.com').then((result) {
          if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
            print('connected');
          } else {
            _showDialog(); // show dialog
          }
        }).catchError((error) {
          _showDialog(); // show dialog
        });
      } on SocketException catch (_) {
        _showDialog();
        print('not connected'); // show dialog
      }
    });

    _getProduct("All");
  }

  // @override
  // void initState() {
  //   super.initState();
  //   firebaseDatabaseUtil=FirebaseDatabaseUtil();
  //   firebaseDatabaseUtil.initState();
  //   _getUserDetail();
  //   Timer.run(() {
  //     try {
  //       InternetAddress.lookup('google.com').then((result) {
  //         if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
  //           print('connected');
  //         } else {
  //           _showDialog(); // show dialog
  //         }
  //       }).catchError((error) {
  //         _showDialog(); // show dialog
  //       });
  //     } on SocketException catch (_) {
  //       _showDialog();
  //       print('not connected'); // show dialog
  //     }
  //   });

  //   _getProduct("All");
  // }

 
  void _showDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
            title: Text("Internet connection is required!"),
          ),
    );
  }

}
