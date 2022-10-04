import 'dart:convert';

import 'package:appmetrica_sdk/appmetrica_sdk.dart';
import 'package:flutter/material.dart' hide Step;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

import '../controllers/chapter_controller.dart';
import '../helpers/utils.dart';
import '../models/chapter.dart';
import '../models/common.dart';
import '../models/db.dart';
import '../objectbox.g.dart';
import '../widgets/common.dart';
import 'lesson.dart';

class QuestionPage extends StatefulWidget {
  const QuestionPage({Key? key}) : super(key: key);

  @override
  State<QuestionPage> createState() => _QuestionPageState();
}

class _QuestionPageState extends State<QuestionPage> with RouteAware {
  final ChapterController _chapterController = Get.put(ChapterController());
  final Book book = Get.arguments[0];
  List<Question> questions = [];

  List<bool> _selectedFilter = [false, true, false];
  bool showPreviousAnswer = true;

  void getQuestions(int filterIndex) {
    for (int i = 0; i < _selectedFilter.length; i++) {
      _selectedFilter[i] = i == filterIndex;
    }
    if (_selectedFilter[0]) {
      //Incorrect
      final Query<Question> query = _chapterController.questionsBox
          .query(Question_.bid.equals(book.id))
          .build();
      setState(() {
        questions = query.find();
        query.close();
        _selectedFilter = [..._selectedFilter];
        showPreviousAnswer = true;
      });
    } else if (_selectedFilter[2]) {
      //All
      final Query<Question> query = _chapterController.questionsBox
          .query(Question_.bid
              .equals(book.id)
              .and(Question_.isCorrect.equals(false)))
          .build();
      setState(() {
        questions = query.find();
        query.close();
        _selectedFilter = [..._selectedFilter];
        showPreviousAnswer = true;
      });
    } else {
      //Today
      final Query<Question> query =
          _chapterController.getTodayQuestionsQuery(book.id);
      setState(() {
        questions = query.find();
        query.close();
        _selectedFilter = [..._selectedFilter];
        showPreviousAnswer = false;
      });
    }
  }

  @override
  void initState() {
    AppmetricaSdk().reportEvent(
      name: 'QUESTION_VIEW',
      attributes: <String, dynamic>{
        'name': book.title,
        'bid': book.id,
      },
    );

    _chapterController.bookID = book.id;

    getQuestions(1);

    super.initState();
  }

  double _filterBtnWidth(BuildContext context) {
    return (MediaQuery.of(context).size.width - 60) / 3;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              toolbarHeight: 60,
              floating: true,
              // snap: true,
              titleSpacing: 8.0,
              title: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  LessonPageTitle(
                    bid: book.id,
                    title: book.title,
                    subtitle: book.subtitle,
                    imageURL: book.image,
                  ),
                ],
              ),
              actions: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: IconTextButton(
                        icon: const FaIcon(
                          FontAwesomeIcons.bookOpen,
                          color: Colors.black45,
                          size: 12,
                        ),
                        text: const Text(
                          "جزوه",
                          style: TextStyle(
                            color: Colors.black87,
                            fontSize: 10,
                          ),
                        ),
                        onPressed: () => Get.toNamed('/notes/${book.id}'),
                      ),
                    ),
                  ],
                ),
              ],
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(70.0),
                child: Container(
                  padding: const EdgeInsets.all(8.0),
                  alignment: Alignment.center,
                  child: ToggleButtons(
                    borderRadius: const BorderRadius.all(Radius.circular(25)),
                    color: Colors.grey,
                    children: <Widget>[
                      Container(
                        alignment: Alignment.center,
                        width: _filterBtnWidth(context),
                        child: const Text('همه'),
                      ),
                      Container(
                        alignment: Alignment.center,
                        width: _filterBtnWidth(context),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            const Center(child: Text('تست‌های امروز')),
                            Positioned(
                              top: 0,
                              left: 4,
                              child: Container(
                                padding: const EdgeInsets.all(6.0),
                                margin: const EdgeInsets.only(right: 2.0),
                                decoration: const BoxDecoration(
                                  color: Colors.orange,
                                  shape: BoxShape.circle,
                                ),
                                child: Obx(
                                  () => Text(
                                    _chapterController.toDayQCount.value
                                        .toString(),
                                    style: const TextStyle(
                                        fontSize: 10, color: Colors.white),
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                      Container(
                        alignment: Alignment.center,
                        width: _filterBtnWidth(context),
                        child: const Text('اشتباهات من'),
                      ),
                    ],
                    isSelected: _selectedFilter,
                    onPressed: (int index) {
                      getQuestions(index);
                    },
                  ),
                ),
              ),
            ),
            (questions.isEmpty)
                ? SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Center(
                        child: Image.asset(
                          'assets/images/empty.png',
                          width: 200,
                        ),
                      ),
                    ),
                  )
                : QuestionList(
                    key: UniqueKey(),
                    showPreviousAnswer: showPreviousAnswer,
                    book: book,
                    questions: questions,
                  ),
          ],
        ),
      ),
    );
  }
}

class QuestionList extends StatelessWidget {
  final List<Question> questions;
  final Book book;
  final bool showPreviousAnswer;

  final ChapterController _chapter = Get.put(ChapterController());
  QuestionList(
      {Key? key,
      required this.book,
      required this.questions,
      required this.showPreviousAnswer})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (_, int index) {
          final Question item = questions.elementAt(index);
          final Step step = Step.fromJson(jsonDecode(item.content));
          if (step.type == StepType.LESSON) {
            _chapter.setQuestion(
              qid: item.qid,
              choice: item.choice,
              step: item.step,
              content: item.content,
              isCorrect: true,
              title: "",
            );
          }

          return Column(
            children: [
              const SizedBox(height: 8.0),
              // Text(item.updatedAt.toString()),
              // Text(item.step.toString()),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Stack(
                  children: [
                    StepItem(
                      key: Key(step.id.toString()),
                      step: step,
                      stepLevel: item.step,
                      book: book,
                      showPreviousAnswer: showPreviousAnswer,
                    ),
                    Positioned(
                      left: 0,
                      child: Container(
                        margin: const EdgeInsets.only(left: 4.0),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6.0, vertical: 3.0),
                        decoration: BoxDecoration(
                          color: item.isCorrect == false
                              ? Colors.orange.shade50
                              : Colors.green.shade50,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(8.0),
                            topRight: Radius.circular(8.0),
                          ),
                        ),
                        child: RichText(
                          text: TextSpan(
                            text: item.isCorrect == false
                                ? 'اشتباهات'
                                : 'مرور ${convertToPersianNumber(item.step)}',
                            style: DefaultTextStyle.of(context).style.copyWith(
                                  fontSize: 10,
                                  color: Colors.black54,
                                ),
                            children: [
                              const TextSpan(text: ' ~ '),
                              TextSpan(text: item.title),
                              const TextSpan(text: ' ~ '),
                              TextSpan(
                                  text:
                                      TimeAgo.timeAgoSinceDate(item.updatedAt)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
        childCount: questions.length,
      ),
    );
  }
}
