import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:resideo_eshopping/Screens/product_detail.dart';
import 'package:resideo_eshopping/model/product.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:resideo_eshopping/util/logger.dart' as logger;
import 'package:cached_network_image/cached_network_image.dart';

class ProductsTile extends StatelessWidget {
  Product _products;
  ProductsTile(this._products);
  Widget widget;
  @override 
  Widget build(BuildContext context) {
    void navigateToProductdetail(Product pd, 
        ) async {
      Navigator.push(context, ScaleRoute(
          page: ProductDetail(pd)));
    }
    if (_products == null)
      logger.info("ProductsTile", "Product object passed in product tile is null");
    else {
      return Column(
        children: <Widget>[
          Card(
            color: (_products.quantity != 0
                ? Color.fromRGBO(255, 255, 255, 1.0)
                : Color.fromRGBO(255, 255, 255, 0.5)),
            child: ListTile(
                isThreeLine: true,
                title: Text(_products.title),
                subtitle:
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(_products.sDesc),
                    Row(
                        children: <Widget>[
                          Icon(FontAwesomeIcons.rupeeSign, size: 10,),
                          Text((_products.price).toString()),
                        ]
                    ),

                  ],
                ),
                onTap: () {
                  navigateToProductdetail(
                      _products);
                },

                leading:
                Container(
                    margin: EdgeInsets.only(left: 6.0),
                    child: Stack(
                        children: <Widget>[
                          CachedNetworkImage(
                            imageUrl: _products.thumbnailUrl,
                            placeholder: (context, url) => CircularProgressIndicator(),
                            errorWidget: (context, url, error) => Image.asset("assets/images/no_image_available.png"),
                          ),
                          (_products.quantity != 0) ? Text('') : Text(
                            'OUT OF STOCK!',
                            style: TextStyle(color: Colors.red, fontSize: 11.0),
                            textAlign: TextAlign.center,),
                        ]
                    )
                )
            ),
          ),
          //Divider()
        ],
      );
    }
  }
  
}

class ScaleRoute extends PageRouteBuilder {
  final Widget page;
  ScaleRoute({this.page})
      : super(
          pageBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
          ) =>
              page,
          transitionsBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
            Widget child,
          ) =>
              ScaleTransition(
                scale: Tween<double>(
                  begin: 0.0,
                  end: 1.0,
                ).animate(
                  CurvedAnimation(
                    parent: animation,
                    curve: Curves.fastOutSlowIn,
                  ),
                ),
                child: child,
              ),
        );
}