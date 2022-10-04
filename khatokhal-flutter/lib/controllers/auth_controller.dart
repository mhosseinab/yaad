import 'dart:convert';

import 'package:appmetrica_sdk/appmetrica_sdk.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:get/state_manager.dart';
import 'package:get_storage/get_storage.dart';

import '../models/User.dart';
import '../services/backend.dart';

class AuthController extends GetxController {
  final box = GetStorage();

  var isLoggedIn = false.obs;
  var isLoading = false.obs;
  var error = false.obs;
  var allowResend = false.obs;
  var isNameRequired = false.obs;
  var uuid = "".obs;
  LoggedInUser? user;

  final token = ReadWriteValue('token', '');
  final mobile = ReadWriteValue('mobile', '');
  final userID = ReadWriteValue('userID', 0);

  @override
  void onInit() {
    checkToken();

    super.onInit();
  }

  Future checkToken() async {
    if (token.val.isEmpty) return;
    user = await BackendService.checkToken(token.val, userID.val);
    isLoggedIn.value = user != null;
    if (!isLoggedIn.value) {
      logout();
    } else {
      AppmetricaSdk().setUserProfileID(userProfileID: user!.id.toString());
    }
  }

  Future<bool> getLoginToken(String mobile) async {
    isLoading.value = true;
    error.value = false;
    if (mobile.startsWith("+98")) mobile = mobile.substring(1);
    if (mobile.startsWith("09")) mobile = "98" + mobile.substring(1);
    TokenRequest? response = await BackendService.getLoginCode(mobile);
    isLoading.value = false;
    if (response == null || !response.success) {
      error.value = true;
      return false;
    }
    uuid.value = response.uuid ?? "";
    return true;
  }

  Future<bool> loginWithCode(String code) async {
    isLoading.value = true;
    error.value = false;
    LoginResponse? response =
        await BackendService.loginWithCode(uuid.value, code);
    isLoading.value = false;
    if (response == null || !response.success || response.data == null) {
      error.value = true;
      return false;
    }
    User? user = response.data;

    isNameRequired.value = user!.firstName == null ||
        user.firstName!.isEmpty ||
        user.lastName == null ||
        user.lastName!.isEmpty;
    isLoggedIn.value = true;
    token.val = user.token;
    mobile.val = user.mobile;
    userID.val = user.id;

    FirebaseAnalytics()
        .logEvent(name: isNameRequired.value ? 'sign_up' : 'login');

    checkToken();
    return true;
  }

  void logout() {
    token.val = "";
    mobile.val = "";
    userID.val = 0;
    isLoggedIn.value = false;
    uuid.value = "";
    isNameRequired.value = false;
  }

  Future<bool> setProfile(
      String firstName, String lastName, bool isStudent) async {
    isLoading.value = true;
    error.value = false;
    LoggedInUser? response = await BackendService.setProfile(
        token.val,
        userID.val,
        jsonEncode(<String, dynamic>{
          'first_name': firstName,
          'last_name': lastName,
          "profile": {"is_student": isStudent}
        }));
    isLoading.value = false;
    if (response == null) {
      error.value = true;
      return false;
    }
    isNameRequired.value = false;
    return true;
  }
}
