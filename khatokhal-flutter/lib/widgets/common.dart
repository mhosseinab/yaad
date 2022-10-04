import 'dart:async';
import 'dart:math';

import 'package:appmetrica_sdk/appmetrica_sdk.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

import '../controllers/auth_controller.dart';
import '../controllers/book_controller.dart';
import '../controllers/chapter_controller.dart';
import '../helpers/utils.dart';
import '../models/Common.dart';
import '../models/db.dart';
import '../pages/login.dart';

class ImageLoadingWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: const EdgeInsets.all(8.0),
      child: const Center(
        child: Image(
          image: AssetImage('assets/images/placeholder-image.png'),
        ),
      ),
    );
  }
}

class ErrorIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Icon(
        Icons.error_rounded,
        color: Colors.orange,
      ),
    );
  }
}

class RatingStars extends StatelessWidget {
  final int rate;
  final double? size;

  RatingStars({required this.rate, this.size});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(
        5,
        (index) => Padding(
          padding: const EdgeInsets.only(left: 4),
          child: FaIcon(
            FontAwesomeIcons.solidStar,
            size: size ?? 8,
            color: (index < rate) ? Colors.black87 : Colors.black26,
          ),
        ),
      ),
    );
  }
}

class OtpTimer extends StatefulWidget {
  final VoidCallback? callback;
  final int seconds;

  const OtpTimer({Key? key, this.callback, required this.seconds})
      : super(key: key);

  @override
  _OtpTimerState createState() => _OtpTimerState(this.callback, this.seconds);
}

class _OtpTimerState extends State<OtpTimer> {
  final int timerMaxSeconds;
  final VoidCallback? callback;
  late Timer _timer;
  int currentSeconds = 0;

  _OtpTimerState(this.callback, this.timerMaxSeconds);

  String get timerText =>
      '${((timerMaxSeconds - currentSeconds) ~/ 60).toString().padLeft(2, '0')}: ${((timerMaxSeconds - currentSeconds) % 60).toString().padLeft(2, '0')}';

  startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        // print(timer.tick);
        currentSeconds = timer.tick;
        if (timer.tick >= timerMaxSeconds) {
          _timer.cancel();
          if (callback != null) callback!();
        }
      });
    });
  }

  @override
  void initState() {
    startTimer();
    super.initState();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Icon(
            Icons.timer,
            size: 16,
          ),
          SizedBox(
            width: 5,
          ),
          Text(timerText),
        ],
      ),
    );
  }
}

class DiscountBadge extends StatelessWidget {
  final Widget child;
  DiscountBadge({required this.child});
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(right: 10),
      decoration: BoxDecoration(
        color: Colors.red,
        borderRadius: const BorderRadius.only(
            bottomLeft: const Radius.circular(6),
            bottomRight: const Radius.circular(6)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            spreadRadius: 0,
            blurRadius: 2,
            offset: const Offset(0, 1), // changes position of shadow
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: child,
    );
  }
}

class CommentForm extends StatefulWidget {
  @override
  _CommentFormState createState() => _CommentFormState();
}

class _CommentFormState extends State<CommentForm> {
  final _bookController = Get.find<BookController>();
  final _controller = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    int rate = _bookController.book!.userRate ?? 0;
    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "ثبت نظر جدید",
              style: Theme.of(context).textTheme.headline1,
            ),
            const SizedBox(height: 16),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  Center(
                    child: RatingBar.builder(
                      initialRating: rate.toDouble(),
                      minRating: 1,
                      direction: Axis.horizontal,
                      allowHalfRating: false,
                      itemCount: 5,
                      itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                      itemBuilder: (context, _) => const FaIcon(
                        FontAwesomeIcons.solidStar,
                        color: Colors.amber,
                      ),
                      onRatingUpdate: (rating) {
                        rate = rating.toInt();
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: _controller,
                    keyboardType: TextInputType.multiline,
                    autofocus: true,
                    minLines: 3,
                    maxLines: 5,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'متن را به درستی وارد کنید';
                      }
                      print(rate);
                      if (rate == 0) {
                        return 'امتیاز خود به این کتاب را ثبت کنید';
                      }
                      return null;
                    },
                    style: TextStyle(
                      fontSize: 16.0,
                    ),
                    decoration: InputDecoration(
                        labelText: "متن",
                        hintText: "متن نظر خود را وارد کنید",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25.0),
                          borderSide: const BorderSide(),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                            vertical: 8.0, horizontal: 12.0)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Obx(
              () => (_bookController.error.value)
                  ? Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text('خطایی رخ داد',
                          style: TextStyle(color: Colors.red)),
                    )
                  : SizedBox.shrink(),
            ),
            Obx(() => ElevatedButton(
                  style: redButtonStyle,
                  onPressed: _bookController.isLoading.value
                      ? null
                      : () async {
                          if (_formKey.currentState!.validate()) {
                            bool success = await _bookController.submitComment(
                                _controller.text, rate);
                            if (success) {
                              showSnackbar(context, "ثبت شد",
                                  barType: SnackBarType.success);
                              Get.back();
                            }
                          }
                        },
                  child: _bookController.isLoading.value
                      ? SizedBox(
                          child: CircularProgressIndicator(),
                          height: 20.0,
                          width: 20.0,
                        )
                      : Text("ارسال"),
                ))
          ],
        ),
      ),
    );
  }
}

