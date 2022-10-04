import 'dart:convert';

import 'package:appmetrica_sdk/appmetrica_sdk.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

import '../controllers/favorites_controller.dart';
import '../helpers/utils.dart';
import '../models/common.dart';
import '../models/db.dart';
import '../widgets/common.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({Key? key}) : super(key: key);

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  final FavoriteController _controller = Get.put(FavoriteController());

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<bool?> confirmDismiss(DismissDirection direction) async {
    return await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("حذف نشان؟"),
          actions: <Widget>[
            TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text("حذف کن")),
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text("انصراف"),
            ),
          ],
        );
      },
    );
  }

  void onDismissed(DismissDirection direction, FavoriteItem item) {
    _controller.defFromFav(item);
    showSnackBar(
      context,
      "حذف شد",
      barType: SnackBarType.success,
    );
  }

  @override
  Widget build(BuildContext context) {
    AppmetricaSdk().reportEvent(
      name: 'FAVORITES_VIEW',
      attributes: <String, dynamic>{},
    );
    List<FavoriteItem> items = _controller.getAllFav();
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'نشان شده‌ها',
          style: TextStyle(
              fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            (items.isEmpty)
                ? Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const <Widget>[
                            Icon(
                              FontAwesomeIcons.box,
                              size: 32.0,
                            ),
                            SizedBox(height: 24),
                            Text("نشان شده‌ای وجود ندارد")
                          ],
                        ),
                      ),
                    ),
                  )
                : Expanded(
                    child: ListView.builder(
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        final FavoriteItem _item = items[index];
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Dismissible(
                            key: UniqueKey(),
                            background: const DismissibleBackground(),
                            confirmDismiss: confirmDismiss,
                            onDismissed: (DismissDirection direction) {
                              onDismissed(direction, _item);
                            },
                            child: InkWell(
                              onTap: () {
                                Get.toNamed('/book/lesson',
                                    arguments: [
                                      Book.fromJson(jsonDecode(_item.bookData))
                                    ],
                                    preventDuplicates: true);
                              },
                              child: BookTileLarge(
                                  key: UniqueKey(),
                                  book: Book.fromJson(
                                      jsonDecode(_item.bookData))),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}

class DismissibleBackground extends StatelessWidget {
  const DismissibleBackground({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 20.0),
      color: Colors.red,
      child: const Icon(
        Icons.delete,
        color: Colors.white,
      ),
    );
  }
}
