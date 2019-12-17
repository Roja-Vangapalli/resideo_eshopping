import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:resideo_eshopping/model/product.dart';
import 'package:resideo_eshopping/Screens/order_confirmation_page.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:resideo_eshopping/services/authentication.dart';
import 'package:resideo_eshopping/util/crud_operations.dart';
import 'package:video_player/video_player.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_plugin_pdf_viewer/flutter_plugin_pdf_viewer.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:resideo_eshopping/model/User.dart';
import 'package:logging/logging.dart';
import 'package:resideo_eshopping/util/logger.dart' as logger;
import 'package:after_layout/after_layout.dart';




class StarDisplay extends StatefulWidget {
  final int value;
  const StarDisplay({Key key, this.value = 0})
      : assert(value != null),
        super(key: key);

  @override
  _StarDisplayState createState() => _StarDisplayState();
}

class _StarDisplayState extends State<StarDisplay> {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        return Icon(
          index < widget.value ? Icons.star : Icons.star_border,
        );
      }),
    );
  }
}

class ProductDetail extends StatefulWidget
{
  static const String TAG ="ProductDetail";
  final Product pd;
  final FirebaseUser user;
  final VoidCallback online;
  final VoidCallback offline;
  final BaseAuth auth;
  ProductDetail(this.pd,this.user,this.online,this.offline,this.auth);

  @override
  _ProductDetailState createState() => _ProductDetailState();
}

class _ProductDetailState extends State<ProductDetail> with AfterLayoutMixin<ProductDetail>{
  Product product;
  String urlPDFPath ;
  bool buttonDisabled=false;
  PDFDocument document;
  String inventoryDetail;
  User userInfo;
  FirebaseDatabaseUtil firebaseDatabaseUtil;

  VideoPlayerController _videoPlayerController;

  Future<void> _initializeVideoPlayerFuture;

  getUserDetail(){
    logger.info(ProductDetail.TAG, "Getting User Details from Firebase "  );
    if(widget.user != null){
     firebaseDatabaseUtil.getUserData(widget.user).then((result){
            userInfo=result;
          });
    }
  }
  @override
  void afterFirstLayout(BuildContext context) {
    // Calling the same function "after layout" to resolve the issue.
    _videoPlayerController = VideoPlayerController.network(widget.pd.pVideo);
    _initializeVideoPlayerFuture = _videoPlayerController.initialize();
    _videoPlayerController.setLooping(true);
    _videoPlayerController.setVolume(1.0);
//    super.initState();
    firebaseDatabaseUtil=FirebaseDatabaseUtil();
    firebaseDatabaseUtil.initState();
    getUserDetail();
    getFileFromUrl(widget.pd.faq).then((f) {
      setState(() {
        urlPDFPath = f.path;
        print(urlPDFPath);
      });
    });

  }
//  void initState() {
//    _videoPlayerController = VideoPlayerController.network(widget.pd.pVideo);
//    _initializeVideoPlayerFuture = _videoPlayerController.initialize();
//    _videoPlayerController.setLooping(true);
//    _videoPlayerController.setVolume(1.0);
//    super.initState();
//    firebaseDatabaseUtil=FirebaseDatabaseUtil();
//    firebaseDatabaseUtil.initState();
//    getUserDetail();
//    getFileFromUrl(widget.pd.faq).then((f) {
//      setState(() {
//        urlPDFPath = f.path;
//        print(urlPDFPath);
//      });
//    });
//  }
  Future<File> getFileFromUrl(String url) async {
    logger.info(ProductDetail.TAG, "Getting PDF File from the Url: " + url);
    try {
      var data = await http.get(url);
      var bytes = data.bodyBytes;
      var dir = await getApplicationDocumentsDirectory();
      File file = File("${dir.path}/mypdfonline.pdf");

      File urlFile = await file.writeAsBytes(bytes);
      return urlFile;
    } catch (e) {
      logger.error(ProductDetail.TAG, "Error while getting the Pdf from URL :" + url);
       Exception("Error opening url file");
    }
  }

