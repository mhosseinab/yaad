import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../controllers/auth_controller.dart';
import '../pages/login.dart';

String convertToPersianNumber(int number) {
  String res = '';
  String _number = NumberFormat.decimalPattern().format(number);
  final _persian = ['۰', '۱', '۲', '۳', '۴', '۵', '۶', '۷', '۸', '۹'];
  _number.characters.forEach((element) {
    res += (int.tryParse(element) != null)
        ? _persian[int.parse(element)]
        : element;
  });
  return res;
}

String removeAllHtmlTags(String htmlText) {
  return Bidi.stripHtmlIfNeeded(htmlText);
}

String removeEmptyHTMLLines(String htmlText) {
  RegExp exp = RegExp(r"<[^/>][^>]*>((\&nbsp\;\s?)+)?<\/[^>]+>",
      multiLine: true, caseSensitive: true);

  return htmlText.replaceAll(exp, '');
}

MaterialColor getRandomColor() {
  return Colors.primaries[Random().nextInt(Colors.primaries.length)];
}

class TimeAgo {
  static String timeAgoSinceDate(int timestamp, {bool numericDates = true}) {
    DateTime _date = DateTime.fromMillisecondsSinceEpoch(timestamp);

    final date2 = DateTime.now();
    final difference = date2.difference(_date);
    // print(difference.inDays);
    if (difference.inDays > 8) {
      return '${convertToPersianNumber((difference.inDays / 7).floor())} هفته پیش';
    } else if ((difference.inDays / 7).floor() >= 1) {
      return (numericDates) ? '۱ هفته پیش' : 'هفته پیش';
    } else if (difference.inDays >= 2) {
      return '${convertToPersianNumber(difference.inDays)} روز پیش';
    } else if (difference.inDays >= 1) {
      return (numericDates) ? '۱ روز پیش' : 'دییروز';
    } else if (difference.inHours >= 2) {
      return '${convertToPersianNumber(difference.inHours)} ساعت پیش';
    } else if (difference.inHours >= 1) {
      return (numericDates) ? '۱ ساعت پیش' : 'ساعتی پیش';
    } else if (difference.inMinutes >= 2) {
      return '${convertToPersianNumber(difference.inMinutes)} دقیقه پیش';
    } else if (difference.inMinutes >= 1) {
      return (numericDates) ? '۱ دقیه' : 'دقیقه ای پیش';
    } else if (difference.inSeconds >= 3) {
      return '${convertToPersianNumber(difference.inSeconds)} ثانیه پیش';
    } else {
      return 'لحظه ای پیش';
    }
  }
}

enum SnackBarType {
  none,
  info,
  warning,
  error,
  success,
}

const snackBarIcon = <SnackBarType, Widget>{
  SnackBarType.none: SizedBox.shrink(),
  SnackBarType.info: Icon(Icons.info_rounded, color: Colors.blueAccent),
  SnackBarType.warning: Icon(Icons.warning_rounded, color: Colors.orange),
  SnackBarType.error: Icon(Icons.error_rounded, color: Colors.red),
  SnackBarType.success:
      Icon(Icons.check_circle, color: Colors.lightGreenAccent),
};

const snackBarTextColor = <SnackBarType, Color>{
  SnackBarType.none: Colors.white,
  SnackBarType.info: Colors.white,
  SnackBarType.warning: Colors.orange,
  SnackBarType.error: Colors.red,
  SnackBarType.success: Colors.lightGreenAccent,
};
void showSnackBar(BuildContext context, String text,
    {SnackBarType barType = SnackBarType.none,
    Duration duration = const Duration(seconds: 2)}) {
  ScaffoldMessenger.of(context).removeCurrentSnackBar();
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Row(
      children: <Widget>[
        snackBarIcon[barType] ?? const SizedBox.shrink(),
        const SizedBox(width: 16),
        Flexible(
          child: Text(
            text,
            maxLines: 3,
            style: Theme.of(context)
                .textTheme
                .bodyText1!
                .copyWith(color: snackBarTextColor[barType]),
          ),
        ),
      ],
    ),
    duration: const Duration(seconds: 3),
  ));
}

void openURL(BuildContext context, String? url) {
  if (url == null) return;
  if (url.startsWith("#")) {
    final AuthController _authController = Get.find<AuthController>();
    if (!_authController.isLoggedIn.value) {
      showLoginBottomSheet(context);
      return;
    }
    final data = RegExp(r'^\#(\d+)(-(\d+))?').firstMatch(url);
    if (data == null) return;
    String? bid = data.group(1);
    String? cid = data.group(3);
    if (bid != null && cid != null) {
      //step is specified
      Get.toNamed('/book/$bid',
          arguments: [null, cid], preventDuplicates: true);
    } else if (bid != null) {
      Get.toNamed('/book/$bid', preventDuplicates: true);
    } else {
      return;
    }
  } else {
    launch(url);
  }
}

bool isNumeric(String? s) {
  if (s == null) {
    return false;
  }
  return double.tryParse(s) != null;
}
