import 'package:flutter/material.dart';
import 'package:resideo_eshopping/pages/product_List_Page.dart';

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
      //home: MyHomePage(title: 'Resideo e-Shopping'),
      home: ProductListPage(title: 'Resideo e-Shopping'),
    );
  }
}