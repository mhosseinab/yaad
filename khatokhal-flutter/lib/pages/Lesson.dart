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
import '../models/Chapter.dart';
import '../models/Common.dart';
import '../models/db.dart';
import '../widgets/AudioPlayerInline.dart';
import '../widgets/VideoPlayerInline.dart';
import '../widgets/common.dart';

class LessonPage extends StatefulWidget {
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
      // print('fetched');

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
    fetchData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final bool _showCaseIsEnabled = true;
    // _authController.box.read('IS_SHOWCASE_ENABLED') == null;
    return Scaffold(
      body: SafeArea(
        child: chapters.isEmpty
            ? Column(
                children: <Widget>[
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
                        padding: EdgeInsets.only(
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
                                  titlePadding: EdgeInsets.only(right: 50),
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
                                          IconTextButton(
                                            icon: const FaIcon(
                                              FontAwesomeIcons.bookOpen,
                                              color: Colors.black45,
                                              size: 20,
                                            ),
                                            text: Text(
                                              "جزوه",
                                              style: const TextStyle(
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
                                              size: 20,
                                            ),
                                            text: Text(
                                              "فهرست",
                                              style: const TextStyle(
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
                                            .elementAt(i),
                                        book: book);
                                  },
                                  childCount:
                                      chapters.elementAt(index).steps.length,
                                ),
                              ),
                              if (!book.isFree && !book.isPurchased)
                                SliverToBoxAdapter(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Container(
                                      decoration: new BoxDecoration(
                                        color: Colors.black87,
                                        borderRadius: new BorderRadius.all(
                                          const Radius.circular(15.0),
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
                                      padding: EdgeInsets.symmetric(
                                          vertical: 64.0, horizontal: 48.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
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
                                          child: Text('فصل بعدی'),
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

  StepItem({Key? key, required this.step, required this.book})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _focusedMenuItems = [
      FocusedMenuItem(
        title: Text("ذخیره در جزوه"),
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
      return SizedBox.shrink();
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
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          clipBehavior: Clip.hardEdge,
          child: ContentWidget(
            step.content,
            type: step.type ?? StepType.LESSON,
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

  ContentWidget(this.content, {required this.type});

  void _openMedia(BuildContext context, String url) {}

  @override
  Widget build(BuildContext context) {
    final double _width = MediaQuery.of(context).size.width;

    if (content == null) return SizedBox.shrink();

    if (type == StepType.LESSON) {
      if (content!.contentType == ContentType.I ||
          content!.contentType == ContentType.T) {
        _chapterController.setIsStepDone(content!.book, content!.id);
      }
    }

    final bool isRtlTitle = intl.Bidi.detectRtlDirectionality(
        removeAllHtmlTags(content!.title ?? ""));
    final bool isRtlTxt = intl.Bidi.detectRtlDirectionality(
        removeAllHtmlTags(removeAllHtmlTags(content!.text ?? "")));
    // print('---> $isRtlTitle $isRtlTxt ${content!.title}');
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
              placeholder: (context, url) => ImageLoadingWidget(),
              errorWidget: (context, url, error) => ErrorIcon(),
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
                data: content!.text ?? "",
                style: {
                  'p': Style(lineHeight: LineHeight(1.7)),
                  'a': Style(textDecoration: TextDecoration.none),
                  'li': Style(
                      margin: EdgeInsets.only(top: 6.0),
                      lineHeight: LineHeight(1.7)),
                  'table': Style(
                    border: Border.all(width: 0.5),
                    margin: EdgeInsets.symmetric(vertical: 4.0),
                  ),
                  'th': Style(
                    padding: EdgeInsets.all(12.0),
                    border: Border.all(width: 0.5),
                    alignment: Alignment.center,
                    lineHeight: LineHeight(1.7),
                  ),
                  'td': Style(
                    padding: EdgeInsets.all(12.0),
                    border: Border.all(width: 0.5),
                    alignment: Alignment.center,
                    lineHeight: LineHeight(1.7),
                  ),
                },
                onAnchorTap: (url, ctx, attributes, element) async {
                  openURL(context, url);
                },
              ),
            ),
          ),
        ],
        if (type == StepType.QUESTION) QuestionContent(content)
      ],
    );
  }
}

class QuestionContent extends StatefulWidget {
  final Content? content;
  QuestionContent(this.content);

  @override
  _QuestionContentState createState() => _QuestionContentState(content);
}

class _QuestionContentState extends State<QuestionContent> {
  final ChapterController _chapterController = Get.find<ChapterController>();
  final Content? content;
  int _selectedChoice = -1;
  _QuestionContentState(this.content);

  @override
  void initState() {
    final Answers? ans = _chapterController.getAnswer(content!.id);
    if (ans != null) _selectedChoice = ans.choice;
    super.initState();
  }

  void onChanged(value) {
    setState(() => _selectedChoice = value!);
    _chapterController.setAnswer(content!.id, value ?? 0);
    _chapterController.setIsStepDone(content!.book, content!.id);
  }

  bool _isNumericChoice() {
    return isNumeric(content!.answerChoices!.first.text);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 16),
        if (_isNumericChoice())
          GridView.count(
            physics: NeverScrollableScrollPhysics(),
            crossAxisCount: 4,
            shrinkWrap: true,
            children: content!.answerChoices!.asMap().entries.map((entry) {
              int idx = entry.key;
              AnswerChoice val = entry.value;
              return ChoiceListButton(
                value: idx,
                isCorrect: val.isCorrect,
                groupValue: _selectedChoice,
                onChanged: onChanged,
                title: Text(
                  val.text ?? "",
                  style: Theme.of(context).textTheme.headline3,
                ),
              );
            }).toList(),
          ),
        if (!_isNumericChoice())
          ...content!.answerChoices!.asMap().entries.map((entry) {
            int idx = entry.key;
            AnswerChoice val = entry.value;
            return ChoiceListButton(
              value: idx,
              isCorrect: val.isCorrect,
              groupValue: _selectedChoice,
              onChanged: onChanged,
              title: Text(val.text ?? ""),
            );
          }).toList(),

        SizedBox(
          height: 8.0,
        ),
        // answer
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: (_selectedChoice > -1)
              ? ExpandablePanel(
                  key: UniqueKey(),
                  header: Container(
                    alignment: Alignment.centerLeft,
                    padding:
                        EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                    child: Text("پاسخ"),
                  ),
                  collapsed: SizedBox.shrink(),
                  expanded: ContentWidget(
                    new Content(
                        id: 0,
                        isDraft: false,
                        book: 0,
                        text: content!.answer!.text,
                        contentType: content!.answer!.contentType,
                        media: content!.answer!.media),
                    type: StepType.LESSON,
                  ),
                  // tapHeaderToExpand: true,
                  // hasIcon: true,
                )
              : SizedBox.shrink(
                  key: UniqueKey(),
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
    required this.value,
    required this.groupValue,
    required this.onChanged,
    required this.isCorrect,
    required this.title,
  });

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
          elevation: 1,
          color: isSelected
              ? (isCorrect ? Colors.green[100] : Colors.red[100])
              : (isCorrect && !isEnabled ? Colors.green[100] : null),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          clipBehavior: Clip.hardEdge,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 8.0),
            child: Center(child: title),
          ),
        ),
      ),
    );
  }
}
