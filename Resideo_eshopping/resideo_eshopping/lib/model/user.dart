import 'package:firebase_database/firebase_database.dart';

class User
{
  String _id;
  String _name;
  String _email;
  String _phone;
  String _address;
  String _zipcode;
  String _password;
  String _imageUrl;

  User(this._name,this._email,this._phone,this._address,this._zipcode,this._password);

  String get id => _id;
  String get name => _name;
  String get email => _email;
  String get phone => _phone;
  String get address => _address;
  String get zipcode => _zipcode;
  String get password => _password;
  String get imageUrl => _imageUrl;
  
  User.fromSnapshot(DataSnapshot snapshot){
    _id=snapshot.key;
    _name=snapshot.value['name'];
    _email=snapshot.value['email'];
    _phone=snapshot.value['phone'];
    _password=snapshot.value['password'];
    _address=snapshot.value['address'];
    _zipcode=snapshot.value['zipcode'];
    _imageUrl=snapshot.value['imageUrl'];
  }
}