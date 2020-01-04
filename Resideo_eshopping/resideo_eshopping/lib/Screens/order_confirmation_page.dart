import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:resideo_eshopping/Screens/home_page.dart';
import 'package:resideo_eshopping/controller/product_controller.dart';
import 'package:resideo_eshopping/model/product.dart';
import 'package:giffy_dialog/giffy_dialog.dart';
import 'package:resideo_eshopping/model/User.dart';
import 'package:after_layout/after_layout.dart';
import 'package:resideo_eshopping/util/logger.dart' as logger;

class OrderConfirmationPage extends StatefulWidget {
  final Product product;
  final User userInfo;
  final FirebaseUser user;
  final VoidCallback online;
  final VoidCallback offline;

  OrderConfirmationPage(this.product, this.userInfo, this.user, this.online,
      this.offline);

  @override
  _OrderConfirmationPageState createState() => _OrderConfirmationPageState();
}

class _OrderConfirmationPageState extends State<OrderConfirmationPage> with AfterLayoutMixin<OrderConfirmationPage> {
  ProductController _productController;
  static const String TAG ="OrderConfirmationPage";

  void navigateToHomePage(BuildContext context) async {
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
              builder: (context) => HomePage()
                ),
        (Route<dynamic> route) => false);
  }

  orderPlaced(BuildContext context) {
    showDialog(
        context: context,
        builder: (_) => NetworkGiffyDialog(
              image: Image.asset('assets/images/tenor.gif'),
              title: Text('Order Placed!!',
                  textAlign: TextAlign.center,
                  style:
                      TextStyle(fontSize: 22.0, fontWeight: FontWeight.w600)),
              description: Text("Thank you for placing order"),
              onOkButtonPressed: () {
                navigateToHomePage(context);
              },
            ));
  }

  showAlertDialog(BuildContext context) {
    // set up the buttons
    Widget cancelButton = PlatformButton(
        child: PlatformText("No"),
        onPressed: () {
          Navigator.pop(context);
        },
        androidFlat: (_) => MaterialFlatButtonData());
    Widget continueButton = PlatformButton(
        child: PlatformText("Yes"),
        onPressed: () {
          Navigator.pop(context);
          _productController.updateInventory(widget.product);
          orderPlaced(context);
        },
        androidFlat: (_) => MaterialFlatButtonData());

    // set up the AlertDialog
    PlatformAlertDialog alert = PlatformAlertDialog(
      title: PlatformText("Order Confrimation"),
      content: PlatformText("Do you want to place order?"),
      actions: <Widget>[
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
  void afterFirstLayout(BuildContext context) {
    _productController = ProductController();
    _productController.init();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.product != null && widget.userInfo != null) {
      return PlatformScaffold(
        appBar: PlatformAppBar(
          title: Container(
            alignment: Alignment.center,
            child: PlatformText("Resideo e-Shopping",
                style: TextStyle(
                  //color: Colors.white,
                )),
          ),
        ),
        body: Column(
          children: <Widget>[
            Flexible(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 15.0),
                children: <Widget>[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        margin: const EdgeInsets.all(20.0),
                        child: Text(
                          'Product: ',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            color: Colors.blue,
                          ),
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.all(20.0),
                        child: PlatformText(
                          widget.product.title,
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 20),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        margin: const EdgeInsets.all(20.0),
                        child: Text(
                          'Estimated Price: ',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            color: Colors.blue,
                          ),
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.all(20.0),
                        child: PlatformText(
                          'Rs. ' + widget.product.price.toString(),
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 20),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        margin: const EdgeInsets.all(20.0),
                        child: Text(
                          'Deliver To: ',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            color: Colors.blue,
                          ),
                        ),
                      ),
                      Container(
                        //margin: const EdgeInsets.all(20.0),

                          child: Flexible(
                            child: PlatformText(
                              widget.userInfo.address.toString(),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 5,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 20),
                            ),
                          )),
                    ],
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        margin: const EdgeInsets.all(20.0),
                        child: Text(
                          'Phone No: ',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            color: Colors.blue,
                          ),
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.all(20.0),
                        child: PlatformText(
                          widget.userInfo.phone.toString(),
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 20),
                        ),
                      ),
                    ],
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
                              Text("Proceed", style: TextStyle(fontSize: 24.0)),
                            ],
                          )),
                      onPressed: () {
                        showAlertDialog(context);
                      },
                      shape: new RoundedRectangleBorder(
                          borderRadius: new BorderRadius.circular(30.0))),
                ),
              ],
            ),
          ],
        ),
      );
    }else
      {
        logger.info(TAG, "object passed from the product detail page to order confirmation page is null");
      }
  }
}
