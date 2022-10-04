import 'package:get/get_state_manager/src/simple/get_controllers.dart';

import '../main.dart';
import '../models/Chapter.dart';
import '../models/db.dart';
import '../objectbox.g.dart';
import '../services/backend.dart';

class ChapterController extends GetxController {
  final Box<Answers> answersBox = objectbox.store.box<Answers>();
  final Box<StepData> stepBox = objectbox.store.box<StepData>();
  final Box<ProgressData> progressBox = objectbox.store.box<ProgressData>();
  final Box<NoteItem> noteBox = objectbox.store.box<NoteItem>();

  List<Result> chapters = [];
  int bookID = 0;

  @override
  void onInit() {
    super.onInit();
  }

  @override
  void onClose() {
    super.onClose();
  }

  Answers? getAnswer(int qid) {
    final Query<Answers> query =
        (answersBox.query(Answers_.qid.equals(qid))).build();
    final result = query.findFirst();
    query.close();
    return result;
  }

  void setAnswer(int qid, int choice) {
    final Query<Answers> query =
        (answersBox.query(Answers_.qid.equals(qid))).build();
    final result = query.findFirst();

    query.close();

    if (result != null) {
      result.updatedAt = DateTime.now().millisecondsSinceEpoch;
      result.choice = choice;
      answersBox.put(result);
    } else {
      answersBox.put(Answers(
          id: 0,
          qid: qid,
          choice: choice,
          updatedAt: DateTime.now().millisecondsSinceEpoch));
    }
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

  void saveNote(NoteItem item) {
    noteBox.put(item);
  }

  Future<List<Result>> fetchChapters(String token, int bookId) {
    if (chapters.isNotEmpty && bookID == bookId) return Future.value(chapters);
    bookID = bookId;
    return BackendService.fetchChapters(token, bookId).then((response) {
      chapters = response?.results ?? [];
      return chapters;
    });
  }
}
