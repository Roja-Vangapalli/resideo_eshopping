import 'package:mobx/mobx.dart';
import 'package:resideo_eshopping/stores/error_store.dart';
import 'package:validators/validators.dart';

part 'login_page_store.g.dart';

class LoginPageStore = _LoginPageStore with _$LoginPageStore;

abstract class _LoginPageStore with Store {
  // store for handling form errors
  final FormErrorStore formErrorStore = FormErrorStore();

  // store for handling error messages
  final ErrorStore errorStore = ErrorStore();

  _LoginPageStore() {
    _setupValidations();
  }

  List<ReactionDisposer> _disposers;

  void _setupValidations() {
    _disposers = [
      reaction((_) => email, validateEmail),
      reaction((_) => password, validatePassword),
    ];
  }

  @observable
  String email = '';

  @observable
  String password = '';

  @observable
  bool success = false;

  @observable
  bool loading = false;

  @computed
  bool get canLogin =>
      !formErrorStore.hasErrorsInLogin && email.isNotEmpty && password.isNotEmpty;

  @computed
  bool get canSignUp =>
      !formErrorStore.hasErrorsInSignUp && email.isNotEmpty && password.isNotEmpty;

  @action
  void setEmail(String value) {
    email = value;
  }

  @action
  void setPassword(String value) {
    password = value;
  }

  @action
  void validateEmail(String value) {
    if (value.isEmpty) {
      formErrorStore.email = "Email can't be empty";
    } else if (!isEmail(value)) {
      formErrorStore.email = 'Please enter a valid email address';
    } else {
      formErrorStore.email = null;
    }
  }

  @action
  void validatePassword(String value) {
    if (value.isEmpty) {
      formErrorStore.password = "Password can't be empty";
    } else {
      formErrorStore.password = null;
    }
  }


  @action
  Future login() async {
    loading = true;

    Future.delayed(Duration(milliseconds: 4000)).then((future) {
      loading = false;
      success = true;
      errorStore.showError = false;
    });
  }


  void dispose() {
    for (final d in _disposers) {
      d();
    }
  }

}

class FormErrorStore = _FormErrorStore with _$FormErrorStore;

abstract class _FormErrorStore with Store {
  @observable
  String email;

  @observable
  String password;

  @computed
  bool get hasErrorsInLogin => email != null || password != null;

  @computed
  bool get hasErrorsInSignUp => email != null || password != null;
}
