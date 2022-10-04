import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

import '../controllers/auth_controller.dart';
import '../models/Common.dart';
import '../pages/login.dart';
import '../services/backend.dart';
import '../widgets/common.dart';

class MyBooksPage extends StatelessWidget {
  final AuthController _authController = Get.find<AuthController>();

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => SafeArea(
        child: !_authController.isLoggedIn.value
            ? Padding(
                padding: EdgeInsets.all(48.0),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(
                      FontAwesomeIcons.userGraduate,
                      size: 32.0,
                    ),
                    SizedBox(height: 24),
                    Text(
                      "برای دسترسی به کتابخانه لازم است ابتدا به حساب کاربری خود وارد شوید",
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 24),
                    ElevatedButton(
                        onPressed: () {
                          showLoginBottomSheet(context);
                        },
                        child: Text('ورود به حساب کاربری'))
                  ],
                ),
              )
            : FutureBuilder(
                future:
                    BackendService.fetchPurchases(_authController.token.val),
                builder: (context, AsyncSnapshot<List<Book>> snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    if (snapshot.hasError || snapshot.data == null) {
                      debugPrint("[ERROR] ${snapshot.error}");
                      return Column(
                        children: <Widget>[
                          Center(
                            heightFactor: 10,
                            child: Text(
                              "خطا در اتصال به سرور",
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      );
                    }
                    if (snapshot.data == null || snapshot.data!.isEmpty) {
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisSize: MainAxisSize.max,
                        children: <Widget>[
                          Center(
                            child: Icon(
                              FontAwesomeIcons.box,
                              size: 32.0,
                            ),
                          ),
                          SizedBox(height: 24),
                          Text(
                            "هنوز کتابی را نخریده اید",
                            textAlign: TextAlign.center,
                          ),
                        ],
                      );
                    }
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ListView.separated(
                        itemCount: snapshot.data!.length,
                        separatorBuilder: (BuildContext context, int index) =>
                            const Divider(),
                        itemBuilder: (BuildContext context, int index) {
                          final Book _item = snapshot.data![index];
                          return InkWell(
                            onTap: () {
                              Get.toNamed('/book/lesson',
                                  arguments: [_item], preventDuplicates: true);
                            },
                            child: BookTileLarge(
                              key: UniqueKey(),
                              book: _item,
                            ),
                          );
                        },
                      ),
                    );
                  } else {
                    return Column(
                      children: <Widget>[
                        Expanded(
                          child: Center(
                            heightFactor: 10,
                            child: LoadingAnimation(),
                          ),
                        ),
                      ],
                    );
                  }
                },
              ),
      ),
    );
  }
}

class Progress {
  int total;
  int done;
  Course course;
  Progress({required this.done, required this.total, required this.course});
}

class Course {
  int id;
  String name;

  Course({required this.id, required this.name});
}
