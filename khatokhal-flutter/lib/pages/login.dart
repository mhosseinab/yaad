import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:toggle_switch/toggle_switch.dart';

import '../controllers/auth_controller.dart';
import '../helpers/utils.dart';
import '../widgets/common.dart';

class LoginSheet extends StatelessWidget {
  final AuthController _authController = Get.put(AuthController());

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Obx(() {
        if (_authController.isNameRequired.value)
          return LoginStep3();
        else if (_authController.isLoggedIn.value)
          return LoginSuccess();
        else if (_authController.uuid.value.isEmpty)
          return LoginStep1();
        else if (_authController.uuid.value.isNotEmpty) return LoginStep2();
        return ErrorIcon();
      }),
    );
  }
}

class LoginStep1 extends StatefulWidget {
  @override
  State<LoginStep1> createState() => _LoginStep1State();
}

class _LoginStep1State extends State<LoginStep1> {
  final AuthController _authController = Get.find<AuthController>();

  final _controller = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          "ورود به حساب کاربری",
          style: Theme.of(context).textTheme.headline1,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 48.0),
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: Form(
              key: _formKey,
              child: TextFormField(
                controller: _controller,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null ||
                      value.isEmpty ||
                      !RegExp(r"^09\d{9}$").hasMatch(value)) {
                    return 'تلفن همراه را به درستی وارد کنید';
                  }
                  return null;
                },
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                ],
                style: TextStyle(
                  fontSize: 16.0,
                ),
                decoration: InputDecoration(
                    labelText: "شماره موبایل",
                    hintText: "09",
                    // icon: Icon(Icons.phone_iphone),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25.0),
                      borderSide: const BorderSide(),
                    ),
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0)),
              ),
            ),
          ),
        ),
        Obx(
          () => (_authController.error.value)
              ? Padding(
                  padding: const EdgeInsets.all(8.0),
                  child:
                      Text('خطایی رخ داد', style: TextStyle(color: Colors.red)),
                )
              : SizedBox.shrink(),
        ),
        Obx(() => ElevatedButton(
              style: redButtonStyle,
              onPressed: _authController.isLoading.value
                  ? null
                  : () async {
                      if (_formKey.currentState!.validate())
                        await _authController.getLoginToken(_controller.text);
                    },
              child: _authController.isLoading.value
                  ? SizedBox(
                      child: CircularProgressIndicator(),
                      height: 20.0,
                      width: 20.0,
                    )
                  : Text("ارسال کد تایید"),
            ))
      ],
    );
  }
}

class LoginStep2 extends StatelessWidget {
  final AuthController _authController = Get.find<AuthController>();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text("کد ۶ رقمی ارسال شده را وارد کنید"),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 48.0, vertical: 24.0),
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: PinCodeTextField(
              length: 6,
              obscureText: false,
              keyboardType: TextInputType.number,
              validator: (v) {
                if (v == null || v.isEmpty) return null;
                return isNumeric(v) ? null : "invalid numbers";
              },
              autovalidateMode: AutovalidateMode.always,
              animationType: AnimationType.fade,
              pinTheme: PinTheme(
                shape: PinCodeFieldShape.underline,
                activeFillColor: Colors.white,
                activeColor: Colors.green,
                inactiveColor: Colors.black38,
                inactiveFillColor: Colors.white70,
                selectedFillColor: Colors.white70,
                // borderRadius: BorderRadius.circular(5),
              ),
              animationDuration: Duration(milliseconds: 300),
              enableActiveFill: true,
              onCompleted: (v) async {
                if (!isNumeric(v)) return;
                await _authController.loginWithCode(v);
              },
              onChanged: (String value) {},
              appContext: context,
              errorTextSpace: 24.0,
            ),
          ),
        ),
        Obx(
          () => (_authController.allowResend.value)
              ? TextButton(
                  onPressed: () async {
                    _authController.uuid.value = "";
                    _authController.allowResend.value = false;
                    _authController.error.value = false;
                  },
                  child: Text("ارسال دوباره کد تایید"),
                )
              : Directionality(
                  textDirection: TextDirection.ltr,
                  child: OtpTimer(
                    seconds: 120,
                    callback: () {
                      _authController.allowResend.value = true;
                    },
                  ),
                ),
        ),
        Obx(
          () => (_authController.error.value)
              ? Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text('کد نامعتبر است',
                      style: TextStyle(color: Colors.red)),
                )
              : SizedBox.shrink(),
        ),
        Obx(() => _authController.isLoading.value
            ? SizedBox(
                child: CircularProgressIndicator(),
                height: 20.0,
                width: 20.0,
              )
            : SizedBox.shrink())
      ],
    );
  }
}

