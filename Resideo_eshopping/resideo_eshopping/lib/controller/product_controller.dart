import 'package:flutter/cupertino.dart';
import 'package:resideo_eshopping/model/product.dart';
import 'package:resideo_eshopping/util/dbhelper.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:resideo_eshopping/util/logger.dart' as logger;
//import 'package:catcher/catcher_plugin.dart';
import 'package:resideo_eshopping/model/places.dart';
import 'package:resideo_eshopping/util/firebase_database_helper.dart';

class ProductController{
  static const String TAG ="ProductController";
  List<Product> products = <Product>[];
  List<Product> currentList = List<Product>();

  static List<Place> placelist = <Place>[];

  Dbhelper helper = Dbhelper();
  FirebaseDatabaseUtil _firebaseDatabaseUtil = new FirebaseDatabaseUtil();

  /*Method to update the product model by getting data from local database or by calling updateProductModel method and
  calling filterProducts method by passing user choice and finally return the filter product list to product list screen
   */
  Future<List<Product>> getProductList(String value) async {
    if (products.length == 0) {
      List<Product> productlist = List<Product>();

      await helper.getProductListDb().timeout(Duration(seconds: 5)).then((result) async {
        int count = result.length;
        for (int i = 0; i < count; i++) {
          productlist.add(Product.fromJSON(result[i]));
        }
        if (productlist.length == 0)
          await updateProductModel();
        else {
          products = productlist;
        }
      })
          .catchError((error){
        logger.error(TAG, " Error in getProductList: "+ value +" " +error);
      });
    }
    return filterProducts(value);
  }

  //Method to fetch products from API
  Future<List<Product>> fetchProducts(http.Client client) async {
    var response;
       response = await client.get(
          'https://fluttercheck-5afbb.firebaseio.com/Products.json?auth=fzAIfjVy6umufLgQj9bd1KmgzzPd6Q6hDvj1r3u1').timeout(Duration(seconds: 5),
           onTimeout: () => _onTimeout());

    if(response.body == null)
      logger.error(TAG, "Connection Issue with Api :" );

    return parseProducts(response.body);
  }

  //Method to decode the Products json and convert it into list of product object
  List<Product> parseProducts(String responseBody) {
    List<Product> _localProductList;
      final parsed = jsonDecode(responseBody).cast<Map<String, dynamic>>();
       if(parsed != null) {
         _localProductList =
             parsed.map<Product>((json) => Product.fromJSON(json)).toList();
         if(_localProductList == null)
           logger.error(TAG, "Conversion from jsom map to product object have Issue :" );
       }else
      logger.error(TAG, "JasonDecode not working:" );
    return _localProductList;
  }

  void init() {
    _firebaseDatabaseUtil.initState();
  }

  //Method to update the product model with list of products
  Future updateProductModel() async {
    await fetchProducts(http.Client()).timeout(Duration(seconds: 5)).then((result) {
      if(result != null) {
        products = result;
        helper.addAllProduct(products);
      }else
        {
          logger.error(TAG, "Product are not fetched from the API" );
        }
    }).catchError((error,stackTrace){
//      Catcher.reportCheckedError(error, stackTrace);
      logger.error(TAG, "Error in updating" +error );
    });
  }

  //Method to filter the product on product list screen based on user input
  filterProducts(String value) {
    currentList.clear();
    if (value == "All") {
      currentList.addAll(products);
    } else {
      for (Product c in products) {
        if (c.category == value) {
          currentList.add(c);
        }
      }
    }
    return currentList;
  }

  //Method to return the update value of product quantity
  int decreaseInventoryCount(Product product) {
    if (product.quantity > 0)
      return (product.quantity - 1);
    else
      return 0;
  }

  //Method to update the inventory count in product model, firebase and local database when customer purchase the product
  Future<bool> updateInventory(Product product) async{
    bool isUpdateSuccessful=false;
    await helper
        .updateInventoryById(product.id, decreaseInventoryCount(product))
        .then((result) async{
      if (result == 1) {
        product.quantity = product.quantity - 1;
       await  _firebaseDatabaseUtil.updateProduct(product).then((result){
          if(result)
          isUpdateSuccessful=true;
        });
      }else
        logger.error(TAG, "Updating in local database is failed" );
    }).catchError((error,stackTrace){
//      Catcher.reportCheckedError(error, stackTrace);
      logger.error(TAG, " Error in updating the Inventory : " + error);
    });
    return isUpdateSuccessful;
  }

  //Method to enable or disable the order now button in product detail screen based on quantity of product
  bool enableDisableOrderNowButton(int quantity) {
    if (quantity <= 0)
      return true;
    else
      return false;
  }

  //Method to display the stock detail based on quantity of product on product detail page
  String inventoryDetail(int quantity) {
    String inventoryDetailMsg;

    if (quantity <= 0) {
      inventoryDetailMsg = "Out of Stock";
      return inventoryDetailMsg;
    } else if (quantity < 5) {
      inventoryDetailMsg = "Only $quantity left";
      return inventoryDetailMsg;
    } else {
      inventoryDetailMsg = "In Stock";
      return inventoryDetailMsg;
    }
  }
 //Method to set the color of inventory detail message on product detail screen
  dynamic inventoryDetailColor(int quantity){

    if(quantity < 5)
      return Color(0xFFF44336);
    else
      return Color(0xFF00C853);
  }

  Future<Stream<Place>> getPlaces() async {
    final String url = 'https://fluttercheck-5afbb.firebaseio.com/Place.json?auth=fzAIfjVy6umufLgQj9bd1KmgzzPd6Q6hDvj1r3u1';

    final client = new http.Client();
    final streamedRest = await client.send(
        http.Request('get', Uri.parse(url))
    );

    return streamedRest.stream
        .transform(utf8.decoder)
        .transform(json.decoder)
        .expand((data) => (data as List))
        .map((data) => Place.fromJSON(data));
  }

  void listenforplace() async {
    final Stream<Place> stream = await getPlaces();
    stream.listen((Place place) {
      placelist.add(place);
    });
  }



  _onTimeout() => logger.error(TAG, "Taking a longer time than usual");
}