class CommentListTile extends StatelessWidget {
  final Comment comment;

  CommentListTile(this.comment);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          foregroundImage: comment.user.avatar != null
              ? CachedNetworkImageProvider(comment.user.avatar ?? "")
              : null,
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(comment.user.name ?? "ناشناس",
                            style: TextStyle(fontSize: 12)),
                        RatingStars(rate: comment.rate),
                      ],
                    ),
                    Expanded(
                      child: Container(
                        alignment: Alignment.topLeft,
                        child: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              IconButton(
                                constraints: BoxConstraints(maxWidth: 20.0),
                                iconSize: 12,
                                color: Colors.black38,
                                icon: const FaIcon(FontAwesomeIcons.thumbsDown),
                                onPressed: () {},
                              ),
                              SizedBox(width: 16.0),
                              Center(
                                child: IconButton(
                                  constraints: BoxConstraints(maxWidth: 20.0),
                                  iconSize: 12,
                                  color: Colors.black38,
                                  icon: const FaIcon(FontAwesomeIcons.thumbsUp),
                                  onPressed: () {},
                                ),
                              ),
                              SizedBox(width: 16.0),
                              IconButton(
                                constraints: BoxConstraints(maxWidth: 20.0),
                                iconSize: 12,
                                color: Colors.black38,
                                icon: const FaIcon(FontAwesomeIcons.ellipsisV),
                                onPressed: () {},
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Text(comment.text,
                    textAlign: TextAlign.justify,
                    style: TextStyle(fontSize: 12)),
                Divider(height: 20, color: Colors.black26),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class AddCommentButton extends StatelessWidget {
  final AuthController _authController = Get.find<AuthController>();
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: redButtonStyle,
      onPressed: () {
        if (!_authController.isLoggedIn.value) {
          showLoginBottomSheet(context);
          return;
        }
        showModalBottomSheet(
          isScrollControlled: true,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(25.0),
            ),
          ),
          clipBehavior: Clip.antiAliasWithSaveLayer,
          backgroundColor: Colors.white,
          context: context,
          builder: (builder) => CommentForm(),
        );
      },
      child: Text(
        "ثبت نظر",
        style: TextStyle(fontWeight: FontWeight.w500),
      ),
    );
  }
}

class IconTextButton extends StatelessWidget {
  final FaIcon icon;
  final Text text;
  final VoidCallback onPressed;

  const IconTextButton(
      {Key? key,
      required this.icon,
      required this.text,
      required this.onPressed})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: icon,
            ),
            Padding(
              padding: const EdgeInsets.all(2.0),
              child: text,
            ),
          ],
        ),
      ),
      onTap: onPressed,
    );
  }
}