class LoginStep3 extends StatefulWidget {
  @override
  _LoginStep3State createState() => _LoginStep3State();
}

class _LoginStep3State extends State<LoginStep3> {
  final AuthController _authController = Get.find<AuthController>();

  final _controller1 = TextEditingController();
  final _controller2 = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool isStudent = true;

  @override
  void dispose() {
    _controller1.dispose();
    _controller2.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          "اطلاعات تکمیلی",
          style: Theme.of(context).textTheme.headline1,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 48.0),
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _controller1,
                    keyboardType: TextInputType.name,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'نام را به درستی وارد کنید';
                      }
                      return null;
                    },
                    style: TextStyle(
                      fontSize: 16.0,
                    ),
                    decoration: InputDecoration(
                        labelText: "نام",
                        // icon: Icon(Icons.phone_iphone),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25.0),
                          borderSide: const BorderSide(),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                            vertical: 8.0, horizontal: 12.0)),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _controller2,
                    keyboardType: TextInputType.name,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'نام خانوادگی را به درستی وارد کنید';
                      }
                      return null;
                    },
                    style: TextStyle(
                      fontSize: 16.0,
                    ),
                    decoration: InputDecoration(
                        labelText: "نام خانوادگی",
                        // icon: Icon(Icons.phone_iphone),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25.0),
                          borderSide: const BorderSide(),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                            vertical: 8.0, horizontal: 12.0)),
                  ),
                  const SizedBox(height: 10),
                  // Here, default theme colors are used for activeBgColor, activeFgColor, inactiveBgColor and inactiveFgColor
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('دانش‌آموز هستید؟'),
                      ToggleSwitch(
                        initialLabelIndex: 1,
                        totalSwitches: 2,
                        labels: ['خیر', 'بله'],
                        inactiveBgColor: Colors.grey[300],
                        onToggle: (index) {
                          isStudent = index == 1;
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        Obx(
          () => (_authController.error.value)
              ? Padding(
                  padding: const EdgeInsets.all(8.0),
                  child:
                      Text('خطایی رخ داد', style: TextStyle(color: Colors.red)),
                )
              : SizedBox.shrink(),
        ),
        Obx(() => ElevatedButton(
              style: redButtonStyle,
              onPressed: _authController.isLoading.value
                  ? null
                  : () async {
                      if (_formKey.currentState!.validate())
                        await _authController.setProfile(
                            _controller1.text, _controller2.text, isStudent);
                    },
              child: _authController.isLoading.value
                  ? SizedBox(
                      child: CircularProgressIndicator(),
                      height: 20.0,
                      width: 20.0,
                    )
                  : Text("تکمیل ثبت نام"),
            ))
      ],
    );
  }
}

class LoginSuccess extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Lottie.asset(
            'assets/other/tick-green.json',
            repeat: false,
            width: 70,
            height: 70,
            fit: BoxFit.fill,
          ),
          SizedBox(height: 10),
          Text('ورود با موفقیت انجام شد'),
        ]);
  }
}

void showLoginBottomSheet(BuildContext context) {
  showModalBottomSheet(
    isScrollControlled: true,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(25.0),
      ),
    ),
    clipBehavior: Clip.antiAliasWithSaveLayer,
    backgroundColor: Colors.white,
    context: context,
    builder: (builder) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 48.0, horizontal: 8.0),
      child: LoginSheet(),
    ),
  );
}
