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
import '../models/common.dart';
import '../pages/comments.dart';
import '../widgets/common.dart';
import '../widgets/video_player_inline.dart';
import 'login.dart';

class BookPage extends StatefulWidget {
  static const double _edgeCorner = 15.0;

  const BookPage({Key? key}) : super(key: key);

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
    int? cid;
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
            if (book!.isPurchased || book!.isFree || cid == 0) {
              Get.toNamed('/book/lesson',
                  arguments: [book, cid], preventDuplicates: true);
            } else {
              showSnackBar(context,
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
      FirebaseAnalytics.instance.logEvent(
        name: 'select_content',
        parameters: <String, dynamic>{
          'content_type': 'book',
          'item_id': book!.id,
        },
      );
    }
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              IconTextButton(
                icon: const FaIcon(
                  FontAwesomeIcons.whatsapp,
                  color: Colors.black87,
                  size: 16,
                ),
                text: const Text(
                  "ارتباط با ما",
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: 11,
                  ),
                ),
                onPressed: () {
                  launch("https://api.whatsapp.com/send?phone=989012334597");
                },
              ),
              Obx(
                () => IconTextButton(
                  icon: FaIcon(
                    FontAwesomeIcons.solidBookmark,
                    color: bookController.isFav.isFalse
                        ? Colors.black54
                        : Colors.red,
                    size: 16,
                  ),
                  text: const Text(
                    "نشان کردن",
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 11,
                    ),
                  ),
                  onPressed: () {
                    if (bookController.isFav.value) {
                      bookController.defFromFave(book!.id);
                    } else {
                      bookController.addToFave(book!.id);
                      FirebaseAnalytics.instance.logEvent(
                        name: 'add_to_wishlist',
                        parameters: <String, dynamic>{
                          'value': book!.price * 10,
                          'currency': 'IRR',
                          'items': [
                            <String, dynamic>{
                              'item_id': book!.id,
                              'item_name': book!.title,
                              'price': book!.price,
                              'discount': book!.discount,
                              'quantity': 1,
                              'currency': 'IRR',
                            }
                          ]
                        },
                      );
                    }
                  },
                ),
              ),
              IconTextButton(
                icon: const FaIcon(
                  FontAwesomeIcons.shareAlt,
                  color: Colors.black54,
                  size: 16,
                ),
                text: const Text(
                  "اشتراک‌گذاری",
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: 11,
                  ),
                ),
                onPressed: () {
                  if (book != null) {
                    Share.share(
                        '${book!.title}\n${book!.subtitle}\n\nhttps://open.khatokhal.org/book/${book!.id}');
                    FirebaseAnalytics.instance.logEvent(
                      name: 'share',
                      parameters: <String, dynamic>{
                        'content_type': 'book',
                        'item_id': book!.id,
                      },
                    );
                  }
                },
              ),
            ],
          ),
        ],
      ),
      body: SafeArea(
        child: book == null
            ? Column(children: [
                Expanded(
                  child: Center(
                    heightFactor: 10,
                    child: isLoading
                        ? const LoadingAnimation()
                        : const ErrorIcon(),
                  ),
                ),
              ])
            : SingleChildScrollView(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8.0, vertical: 24.0),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            BookTile(book: book),
                            const SizedBox(height: 36),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 24),
                              child: Row(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Expanded(
                                    child: ElevatedButton(
                                      style: redButtonStyle,
                                      onPressed: () {
                                        Get.toNamed('/book/lesson',
                                            arguments: [book],
                                            preventDuplicates: true);
                                      },
                                      child: Text(
                                        (book!.isFree)
                                            ? "شروع رایگان"
                                            : (book!.isPurchased
                                                ? "ادامه دهید"
                                                : "شروع رایگان"),
                                      ),
                                    ),
                                  ),
                                  const VerticalDivider(
                                    width: 16,
                                  ),
                                  Expanded(
                                    child: Directionality(
                                      textDirection: TextDirection.ltr,
                                      child: OutlinedButton.icon(
                                        style: OutlinedButton.styleFrom(
                                          padding: const EdgeInsets.all(8.0),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(25.0),
                                          ),
                                        ),
                                        onPressed: () {
                                          Get.toNamed('/book/info',
                                              arguments: [book]);
                                        },
                                        icon: const FaIcon(
                                            FontAwesomeIcons.list,
                                            size: 16),
                                        label: const Text("فهرست"),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Divider(height: 36),
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
                                        const Text("خرید"),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    child: Column(
                                      children: [
                                        Text(convertToPersianNumber(
                                            book!.stepCount)),
                                        const Text("قدم"),
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
                                            const FaIcon(
                                              FontAwesomeIcons.solidStar,
                                              size: 12,
                                            ),
                                            const VerticalDivider(
                                              width: 5,
                                            ),
                                            Text(book!.rateCount > 0
                                                ? book!.rate.toStringAsFixed(1)
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
                                const SizedBox(height: 8),
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
                              const SizedBox(height: 8),
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
                                    // print(rating);
                                    bookController
                                        .submitRating(book!.id, rating)
                                        .then(
                                          (success) => showSnackBar(
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
                              const Divider(height: 32, color: Colors.black26),
                              book!.comments == null || book!.comments!.isEmpty
                                  ? Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 24.0),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: const [
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
                                          shape: const RoundedRectangleBorder(
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
                                padding: const EdgeInsets.symmetric(
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