  @override
  Widget build(BuildContext context) {
    void navigateToCustomerAddress(User userInfo) async{
     Navigator.push(context, MaterialPageRoute(builder: (context)=> AddUserDetails(widget.pd,userInfo,widget.user,widget.online,widget.offline,widget.auth)));
  }
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
                   Text(widget.pd.title,style: TextStyle(fontWeight: FontWeight.bold,fontSize: 15,color: Colors.blue),),
                   Spacer(),
                   StarDisplay(value: widget.pd.rating,),
             
                ],
                ),
                Text(widget.pd.sDesc),
                SizedBox(height: 20,),
                _showSlides(),
                //Image.network(pd.img),
        
        /*
                FutureBuilder(
                  future: _initializeVideoPlayerFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      return AspectRatio(
                        aspectRatio: _videoPlayerController.value.aspectRatio,
                        child:
                          CarouselSlider(
                            height: 300.0,
                            items: [
                              Image.network(widget.pd.img, fit: BoxFit.fill,),
                              VideoPlayer(_videoPlayerController),
                            ],
                          ), 
                      );
                    } else {
                      return Center(child: CircularProgressIndicator());
                    }
                  },
                ),
                FloatingActionButton(
                  backgroundColor: Colors.transparent,
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
                  ),
                ), 

                */
                SizedBox(height: 20,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                   Icon(FontAwesomeIcons.rupeeSign),
                   Text(widget.pd.price.toString(),style: TextStyle(fontWeight: FontWeight.bold,fontSize: 30),),
                   Spacer(),
                   getInventory(widget.pd.quantity),     
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
                  child: Text("Order Now",style: TextStyle(fontSize: 20),),
                  onPressed: buttonDisabled? null:(){
                    if(widget.user == null)
                    {
                      Navigator.pop(context);
                      widget.online();
                    }else
                    if(userInfo == null || userInfo.address == null || userInfo.phone == null)
                    {
                      showAlertDialog(context);
                    }else
                    navigateToCustomerAddress(userInfo);
                  },
                ),
                SizedBox(height: 20,),
                Text("About This Item",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20),),
                SizedBox(height: 10,),
                Text(widget.pd.lDesc,style: TextStyle(fontSize: 15),),
                SizedBox(height: 20,),
                Text('Customer Reviews',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20),),
                SizedBox(height: 10,),
                Text(widget.pd.review,style: TextStyle(fontSize: 15),),

                SizedBox(height: 20,), 
                ButtonTheme(
                  minWidth:400.0,
                  height:40.0,
                  child:RaisedButton(
                      
                      color: Colors.amber,
                      // width: double.infinity,
                      child: Text("FAQ"),
                      onPressed: () {
                        logger.error(ProductDetail.TAG, "Error while getting the Pdf from URL :" );
                        if (urlPDFPath != null) {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                         PdfViewPage(path: urlPDFPath)));
                                      // PdfViewPage(path: widget.pd.faq)));
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

  dynamic getInventory(int quantity){

    if(quantity <=0){
    buttonDisabled=true;
    inventoryDetail="Out of Stock";
    return  Text(inventoryDetail,style: TextStyle(color: Colors.red,) );
    }
    else
    if (quantity<5){
    inventoryDetail="Only $quantity left";
    return  Text(inventoryDetail,style: TextStyle(color: Colors.red,) );
    }
    else{
    inventoryDetail="In Stock";
    return  Text(inventoryDetail,style: TextStyle(color: Colors.green,) );
    }
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
                    ),
                  )
              )
          )
        ],
      );

  }

  Widget _showSlides(){
    return CarouselSlider(
      height: 300.0,
      items: [
        Image.network(widget.pd.img, fit: BoxFit.fill,),
         _showVideo(),
      ],
    );
}
}

class PdfViewPage extends StatefulWidget {
  final String path;

  const PdfViewPage({Key key, this.path}) : super(key: key);
  @override
  _PdfViewPageState createState() => _PdfViewPageState();
}

class _PdfViewPageState extends State<PdfViewPage> {
  int _totalPages = 0;
  int _currentPage = 0;
  bool pdfReady = false;
  PDFViewController _pdfViewController;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("FAQ"),
      ),
      body: Stack(
        children: <Widget>[
          PDFView(
            filePath: widget.path,
            autoSpacing: true,
            enableSwipe: true,
            pageSnap: true,
            swipeHorizontal: true,
            nightMode: false,
            onError: (e) {
              print(e);
            },
            onRender: (_pages) {
              setState(() {
                _totalPages = _pages;
                pdfReady = true;
              });
            },
            onViewCreated: (PDFViewController vc) {
              _pdfViewController = vc;
            },
            onPageChanged: (int page, int total) {
              setState(() {});
            },
            onPageError: (page, e) {},
          ),
          !pdfReady
              ? Center(
                  child: CircularProgressIndicator(),
                )
              : Offstage()
        ],
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          _currentPage > 0
              ? FloatingActionButton.extended(
                  backgroundColor: Colors.red,
                  label: Text("Go to ${_currentPage - 1}"),
                  onPressed: () {
                    _currentPage -= 1;
                    _pdfViewController.setPage(_currentPage);
                  },
                )
              : Offstage(),
          _currentPage+1 < _totalPages
              ? FloatingActionButton.extended(
                  backgroundColor: Colors.green,
                  label: Text("Go to ${_currentPage + 1}"),
                  onPressed: () {
                    _currentPage += 1;
                    _pdfViewController.setPage(_currentPage);
                  },
                )
              : Offstage(),
        ],
      ),
    );
  }
}