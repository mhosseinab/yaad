import 'package:get/get_state_manager/src/simple/get_controllers.dart';

import '../main.dart';
import '../models/db.dart';
import '../objectbox.g.dart';

class NotesController extends GetxController {
  final Box<Answers> answersBox = objectbox.store.box<Answers>();
  final Box<NoteItem> noteBox = objectbox.store.box<NoteItem>();

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

  void saveNote(NoteItem item) {
    // print(item.toString());
    noteBox.put(item);
  }

  void deleteNote(NoteItem item) {
    noteBox.remove(item.id);
  }
}