class BookTileLarge extends StatelessWidget {
  final Book? book;
  final ChapterController _chapterController = Get.put(ChapterController());
  BookTileLarge({Key? key, required this.book}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final double _imageWidth = min(MediaQuery.of(context).size.width, 400);

    ProgressData? _pData =
        book != null ? _chapterController.getProgress(book!.id) : null;

    return ClipRRect(
      borderRadius: BorderRadius.circular(15.0),
      child: Stack(
        alignment: Alignment.bottomRight,
        children: [
          Hero(
            tag: "bookImage${book!.id}",
            child: CachedNetworkImage(
              width: _imageWidth,
              fit: BoxFit.cover,
              imageUrl: book!.image,
              placeholder: (context, url) => ImageLoadingWidget(),
              errorWidget: (context, url, error) => ErrorIcon(),
            ),
          ),
          Container(
            color: Colors.black54,
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  book!.title,
                  style: Theme.of(context)
                      .textTheme
                      .headline2!
                      .copyWith(color: Colors.white),
                ),
                Text(
                  book!.subtitle,
                  style: Theme.of(context)
                      .textTheme
                      .subtitle1!
                      .copyWith(color: Colors.white70),
                ),
              ],
            ),
          ),
          if (_pData != null)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: LinearProgressIndicator(
                value: _pData.total > 0 ? _pData.steps / _pData.total : 0,
              ),
            ),
          if (book!.isFree || book!.discount != 0)
            Positioned(
              top: 0,
              child: DiscountBadge(
                child: Text(
                  book!.isFree
                      ? 'رایگان'
                      : book!.discount < 100
                          ? '% ${book!.discount.toInt()}'
                          : '${book!.discount.toInt()} تومان',
                  style: TextStyle(color: Colors.white, fontSize: 11),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class LessonPageTitle extends StatelessWidget {
  final int bid;
  final String title;
  final String subtitle;
  final String imageURL;

  LessonPageTitle(
      {required this.bid,
      required this.title,
      required this.subtitle,
      required this.imageURL});

  @override
  Widget build(BuildContext context) {
    final double _titleWidth = MediaQuery.of(context).size.width - 12;
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Hero(
          tag: "bookImage$bid",
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10.0),
            child: CachedNetworkImage(
              width: _titleWidth / 8,
              height: _titleWidth / 8,
              fit: BoxFit.cover,
              imageUrl: imageURL,
            ),
          ),
        ),
        SizedBox(width: 12),
        Container(
          width: _titleWidth / (3.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.headline4,
                softWrap: false,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.start,
              ),
              Text(
                subtitle,
                style: Theme.of(context)
                    .textTheme
                    .headline5!
                    .copyWith(color: Colors.black38),
                softWrap: false,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.start,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class RedBuyButton extends StatelessWidget {
  final Book? book;
  final BookController bookController = Get.put(BookController());

  RedBuyButton({this.book});

  int _calcDiscountedPrice() {
    return (book!.discount < 100
            ? (book!.price - (book!.price * book!.discount / 100))
            : book!.price - book!.discount)
        .round();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => ElevatedButton(
        style: redButtonStyle,
        onPressed: bookController.isLoading.value
            ? null
            : () async {
                if (!bookController.isLoggedIn.value) {
                  showLoginBottomSheet(context);
                  return;
                }
                if (book!.isPurchased || book!.isFree) {
                  Get.toNamed('/book/lesson',
                      arguments: [book], preventDuplicates: true);
                } else {
                  AppmetricaSdk().reportEvent(
                    name: 'PURCHASE_INIT',
                    attributes: <String, dynamic>{
                      'name': book!.title,
                      'bid': book!.id,
                    },
                  );
                  FirebaseAnalytics().logEvent(
                    name: 'begin_checkout',
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
                  String url = await bookController.getBookPaymentURL(book!.id);
                  // print(url);
                  if (url.isEmpty)
                    showSnackbar(context, "خطایی رخ داد",
                        barType: SnackBarType.error);
                  else {
                    Get.toNamed('/webView', arguments: [book!.id, url]);
                  }
                }
              },
        child: IntrinsicHeight(
          child: bookController.isLoading.value
              ? SizedBox(
                  child: CircularProgressIndicator(),
                  height: 20.0,
                  width: 20.0,
                )
              : book!.isPurchased || book!.isFree
                  ? Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'درسنامه و تست',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (book!.isFree)
                          VerticalDivider(
                            width: 36,
                            color: Colors.white,
                          ),
                        if (book!.isFree)
                          Text(
                            "رایگان",
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                      ],
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'خرید',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        VerticalDivider(
                          width: 28,
                          color: Colors.white,
                        ),
                        if (book!.discount == 0)
                          Text(
                            "${convertToPersianNumber(book!.price)} تومان",
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        if (book!.discount != 0)
                          Text.rich(
                            TextSpan(
                              children: <TextSpan>[
                                TextSpan(
                                  text:
                                      "${convertToPersianNumber(book!.price)} تومان",
                                  style: new TextStyle(
                                      color: Colors.white70,
                                      decoration: TextDecoration.lineThrough,
                                      decorationThickness: 2),
                                ),
                                TextSpan(
                                  text:
                                      "  ${convertToPersianNumber(_calcDiscountedPrice())} تومان",
                                ),
                              ],
                            ),
                          )
                      ],
                    ),
        ),
      ),
    );
  }
}

class LoadingAnimation extends StatelessWidget {
  LoadingAnimation({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Lottie.asset(
      'assets/other/loading.json',
      repeat: true,
      width: 160,
      height: 160,
    );
  }
}

final redButtonStyle = ElevatedButton.styleFrom(
  padding: EdgeInsets.symmetric(vertical: 8, horizontal: 24),
  elevation: 0,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(30.0),
  ),
);
