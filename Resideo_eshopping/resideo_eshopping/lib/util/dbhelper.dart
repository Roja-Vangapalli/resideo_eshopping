import 'package:resideo_eshopping/model/product.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:async';

class Dbhelper {
  static final Dbhelper _helper = Dbhelper.private();

  int _dbversion = 1;
  String _dbname = "eshoppingdb.db";
  String _tblname = 'Product';
  String _colid = "ProductId";
  String _coltitle = "ProductName";
  String _colsDesc = "ShortDescription";
  String _colimg = "Image";
  String _colprice = "Price";
  String _colquantity = "Inventory";
  String _collDesc = "LongDescription";
  String _colcategory = "Category";
  String _colrating = "Rating";
  String _colreview = "Review";
  String _colthumbnail = "Thumbnail";
  String _colfaq = "FAQ";
  String _colpVideo = "ProductVideo";
  String _collatitude = "Latitude";
  String _collongitude = "Longitude";

  Dbhelper.private();

  factory Dbhelper() {
    return _helper;
  }

  Database _db;

  Future<Database> get db async {
    if (_db == null || !_db.isOpen) _db = await initializedb();
    return _db;
  }

  Future<Database> initializedb() async {
    var eshoppingdb;
      Directory dir = await getApplicationDocumentsDirectory();
      String path = dir.path + _dbname;
      eshoppingdb =
          await openDatabase(path, version: _dbversion, onCreate: _createdb);
    return eshoppingdb;
  }

  void _createdb(Database db, int newversion) async {
      return await db.execute(
          'CREATE TABLE $_tblname($_colid INTEGER,$_coltitle TEXT,$_colsDesc TEXT,$_colimg TEXT,$_colprice INTEGER,$_colquantity INTEGER,$_collDesc TEXT,$_colcategory TEXT,$_colrating INTEGER,$_colreview TEXT,$_colthumbnail TEXT,$_colfaq TEXT,$_colpVideo TEXT,$_collatitude TEXT,$_collongitude TEXT)');

  }

  Future<int> _addProduct(Database db, Product pd) async {
    var result;
      result = await db.insert(_tblname, pd.toJson());
    return result;
  }

  void addAllProduct(List<Product> pd) async {
    Database db = await this.db;
    int count = pd.length;
    for (int i = 0; i < count; i++) {
      await _addProduct(db, pd[i]);
    }
    close();
  }

  Future<List> getProductListDb() async {
    Database db = await this.db;
    var result;
      result = await db.rawQuery('SELECT * FROM $_tblname');
    close();
    return result;
  }


  Future<int> updateInventoryById(int id, int newInventoryValue) async {
    Database db = await this.db;
    var result;
      result = await db.rawUpdate(
          "UPDATE $_tblname SET $_colquantity = $newInventoryValue WHERE $_colid = $id");
    close();
    return result;
  }

  Future close() async {
    Database db = await this.db;
      await db.close();
  }
}
