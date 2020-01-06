import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:path_provider/path_provider.dart';
import 'package:resideo_eshopping/controller/app_localizations.dart';
import 'package:resideo_eshopping/controller/product_controller.dart';
import 'package:resideo_eshopping/model/product.dart';
import 'package:resideo_eshopping/Screens/order_confirmation_page.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter_plugin_pdf_viewer/flutter_plugin_pdf_viewer.dart';
import 'package:resideo_eshopping/model/User.dart';
import 'package:resideo_eshopping/widgets/rating_start.dart';
import 'package:resideo_eshopping/util/logger.dart' as logger;
import 'package:resideo_eshopping/widgets/pdf_viewer.dart';

import 'package:http/http.dart' as http;


class ProductDetail extends StatefulWidget
{
 
  final Product product;
  final FirebaseUser user;
  final VoidCallback online;
  final VoidCallback offline;
  final User userInfo;
  ProductDetail(this.product,this.user,this.online,this.offline, this.userInfo);


  @override
  _ProductDetailState createState() => _ProductDetailState();
}

class _ProductDetailState extends State<ProductDetail> {
  static const String TAG ="ProductDetail";
  Product product;
  String urlPDFPath ;
  bool buttonDisabled;
  PDFDocument document;
  VideoPlayerController _videoPlayerController;
  ProductController _productController;
  Future<void> _initializeVideoPlayerFuture;

  @override
  void initState() {
    super.initState();
    _videoPlayerController = VideoPlayerController.network(widget.product.pVideoUrl);
    _initializeVideoPlayerFuture = _videoPlayerController.initialize();
    _videoPlayerController.setLooping(true);
    _videoPlayerController.setVolume(1.0);
    _productController=ProductController();

    getFileFromUrl(widget.product.faqUrl).then((f) {
      setState(() {
        urlPDFPath = f.path;
        print(urlPDFPath);
      });
    });
  }

  Future<File> getFileFromUrl(String url) async {
    logger.info(TAG, "Getting PDF File from the Url: " + url);
    try {
      var data = await http.get(url);
      var bytes = data.bodyBytes;
      var dir = await getApplicationDocumentsDirectory();
      File file = File("${dir.path}/mypdfonline.pdf");

      File urlFile = await file.writeAsBytes(bytes);
      return urlFile;
    } catch (e) {
      logger.error(TAG, "Error while getting the Pdf from URL :" + e);
    }
  }

  @override
  Widget build(BuildContext context) {
    buttonDisabled =
        _productController.enableDisableOrderNowButton(widget.product.quantity);
    void navigateToCustomerAddress() async {
      Navigator.push(context, MaterialPageRoute(builder: (context) =>
          OrderConfirmationPage(
              widget.product, widget.userInfo, widget.user, widget.online,
              widget.offline)
              ));
    }

    if (widget.product == null)
      print(
          "product object passed from the product list page in product detail page is empty");
    else {
      return PlatformScaffold(
        appBar: PlatformAppBar(
          title: PlatformText("Resideo e-Shopping"),
        ),
        body: Container(
            padding: EdgeInsets.all(15.0),
            child: ListView(
              children: <Widget>[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        Text(widget.product.title, style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: Colors.blue),),
                        Spacer(),
                        StarDisplay(value: widget.product.rating,),
                      ],
                    ),
                    Text(widget.product.sDesc),
                    SizedBox(height: 20,),
                    _showSlides(),
                    SizedBox(height: 20,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        Icon(FontAwesomeIcons.rupeeSign),
                        Text(widget.product.price.toString(), style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 30),),
                        Spacer(),
                        //getInventory(widget.product.quantity),
                        Text(_productController.inventoryDetail(
                            widget.product.quantity), style: TextStyle(
                          color: _productController.inventoryDetailColor(
                              widget.product.quantity),)),
                      ],
                    ),
                    SizedBox(height: 20,),
                    MaterialButton(
                      textColor: Colors.white,
                      minWidth: double.infinity,
                      shape: RoundedRectangleBorder(),
                      color: Colors.blue,
                      disabledColor: Colors.blueGrey,
                      disabledTextColor: Colors.black,
                      child: Text(AppLocalizations.of(context).getString("Order_NOW"),
                        style: TextStyle(fontSize: 20),),
                      onPressed: buttonDisabled ? null : () {
                        if (widget.user == null) {
                          Navigator.pop(context);
                          widget.online();
                        } else if (widget.userInfo == null ||
                            widget.userInfo.address == null ||
                            widget.userInfo.phone == null) {
                          showAlertDialog(context);
                        } else
                          navigateToCustomerAddress();
                      },
                    ),
                    SizedBox(height: 20,),
                    PlatformText("About This Item", style: TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 20),),
                    SizedBox(height: 10,),
                    Text(widget.product.lDesc, style: TextStyle(fontSize: 15),),
                    SizedBox(height: 20,),
                    Text('Customer Reviews', style: TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 20),),
                    SizedBox(height: 10,),
                    Text(
                      widget.product.review, style: TextStyle(fontSize: 15),),

                    SizedBox(height: 20,),
                    ButtonTheme(
                      minWidth: 400.0,
                      height: 40.0,
                      child: RaisedButton(

                        color: Colors.amber,
                        // width: double.infinity,
                        child: Text(AppLocalizations.of(context).getString("Frequently_ASKED"), ),
                        onPressed: () {
                          if (urlPDFPath != null) {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        PdfViewPage(path: urlPDFPath)));
                          }
                        },
                      ),
                    )
                  ],
                ),
              ],
            )
        ),
      );
    }
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    super.dispose();
  }

   showAlertDialog(BuildContext context) {
    // set up the buttons
    Widget cancelButton = PlatformButton(
      child: PlatformText("ok"),
      onPressed: () {
        Navigator.pop(context);
      },
      androidFlat: (_) => MaterialFlatButtonData()
    );

    // set up the AlertDialog
    PlatformAlertDialog alert = PlatformAlertDialog(
      title: PlatformText("Update User Profile"),
      content: PlatformText("Please update Address and phone No in your user Profile"),
      actions: <Widget>[
        cancelButton,
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



  Widget _showVideo(){
    return Stack(
      children: <Widget>[
        Center(
          child: FutureBuilder(
          future: _initializeVideoPlayerFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      return AspectRatio(
                        aspectRatio: _videoPlayerController.value.aspectRatio,
                        child: VideoPlayer(_videoPlayerController),
                      );
                    } else {
                      return Center(child: CircularProgressIndicator());
                    }
                  },
          ),
        ),
        Center(
              child:
                      ButtonTheme(
                          height: 10.0,
                          minWidth: 20.0,
                          child: RaisedButton(
                            padding: EdgeInsets.all(6.0),
                            color: Colors.transparent,
                            textColor: Colors.white,
                            onPressed: () {
                              setState(() {
                                if (_videoPlayerController.value.isPlaying) {
                                  _videoPlayerController.pause();
                                } else {
                                  _videoPlayerController.play();
                                }
                              });
                            },
                            child: Icon(
                              _videoPlayerController.value.isPlaying ? Icons.pause : Icons.play_arrow,
                              size: 120.0,
                              color: Colors.transparent,
                            ),
                          )
                      ),
          )
        ],
      );

  }

  Widget _showSlides(){
    return CarouselSlider(
      height: 300.0,
      items: [
        Image.network(widget.product.imgUrl, fit: BoxFit.fill,),
         _showVideo(),
      ],
    );
}
}

