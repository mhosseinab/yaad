import 'dart:convert';

import 'package:get/get.dart';
import 'package:objectbox/src/native/query/query.dart' as ObjQuery;

import '../main.dart';
import '../models/chapter.dart';
import '../models/db.dart';
import '../objectbox.g.dart';
import '../services/backend.dart';

class ChapterController extends GetxController {
  final Box<Question> questionsBox = objectBox.store.box<Question>();
  final Box<StepData> stepBox = objectBox.store.box<StepData>();
  final Box<ProgressData> progressBox = objectBox.store.box<ProgressData>();
  final Box<NoteItem> noteBox = objectBox.store.box<NoteItem>();

  static const int oneDay = 24 * 60 * 60 * 1000;

  List<Result> chapters = [];
  final RxList questions = RxList<Question>([]);
  RxInt toDayQCount = 0.obs;
  int bookID = 0;

  Question? getQuestion(int qid) {
    final Query<Question> query =
        (questionsBox.query(Question_.qid.equals(qid))).build();
    final result = query.findFirst();
    query.close();
    return result;
  }

  void setQuestion({
    required int qid,
    required int choice,
    required int step,
    required String content,
    required bool isCorrect,
    String? title,
  }) {
    final Query<Question> query =
        (questionsBox.query(Question_.qid.equals(qid))).build();
    final result = query.findFirst();

    query.close();

    if (result != null) {
      // print('updating: $isCorrect $step');
      result.updatedAt = DateTime.now().millisecondsSinceEpoch;
      result.choice = choice;
      result.step = step;
      result.isCorrect = isCorrect;
      questionsBox.put(result);
    } else {
      // print('inserting: $isCorrect $step');
      questionsBox.put(Question(
        id: 0,
        qid: qid,
        bid: bookID,
        choice: choice,
        updatedAt: DateTime.now().millisecondsSinceEpoch,
        content: content,
        isCorrect: isCorrect,
        step: step,
        title: title ?? "",
      ));
    }

    Future.delayed(Duration.zero, () {
      toDayQCount.value = getTodayQuestionCount(bookID);
    });
  }

  bool isStepDone(int sid) {
    final Query<StepData> query =
        (stepBox.query(StepData_.sid.equals(sid))).build();
    final result = query.findFirst();
    query.close();
    return result != null;
  }

  void setIsStepDone(int bid, int sid) {
    final Query<StepData> query =
        (stepBox.query(StepData_.sid.equals(sid))).build();

    final result = query.findFirst();

    query.close();

    if (result == null) {
      stepBox.put(StepData(id: 0, sid: sid, isRead: true));
      addBookProgress(bid);
      // print('isDone saved');
    } else {
      // print('is already done');
    }
  }

  ProgressData? getProgress(int bid) {
    final Query<ProgressData> query =
        (progressBox.query(ProgressData_.bid.equals(bid))).build();

    final result = query.findFirst();

    query.close();

    return result;
  }

  void addBookProgress(int bid) {
    ProgressData? prg = getProgress(bid);
    if (prg == null) return;
    prg.steps += 1;
    progressBox.put(prg);
  }

  void setChapterStates(int bid, int lastChapter, List<String> offsets) {
    ProgressData? prg = getProgress(bid);
    if (prg == null) return;
    prg.lastChapterIndex = lastChapter;
    prg.chaptersOffset = offsets;
    progressBox.put(prg);
  }

  void setChapterComplete(String chapterIndex) {
    ProgressData? prg = getProgress(bookID);
    if (prg == null) return;
    prg.lastCompletedChapter
        .addIf(!prg.lastCompletedChapter.contains(chapterIndex), chapterIndex);

    prg.updatedAt = DateTime.now().millisecondsSinceEpoch;
    progressBox.put(prg);
  }

  bool isChapterComplete(String index) {
    ProgressData? prg = getProgress(bookID);
    if (prg == null) return false;
    return prg.lastCompletedChapter.contains(index);
  }

  void saveNewQuestions(int stepIndex) {
    chapters.elementAt(stepIndex).steps.asMap().forEach((index, element) => {
          if (index != 0)
            {
              for (Step step in element)
                {
                  questionsBox.put(
                    Question(
                      id: 0,
                      qid: step.content!.id,
                      bid: bookID,
                      choice: -1,
                      updatedAt: DateTime.now().millisecondsSinceEpoch,
                      content: jsonEncode(step.toJson()),
                      isCorrect: null,
                      step: index,
                      title: chapters.elementAt(stepIndex).title ?? "",
                    ),
                  )
                }
            }
        });
    Future.delayed(Duration.zero, () {
      toDayQCount.value = getTodayQuestionCount(bookID);
    });
  }

