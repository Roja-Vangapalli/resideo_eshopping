// import 'package:flutter/material.dart';
// import 'package:mobx/mobx.dart';
// import 'package:resideo_eshopping/Screens/product_list_page.dart';
// import 'package:resideo_eshopping/controller/product_controller.dart';
// import 'package:resideo_eshopping/util/firebase_database_helper.dart';
// import 'package:resideo_eshopping/model/product.dart';
// import 'package:resideo_eshopping/model/User.dart';
// import 'package:resideo_eshopping/util/logger.dart' as logger;

// part 'product_list_page_store.g.dart';

// class ProductsListPageStore = _ProductsListPageStore with _$ProductsListPageStore;

// abstract class _ProductsListPageStore with Store {
//   List<Product> currentList = <Product>[];
//   BuildContext context;
//   User userInfo;
//   User user;
//   static const String TAG = "ProductsListPageStore";
//   FirebaseDatabaseUtil firebaseDatabaseUtil;
//   ProductController productController = ProductController();
//   ProductsListPage productsListPage =ProductsListPage();
//   @observable
//   String _name = "";
//   @observable
//   String _email = "";
//   @observable
//   String _imageUrl = null;
//   @observable
//   bool isProfile = false;
//   @observable
//   bool _isProgressBarShown = false;

//   @action
//    closeUserProfile() {
//     getUserDetail( );
//     isProfile = false;
//   }

//   @action
//   void setProfile() {
//     if (productsListPage.user == null) {
//       _name = "";
//       _email = "";
//       _imageUrl = null;
//     } else {
//       _email = productsListPage.user.email.toString();
//     }
//   }

//   @action
//   getUserDetail() {
//     if (productsListPage.user != null) {
//       logger.info(
//           TAG, " Getting the User details from API  :");
//       firebaseDatabaseUtil.getUserData(productsListPage.user).then((result) {
//         userInfo = result;
//         if (userInfo != null) {
//           logger.info(TAG,
//               " Getting the User INFO details from API  are not null :");
//           _name = userInfo.name;
//           _imageUrl = userInfo.imageUrl;
//         } else {
//           logger.info(TAG,
//               " Getting the User INFO details from API  are null :");
//         }
//       }).catchError((error) {
//         logger.error(TAG,
//             " Error in the getting user details from API  :" + error);
//       });
//     } else {
//       logger.info(TAG, " widget user are null :");
//     }
//   }

//   @action
//   getProduct(String value) {
//     logger.info(TAG, " _getProduct method for getting products:");

//     productController.getProductList(value).then((result) {
//       if (result != null) {
//         currentList = result;
//         logger.info(TAG, " Getting the Products details from API  :" + value);
//         _isProgressBarShown = false;
//       }
//       else {
//         logger.info(TAG, " product list is empty  :");
//       }
//     }).catchError((error) {
//       logger.error(TAG, " product list is empty  :" + error);
//     });
//   }
// }