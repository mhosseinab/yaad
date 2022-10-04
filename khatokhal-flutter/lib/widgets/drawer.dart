import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../colors.dart';
import '../controllers/auth_controller.dart';
import '../pages/login.dart';

class AppDrawer extends StatelessWidget {
  final _authController = Get.find<AuthController>();
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(
              color: MaterialColor(0xffee3734, RedColor),
            ),
            child: Text('Drawer Header'),
          ),
          ListTile(
            leading: const FaIcon(
              FontAwesomeIcons.whatsapp,
              size: 20,
              color: MaterialColor(0xffee3734, RedColor),
            ),
            title: const Text('ارتباط با ما'),
            onTap: () {
              launch("https://api.whatsapp.com/send?phone=989012334597");
            },
          ),
          Obx(
            () => _authController.isLoggedIn.value
                ? ListTile(
                    leading: const Icon(
                      Icons.logout,
                      size: 20,
                      color: MaterialColor(0xffee3734, RedColor),
                    ),
                    title: const Text('خروج'),
                    onTap: () {
                      _authController.logout();
                      Get.back();
                    },
                  )
                : ListTile(
                    leading: const Icon(
                      Icons.login,
                      size: 20,
                      color: MaterialColor(0xffee3734, RedColor),
                    ),
                    title: const Text('ورود به حساب کاربری'),
                    onTap: () {
                      showLoginBottomSheet(context);
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
