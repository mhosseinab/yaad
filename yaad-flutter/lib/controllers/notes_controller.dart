import 'package:get/get_state_manager/src/simple/get_controllers.dart';

import '../main.dart';
import '../models/db.dart';
import '../objectbox.g.dart';

class NotesController extends GetxController {
  final Box<Question> answersBox = objectBox.store.box<Question>();
  final Box<NoteItem> noteBox = objectBox.store.box<NoteItem>();

  Question? getQuestion(int qid) {
    final Query<Question> query =
        (answersBox.query(Question_.qid.equals(qid))).build();
    final result = query.findFirst();
    query.close();
    return result;
  }

  void saveNote(NoteItem item) {
    // print(item.toString());
    noteBox.put(item);
  }

  void deleteNote(NoteItem item) {
    noteBox.remove(item.id);
  }
}
