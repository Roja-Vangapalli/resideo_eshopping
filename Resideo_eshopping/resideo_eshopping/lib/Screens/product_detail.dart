import 'dart:io';
import 'package:carousel_pro/carousel_pro.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:resideo_eshopping/controller/app_localizations.dart';
import 'package:resideo_eshopping/controller/product_controller.dart';
import 'package:resideo_eshopping/model/places.dart';
import 'package:resideo_eshopping/model/product.dart';
import 'package:resideo_eshopping/Screens/order_confirmation_page.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:resideo_eshopping/model/user_repository.dart';
import 'package:resideo_eshopping/stores/home_page_store.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter_plugin_pdf_viewer/flutter_plugin_pdf_viewer.dart';
import 'package:resideo_eshopping/widgets/rating_start.dart';
import 'package:resideo_eshopping/util/logger.dart' as logger;
import 'package:resideo_eshopping/widgets/pdf_viewer.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'login_page.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ProductDetail extends StatefulWidget {
  final Product product;
  ProductDetail(
      this.product);
  @override
  _ProductDetailState createState() => _ProductDetailState();
}

class _ProductDetailState extends State<ProductDetail> {
  static const String TAG = "ProductDetail";
  Product product;
  String urlPDFPath;
  bool buttonDisabled;
  PDFDocument document;
  VideoPlayerController _videoPlayerController;
  ProductController _productController;
  Future<void> _initializeVideoPlayerFuture;
  List<Place> finallist = <Place>[];

  List<String> distance = <String>[];


  final _homeStore = HomePageStore();

  @override
  void initState() {
    super.initState();
     caldistance(widget.product.latitude, widget.product.longitude);

    _videoPlayerController =
        VideoPlayerController.network(widget.product.pVideoUrl);
    _initializeVideoPlayerFuture = _videoPlayerController.initialize();
    _videoPlayerController.setLooping(true);
    _videoPlayerController.setVolume(1.0);
    _productController = ProductController();
    getFileFromUrl(widget.product.faqUrl).then((f) {
      if (mounted) {
      setState(() {
        urlPDFPath = f.path;
      });
      }
    });
  }

  Future<File> getFileFromUrl(String url) async {
    logger.info(TAG, "Getting PDF File from the Url: " + url);
    var data = await http.get(url);
    var bytes = data.bodyBytes;
    var dir = await getApplicationDocumentsDirectory();
    File file = File("${dir.path}/mypdfonline.pdf");

    File urlFile = await file.writeAsBytes(bytes);
    return urlFile;
    //logger.error(TAG, "Error while getting the Pdf from URL :" + e);
  }


   void caldistance(String lat, String long) async {
     double slat = double.parse(lat);
     double slong = double.parse(long);
     int len = ProductController.placelist.length;
     for (int i = 0; i < len; i++)  {
       double elat = double.parse(ProductController.placelist[i].latitude);
       double elong = double.parse(ProductController.placelist[i].longitude);
       double distanceInM = await Geolocator().distanceBetween(slat, slong, elat, elong);
       double distanceInKm = distanceInM / 1000;
       if (distanceInKm < 5) {
         finallist.add(ProductController.placelist[i]);
         distance.add(distanceInKm.toInt().floor().toString());
       }
     }
   }

