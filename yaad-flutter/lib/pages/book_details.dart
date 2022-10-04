import 'package:appmetrica_sdk/appmetrica_sdk.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../helpers/utils.dart';
import '../models/chapter_list.dart';
import '../models/common.dart';
import '../services/backend.dart';
import '../widgets/common.dart';

class BookDetailPage extends StatelessWidget {
  final Book book = Get.arguments[0];

  BookDetailPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    AppmetricaSdk().reportEvent(
      name: 'BOOK_VIEW',
      attributes: <String, dynamic>{
        'name': book.title,
        'bid': book.id,
      },
    );
    return Scaffold(
      appBar: AppBar(
        title: LessonPageTitle(
          bid: book.id,
          title: book.title,
          subtitle: book.subtitle,
          imageURL: book.image,
        ),
      ),
      body: SafeArea(
        child: FutureBuilder(
          future: BackendService.fetchChapterList(book.id),
          builder: (context, AsyncSnapshot<ChapterList?> snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              if (snapshot.hasError || snapshot.data == null) {
                debugPrint("[ERROR] ${snapshot.error}");
                return Column(
                  children: const <Widget>[
                    Center(
                      heightFactor: 0.3,
                      child: Text(
                        "خطا در اتصال به سرور",
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                );
              }
              return Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(children: [
                  const Center(
                    child: Text('فهرست'),
                  ),
                  const SizedBox(height: 16.0),
                  Expanded(
                    child: ListView.separated(
                      itemBuilder: (context, index) => ListTile(
                        onTap: () {
                          Get.back(result: index);
                        },
                        dense: true,
                        minLeadingWidth: 16,
                        horizontalTitleGap: 4,
                        trailing: Text(
                          '${convertToPersianNumber(snapshot.data!.results[index].stepCount)} قدم',
                          style: const TextStyle(
                              fontSize: 11, color: Colors.black54),
                        ),
                        contentPadding: const EdgeInsets.all(2),
                        leading:
                            Text('${convertToPersianNumber(index + 1)} . '),
                        title: Text(snapshot.data!.results[index].title),
                      ),
                      separatorBuilder: (context, index) => const Divider(
                        color: Colors.black26,
                        height: 1.0,
                      ),
                      itemCount: snapshot.data!.results.length,
                    ),
                  ),
                ]),
              );
            } else {
              return Column(
                children: const <Widget>[
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
