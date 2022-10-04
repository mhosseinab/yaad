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
import '../models/common.dart';
import '../models/db.dart';
import '../pages/login.dart';

class ImageLoadingWidget extends StatelessWidget {
  const ImageLoadingWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(8.0),
      child: Center(
        child: Image(
          image: AssetImage('assets/images/placeholder-image.png'),
        ),
      ),
    );
  }
}

class ErrorIcon extends StatelessWidget {
  const ErrorIcon({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Center(
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

  const RatingStars({Key? key, required this.rate, this.size})
      : super(key: key);

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
  _OtpTimerState createState() => _OtpTimerState();
}

class _OtpTimerState extends State<OtpTimer> {
  late Timer _timer;
  int currentSeconds = 0;

  _OtpTimerState();

  String get timerText =>
      '${((widget.seconds - currentSeconds) ~/ 60).toString().padLeft(2, '0')}: ${((widget.seconds - currentSeconds) % 60).toString().padLeft(2, '0')}';

  startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        // print(timer.tick);
        currentSeconds = timer.tick;
        if (timer.tick >= widget.seconds) {
          _timer.cancel();
          if (widget.callback != null) widget.callback!();
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
          const Icon(
            Icons.timer,
            size: 16,
          ),
          const SizedBox(
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
  const DiscountBadge({Key? key, required this.child}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 10),
      decoration: BoxDecoration(
        color: Colors.red,
        borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(6), bottomRight: Radius.circular(6)),
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
  const CommentForm({Key? key}) : super(key: key);

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
                      debugPrint(rate.toString());
                      if (rate == 0) {
                        return 'امتیاز خود به این کتاب را ثبت کنید';
                      }
                      return null;
                    },
                    style: const TextStyle(
                      fontSize: 16.0,
                    ),
                    decoration: InputDecoration(
                        labelText: "متن",
                        hintText: "متن نظر خود را وارد کنید",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25.0),
                          borderSide: const BorderSide(),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 8.0, horizontal: 12.0)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Obx(
              () => (_bookController.error.value)
                  ? const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text('خطایی رخ داد',
                          style: TextStyle(color: Colors.red)),
                    )
                  : const SizedBox.shrink(),
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
                              showSnackBar(context, "ثبت شد",
                                  barType: SnackBarType.success);
                              Get.back();
                            }
                          }
                        },
                  child: _bookController.isLoading.value
                      ? const SizedBox(
                          child: CircularProgressIndicator(),
                          height: 20.0,
                          width: 20.0,
                        )
                      : const Text("ارسال"),
                ))
          ],
        ),
      ),
    );
  }
}

class CommentListTile extends StatelessWidget {
  final Comment comment;