  @override
  Widget build(BuildContext context) {
    UserRepository userRepository = Provider.of<UserRepository>(context);
    buttonDisabled =
        _productController.enableDisableOrderNowButton(widget.product.quantity);
    void navigateToCustomerAddress() async {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  OrderConfirmationPage(
                    widget.product,
                  )));
    }

    if (widget.product == null)
      logger.info(TAG,
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
                        Text(
                          widget.product.title,
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: Colors.blue),
                        ),
                        Spacer(),
                        StarDisplay(
                          value: widget.product.rating,
                        ),
                      ],
                    ),
                    Text(widget.product.sDesc),
                    SizedBox(
                      height: 20,
                    ),
                    _showSlides(),
                    SizedBox(
                      height: 20,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        Icon(FontAwesomeIcons.rupeeSign),
                        Text(
                          widget.product.price.toString(),
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 30),
                        ),
                        Spacer(),
                        //getInventory(widget.product.quantity),
                        Text(
                            _productController
                                .inventoryDetail(widget.product.quantity),
                            style: TextStyle(
                              color: _productController.inventoryDetailColor(
                                  widget.product.quantity),
                            )),
                      ],
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    MaterialButton(
                      textColor: Colors.white,
                      minWidth: double.infinity,
                      shape: RoundedRectangleBorder(),
                      color: Colors.blue,
                      disabledColor: Colors.blueGrey,
                      disabledTextColor: Colors.black,
                      child: Text(
                        AppLocalizations.of(context).getString("Order_NOW"),
                        style: TextStyle(fontSize: 20),
                      ),
                      onPressed: buttonDisabled
                          ? null
                          : () {
                        if (userRepository.user == null) {
                          // Navigator.pop(context);
                          // widget.online();
                          Navigator.of(context).push(
                              MaterialPageRoute(builder: (context) {
                                return LoginPage(
                                  onSignedIn: _homeStore.onLoggedIn,
                                );
                              }));
                          // Navigator.popAndPushNamed(context, 'OrderConfirmationPage');
                        } else if (userRepository.userinfo == null ||
                            userRepository.userInfo.address == null ||
                            userRepository.userInfo.phone == null) {
                          showAlertDialog(context);
                        } else
                          navigateToCustomerAddress();
                      },
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    PlatformText(
                      "About This Item",
                      style:
                         TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Text(
                      widget.product.lDesc,
                      style: TextStyle(fontSize: 15),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Text(
                      'Customer Reviews',
                      style:
                      TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Text(
                      widget.product.review,
                      style: TextStyle(fontSize: 15),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    ButtonTheme(
                      minWidth: 400.0,
                      height: 40.0,
                      child: RaisedButton(
                        color: Colors.amber,

                        // width: double.infinity,
                        child: Text(
                          AppLocalizations.of(context)
                              .getString("Frequently_ASKED"),
                        ),

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
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Text(
                      'Near by Places',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 20),
                    ),
                    SizedBox(
                      height: 20,
                      width: 20,
                    ),
                    SizedBox(
                      height: 200.0,
                      //width : 200.0,
                      child: ListView.builder(
                        shrinkWrap: true,
                        scrollDirection: Axis.horizontal,
                        itemCount: finallist.length,
                        itemExtent: 100.0,
                        itemBuilder: (context, index) {
                          var item = finallist[index];
                          return Column(
                            children: <Widget>[
                              Padding(
                                padding: EdgeInsets.symmetric( horizontal: 5.0, vertical: 0.0),
                                 child:CachedNetworkImage(
                                   imageUrl: item.imageUrl,
                                   placeholder: (context, url) => CircularProgressIndicator(),
                                   errorWidget: (context, url, error) => Image.asset("assets/images/no_image_available.png"),
                                 ),
                                  ),
                              Padding(
                                padding :EdgeInsets.symmetric(horizontal: 5.0, vertical: 0.0),
                                child: Text(item.name,textAlign: TextAlign.center,style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                              ),
                              Padding(
                                padding :EdgeInsets.symmetric(horizontal: 5.0, vertical: 0.0),
                                child: Text(item.sdesc,textAlign: TextAlign.center),
                              ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Text(
                                  distance[index], textAlign: TextAlign.center,
                                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  'Km', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                                )
                              ],
                             ),
                            ]
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ],
            )),
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
        androidFlat: (_) => MaterialFlatButtonData());

    // set up the AlertDialog
    PlatformAlertDialog alert = PlatformAlertDialog(
      title: PlatformText("Update User Profile"),
      content: PlatformText(
          "Please update Address and phone No in your user Profile"),
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

  Widget _showVideo() {
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
              height: 0.0,
              minWidth: 0.0,
              child: RaisedButton(
                padding: EdgeInsets.all(6.0),
                color: Colors.transparent,
                //textColor: Colors.white,
                onPressed: () {
                  if (mounted) { 
                  setState(() {
                    if (_videoPlayerController.value.isPlaying) {
                      _videoPlayerController.pause();
                    } else {
                      _videoPlayerController.play();
                    }
                  });
                  }
                },
                child: Icon(
                  _videoPlayerController.value.isPlaying ? Icons.pause : Icons
                      .play_arrow,
                  size: 0.0,
                  color: Colors.transparent,
                ),
              )
          ),
        )
      ],
    );
  }

  Widget _showSlides() {
    return SizedBox(
        height: 400.0,
        width: 800.0,
        child: Carousel(
          images: [
            CachedNetworkImage(
              imageUrl: widget.product.imgUrl,
              placeholder: (context, url) => CircularProgressIndicator(),
              errorWidget: (context, url, error) => Image.asset("assets/images/no_image_available.png"),
            ),
            _showVideo(),
          ],
          autoplay: false,
          dotSize: 4.0,
          dotSpacing: 15.0,
          dotColor: Colors.blue,
          indicatorBgPadding: 5.0,
          dotBgColor: Colors.lightBlueAccent.withOpacity(0.2),
          borderRadius: false,
          moveIndicatorFromBottom: 180.0,
          noRadiusForIndicator: true,
          overlayShadow: true,
          overlayShadowColors: Colors.white,
          overlayShadowSize: 0.7,
        )
    );
  }
}

