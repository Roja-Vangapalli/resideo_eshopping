import 'package:after_layout/after_layout.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:provider/provider.dart';
import 'package:resideo_eshopping/model/user_repository.dart';
import 'package:resideo_eshopping/widgets/progress_indicator.dart';
import 'package:resideo_eshopping/widgets/strings.dart';
import 'package:resideo_eshopping/widgets/text_field.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:resideo_eshopping/stores/login_page_store.dart';
import 'package:resideo_eshopping/util/logger.dart' as logger;

enum FormMode {LOGIN, SIGNUP}

class LoginPage extends StatefulWidget{
  LoginPage({ this.onSignedIn});
  final VoidCallback onSignedIn;
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with AfterLayoutMixin<LoginPage>{
  TextEditingController _email = TextEditingController();
  TextEditingController _password = TextEditingController();
  bool isOpen =false;

  FocusNode _passwordFocusNode;

  static const String TAG ="LoginSignUpPage";
  final _formKey = GlobalKey<FormState>();
  final _key = GlobalKey<ScaffoldState>();
  final _store = LoginPageStore();
  FormMode _formMode = FormMode.LOGIN;
  String userId = "";
  @override
  void afterFirstLayout(BuildContext context){
    _passwordFocusNode = FocusNode();

    _email.addListener(() {
      _store.setEmail(_email.text);
    });
    _password.addListener(() {
      _store.setPassword(_password.text);
    });
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      key: _key,
      appBar: AppBar(
        title: Text("Resideo E-Shopping"),
      ),
      body: _buildBody(),
    );
  }

  Material _buildBody() {
    return Material(
      child:
      Stack(
        children: <Widget>[
          _buildForm(),
          Observer(
            builder: (context) {
              return Visibility(
                visible: _store.loading,
                child: ProgressIndicatorWidget(),
              );
            },
          )
        ],
      ),
    );
  }


  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SizedBox(height: 24.0),
              _showLogo(),
              _buildEmailField(),
              _buildPasswordField(),
              _buildSignInButton(),
              _showSecondaryButton()
            ],
          ),
        ),
      ),
    );
  }

  Widget _showLogo() {
    return new Hero(
      tag: 'hero',
      child: Padding(
        padding: EdgeInsets.only(right: 50,top: 30),
        child: CircleAvatar(
          backgroundColor: Colors.transparent,
          radius: 80.0,
          child: GestureDetector(
          child:Image.asset('assets/images/logo.png'),
          ),
          
        ),
      ),
    );
  }

  Widget _buildEmailField() {
    return Observer(
      builder: (context) {
        return TextFieldWidget(
          hint: Strings.login_et_user_email,
          inputType: TextInputType.emailAddress,
          icon: Icons.person,
          iconColor: Colors.black54,
          textController: _email,
          inputAction: TextInputAction.next,
          onFieldSubmitted: (value) {
            FocusScope.of(context).requestFocus(_passwordFocusNode);
          },
          errorText: _store.formErrorStore.email,
        );
      },
    );
  }

  Widget _buildPasswordField() {
    return Observer(
      builder: (context) {
        return TextFieldWidget(
          hint: Strings.login_et_user_password,
          isObscure: true,
          padding: EdgeInsets.only(top: 16.0),
          icon: Icons.lock,
          iconColor: Colors.black54,
          textController: _password,
          errorText: _store.formErrorStore.password,
        );
      },
    );
  }


  Widget _buildSignInButton() {
    UserRepository user = Provider.of<UserRepository>(context);
        return Padding(
          padding: EdgeInsets.fromLTRB(0.0, 45.0, 0.0, 0.0),
          child: SizedBox(
              height: 40.0,
              child: new RaisedButton(
                elevation: 5.0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
                color: Colors.blue,

                onPressed: () async {
                try{

                  if(_store.canLogin) _store.login();

                  if (_formKey.currentState.validate()) {
                    if(_formMode == FormMode.LOGIN){
                      SharedPreferences prefs = await SharedPreferences.getInstance();
                      userId = await user.signIn(_email.text, _password.text);
                      prefs.setString('uid', userId);

                      if (!mounted) return;
                      if(mounted) {
                        setState(() {
                          if (userId != null) {
                            Navigator.of(context).pop();
                            UserRepository user1 = Provider.of<UserRepository>(context);
                           user1.getUserdetails();
                            Flushbar(
                              message: "You are Signed in!",
                              duration: Duration(seconds: 3),
                            )
                           
                              ..show(context);
                          }
                          else {
                            Flushbar(
                              message: "Not signed in! Please enter correct details",
                              duration: Duration(seconds: 3),
                            )
                              ..show(context);
                          }
                        });
                      }
                    }
                    else{
                      userId = await user.signUp(_email.text, _password.text);
                      if(userId != null){
                        Flushbar(
                          message: "Created account Successfully",
                          duration: Duration(seconds: 3),
                        )..show(context);
                      }
                      else{
                        Flushbar(
                          message: "Account is not created! Please add valid details.",
                          duration: Duration(seconds: 3),
                        )..show(context);
                      }
                    }

                          if ( userId != null && userId.length > 0 && _formMode == FormMode.LOGIN) {
                            widget.onSignedIn();

                          }
                  }

                  }catch (e) {
                  Flushbar(
                    message: "Not signed in! Please enter correct details",
                    duration: Duration(seconds: 3),
                  )..show(context);
                  logger.error(TAG, " Error in sending the Data to  the Firbase ");

                }
                },
                child: _formMode == FormMode.LOGIN
                    ? Text('Login',
                    style: TextStyle(fontSize: 20.0, color: Colors.white))
                    : Text('Create account',
                    style: TextStyle(fontSize: 20.0, color: Colors.white)),
              )),
        );
  }

  Widget _showSecondaryButton() {
        return
          FlatButton(
              child:
              _formMode == FormMode.LOGIN
                  ? Text('Create an account',
                  style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w300))
                  : Text('Have an account? Sign in',
                  style:
                  TextStyle(fontSize: 18.0, fontWeight: FontWeight.w300)),
              onPressed: _formMode == FormMode.LOGIN ? _changeFormToSignUp : _changeFormToLogin
          );
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void _changeFormToSignUp(){
    if (mounted) {
    setState(() {
      _email.clear();
      _password.clear();
      _formMode = FormMode.SIGNUP;
    });
    }
  }

  void _changeFormToLogin(){
    if (mounted) {
    setState(() {
      _email.clear();
      _password.clear();
      _formMode = FormMode.LOGIN;
    });
    }

  }

}

