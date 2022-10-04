import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../controllers/auth_controller.dart';
import '../pages/login.dart';

class AppDrawer extends StatelessWidget {
  final _authController = Get.find<AuthController>();

  AppDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            // decoration: BoxDecoration(
            //   color: MaterialColor(0xffee3734, redColor),
            // ),
            child: Center(
              child: Image.asset(
                'assets/images/app-icon.png',
                width: 80,
              ),
            ),
          ),
          ListTile(
            leading: FaIcon(
              FontAwesomeIcons.whatsapp,
              size: 20,
              color: Theme.of(context).primaryColor,
            ),
            title: const Text('ارتباط با ما'),
            onTap: () {
              launch("https://api.whatsapp.com/send?phone=989012334597");
            },
          ),
          Obx(
            () => _authController.isLoggedIn.value
                ? ListTile(
                    leading: Icon(
                      Icons.logout,
                      size: 20,
                      color: Theme.of(context).primaryColor,
                    ),
                    title: const Text('خروج'),
                    onTap: () {
                      _authController.logout();
                      Get.back();
                    },
                  )
                : ListTile(
                    leading: Icon(
                      Icons.login,
                      size: 20,
                      color: Theme.of(context).primaryColor,
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
