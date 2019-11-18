import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:resideo_eshopping/models/product.dart';
import 'package:resideo_eshopping/repository/get_Product.dart';
import 'package:resideo_eshopping/widgets/product_tile.dart';

class ProductListPage extends StatefulWidget {
  ProductListPage({Key key, this.title}) : super(key: key);

  String title;

  @override 
  _ProductListPageState createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> with SingleTickerProviderStateMixin{

  ScrollController _scrollController = ScrollController();

  List<Product> _products = <Product>[];

  AnimationController controller;
  Animation<double> animation;

  @override 
  Widget build(BuildContext context){
    var key = GlobalKey<ScaffoldState>();
    return Scaffold(
      key: key,
      appBar: AppBar(
        title: Text(widget.title),
        bottom: _createProgressIndicator(),
        actions: <Widget>[
          Container(
            margin: EdgeInsets.symmetric(vertical: 10),
            height: 100,
            width: 100,
            child: PopupMenuButton(
              child:Icon(Icons.filter_list),
              //onSelected: () => setState(),
              itemBuilder: (context) => [
                PopupMenuItem(
                  child: Text('Men'),
                ),
                PopupMenuItem(
                  child: Text('Women'),
                ),
                PopupMenuItem(
                  child: Text('Kids'),
                )
              ]
            ),
          ),
          //dropdownWidget(),
        ],
      ),
      body: 
      Container(
        padding: EdgeInsets.all(8.0),
        child: Stack(
          children: <Widget>[
            ListView.builder(
          itemCount: _products.length,
          controller: _scrollController,
          itemBuilder: (context, index) => ProductsTile(_products[index]), 
        ),
          ],
        ),
      ),
    );
  }


  @override 
  void initState() {
    super.initState();
    listenForProducts();
    controller = AnimationController(
      duration: const Duration(milliseconds: 10000), 
      vsync: this
    );
    animation = Tween(begin: 0.0, end: 20.0).animate(controller);
    controller.repeat();
    _scrollController.addListener(() {
    });
  }

  @override 
  void dispose(){
    _scrollController.dispose();
    controller.dispose();
    super.dispose();
  }

  void listenForProducts() async {
    Stream<Product> stream = await getProducts();
    stream.listen((Product products) =>
      setState(() => _products.add(products))
      );
  }

  PreferredSize _createProgressIndicator() => PreferredSize(
  preferredSize: Size(double.infinity, 4.0),
    child: SizedBox(
      height: 4.0,
      child: LinearProgressIndicator(value: animation.value,)
    )
  );

}
