import 'dart:convert';
import 'dart:math';

import 'package:appmetrica_sdk/appmetrica_sdk.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart' hide Step;
import 'package:flutter_html/flutter_html.dart';
import 'package:focused_menu/focused_menu.dart';
import 'package:focused_menu/modals.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart' as intl;

import '../controllers/auth_controller.dart';
import '../controllers/chapter_controller.dart';
import '../helpers/utils.dart';
import '../models/chapter.dart';
import '../models/common.dart';
import '../models/db.dart';
import '../widgets/audio_player_inline.dart';
import '../widgets/common.dart';
import '../widgets/video_player_inline.dart';

class LessonPage extends StatefulWidget {
  const LessonPage({Key? key}) : super(key: key);

  @override
  State<LessonPage> createState() => _LessonPageState();
}

class _LessonPageState extends State<LessonPage> with RouteAware {
  final AuthController _authController = Get.find<AuthController>();
  final ChapterController _chapterController = Get.put(ChapterController());

  int _currentIndex = 0;

  // GlobalKey _bookIndexBtnKey = GlobalKey();
  // GlobalKey _notesBtnKey = GlobalKey();
  // GlobalKey _stepCardKey = GlobalKey();

  late PageController _pageController;
  final Book book = Get.arguments[0];
  final int? _initChapterID =
      (Get.arguments.length > 1 && Get.arguments[1] != null)
          ? Get.arguments[1]
          : null;

  List<Result> chapters = [];
  List<String> _initOffsets = [];

  final PageStorageBucket _bucket = PageStorageBucket();

  saveScrollOffset(BuildContext context, double offset, String key) =>
      _bucket.writeState(context, offset, identifier: ValueKey(key));

  double currentPageScrollOffset(BuildContext context, String key) =>
      _bucket.readState(context, identifier: ValueKey(key)) ?? 0.0;

  double getStoredInitOffset(int index) {
    // print(_initOffsets);
    return double.parse(
        (index < _initOffsets.length) ? _initOffsets.elementAt(index) : '0.0');
  }

  void fetchData() {
    _chapterController
        .fetchChapters(_authController.token.val, book.id)
        .then((response) {
      setState(() {
        final ProgressData? _progress = _chapterController.getProgress(book.id);
        _currentIndex = _initChapterID != null
            ? _initChapterID ?? 0
            : _progress?.lastChapterIndex ?? 0;
        _initOffsets = _progress?.chaptersOffset ?? [];
        _pageController = PageController(initialPage: _currentIndex);
        chapters = response;
      });

      // if (_authController.box.read('IS_SHOWCASE_ENABLED') == null) {
      // WidgetsBinding.instance!.addPostFrameCallback((_) =>
      //     ShowCaseWidget.of(context)!
      //         .startShowCase([_bookIndexBtnKey, _notesBtnKey, _stepCardKey]));
      // _authController.box.write('IS_SHOWCASE_ENABLED', false);
      // }
    });
  }

