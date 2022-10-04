import 'dart:io';

import 'package:appmetrica_sdk/appmetrica_sdk.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

// import 'package:workmanager/workmanager.dart';

import './controllers/auth_controller.dart';
import './routes.dart';
import 'colors.dart';
import 'models/db.dart';

late ObjectBox objectBox;
late ByteData boxReference;
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

class ReceivedNotification {
  ReceivedNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.payload,
  });

  final int id;
  final String? title;
  final String? body;
  final String? payload;
}

String? selectedNotificationPayload;
void callbackDispatcher() async {
  /*WidgetsFlutterBinding.ensureInitialized();
  objectBox = await ObjectBox.create();
  objectBox.store = Store.fromReference(getObjectBoxModel(), boxReference);

  ChapterController controller = Get.put(ChapterController());

  final int? count = controller.getAllTodayQuestionCount();

  if (count == null) {
    return;
  } else {
    Workmanager().executeTask((task, inputData) {
      showNotification(
        title: 'یادآوری',
        body: count > 0
            ? '$count تست جدید منتظر شماست.'
            : 'درسنامه های امروز منتظر شماست',
        payload: 'payload',
      );
      return Future.value(true);
    });
  }*/
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  ByteData data =
      await PlatformAssetBundle().load('assets/ca/lets-encrypt-r3.pem');
  SecurityContext.defaultContext
      .setTrustedCertificatesBytes(data.buffer.asUint8List());

  await GetStorage.init();
  await Firebase.initializeApp();

  Get.put(AuthController());

  objectBox = await ObjectBox.create();
  boxReference = objectBox.store.reference;

  if (Platform.isAndroid) {
    await AndroidInAppWebViewController.setWebContentsDebuggingEnabled(true);
  }

  await FirebaseCrashlytics.instance
      .setCrashlyticsCollectionEnabled(!kDebugMode);

  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;

  // Workmanager().initialize(
  //     callbackDispatcher, // The top level function, aka callbackDispatcher
  //     isInDebugMode: kDebugMode);

  initializeNotification();

  // Workmanager().cancelAll();
  // Workmanager().registerPeriodicTask(
  //   "1",
  //   "REVIEW_NOTICE",
  //   frequency: const Duration(minutes: 15),
  // );

  runApp(const AppMain());
}

void selectNotification(String? payload) async {
  debugPrint('notification payload: $payload');
}

void initializeNotification() async {
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
// initialise the plugin. app_icon needs to be a added as a drawable resource to the Android head project
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/launcher_icon');
  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
  );
  await flutterLocalNotificationsPlugin.initialize(initializationSettings,
      onSelectNotification: selectNotification);
}

void showNotification(
    {required String title, required String body, String? payload}) async {
  const AndroidNotificationDetails androidPlatformChannelSpecifics =
      AndroidNotificationDetails('1', 'Yaad',
          channelDescription: 'Yaad events channel',
          importance: Importance.max,
          priority: Priority.high,
          ticker: 'ticker');
  const NotificationDetails platformChannelSpecifics =
      NotificationDetails(android: androidPlatformChannelSpecifics);
  await flutterLocalNotificationsPlugin.show(
    0,
    title,
    body,
    platformChannelSpecifics,
    payload: payload,
  );
}

class AppMain extends StatelessWidget {
  const AppMain({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'خط و خال',
      localizationsDelegates: const [
        GlobalCupertinoLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale("fa", ""),
      ],
      locale: const Locale("fa", ""),
      theme: ThemeData(
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.android: CupertinoPageTransitionsBuilder(),
            TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          },
        ),
        colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: const Color(0xff81c451),
              background: Colors.black12,
            ),
        fontFamily: 'Vazir',
        primarySwatch: const MaterialColor(0xffee3734, redColor),
        primaryTextTheme: const TextTheme(
            headline6: TextStyle(
                color: Color(0xff81c451),
                fontSize: 16,
                fontWeight: FontWeight.bold)),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          iconTheme: IconThemeData(color: Colors.black),
        ),
        textTheme: const TextTheme(
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
            color: Color(0xff81c451),
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
