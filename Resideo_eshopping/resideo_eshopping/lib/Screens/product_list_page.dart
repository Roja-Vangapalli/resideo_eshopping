import 'dart:io';
import 'dart:async';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:provider/provider.dart';
import 'package:resideo_eshopping/Screens/login_page.dart';
import 'package:resideo_eshopping/Screens/user_profile.dart';
import 'package:resideo_eshopping/model/product.dart';
import 'package:resideo_eshopping/controller/product_controller.dart';
import 'package:resideo_eshopping/model/user_repository.dart';
import 'package:resideo_eshopping/stores/home_page_store.dart';
import 'package:resideo_eshopping/util/firebase_database_helper.dart';
import 'package:resideo_eshopping/Screens/products_tile.dart';
import 'package:resideo_eshopping/util/logger.dart' as logger;
import 'package:resideo_eshopping/widgets/progress_indicator.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ProductsListPage extends StatefulWidget {
 static const String TAG ="PoductsListPage";
  ProductsListPage();
  @override
  _ProductsListPageState createState() => _ProductsListPageState();
}

class _ProductsListPageState extends State<ProductsListPage>
    with SingleTickerProviderStateMixin {
  ProductController productController = ProductController();
  final _homeStore = HomePageStore();
  final key = GlobalKey<ScaffoldState>();
  FirebaseDatabaseUtil firebaseDatabaseUtil;
  String dropdownValue = 'Categories';
  List<Product> currentList = <Product>[];
  bool _isProgressBarShown = true;
  String _name = "";
  String _email = "";
  String _imageUrl;

  void _setProfile(user) {
    if (user == null) {
      _name = "";
      _email = "";
      _imageUrl = null;
    } else {
      _email = user.email.toString();
    }
  }


  _getProduct(String value) {
    logger.info(
        ProductsListPage.TAG, " _getProduct method for getting products:");

    productController.getProductList(value).then((result) {
      if (result != null) {
        if (mounted) {
          setState(() {
            currentList = result;
            logger.info(ProductsListPage.TAG,
                " Getting the Products details from API  :" + value);
            _isProgressBarShown = false;
          });
        }
      } else {
        logger.info(ProductsListPage.TAG, " product list is empty  :");
      }
    }).catchError((error) {
      logger.error(ProductsListPage.TAG, " product list is empty  :" + error);
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget widget1;
    UserRepository userRepository = Provider.of<UserRepository>(context);
    _setProfile(userRepository.user);

    if (_isProgressBarShown) {
      widget1 = Center(
          child: Padding(
        padding: const EdgeInsets.only(left: 16.0, right: 16.0),
        child: ProgressIndicatorWidget(),
      ));
    } else {
      widget1 = ListView.builder(
        shrinkWrap: true,
        padding: const EdgeInsets.all(0.0),
        itemCount: currentList.length,
        itemBuilder: (context, index) =>
            ProductsTile(currentList[index]),
      );
    }

    return Scaffold(
      key: key,
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            Container(
                child: (userRepository.imageUrl!= "" && userRepository.imageUrl != null)
                    ? UserAccountsDrawerHeader(
                        accountName: Text(userRepository.name),
                        accountEmail: Text(_email),
                        currentAccountPicture: CircleAvatar(
                          backgroundImage: NetworkImage(userRepository.imageUrl),
                          backgroundColor:
                              Theme.of(context).platform == TargetPlatform.iOS
                                  ? Colors.blue
                                  : Colors.white,
                        ),
                      )
                    : UserAccountsDrawerHeader(
                        accountName: Text(userRepository.name),
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
                      )),
            ExpansionTile(
              title: Text("Filter"),
              children: <Widget>[
                _createDrawerItem(
                    icon: FontAwesomeIcons.male,
                    text: 'All',
                    onTap: () => _getProduct('All')),
                _createDrawerItem(
                    icon: FontAwesomeIcons.male,
                    text: 'Men',
                    onTap: () => _getProduct('Men')),
                _createDrawerItem(
                    icon: FontAwesomeIcons.female,
                    text: 'Women',
                    onTap: () => _getProduct('Women')),
                _createDrawerItem(
                    icon: FontAwesomeIcons.child,
                    text: 'Kids',
                    onTap: () => _getProduct('Kid')),
              ],
            ),
            Divider(),
            _createDrawerItem(
                icon: FontAwesomeIcons.user,
                text: 'My Account',
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => SignUp()));
                }),
            _loginSignupButton(userRepository.user),
          ],
        ),
      ),
      appBar: AppBar(
        title: Text("Resideo eShopping"),
      ),
      body: widget1,
    );
  }

  Widget _loginSignupButton(user) {
    UserRepository userRepository = Provider.of<UserRepository>(context);
    if (userRepository.user != null) {
      return PlatformButton(
          onPressed: () async {
            await userRepository.signOut();
            //widget.offline;
            userRepository.userInfo = null;
            Flushbar(
              message: "You are logged out!",
              duration: Duration(seconds: 3),
            )..show(context);
          },
          child: Text('LOG OUT'),
          color: Color.fromRGBO(255, 0, 0, 1.0),
          android: (_) => MaterialRaisedButtonData(),
          ios: (_) => CupertinoButtonData());
    } else {
      return PlatformButton(
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) {
              return LoginPage(onSignedIn: _homeStore.onLoggedIn);
            }));
          },
          child: Text('LOG IN'),
          color: Color.fromRGBO(255, 0, 0, 1.0),
          android: (_) => MaterialRaisedButtonData(),
          ios: (_) => CupertinoButtonData());
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
  void initState() {
    super.initState();
    Timer.run(() {
      try {
        InternetAddress.lookup('google.com')
            .timeout(Duration(seconds: 3))
            .then((result) {
          if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
            productController.listenforplace();
            _getProduct("All");
            logger.info(ProductsListPage.TAG, " Connected :");
          } else {
            Future.delayed(const Duration(seconds: 5));
            Flushbar(
              message: "Not Connected to Internet!!",
              duration: Duration(seconds: 3),
            )..show(context);
          }
        });
      } on SocketException catch (_) {
        Future.delayed(const Duration(seconds: 5));
        Flushbar(
          message: "Not connected to Internet!!",
          duration: Duration(seconds: 3),
        )..show(context);
        logger.error(ProductsListPage.TAG, " Error while connecting  :");
      }
    });
    firebaseDatabaseUtil = FirebaseDatabaseUtil();
    firebaseDatabaseUtil.initState();
  }

  @override
  void didUpdateWidget(ProductsListPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    // user2.getUserdetails();
    UserRepository user1 = Provider.of<UserRepository>(context);
    user1.getUserdetails();
  }

  void _showDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Internet connection is required!"),
      ),
    );
  }
}