  void goToIndex(int index) {
    index = min(index, chapters.length - 1);
    _pageController.jumpToPage(index);
    // _pageController.animateToPage(index,
    //     duration: Duration(milliseconds: 500), curve: Curves.ease);
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  void dispose() {
    List<String> offsets = chapters
        .map((chapter) =>
            currentPageScrollOffset(context, 'SCROLL_OFFSET_${chapter.id}')
                .toString())
        .toList();
    _chapterController.setChapterStates(
        book.id, _currentIndex, offsets.isNotEmpty ? offsets : []);
    _chapterController.chapters = [];
    super.dispose();
  }

  @override
  void initState() {
    AppmetricaSdk().reportEvent(
      name: 'LESSON_VIEW',
      attributes: <String, dynamic>{
        'name': book.title,
        'bid': book.id,
      },
    );
    _chapterController.bookID = book.id;

    fetchData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // _chapterController.questionsBox.removeAll();
    // _chapterController.progressBox.removeAll();

    const bool _showCaseIsEnabled = true;
    // _authController.box.read('IS_SHOWCASE_ENABLED') == null;
    return Scaffold(
      body: SafeArea(
        child: chapters.isEmpty
            ? Column(
                children: const <Widget>[
                  Expanded(
                    child: Center(
                      heightFactor: 10,
                      child: LoadingAnimation(),
                    ),
                  ),
                ],
              )
            : Stack(
                children: <Widget>[
                  PageView.builder(
                    onPageChanged: (page) {
                      setState(() {
                        _currentIndex = page;
                      });
                    },
                    controller: _pageController,
                    // physics: NeverScrollableScrollPhysics(),
                    itemCount: chapters.length,
                    itemBuilder: (context, index) {
                      final String _bucketKey =
                          'SCROLL_OFFSET_${chapters.elementAt(index).id}';
                      return Padding(
                        padding: const EdgeInsets.only(
                          top: 20,
                          left: 8.0,
                          right: 8.0,
                          bottom: 8.0,
                        ),
                        child: NotificationListener<ScrollNotification>(
                          onNotification: (ScrollNotification pos) {
                            if (pos is ScrollEndNotification) {
                              saveScrollOffset(
                                  context, pos.metrics.pixels, _bucketKey);
                            }
                            return true;
                          },
                          child: CustomScrollView(
                            controller: ScrollController(
                              initialScrollOffset: currentPageScrollOffset(
                                          context, _bucketKey) !=
                                      0
                                  ? currentPageScrollOffset(context, _bucketKey)
                                  : getStoredInitOffset(index),
                            ),
                            slivers: [
                              SliverAppBar(
                                toolbarHeight: 60,
                                floating: true,
                                snap: true,
                                flexibleSpace: FlexibleSpaceBar(
                                  titlePadding:
                                      const EdgeInsets.only(right: 50),
                                  title: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      LessonPageTitle(
                                        bid: book.id,
                                        title:
                                            chapters.elementAt(index).title ??
                                                "",
                                        subtitle: book.title,
                                        imageURL: book.image,
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          InkWell(
                                            onTap: () => Get.toNamed(
                                                '/book/question',
                                                arguments: [book],
                                                preventDuplicates: true),
                                            child: Container(
                                              margin: const EdgeInsets.only(
                                                  left: 8.0),
                                              child: Column(
                                                children: [
                                                  Container(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            5.0),
                                                    margin:
                                                        const EdgeInsets.only(
                                                            top: 7.0),
                                                    decoration:
                                                        const BoxDecoration(
                                                      color: Colors.orange,
                                                      shape: BoxShape.circle,
                                                    ),
                                                    child: Obx(
                                                      () => Text(
                                                        _chapterController
                                                            .toDayQCount.value
                                                            .toString(),
                                                        style: const TextStyle(
                                                            fontSize: 10,
                                                            color:
                                                                Colors.white),
                                                      ),
                                                    ),
                                                  ),
                                                  const Text(
                                                    "تست",
                                                    style: TextStyle(
                                                      color: Colors.black87,
                                                      fontSize: 11,
                                                    ),
                                                  )
                                                ],
                                              ),
                                            ),
                                          ),
                                          IconTextButton(
                                            icon: const FaIcon(
                                              FontAwesomeIcons.bookOpen,
                                              color: Colors.black45,
                                              size: 12,
                                            ),
                                            text: const Text(
                                              "جزوه",
                                              style: TextStyle(
                                                color: Colors.black87,
                                                fontSize: 11,
                                              ),
                                            ),
                                            onPressed: () => Get.toNamed(
                                                '/notes/${book.id}'),
                                          ),
                                          IconTextButton(
                                            icon: const FaIcon(
                                              FontAwesomeIcons.listUl,
                                              color: Colors.black45,
                                              size: 12,
                                            ),
                                            text: const Text(
                                              "فهرست",
                                              style: TextStyle(
                                                color: Colors.black87,
                                                fontSize: 11,
                                              ),
                                            ),
                                            onPressed: () async {
                                              Get.toNamed('/book/info',
                                                      arguments: [book])
                                                  ?.then((toIndex) {
                                                if (toIndex != null &&
                                                    toIndex != _currentIndex) {
                                                  goToIndex(toIndex);
                                                }
                                              });
                                            },
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                              ),
                              SliverList(
                                delegate: SliverChildBuilderDelegate(
                                  (_, int i) {
                                    return StepItem(
                                        // key: (index == 0) ? _stepCardKey : null,
                                        step: chapters
                                            .elementAt(index)
                                            .steps
                                            .elementAt(0)
                                            .elementAt(i),
                                        book: book);
                                  },
                                  childCount: chapters
                                      .elementAt(index)
                                      .steps
                                      .elementAt(0)
                                      .length,
                                ),
                              ),
                              if (!book.isFree && !book.isPurchased)
                                SliverToBoxAdapter(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Container(
                                      decoration: const BoxDecoration(
                                        color: Colors.black87,
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(15.0),
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.grey,
                                            offset: Offset(0.0, 1.0), //(x,y)
                                            blurRadius: 6.0,
                                          ),
                                        ],
                                      ),
                                      width: double.infinity,
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 64.0, horizontal: 48.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: <Widget>[
                                          RedBuyButton(
                                            book: book,
                                          ),
                                          const SizedBox(height: 24.0),
                                          Text(
                                            'قسمت رایگان این مسیر به پایان رسید',
                                            textAlign: TextAlign.center,
                                            style: Theme.of(context)
                                                .textTheme
                                                .headline2!
                                                .copyWith(color: Colors.white),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              SliverToBoxAdapter(
                                child: Padding(
                                  padding: const EdgeInsets.all(36.0),
                                  child: MarkAsReadButton(
                                    stepIndex: index,
                                    controller: _chapterController,
                                  ),
                                ),
                              ),
                              if (index < chapters.length - 1)
                                SliverToBoxAdapter(
                                  child: Padding(
                                    padding: const EdgeInsets.all(36.0),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.max,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Image.asset(
                                          'assets/images/swipe-right.png',
                                          width: 60,
                                        ),
                                        InkWell(
                                          onTap: () => goToIndex(index + 1),
                                          child: const Text('فصل بعدی'),
                                        )
                                      ],
                                    ),
                                  ),
                                )
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  if (chapters.length > 1)
                    Positioned(
                      top: 5.0,
                      left: 10.0,
                      right: 10.0,
                      child: Row(
                        children:
                            [for (int i = 0; i < chapters.length; i += 1) i]
                                .map(
                                  (i) => AnimatedBar(
                                    position: i,
                                    currentIndex: _currentIndex,
                                    onTap: goToIndex,
                                  ),
                                )
                                .toList(),
                      ),
                    ),
                ],
              ),
      ),
    );
    /* return Scaffold(
      appBar: AppBar(
        title: LessonPageTitle(
          bid: book.id,
          title: book.title,
          subtitle: book.subtitle,
          imageURL: book.image,
        ),
        actions: [
          IconTextButton(
            icon: const FaIcon(
              FontAwesomeIcons.bookOpen,
              color: Colors.black87,
              size: 20,
            ),
            text: Text(
              "جزوه",
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 11,
              ),
            ),
            onPressed: () => Get.toNamed('/notes/${book.id}'),
          ),
          IconTextButton(
            icon: const FaIcon(
              FontAwesomeIcons.listUl,
              color: Colors.black87,
              size: 20,
            ),
            text: Text(
              "فهرست",
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 11,
              ),
            ),
            onPressed: () => Get.toNamed('/book/info', arguments: [book]),
          ),
        ],
      ),
      body: SafeArea(
        child: Container(
          // padding: const EdgeInsets.all(8),
          child: FutureBuilder(
              future: BackendService.fetchChapters(
                  _authController.token.val, book.id),
              builder: (context, AsyncSnapshot<Chapters?> snapshot) {
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
                  return CustomScrollView(
                    slivers: [
                      ...snapshot.data!.results
                          .map<Widget>((chapter) => chapter.steps.length == 0
                              ? SliverToBoxAdapter(
                                  child: SizedBox.shrink(),
                                )
                              : SliverStickyHeader(
                                  header: chapter.title == null
                                      ? SizedBox.shrink()
                                      : Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 8, horizontal: 16),
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(24.0),
                                            child: Container(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .primary,
                                              padding: const EdgeInsets.all(8),
                                              alignment: Alignment.center,
                                              child: Text(
                                                chapter.title ?? "",
                                                style: const TextStyle(
                                                    color: Colors.white),
                                              ),
                                            ),
                                          ),
                                        ),
                                  sliver: SliverList(
                                    delegate: SliverChildBuilderDelegate(
                                      (context, i) {
                                        return StepItem(
                                          book: book,
                                          step: chapter.steps.elementAt(i),
                                        );
                                      },
                                      childCount: chapter.steps.length,
                                    ),
                                  ),
                                  sticky: false,
                                ))
                          .toList(),
                      if (!book.isFree && !book.isPurchased)
                        SliverToBoxAdapter(
                          child: Container(
                            color: Colors.black87,
                            width: double.infinity,
                            padding: EdgeInsets.symmetric(
                                horizontal: 24, vertical: 8),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 36.0, horizontal: 12.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  RedBuyButton(
                                    book: book,
                                  ),
                                  SizedBox(height: 24.0),
                                  Text(
                                    'قسمت رایگان این مسیر به پایان رسید',
                                    textAlign: TextAlign.center,
                                    style: Theme.of(context)
                                        .textTheme
                                        .headline2!
                                        .copyWith(color: Colors.white),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                    ],
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
              }),
        ),
      ),
    );
    */
  }
}

// class ShowCaseWidgetIfEnabled extends StatelessWidget {
//   final Widget child;
//   final bool enabled;
//
//   ShowCaseWidgetIfEnabled({required this.child, required this.enabled});
//
//   @override
//   Widget build(BuildContext context) {
//     return (enabled)
//         ? ShowCaseWidget(
//             builder: Builder(builder: (context) => child),
//           )
//         : child;
//   }
// }

// class ShowCaseIfEnabled extends StatelessWidget {
//   final Widget child;
//   final bool enabled;
//   final GlobalKey globalKey;
//   final String? title;
//   final String description;
//
//   ShowCaseIfEnabled({
//     required this.child,
//     required this.enabled,
//     this.title,
//     required this.description,
//     required this.globalKey,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return (enabled)
//         ? Showcase(
//             key: globalKey,
//             title: title,
//             description: description,
//             child: child,
//           )
//         : child;
//   }
// }

class AnimatedBar extends StatelessWidget {
  final int position;
  final int currentIndex;
  final ValueSetter<int> onTap;

  const AnimatedBar({
    Key? key,
    required this.position,
    required this.currentIndex,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          onTap(position);
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 1.5),
          child: position == currentIndex
              ? Container(
                  height: 5.0,
                  width: double.infinity,
                  color: Colors.amber,
                )
              : Container(
                  height: 5.0,
                  width: double.infinity,
                  color: position < currentIndex
                      ? Colors.blueGrey
                      : Colors.black12,
                ),
        ),
      ),
    );
  }
}

class StepItem extends StatelessWidget {
  final ChapterController _chapterController = Get.put(ChapterController());
  final Step step;
  final Book book;
  final int? stepLevel;
  final bool? showPreviousAnswer;

  StepItem(
      {Key? key,
      required this.step,
      required this.book,
      this.stepLevel,
      this.showPreviousAnswer})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _focusedMenuItems = [
      FocusedMenuItem(
        title: const Text("ذخیره در جزوه"),
        onPressed: () {
          NoteItem _item = NoteItem(id: 0, bid: book.id);
          _item.content = jsonEncode(step);
          _item.noteType = NoteType.Step;
          _chapterController.saveNote(_item);
        },
        trailingIcon: const Icon(FontAwesomeIcons.bookOpen),
      ),
      // FocusedMenuItem(
      //   title: Text("اشتراک‌گذاری"),
      //   onPressed: () {},
      //   trailingIcon: const Icon(Icons.share),
      // ),
    ];

    if (step.content == null) {
      return const SizedBox.shrink();
    }

    final double _width = MediaQuery.of(context).size.width;
    final double _focusedMenuWidth = min(_width * 0.5, 200);

    return FocusedMenuHolder(
      onPressed: () {},
      menuItems: _focusedMenuItems,
      menuWidth: _focusedMenuWidth,
      child: Container(
        margin: const EdgeInsets.only(top: 8),
        child: Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          clipBehavior: Clip.hardEdge,
          child: ContentWidget(
            step.content,
            key: Key(step.id.toString()),
            type: step.type ?? StepType.LESSON,
            step: stepLevel ?? 0,
            showPreviousAnswer: showPreviousAnswer,
          ),
        ),
      ),
    );
  }
}

class ContentWidget extends StatelessWidget {
  final ChapterController _chapterController = Get.find<ChapterController>();
  final Content? content;
  final StepType type;
  final int? step;
  final bool? showPreviousAnswer;

  ContentWidget(this.content,
      {required this.type, this.step, this.showPreviousAnswer, Key? key})
      : super(key: key);

  void _openMedia(BuildContext context, String url) {}

  @override
  Widget build(BuildContext context) {
    final double _width = MediaQuery.of(context).size.width;

    if (content == null) return const SizedBox.shrink();

    if (type == StepType.LESSON) {
      if (content!.contentType == ContentType.I ||
          content!.contentType == ContentType.T) {
        _chapterController.setIsStepDone(content!.book, content!.id);
      }
    }

    final bool isRtlTitle = intl.Bidi.detectRtlDirectionality(
        removeAllHtmlTags(content!.title ?? "").trim());
    final bool isRtlTxt = intl.Bidi.detectRtlDirectionality(
        removeAllHtmlTags(content!.text ?? "").trim());
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (content!.title != null) ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(
                bottom: 16.0, left: 12.0, right: 12.0, top: 16.0),
            child: Directionality(
              textDirection: isRtlTitle ? TextDirection.rtl : TextDirection.ltr,
              child: Text(
                content!.title ?? "",
                style: Theme.of(context).textTheme.headline2,
                textAlign: TextAlign.start,
              ),
            ),
          )
        ],
        if (content!.contentType == ContentType.I) ...[
          InkWell(
            onTap: () {
              _openMedia(context, content!.media ?? "");
            },
            child: CachedNetworkImage(
              width: _width,
              fit: BoxFit.fitWidth,
              imageUrl: content!.media ?? "",
              placeholder: (context, url) => const ImageLoadingWidget(),
              errorWidget: (context, url, error) => const ErrorIcon(),
            ),
          )
        ] else if (content!.contentType == ContentType.A) ...[
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: AudioPlayerInline(
              url: content!.media ?? "",
              onPlay: () =>
                  _chapterController.setIsStepDone(content!.book, content!.id),
            ),
          ),
        ] else if (content!.contentType == ContentType.V) ...[
          VideoPlayerInline(
            url: content!.media ?? "",
            onPlay: () =>
                _chapterController.setIsStepDone(content!.book, content!.id),
          ),
        ],
        if (content!.text != null && content!.text!.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            child: Directionality(
              textDirection: isRtlTxt ? TextDirection.rtl : TextDirection.ltr,
              child: Html(
                data: removeEmptyHTMLLines(content!.text ?? ""),
                style: {
                  'p': Style(lineHeight: const LineHeight(1.6)),
                  'a': Style(textDecoration: TextDecoration.none),
                  'li': Style(
                    margin: const EdgeInsets.only(top: 6.0),
                    lineHeight: const LineHeight(1.6),
                  ),
                  'table': Style(
                    border: Border.all(width: 0.5),
                    margin: const EdgeInsets.symmetric(vertical: 4.0),
                  ),
                  'th': Style(
                    padding: const EdgeInsets.all(8.0),
                    border: Border.all(width: 0.5),
                    alignment: Alignment.center,
                  ),
                  'td': Style(
                    padding: const EdgeInsets.all(8.0),
                    border: Border.all(width: 0.5),
                    alignment: Alignment.center,
                    lineHeight: const LineHeight(1.0),
                  ),
                },
                onAnchorTap: (url, ctx, attributes, element) async {
                  openURL(context, url);
                },
              ),
            ),
          ),
        ],
        if (type == StepType.QUESTION)
          QuestionContent(
            content,
            step ?? 0,
            showPreviousAnswer: showPreviousAnswer,
            key: key,
          )
      ],
    );
  }
}

