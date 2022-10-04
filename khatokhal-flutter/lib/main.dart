import 'dart:io';

import 'package:appmetrica_sdk/appmetrica_sdk.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import './controllers/auth_controller.dart';
import './routes.dart';
import 'colors.dart';
import 'models/db.dart';

late ObjectBox objectbox;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  ByteData data =
      await PlatformAssetBundle().load('assets/ca/lets-encrypt-r3.pem');
  SecurityContext.defaultContext
      .setTrustedCertificatesBytes(data.buffer.asUint8List());

  await GetStorage.init();
  await Firebase.initializeApp();

  /// Initializing the AppMetrica SDK.
  await AppmetricaSdk()
      .activate(apiKey: 'df137d6d-dda9-4d68-b8e6-db14439e18c0');

  Get.put(AuthController());

  objectbox = await ObjectBox.create();

  if (Platform.isAndroid) {
    await AndroidInAppWebViewController.setWebContentsDebuggingEnabled(true);
  }

  if (kDebugMode) {
    await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(false);
  } else {
    await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
  }

  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;

  runApp(AppMain());
}

class AppMain extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'خط و خال',
      localizationsDelegates: [
        GlobalCupertinoLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: [
        Locale("fa", ""),
      ],
      locale: Locale("fa", ""),
      theme: ThemeData(
        pageTransitionsTheme: PageTransitionsTheme(
          builders: {
            TargetPlatform.android: CupertinoPageTransitionsBuilder(),
            TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          },
        ),
        colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: Color(0xffee3734),
              background: Colors.black12,
            ),
        fontFamily: 'Vazir',
        primarySwatch: MaterialColor(0xffee3734, RedColor),
        primaryTextTheme: TextTheme(
            headline6: TextStyle(
                color: Color(0xffee3734),
                fontSize: 16,
                fontWeight: FontWeight.bold)),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.white,
          iconTheme: IconThemeData(color: Colors.black),
        ),
        textTheme: TextTheme(
          headline1: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 18,
            color: Colors.black87,
          ),
          headline2: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 16,
            color: Colors.black87,
          ),
          headline3: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 15,
            color: Colors.black87,
          ),
          headline4: TextStyle(
            fontWeight: FontWeight.w400,
            fontSize: 15,
            color: Colors.black87,
          ),
          headline5: TextStyle(
            fontWeight: FontWeight.w300,
            fontSize: 14,
            color: Colors.black87,
          ),
          headline6: TextStyle(
            fontWeight: FontWeight.w200,
            fontSize: 14,
            color: Colors.black87,
          ),
          subtitle1: TextStyle(
            fontWeight: FontWeight.w300,
            fontSize: 14,
            color: Colors.black87,
          ),
          bodyText1: TextStyle(
            fontWeight: FontWeight.w400,
            fontSize: 14,
            color: Color(0xffee3734),
          ),
          bodyText2: TextStyle(
            fontWeight: FontWeight.w400,
            fontSize: 14,
            color: Colors.black87,
          ),
          subtitle2: TextStyle(
            fontWeight: FontWeight.w400,
            fontSize: 14,
            color: Colors.white,
          ),
        ),
      ),
      initialRoute: '/',
      getPages: Routes.routes,
    );
  }
}