  void syncQuestionsData(int stepIndex) {
    List<Question> _data =
        questionsBox.query(Question_.bid.equals(bookID)).build().find();
    List<int> _qIDs = _data.map((e) => e.qid).toList();
    chapters.elementAt(stepIndex).steps.asMap().forEach((index, chapter) {
      if (index != 0) {
        for (final Step step in chapter) {
          if (!_qIDs.contains(step.content!.id)) continue;

          final Question _item =
              _data.firstWhere((element) => element.qid == step.content!.id);
          _item.content = jsonEncode(step.toJson());
          questionsBox.put(_item);
          // print('syncQuestionsData ${_item.qid}');
        }
      }
    });
    Future.delayed(Duration.zero, () {
      toDayQCount.value = getTodayQuestionCount(bookID);
    });
  }

  int getCurrentStep() {
    int currentStep = 0;
    Query<Question> query;
    int count = 0;

    for (int i = 1; i <= 5; i++) {
      query = getStepQuery(i);
      count = query.count();
      query.close();
      if (count != 0) {
        currentStep = i;
        // return currentStep;
      }
      // print("$i --> $count");
    }
    // print("currentStep --> $currentStep");
    return currentStep;
  }

  Query<Question> getStepQuery(final int step) {
    final int now = DateTime.now().millisecondsSinceEpoch;
    return questionsBox
        .query(Question_.bid
            .equals(bookID)
            .and(Question_.step.equals(step).andAll([
              Question_.updatedAt
                  .lessOrEqual(now - oneDay * getStepOffset(step)),
              Question_.isCorrect.isNull(),
            ])))
        .build();
  }

  Query<Question> getTodayQuestionsQuery(int bid) {
    final int now = DateTime.now().millisecondsSinceEpoch;
    final int currentStep = getCurrentStep();
    // final int stepOffset = getStepOffset(currentStep);
    // print('-----> $stepOffset');
    // print('-----> ${TimeAgo.timeAgoSinceDate(now - oneDay * stepOffset)}');
    ObjQuery.Condition<Question> stepConstrains =
        Question_.step.equals(1000); //dummy query
    for (int step = 1; step <= currentStep; step++) {
      stepConstrains =
          stepConstrains.or(Question_.step.lessOrEqual(step).andAll(
        [
          Question_.bid.equals(bid),
          Question_.isCorrect.isNull(),
          Question_.updatedAt.lessOrEqual(now - oneDay * getStepOffset(step)),
        ],
      ));
    }
    return questionsBox
        .query(
          Question_.bid.equals(bid).and(stepConstrains).or(
                Question_.isCorrect.equals(false).andAll([
                  Question_.updatedAt.lessOrEqual(now - oneDay),
                  Question_.bid.equals(bid),
                ]),
              ),
        )
        .build();
  }

  int getTodayQuestionCount(int bid) {
    final Query<Question> query = getTodayQuestionsQuery(bid);
    int count = query.count();
    query.close();
    return count;
  }

  void saveNote(NoteItem item) {
    noteBox.put(item);
  }

  Future<List<Result>> fetchChapters(String token, int bookId) {
    // print(bookId);
    if (chapters.isNotEmpty && bookID == bookId) return Future.value(chapters);
    bookID = bookId;
    return BackendService.fetchChapters(token, bookId).then((response) {
      chapters = response?.results ?? [];
      return chapters;
    });
  }

  int? getAllTodayQuestionCount() {
    final query = questionsBox.query().build();
    PropertyQuery<int> pq = query.property(Question_.bid);
    pq.distinct = true;
    List<int> bids = pq.find();
    query.close();
    // if (kDebugMode) print(bids);

    if (bids.isEmpty) return null;

    int count = 0;

    for (int bid in bids) {
      count += getTodayQuestionCount(bid);
      // if (kDebugMode) print(count);
    }
    return count;
  }

  int getStepOffset(int step) {
    return STEP_OFFSET[step] ?? 60;
  }
}

Map<int, int> STEP_OFFSET = {
  1: 1,
  2: 3,
  3: 11,
  4: 30,
  5: 60,
};