class QuestionContent extends StatefulWidget {
  final Content? content;
  final int step;
  final bool showPreviousAnswer;

  const QuestionContent(this.content, this.step,
      {bool? showPreviousAnswer, Key? key})
      : showPreviousAnswer = showPreviousAnswer ?? true,
        super(key: key);

  @override
  _QuestionContentState createState() => _QuestionContentState();
}

class _QuestionContentState extends State<QuestionContent>
    with AutomaticKeepAliveClientMixin {
  final ChapterController _chapterController = Get.find<ChapterController>();

  int _selectedChoice = -1;
  late int _correctAnswer;

  _QuestionContentState();

  @override
  void initState() {
    final Question? ans = _chapterController.getQuestion(widget.content!.id);
    if (ans != null && widget.showPreviousAnswer) _selectedChoice = ans.choice;
    super.initState();
  }

  @override
  bool get wantKeepAlive => !widget.showPreviousAnswer;

  void onChanged(value) {
    final bool isCorrect = value == _correctAnswer;
    setState(() => _selectedChoice = value!);
    _chapterController.setQuestion(
        qid: widget.content!.id,
        choice: value ?? 0,
        step: widget.step,
        content: jsonEncode(widget.content),
        isCorrect: isCorrect);
    _chapterController.setIsStepDone(widget.content!.book, widget.content!.id);
  }

  bool _isNumericChoice() {
    return isNumeric(widget.content!.answerChoices!.first.text);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Column(
      children: [
        const SizedBox(height: 16),
        if (_isNumericChoice())
          GridView.count(
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 4,
            shrinkWrap: true,
            children:
                widget.content!.answerChoices!.asMap().entries.map((entry) {
              int idx = entry.key;
              AnswerChoice val = entry.value;
              if (val.isCorrect) _correctAnswer = idx;
              return ChoiceListButton(
                key: UniqueKey(),
                value: idx,
                isCorrect: val.isCorrect,
                groupValue: _selectedChoice,
                onChanged: onChanged,
                title: Center(
                  child: Text(
                    val.text ?? "",
                    style: Theme.of(context).textTheme.headline3,
                  ),
                ),
              );
            }).toList(),
          ),
        if (!_isNumericChoice())
          ...widget.content!.answerChoices!.asMap().entries.map((entry) {
            int idx = entry.key;
            AnswerChoice val = entry.value;
            if (val.isCorrect) _correctAnswer = idx;
            return ChoiceListButton(
              key: UniqueKey(),
              value: idx,
              isCorrect: val.isCorrect,
              groupValue: _selectedChoice,
              onChanged: onChanged,
              title: Text(val.text ?? ""),
            );
          }).toList(),

        const SizedBox(
          height: 8.0,
        ),
        // answer
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: ExpandablePanel(
            key: UniqueKey(),
            header: Container(
              alignment: Alignment.centerLeft,
              padding:
                  const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
              child: const Text("پاسخ"),
            ),
            collapsed: const SizedBox.shrink(),
            expanded: ContentWidget(
              Content(
                  id: 0,
                  isDraft: false,
                  book: 0,
                  text: widget.content!.answer!.text,
                  contentType: widget.content!.answer!.contentType,
                  media: widget.content!.answer!.media),
              type: StepType.LESSON,
            ),
            // tapHeaderToExpand: true,
            // hasIcon: true,
          ),
        ),
      ],
    );
  }
}

