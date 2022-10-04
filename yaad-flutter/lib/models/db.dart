import 'package:objectbox/objectbox.dart';

import '../models/common.dart';
import '../objectbox.g.dart'; // created by `flutter pub run build_runner build`

class ObjectBox {
  /// The Store of this app.
  late final Store store;

  ObjectBox._create(this.store) {
    // Add any additional setup code, e.g. build queries.
  }

  /// Create an instance of ObjectBox to use throughout the app.
  static Future<ObjectBox> create() async {
    // Future<Store> openStore() {...} is defined in the generated objectbox.g.dart
    final store = await openStore();
    return ObjectBox._create(store);
  }
}

@Entity()
class Question {
  Question({
    required this.id,
    required this.qid,
    required this.bid,
    required this.choice,
    required this.updatedAt,
    required this.step,
    required this.content,
    required this.title,
    this.isCorrect,
  });

  int id;

  @Index()
  int qid;

  @Index()
  int bid;

  int choice;

  @Index()
  int updatedAt;

  @Index()
  int step;

  String content;
  String title;

  bool? isCorrect;

  Map<String, dynamic> toJson() => {
        // "id": id,
        "qid": qid,
        "bid": bid,
        // "content": content,
        "choice": choice,
        "step": step,
        "isCorrect": isCorrect,
        "updatedAt": updatedAt,
      };
}

@Entity()
class ContentData {
  ContentData({
    required this.id,
    required this.cid,
    required this.type,
  });

  int id;

  @Index()
  @Unique()
  int cid;

  String type;
}

@Entity()
class ProgressData {
  ProgressData({
    required this.id,
    required this.bid,
    required this.steps,
    required this.total,
    required this.courseID,
    required this.courseName,
    int? updatedAt,
    int? lastChapterIndex,
    List<String>? lastCompletedChapter,
    List<String>? chaptersOffset,
  })  : lastChapterIndex = lastChapterIndex ?? 0,
        chaptersOffset = chaptersOffset ?? [],
        updatedAt = updatedAt ?? 0,
        lastCompletedChapter = lastCompletedChapter ?? [];

  int id;
  @Index()
  @Unique()
  int bid;
  int steps;
  int total;
  int courseID;
  String courseName;
  int? lastChapterIndex;
  List<String> chaptersOffset;
  List<String> lastCompletedChapter;
  int updatedAt;
}

@Entity()
class StepData {
  StepData({
    required this.id,
    required this.sid,
    required this.isRead,
  });

  int id;
  @Index()
  @Unique()
  int sid;
  bool isRead;
}

enum NoteType {
  Step,
  Note,
}

@Entity()
class NoteItem {
  int id;

  @Index()
  int bid;

  bool isSynced;

  int? dbNoteType;

  String? content;

  @Index()
  int updatedAt;

  String? text;
  String? media;
  int? dbMediaType;

  NoteItem({
    required this.id,
    required this.bid,
    this.content,
    this.text,
    this.media,
    this.dbNoteType,
    this.dbMediaType,
    bool? isSynced,
    int? updatedAt,
  })  : updatedAt = updatedAt ?? DateTime.now().millisecondsSinceEpoch,
        isSynced = isSynced ?? false;

  NoteType get noteType {
    _ensureStableEnumValues();
    return NoteType.values[dbNoteType ?? 0];
  }

  set noteType(NoteType type) {
    _ensureStableEnumValues();
    dbNoteType = type.index;
  }

  ContentType get mediaType {
    _ensureStableEnumValues();
    return ContentType.values[dbMediaType ?? 0];
  }

  set mediaType(ContentType type) {
    dbMediaType = type.index;
  }

  void _ensureStableEnumValues() {
    assert(NoteType.Step.index == 0);
    assert(NoteType.Note.index == 1);
  }
}

@Entity()
class FavoriteItem {
  FavoriteItem({
    required this.id,
    required this.bid,
    required this.bookData,
    bool? isSynced,
    int? updatedAt,
  })  : updatedAt = updatedAt ?? DateTime.now().millisecondsSinceEpoch,
        isSynced = isSynced ?? false;

  int id;

  @Index()
  int bid;
  String bookData;
  bool isSynced;
  int updatedAt;
}
