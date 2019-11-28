import 'package:flutter/material.dart';
import 'package:resideo_eshopping/Screens/product_list_page.dart';
import 'package:resideo_eshopping/Screens/signup.dart';
void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Resideo e-Shopping',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: SignUp(),
      //home: ProductsListPage(title: 'Resideo e-Shopping'),
    );
  }
}