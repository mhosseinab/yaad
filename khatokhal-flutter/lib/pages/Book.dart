import 'package:appmetrica_sdk/appmetrica_sdk.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:share/share.dart';
import 'package:url_launcher/url_launcher.dart';

import '../controllers/book_controller.dart';
import '../helpers/utils.dart';
import '../models/Common.dart';
import '../pages/comments.dart';
import '../widgets/VideoPlayerInline.dart';
import '../widgets/common.dart';
import 'login.dart';

class BookPage extends StatefulWidget {
  static const double _edgeCorner = 15.0;

  @override
  State<BookPage> createState() => _BookPageState();
}

class _BookPageState extends State<BookPage> {
  Book? book;
  bool isLoading = true;
  bool reloadOnResume = false;
  final BookController bookController = Get.put(BookController());

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    print("initState");
    var cid;
    if (book == null) {
      if (Get.arguments != null) {
        book = Get.arguments[0];
        cid = int.parse(Get.arguments[1]);
        if (book != null) {
          isLoading = false;
          return;
        }
      }
      bookController.fetchBook(Get.parameters['id']).then((value) {
        setState(() {
          book = value;
          isLoading = false;
          if (cid != null) {
            //got to step
            print('------cid $cid');
            if (book!.isPurchased || book!.isFree || cid == 0) {
              Get.toNamed('/book/lesson',
                  arguments: [book, cid], preventDuplicates: true);
            } else {
              showSnackbar(context,
                  "برای مشاهده این بخش از کتاب ابتدا لازم است کتاب را خریداری کنید",
                  barType: SnackBarType.warning);
            }
          }
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (book != null) {
      AppmetricaSdk().reportEvent(
        name: 'BOOK_VIEW',
        attributes: <String, dynamic>{
          'name': book!.title,
          'bid': book!.id,
        },
      );
      FirebaseAnalytics().logEvent(
        name: 'select_content',
        parameters: <String, dynamic>{
          'content_type': 'book',
          'item_id': book!.id,
        },
      );
    }
    return Scaffold(
      appBar: AppBar(actions: [
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
            FontAwesomeIcons.shareAlt,
            color: Colors.black54,
            size: 20,
          ),
          text: Text(
            "اشتراک‌گذاری",
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 11,
            ),
          ),
          onPressed: () {
            if (book != null) {
              Share.share(
                  '${book!.title}\n${book!.subtitle}\n\nhttps://open.khatokhal.org/book/${book!.id}');
              FirebaseAnalytics().logEvent(
                name: 'share',
                parameters: <String, dynamic>{
                  'content_type': 'book',
                  'item_id': book!.id,
                },
              );
            }
          },
        ),
      ]),
      body: SafeArea(
        child: book == null
            ? Column(children: [
                Expanded(
                  child: Center(
                    heightFactor: 10,
                    child: isLoading ? LoadingAnimation() : ErrorIcon(),
                  ),
                ),
              ])
            : SingleChildScrollView(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(BookPage._edgeCorner),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              BookTileLarge(book: book),
                              SizedBox(height: 24),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                ),
                                child: RedBuyButton(
                                  book: book,
                                ),
                              ),
                              SizedBox(height: 10),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 24),
                                child: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Expanded(
                                      child: OutlinedButton(
                                        style: redButtonStyle,
                                        onPressed: () {
                                          if (book!.isPurchased ||
                                              book!.isFree) {
                                            Get.toNamed('/notes/${book!.id}');
                                          } else {
                                            Get.toNamed('/book/lesson',
                                                arguments: [book],
                                                preventDuplicates: true);
                                          }
                                        },
                                        child: Text(
                                          (book!.isPurchased || book!.isFree)
                                              ? "جزوه"
                                              : "شروع رایگان",
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyText1,
                                        ),
                                      ),
                                    ),
                                    VerticalDivider(
                                      width: 16,
                                    ),
                                    Expanded(
                                      child: Obx(
                                        () => OutlinedButton.icon(
                                          style: bookController.isFav.value
                                              ? OutlinedButton.styleFrom(
                                                  backgroundColor: Colors.red,
                                                  padding: EdgeInsets.symmetric(
                                                      vertical: 8,
                                                      horizontal: 20),
                                                  elevation: 0,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            30.0),
                                                  ),
                                                )
                                              : redButtonStyle,
                                          onPressed: () {
                                            if (bookController.isFav.value) {
                                              bookController
                                                  .defFromFave(book!.id);
                                            } else {
                                              bookController
                                                  .addToFave(book!.id);
                                              FirebaseAnalytics().logEvent(
                                                name: 'add_to_wishlist',
                                                parameters: <String, dynamic>{
                                                  'value': book!.price * 10,
                                                  'currency': 'IRR',
                                                  'items': [
                                                    <String, dynamic>{
                                                      'item_id': book!.id,
                                                      'item_name': book!.title,
                                                      'price': book!.price,
                                                      'discount':
                                                          book!.discount,
                                                      'quantity': 1,
                                                      'currency': 'IRR',
                                                    }
                                                  ]
                                                },
                                              );
                                            }
                                          },
                                          icon: FaIcon(
                                              FontAwesomeIcons.solidBookmark,
                                              size: 16,
                                              color: bookController.isFav.value
                                                  ? Colors.white
                                                  : Colors.red),
                                          label: Text(
                                            "نشان کردن",
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyText1!
                                                .copyWith(
                                                    color: bookController
                                                            .isFav.value
                                                        ? Colors.white
                                                        : Colors.red),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 24),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Expanded(
                                    child: Container(
                                      padding: EdgeInsets.only(right: 24),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: <Widget>[
                                          Text(
                                            'مؤلف:',
                                            style: Theme.of(context)
                                                .textTheme
                                                .headline6,
                                          ),
                                          Text(book!.author,
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold)),
                                        ],
                                      ),
                                    ),
                                  ),
                                  VerticalDivider(width: 10),
                                  Expanded(
                                    child: Container(
                                      padding: EdgeInsets.only(right: 24),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: <Widget>[
                                          Text(
                                            'ناشر:',
                                            style: Theme.of(context)
                                                .textTheme
                                                .headline6,
                                          ),
                                          Text(book!.publisher.title,
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold)),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Divider(height: 24),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 32),
                                child: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        children: [
                                          Text(convertToPersianNumber(
                                              book!.purchaseCount)),
                                          Text("خرید"),
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      child: Column(
                                        children: [
                                          Text(convertToPersianNumber(
                                              book!.stepCount)),
                                          Text("قدم"),
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      child: Column(
                                        children: [
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              FaIcon(
                                                FontAwesomeIcons.solidStar,
                                                size: 12,
                                              ),
                                              VerticalDivider(
                                                width: 5,
                                              ),
                                              Text(book!.rateCount > 0
                                                  ? book!.rate
                                                      .toStringAsFixed(1)
                                                  : ""),
                                            ],
                                          ),
                                          Text(
                                              "${convertToPersianNumber(book!.rateCount)} نفر"),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                    if (book!.video != null && book!.video!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: VideoPlayerInline(url: book!.video ?? ""),
                      ),
                    if (book!.about.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(BookPage._edgeCorner),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 16,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text(
                                  "درباره کتاب",
                                  style: Theme.of(context).textTheme.headline2,
                                ),
                                SizedBox(height: 8),
                                Text(
                                  book!.about,
                                  textAlign: TextAlign.justify,
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(BookPage._edgeCorner),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                "نظرات",
                                style: Theme.of(context).textTheme.headline2,
                              ),
                              SizedBox(height: 8),
                              Center(
                                child: RatingBar.builder(
                                  initialRating: book!.userRate != null
                                      ? book!.userRate!.toDouble()
                                      : 0,
                                  minRating: 1,
                                  direction: Axis.horizontal,
                                  allowHalfRating: false,
                                  itemCount: 5,
                                  itemPadding: const EdgeInsets.symmetric(
                                      horizontal: 4.0),
                                  itemBuilder: (context, _) => const FaIcon(
                                    FontAwesomeIcons.solidStar,
                                    color: Colors.amber,
                                  ),
                                  onRatingUpdate: (rating) {
                                    if (!bookController.isLoggedIn.value) {
                                      showLoginBottomSheet(context);
                                      return;
                                    }
                                    print(rating);
                                    bookController
                                        .submitRating(book!.id, rating)
                                        .then(
                                          (success) => showSnackbar(
                                              context,
                                              success
                                                  ? "ثبت شد"
                                                  : "خطایی رخ داد",
                                              barType: success
                                                  ? SnackBarType.success
                                                  : SnackBarType.error),
                                        );
                                  },
                                ),
                              ),
                              const SizedBox(height: 12),
                              Center(
                                child: Text(book!.userRate != null
                                    ? "امتیاز شما به این کتاب"
                                    : "به این کتاب امتیاز دهید"),
                              ),
                              Divider(height: 32, color: Colors.black26),
                              book!.comments == null ||
                                      book!.comments!.length == 0
                                  ? Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 24.0),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            'اولین نظر را درباره این کتاب ثبت کنید',
                                            textAlign: TextAlign.center,
                                          )
                                        ],
                                      ),
                                    )
                                  : Column(
                                      children: book!.comments!
                                          .map((comment) =>
                                              CommentListTile(comment))
                                          .toList(),
                                    ),
                              if (!(book!.comments == null ||
                                  book!.comments!.length < 5))
                                Container(
                                  alignment: Alignment.center,
                                  child: TextButton(
                                      onPressed: () {
                                        showModalBottomSheet(
                                          isScrollControlled: true,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.vertical(
                                              top: Radius.circular(25.0),
                                            ),
                                          ),
                                          clipBehavior:
                                              Clip.antiAliasWithSaveLayer,
                                          backgroundColor: Colors.white,
                                          context: context,
                                          builder: (builder) => Container(
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .height /
                                                  1.4,
                                              child: CommentsPage(
                                                bid: book!.id,
                                              )),
                                        );
                                      },
                                      child: Text(
                                        "—  مشاهده همه نظرات  —",
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyText1,
                                      )),
                                ),
                              Container(
                                width: double.infinity,
                                padding: EdgeInsets.symmetric(
                                    horizontal: 32, vertical: 8),
                                child: AddCommentButton(),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    /* Padding(
                padding: const EdgeInsets.all(8),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      children: [
                        Center(
                          child: Text('فهرست'),
                        ),
                        Column(
                          children: <Widget>[
                            SizedBox(height: 20.0),
                            ExpansionTile(
                              title: Text(
                                "بخش اول: شعر موج نو",
                                style: Theme.of(context).textTheme.headline5,
                              ),
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.only(right: 24.0),
                                  child: ExpansionTile(
                                    title: Text(
                                      'فصل 1: تاریخچه',
                                      style:
                                          Theme.of(context).textTheme.headline6,
                                    ),
                                    children: <Widget>[
                                      ListTile(
                                        title: Text('data'),
                                      )
                                    ],
                                  ),
                                ),
                                ListTile(
                                  title: Text('data'),
                                )
                              ],
                            ),
                            ExpansionTile(
                              title: Text(
                                "بخش دوم: شعر نیمایی",
                                style: Theme.of(context).textTheme.headline5,
                              ),
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.only(right: 24.0),
                                  child: ExpansionTile(
                                    title: Text(
                                      'فصل 1: تاریخچه',
                                      style:
                                          Theme.of(context).textTheme.headline6,
                                    ),
                                    children: <Widget>[
                                      ListTile(
                                        title: Text('data'),
                                      )
                                    ],
                                  ),
                                ),
                                ListTile(
                                  title: Text('data'),
                                )
                              ],
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              ) */
                  ],
                ),
              ),
      ),
    );
  }
}