class ChoiceListButton extends StatelessWidget {
  final int value;
  final int groupValue;
  final Widget title;
  final ValueChanged<int?> onChanged;
  final bool isCorrect;

  const ChoiceListButton({
    Key? key,
    required this.value,
    required this.groupValue,
    required this.onChanged,
    required this.isCorrect,
    required this.title,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isEnabled = groupValue < 0;
    final isSelected = (value == groupValue);
    return InkWell(
      onTap: () {
        if (isEnabled) onChanged(value);
      },
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        child: Card(
          elevation: 0,
          color: isSelected
              ? (isCorrect ? Colors.green[100] : Colors.red[100])
              : (isCorrect && !isEnabled ? Colors.green[100] : null),
          shape: RoundedRectangleBorder(
            side: const BorderSide(color: Colors.black12),
            borderRadius: BorderRadius.circular(15),
          ),
          clipBehavior: Clip.hardEdge,
          child: Padding(
            padding:
                const EdgeInsets.symmetric(vertical: 10.0, horizontal: 12.0),
            child: title,
          ),
        ),
      ),
    );
  }
}

class MarkAsReadButton extends StatefulWidget {
  final int stepIndex;
  final ChapterController controller;

  const MarkAsReadButton(
      {Key? key, required this.stepIndex, required this.controller})
      : super(key: key);

