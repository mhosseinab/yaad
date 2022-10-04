import 'dart:io';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:url_launcher/url_launcher.dart';

import '../colors.dart';
import '../helpers/utils.dart';
import '../widgets/common.dart';
import '../widgets/drawer.dart';
import 'MyBooksLibrary.dart';
import 'Store.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int tabIndex = 0;
  bool isCheckedForUpdate = false;
  DateTime currentBackPressTime = DateTime.now();

  checkForUpdate() {
    isCheckedForUpdate = true;
    print("checkForUpdate");
    InAppUpdate.checkForUpdate().then((info) {
      if (info.updateAvailability == UpdateAvailability.updateAvailable) {
        InAppUpdate.performImmediateUpdate().catchError((e) => showSnackbar(
            context, "نسخه جدید منتشر شده نصب نشد. بروزرسانی کنید",
            barType: SnackBarType.error));
      } else {
        print("no updates");
      }
    }).catchError((e) {
      print(e.toString());
    });
  }

  requestReview() async {
    final int now = DateTime.now().millisecondsSinceEpoch;
    final reviewNoticeTime =
        ReadWriteValue('reviewNoticeTime', now + 60 * 60 * 24 * 1000);

    print("reviewNoticeTime 1 : ${reviewNoticeTime.val}");
    if (now > reviewNoticeTime.val) {
      final InAppReview inAppReview = InAppReview.instance;
      print("requestReview");

      if (await inAppReview.isAvailable()) {
        inAppReview.requestReview();
      } else {
        print("inAppReview isNotAvailable");
      }

      reviewNoticeTime.val = now + 60 * 60 * 24 * 1000;
    }

    print("reviewNoticeTime 2 : ${reviewNoticeTime.val}");
  }

  Future<bool> onWillPop() {
    DateTime now = DateTime.now();
    if (now.difference(currentBackPressTime) > Duration(seconds: 2)) {
      currentBackPressTime = now;
      showSnackbar(context, "برای خروج دکمه بازگشت را دوباره بزنید");
      return Future.value(false);
    }
    return Future.value(true);
  }

  void changeTabIndex(index) {
    if (tabIndex != index)
      setState(() {
        tabIndex = index;
      });
  }

  @override
  void initState() {
    if (Platform.isAndroid && !isCheckedForUpdate) checkForUpdate();
    requestReview();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            const ['فروشگاه', 'کتابخانه'][tabIndex],
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: MaterialColor(0xffee3734, RedColor)),
          ),
          actions: [
            IconTextButton(
              icon: const FaIcon(
                FontAwesomeIcons.whatsapp,
                color: Colors.black87,
                size: 20,
              ),
              text: Text(
                "ارتباط با ما",
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 11,
                ),
              ),
              onPressed: () {
                launch("https://api.whatsapp.com/send?phone=989012334597");
              },
            ),
            IconTextButton(
              icon: const FaIcon(
                FontAwesomeIcons.bookmark,
                color: Colors.black87,
                size: 20,
              ),
              text: Text(
                "نشان شده‌ها",
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 11,
                ),
              ),
              onPressed: () {
                Get.toNamed('/favorites');
              },
            ),
          ],
        ),
        body: SafeArea(
          child: IndexedStack(
            index: tabIndex,
            children: [
              // ReportPage(),
              StorePage(),
              MyBooksPage(),
            ],
          ),
        ),
        drawer: AppDrawer(),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: tabIndex,
          onTap: changeTabIndex,
          //showUnselectedLabels: false,
          items: [
            // const BottomNavigationBarItem(
            //   icon: const Icon(Icons.bar_chart),
            //   label: 'گزارش',
            // ),
            const BottomNavigationBarItem(
              icon: const Icon(Icons.shopping_bag),
              label: 'فروشگاه',
            ),
            const BottomNavigationBarItem(
              icon: const Icon(Icons.home_filled),
              label: 'کتابخانه',
            ),
          ],
        ),
      ),
    );
  }
}