  const CommentListTile(this.comment, {Key? key}) : super(key: key);

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
                            style: const TextStyle(fontSize: 12)),
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
                                constraints:
                                    const BoxConstraints(maxWidth: 20.0),
                                iconSize: 12,
                                color: Colors.black38,
                                icon: const FaIcon(FontAwesomeIcons.thumbsDown),
                                onPressed: () {},
                              ),
                              const SizedBox(width: 16.0),
                              Center(
                                child: IconButton(
                                  constraints:
                                      const BoxConstraints(maxWidth: 20.0),
                                  iconSize: 12,
                                  color: Colors.black38,
                                  icon: const FaIcon(FontAwesomeIcons.thumbsUp),
                                  onPressed: () {},
                                ),
                              ),
                              const SizedBox(width: 16.0),
                              IconButton(
                                constraints:
                                    const BoxConstraints(maxWidth: 20.0),
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
                const SizedBox(height: 16),
                Text(comment.text,
                    textAlign: TextAlign.justify,
                    style: const TextStyle(fontSize: 12)),
                const Divider(height: 20, color: Colors.black26),
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

  AddCommentButton({Key? key}) : super(key: key);
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
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(25.0),
            ),
          ),
          clipBehavior: Clip.antiAliasWithSaveLayer,
          backgroundColor: Colors.white,
          context: context,
          builder: (builder) => const CommentForm(),
        );
      },
      child: const Text(
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
        padding: const EdgeInsets.symmetric(horizontal: 4),
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
              placeholder: (context, url) => const ImageLoadingWidget(),
              errorWidget: (context, url, error) => const ErrorIcon(),
            ),
          ),
          Container(
            color: Colors.black54,
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
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
                  style: const TextStyle(color: Colors.white, fontSize: 11),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class BookTile extends StatelessWidget {
  final Book? book;

  const BookTile({Key? key, required this.book}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double _imageWidth = min(MediaQuery.of(context).size.width / 3, 150);

    return Row(
      children: [
        SizedBox(
          width: _imageWidth,
          height: _imageWidth,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(15.0),
            child: Stack(
              alignment: Alignment.bottomRight,
              children: [
                Hero(
                  tag: "bookImage${book!.id}",
                  child: CachedNetworkImage(
                    width: _imageWidth,
                    height: _imageWidth,
                    fit: BoxFit.cover,
                    imageUrl: book!.image,
                    placeholder: (context, url) => const ImageLoadingWidget(),
                    errorWidget: (context, url, error) => const ErrorIcon(),
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
                        style:
                            const TextStyle(color: Colors.white, fontSize: 11),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 24),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                book?.title ?? "--",
                style: Theme.of(context).textTheme.headline3,
              ),
              Text(
                book?.subtitle ?? "--",
                style: Theme.of(context)
                    .textTheme
                    .headline5
                    ?.copyWith(color: Colors.black45),
              ),
              const Divider(height: 24),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'مؤلف:',
                    style: Theme.of(context).textTheme.headline6,
                  ),
                  Text(book!.author,
                      textAlign: TextAlign.center,
                      style: Theme.of(context)
                          .textTheme
                          .headline6
                          ?.copyWith(fontWeight: FontWeight.w500)),
                ],
              ),
              const Divider(height: 10),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'ناشر:',
                    style: Theme.of(context).textTheme.headline6,
                  ),
                  Text(book!.publisher.title,
                      style: Theme.of(context)
                          .textTheme
                          .headline6
                          ?.copyWith(fontWeight: FontWeight.w500)),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class LessonPageTitle extends StatelessWidget {
  final int bid;
  final String title;
  final String subtitle;
  final String imageURL;

  const LessonPageTitle(
      {Key? key,
      required this.bid,
      required this.title,
      required this.subtitle,
      required this.imageURL})
      : super(key: key);

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
        const SizedBox(width: 10),
        SizedBox(
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

  RedBuyButton({Key? key, this.book}) : super(key: key);

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
                  FirebaseAnalytics.instance.logEvent(
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
                  if (url.isEmpty) {
                    showSnackBar(context, "خطایی رخ داد",
                        barType: SnackBarType.error);
                  } else {
                    Get.toNamed('/webView', arguments: [book!.id, url]);
                  }
                }
              },
        child: IntrinsicHeight(
          child: bookController.isLoading.value
              ? const SizedBox(
                  child: CircularProgressIndicator(),
                  height: 20.0,
                  width: 20.0,
                )
              : book!.isPurchased || book!.isFree
                  ? Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'درسنامه و تست',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (book!.isFree)
                          const VerticalDivider(
                            width: 36,
                            color: Colors.white,
                          ),
                        if (book!.isFree)
                          const Text(
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
                        const Text(
                          'خرید',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const VerticalDivider(
                          width: 16,
                          color: Colors.white,
                        ),
                        if (book!.discount == 0)
                          Text(
                            "${convertToPersianNumber(book!.price)} تومان",
                            style: const TextStyle(
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
                                  style: const TextStyle(
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
  const LoadingAnimation({Key? key}) : super(key: key);

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
  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 24),
  elevation: 0,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(30.0),
  ),
);