  @override
  _MarkAsReadButtonState createState() => _MarkAsReadButtonState();
}

class _MarkAsReadButtonState extends State<MarkAsReadButton> {
  bool _selected = false;

  _MarkAsReadButtonState();

  @override
  void initState() {
    super.initState();
    _selected =
        widget.controller.isChapterComplete(widget.stepIndex.toString());
    if (_selected) {
      widget.controller.syncQuestionsData(widget.stepIndex);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_selected) {
      _selected =
          widget.controller.isChapterComplete(widget.stepIndex.toString());
    }
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24.0),
        child: TextButton.icon(
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 24),
            elevation: 0,
            backgroundColor: Colors.amber[800],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30.0),
            ),
          ),
          onPressed: _selected
              ? null
              : () {
                  setState(() {
                    _selected = true;
                    widget.controller
                        .setChapterComplete(widget.stepIndex.toString());
                    widget.controller.saveNewQuestions(widget.stepIndex);
                  });
                },
          label: _selected
              ? const SizedBox.shrink()
              : const Text(
                  'این فصل را کامل خواندم',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w300,
                  ),
                ),
          icon: _selected
              ? const FaIcon(
                  FontAwesomeIcons.thumbsUp,
                  color: Colors.white,
                )
              : const FaIcon(
                  FontAwesomeIcons.tasks,
                  color: Colors.white,
                ),
        ),
      ),
    );
  }
}
