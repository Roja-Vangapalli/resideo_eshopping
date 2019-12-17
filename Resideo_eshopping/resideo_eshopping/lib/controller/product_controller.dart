import 'package:resideo_eshopping/model/product.dart';
import 'package:resideo_eshopping/util/dbhelper.dart';
import 'package:resideo_eshopping/repository/products_repository.dart';
import 'package:resideo_eshopping/util/crud_operations.dart';
import 'package:resideo_eshopping/util/logger.dart' as logger;

class ProductController {
  static List<Product> products = <Product>[];
  List<Product> currentList = List<Product>();
  Dbhelper helper = Dbhelper();
  FirebaseDatabaseUtil help = new FirebaseDatabaseUtil();

  Future<List<Product>> getProductList(String value) async {

    if (products.length == 0) {
      List<Product> productlist = List<Product>();

      await helper.getProductListDb().then((result) {
        int count = result.length;
        for (int i = 0; i < count; i++) {
          productlist.add(Product.fromObject(result[i]));
        }
        if (productlist.length == 0)
          listenForProducts();
        else {
          products = productlist;
        }
      });
    }
    return filterProducts(value);
  }

  void init() {
    help.initState();
  }

  void listenForProducts() async {
    Stream<Product> stream = await getProducts();
    stream.listen((Product product) {
      products.add(product);
    }, onDone: () {
      helper.addAllProduct(products);
    });
  }

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

  int _decreaseInventoryCount(Product product) {
    if (product.quantity > 0)
      return (product.quantity - 1);
    else
      return 0;
  }

  void updateInventory(Product product) {
    helper
        .updateInventoryById(product.id, _decreaseInventoryCount(product))
        .then((result) {
      if (result != null) {
        product.quantity = product.quantity - 1;
        help.updateProduct(product);
      }
    });
  }
}
