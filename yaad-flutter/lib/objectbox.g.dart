// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: camel_case_types

import 'dart:typed_data';

import 'package:objectbox/flatbuffers/flat_buffers.dart' as fb;
import 'package:objectbox/internal.dart'; // generated code can access "internal" functionality
import 'package:objectbox/objectbox.dart';
import 'package:objectbox_flutter_libs/objectbox_flutter_libs.dart';

import 'models/db.dart';

export 'package:objectbox/objectbox.dart'; // so that callers only have to import this file

final _entities = <ModelEntity>[
  ModelEntity(
      id: const IdUid(1, 4563218010162879108),
      name: 'ContentData',
      lastPropertyId: const IdUid(3, 6646437888379198374),
      flags: 0,
      properties: <ModelProperty>[
        ModelProperty(
            id: const IdUid(1, 8670501140057823006),
            name: 'id',
            type: 6,
            flags: 1),
        ModelProperty(
            id: const IdUid(2, 5895178826090598036),
            name: 'cid',
            type: 6,
            flags: 40,
            indexId: const IdUid(1, 5171179679267562432)),
        ModelProperty(
            id: const IdUid(3, 6646437888379198374),
            name: 'type',
            type: 9,
            flags: 0)
      ],
      relations: <ModelRelation>[],
      backlinks: <ModelBacklink>[]),
  ModelEntity(
      id: const IdUid(2, 4446817241284753361),
      name: 'FavoriteItem',
      lastPropertyId: const IdUid(5, 6821822948695139884),
      flags: 0,
      properties: <ModelProperty>[
        ModelProperty(
            id: const IdUid(1, 5494707094200503769),
            name: 'id',
            type: 6,
            flags: 1),
        ModelProperty(
            id: const IdUid(2, 2135161876138173592),
            name: 'bid',
            type: 6,
            flags: 8,
            indexId: const IdUid(2, 3785087039510899673)),
        ModelProperty(
            id: const IdUid(3, 9112271624153417942),
            name: 'bookData',
            type: 9,
            flags: 0),
        ModelProperty(
            id: const IdUid(4, 5005027425435054429),
            name: 'isSynced',
            type: 1,
            flags: 0),
        ModelProperty(
            id: const IdUid(5, 6821822948695139884),
            name: 'updatedAt',
            type: 6,
            flags: 0)
      ],
      relations: <ModelRelation>[],
      backlinks: <ModelBacklink>[]),
  ModelEntity(
      id: const IdUid(3, 5881342403819053536),
      name: 'NoteItem',
      lastPropertyId: const IdUid(9, 373209885805525641),
      flags: 0,
      properties: <ModelProperty>[
        ModelProperty(
            id: const IdUid(1, 2147471976017334213),
            name: 'id',
            type: 6,
            flags: 1),
        ModelProperty(
            id: const IdUid(2, 4252183048135675007),
            name: 'bid',
            type: 6,
            flags: 8,
            indexId: const IdUid(3, 455826578627965591)),
        ModelProperty(
            id: const IdUid(3, 4764524233539691359),
            name: 'isSynced',
            type: 1,
            flags: 0),
        ModelProperty(
            id: const IdUid(4, 2130282353027768359),
            name: 'dbNoteType',
            type: 6,
            flags: 0),
        ModelProperty(
            id: const IdUid(5, 6655819107911040800),
            name: 'content',
            type: 9,
            flags: 0),
        ModelProperty(
            id: const IdUid(6, 1018000779065974825),
            name: 'updatedAt',
            type: 6,
            flags: 8,
            indexId: const IdUid(4, 8493079364630879206)),
        ModelProperty(
            id: const IdUid(7, 4101422913059471650),
            name: 'text',
            type: 9,
            flags: 0),
        ModelProperty(
            id: const IdUid(8, 6313989476965415447),
            name: 'media',
            type: 9,
            flags: 0),
        ModelProperty(
            id: const IdUid(9, 373209885805525641),
            name: 'dbMediaType',
            type: 6,
            flags: 0)
      ],
      relations: <ModelRelation>[],
      backlinks: <ModelBacklink>[]),
  ModelEntity(
      id: const IdUid(4, 3405867264433745772),
      name: 'ProgressData',
      lastPropertyId: const IdUid(10, 2034411764712415869),
      flags: 0,
      properties: <ModelProperty>[
        ModelProperty(
            id: const IdUid(1, 2822581950506050496),
            name: 'id',
            type: 6,
            flags: 1),
        ModelProperty(
            id: const IdUid(2, 3829322735860229138),
            name: 'bid',
            type: 6,
            flags: 40,
            indexId: const IdUid(5, 8583525657888204604)),
        ModelProperty(
            id: const IdUid(3, 7720707224436204166),
            name: 'steps',
            type: 6,
            flags: 0),
        ModelProperty(
            id: const IdUid(4, 943228812169050501),
            name: 'total',
            type: 6,
            flags: 0),
        ModelProperty(
            id: const IdUid(5, 223293623502524291),
            name: 'courseID',
            type: 6,
            flags: 0),
        ModelProperty(
            id: const IdUid(6, 3710011766806959830),
            name: 'courseName',
            type: 9,
            flags: 0),
        ModelProperty(
            id: const IdUid(7, 5022424880820362762),
            name: 'lastChapterIndex',
            type: 6,
            flags: 0),
        ModelProperty(
            id: const IdUid(8, 7204182309608027730),
            name: 'chaptersOffset',
            type: 30,
            flags: 0),
        ModelProperty(
            id: const IdUid(9, 84647203639909720),
            name: 'updatedAt',
            type: 6,
            flags: 0),
        ModelProperty(
            id: const IdUid(10, 2034411764712415869),
            name: 'lastCompletedChapter',
            type: 30,
            flags: 0)
      ],
      relations: <ModelRelation>[],
      backlinks: <ModelBacklink>[]),
  ModelEntity(
      id: const IdUid(5, 117434558778422587),
      name: 'Question',
      lastPropertyId: const IdUid(9, 6074673740609147139),
      flags: 0,
      properties: <ModelProperty>[
        ModelProperty(
            id: const IdUid(1, 5787518708210071012),
            name: 'id',
            type: 6,
            flags: 1),
        ModelProperty(
            id: const IdUid(2, 443335155718613339),
            name: 'qid',
            type: 6,
            flags: 8,
            indexId: const IdUid(6, 5635127164842535664)),
        ModelProperty(
            id: const IdUid(3, 307344755498199953),
            name: 'bid',
            type: 6,
            flags: 8,
            indexId: const IdUid(7, 4500072241082727912)),
        ModelProperty(
            id: const IdUid(4, 5705709502693577065),
            name: 'choice',
            type: 6,
            flags: 0),
        ModelProperty(
            id: const IdUid(5, 4846234551243837006),
            name: 'updatedAt',
            type: 6,
            flags: 8,
            indexId: const IdUid(8, 4889994337084852386)),
        ModelProperty(
            id: const IdUid(6, 4071057270965441903),
            name: 'step',
            type: 6,
            flags: 8,
            indexId: const IdUid(9, 1520411700022475134)),
        ModelProperty(
            id: const IdUid(7, 3045737691430424900),
            name: 'content',
            type: 9,
            flags: 0),
        ModelProperty(
            id: const IdUid(8, 6375446358478940634),
            name: 'isCorrect',
            type: 1,
            flags: 0),
        ModelProperty(
            id: const IdUid(9, 6074673740609147139),
            name: 'title',
            type: 9,
            flags: 0)
      ],
      relations: <ModelRelation>[],
      backlinks: <ModelBacklink>[]),
  ModelEntity(
      id: const IdUid(6, 41409114653119084),
      name: 'StepData',
      lastPropertyId: const IdUid(3, 3482761613851747915),
      flags: 0,
      properties: <ModelProperty>[
        ModelProperty(
            id: const IdUid(1, 5732627956860326767),
            name: 'id',
            type: 6,
            flags: 1),
        ModelProperty(
            id: const IdUid(2, 4237790256325356950),
            name: 'sid',
            type: 6,
            flags: 40,
            indexId: const IdUid(10, 7744976464761557373)),
        ModelProperty(
            id: const IdUid(3, 3482761613851747915),
            name: 'isRead',
            type: 1,
            flags: 0)
      ],
      relations: <ModelRelation>[],
      backlinks: <ModelBacklink>[])
];

/// Open an ObjectBox store with the model declared in this file.
Future<Store> openStore(
        {String? directory,
        int? maxDBSizeInKB,
        int? fileMode,
        int? maxReaders,
        bool queriesCaseSensitiveDefault = true,
        String? macosApplicationGroup}) async =>
    Store(getObjectBoxModel(),
        directory: directory ?? (await defaultStoreDirectory()).path,
        maxDBSizeInKB: maxDBSizeInKB,
        fileMode: fileMode,
        maxReaders: maxReaders,
        queriesCaseSensitiveDefault: queriesCaseSensitiveDefault,
        macosApplicationGroup: macosApplicationGroup);

/// ObjectBox model definition, pass it to [Store] - Store(getObjectBoxModel())
ModelDefinition getObjectBoxModel() {
  final model = ModelInfo(
      entities: _entities,
      lastEntityId: const IdUid(6, 41409114653119084),
      lastIndexId: const IdUid(10, 7744976464761557373),
      lastRelationId: const IdUid(0, 0),
      lastSequenceId: const IdUid(0, 0),
      retiredEntityUids: const [],
      retiredIndexUids: const [],
      retiredPropertyUids: const [],
      retiredRelationUids: const [],
      modelVersion: 5,
      modelVersionParserMinimum: 5,
      version: 1);

  final bindings = <Type, EntityDefinition>{
    ContentData: EntityDefinition<ContentData>(
        model: _entities[0],
        toOneRelations: (ContentData object) => [],
        toManyRelations: (ContentData object) => {},
        getId: (ContentData object) => object.id,
        setId: (ContentData object, int id) {
          object.id = id;
        },
        objectToFB: (ContentData object, fb.Builder fbb) {
          final typeOffset = fbb.writeString(object.type);
          fbb.startTable(4);
          fbb.addInt64(0, object.id);
          fbb.addInt64(1, object.cid);
          fbb.addOffset(2, typeOffset);
          fbb.finish(fbb.endTable());
          return object.id;
        },
        objectFromFB: (Store store, ByteData fbData) {
          final buffer = fb.BufferContext(fbData);
          final rootOffset = buffer.derefObject(0);

          final object = ContentData(
              id: const fb.Int64Reader().vTableGet(buffer, rootOffset, 4, 0),
              cid: const fb.Int64Reader().vTableGet(buffer, rootOffset, 6, 0),
              type:
                  const fb.StringReader().vTableGet(buffer, rootOffset, 8, ''));

          return object;
        }),
    FavoriteItem: EntityDefinition<FavoriteItem>(
        model: _entities[1],
        toOneRelations: (FavoriteItem object) => [],
        toManyRelations: (FavoriteItem object) => {},
        getId: (FavoriteItem object) => object.id,
        setId: (FavoriteItem object, int id) {
          object.id = id;
        },
        objectToFB: (FavoriteItem object, fb.Builder fbb) {
          final bookDataOffset = fbb.writeString(object.bookData);
          fbb.startTable(6);
          fbb.addInt64(0, object.id);
          fbb.addInt64(1, object.bid);
          fbb.addOffset(2, bookDataOffset);
          fbb.addBool(3, object.isSynced);
          fbb.addInt64(4, object.updatedAt);
          fbb.finish(fbb.endTable());
          return object.id;
        },
        objectFromFB: (Store store, ByteData fbData) {
          final buffer = fb.BufferContext(fbData);
          final rootOffset = buffer.derefObject(0);

          final object = FavoriteItem(
              id: const fb.Int64Reader().vTableGet(buffer, rootOffset, 4, 0),
              bid: const fb.Int64Reader().vTableGet(buffer, rootOffset, 6, 0),
              bookData:
                  const fb.StringReader().vTableGet(buffer, rootOffset, 8, ''),
              isSynced: const fb.BoolReader()
                  .vTableGet(buffer, rootOffset, 10, false),
              updatedAt:
                  const fb.Int64Reader().vTableGet(buffer, rootOffset, 12, 0));

          return object;
        }),
    NoteItem: EntityDefinition<NoteItem>(
        model: _entities[2],
        toOneRelations: (NoteItem object) => [],
        toManyRelations: (NoteItem object) => {},
        getId: (NoteItem object) => object.id,
        setId: (NoteItem object, int id) {
          object.id = id;
        },
        objectToFB: (NoteItem object, fb.Builder fbb) {
          final contentOffset =
              object.content == null ? null : fbb.writeString(object.content!);
          final textOffset =
              object.text == null ? null : fbb.writeString(object.text!);
          final mediaOffset =
              object.media == null ? null : fbb.writeString(object.media!);
          fbb.startTable(10);
          fbb.addInt64(0, object.id);
          fbb.addInt64(1, object.bid);
          fbb.addBool(2, object.isSynced);
          fbb.addInt64(3, object.dbNoteType);
          fbb.addOffset(4, contentOffset);
          fbb.addInt64(5, object.updatedAt);
          fbb.addOffset(6, textOffset);
          fbb.addOffset(7, mediaOffset);
          fbb.addInt64(8, object.dbMediaType);
          fbb.finish(fbb.endTable());
          return object.id;
        },
        objectFromFB: (Store store, ByteData fbData) {
          final buffer = fb.BufferContext(fbData);
          final rootOffset = buffer.derefObject(0);

          final object = NoteItem(
              id: const fb.Int64Reader().vTableGet(buffer, rootOffset, 4, 0),
              bid: const fb.Int64Reader().vTableGet(buffer, rootOffset, 6, 0),
              content: const fb.StringReader()
                  .vTableGetNullable(buffer, rootOffset, 12),
              text: const fb.StringReader()
                  .vTableGetNullable(buffer, rootOffset, 16),
              media: const fb.StringReader()
                  .vTableGetNullable(buffer, rootOffset, 18),
              dbNoteType: const fb.Int64Reader()
                  .vTableGetNullable(buffer, rootOffset, 10),
              dbMediaType: const fb.Int64Reader()
                  .vTableGetNullable(buffer, rootOffset, 20),
              isSynced:
                  const fb.BoolReader().vTableGet(buffer, rootOffset, 8, false),
              updatedAt:
                  const fb.Int64Reader().vTableGet(buffer, rootOffset, 14, 0));

          return object;
        }),
    ProgressData: EntityDefinition<ProgressData>(
        model: _entities[3],
        toOneRelations: (ProgressData object) => [],
        toManyRelations: (ProgressData object) => {},
        getId: (ProgressData object) => object.id,
        setId: (ProgressData object, int id) {
          object.id = id;
        },
        objectToFB: (ProgressData object, fb.Builder fbb) {
          final courseNameOffset = fbb.writeString(object.courseName);
          final chaptersOffsetOffset = fbb.writeList(object.chaptersOffset
              .map(fbb.writeString)
              .toList(growable: false));
          final lastCompletedChapterOffset = fbb.writeList(object
              .lastCompletedChapter
              .map(fbb.writeString)
              .toList(growable: false));
          fbb.startTable(11);
          fbb.addInt64(0, object.id);
          fbb.addInt64(1, object.bid);
          fbb.addInt64(2, object.steps);
          fbb.addInt64(3, object.total);
          fbb.addInt64(4, object.courseID);
          fbb.addOffset(5, courseNameOffset);
          fbb.addInt64(6, object.lastChapterIndex);
          fbb.addOffset(7, chaptersOffsetOffset);
          fbb.addInt64(8, object.updatedAt);
          fbb.addOffset(9, lastCompletedChapterOffset);
          fbb.finish(fbb.endTable());
          return object.id;
        },
        objectFromFB: (Store store, ByteData fbData) {
          final buffer = fb.BufferContext(fbData);
          final rootOffset = buffer.derefObject(0);

          final object = ProgressData(
              id: const fb.Int64Reader().vTableGet(buffer, rootOffset, 4, 0),
              bid: const fb.Int64Reader().vTableGet(buffer, rootOffset, 6, 0),
              steps: const fb.Int64Reader().vTableGet(buffer, rootOffset, 8, 0),
              total:
                  const fb.Int64Reader().vTableGet(buffer, rootOffset, 10, 0),
              courseID:
                  const fb.Int64Reader().vTableGet(buffer, rootOffset, 12, 0),
              courseName:
                  const fb.StringReader().vTableGet(buffer, rootOffset, 14, ''),
              updatedAt:
                  const fb.Int64Reader().vTableGet(buffer, rootOffset, 20, 0),
              lastChapterIndex: const fb.Int64Reader()
                  .vTableGetNullable(buffer, rootOffset, 16),
              lastCompletedChapter:
                  const fb.ListReader<String>(fb.StringReader(), lazy: false)
                      .vTableGet(buffer, rootOffset, 22, []),
              chaptersOffset:
                  const fb.ListReader<String>(fb.StringReader(), lazy: false)
                      .vTableGet(buffer, rootOffset, 18, []));

          return object;
        }),
    Question: EntityDefinition<Question>(
        model: _entities[4],
        toOneRelations: (Question object) => [],
        toManyRelations: (Question object) => {},
        getId: (Question object) => object.id,
        setId: (Question object, int id) {
          object.id = id;
        },
        objectToFB: (Question object, fb.Builder fbb) {
          final contentOffset = fbb.writeString(object.content);
          final titleOffset = fbb.writeString(object.title);
          fbb.startTable(10);
          fbb.addInt64(0, object.id);
          fbb.addInt64(1, object.qid);
          fbb.addInt64(2, object.bid);
          fbb.addInt64(3, object.choice);
          fbb.addInt64(4, object.updatedAt);
          fbb.addInt64(5, object.step);
          fbb.addOffset(6, contentOffset);
          fbb.addBool(7, object.isCorrect);
          fbb.addOffset(8, titleOffset);
          fbb.finish(fbb.endTable());
          return object.id;
        },
        objectFromFB: (Store store, ByteData fbData) {
          final buffer = fb.BufferContext(fbData);
          final rootOffset = buffer.derefObject(0);

          final object = Question(
              id: const fb.Int64Reader().vTableGet(buffer, rootOffset, 4, 0),
              qid: const fb.Int64Reader().vTableGet(buffer, rootOffset, 6, 0),
              bid: const fb.Int64Reader().vTableGet(buffer, rootOffset, 8, 0),
              choice:
                  const fb.Int64Reader().vTableGet(buffer, rootOffset, 10, 0),
              updatedAt:
                  const fb.Int64Reader().vTableGet(buffer, rootOffset, 12, 0),
              step: const fb.Int64Reader().vTableGet(buffer, rootOffset, 14, 0),
              content:
                  const fb.StringReader().vTableGet(buffer, rootOffset, 16, ''),
              title:
                  const fb.StringReader().vTableGet(buffer, rootOffset, 20, ''),
              isCorrect: const fb.BoolReader()
                  .vTableGetNullable(buffer, rootOffset, 18));

          return object;
        }),
    StepData: EntityDefinition<StepData>(
        model: _entities[5],
        toOneRelations: (StepData object) => [],
        toManyRelations: (StepData object) => {},
        getId: (StepData object) => object.id,
        setId: (StepData object, int id) {
          object.id = id;
        },
        objectToFB: (StepData object, fb.Builder fbb) {
          fbb.startTable(4);
          fbb.addInt64(0, object.id);
          fbb.addInt64(1, object.sid);
          fbb.addBool(2, object.isRead);
          fbb.finish(fbb.endTable());
          return object.id;
        },
        objectFromFB: (Store store, ByteData fbData) {
          final buffer = fb.BufferContext(fbData);
          final rootOffset = buffer.derefObject(0);

          final object = StepData(
              id: const fb.Int64Reader().vTableGet(buffer, rootOffset, 4, 0),
              sid: const fb.Int64Reader().vTableGet(buffer, rootOffset, 6, 0),
              isRead: const fb.BoolReader()
                  .vTableGet(buffer, rootOffset, 8, false));

          return object;
        })
  };

  return ModelDefinition(model, bindings);
}

/// [ContentData] entity fields to define ObjectBox queries.
class ContentData_ {
  /// see [ContentData.id]
  static final id =
      QueryIntegerProperty<ContentData>(_entities[0].properties[0]);

  /// see [ContentData.cid]
  static final cid =
      QueryIntegerProperty<ContentData>(_entities[0].properties[1]);

  /// see [ContentData.type]
  static final type =
      QueryStringProperty<ContentData>(_entities[0].properties[2]);
}

/// [FavoriteItem] entity fields to define ObjectBox queries.
class FavoriteItem_ {
  /// see [FavoriteItem.id]
  static final id =
      QueryIntegerProperty<FavoriteItem>(_entities[1].properties[0]);

  /// see [FavoriteItem.bid]
  static final bid =
      QueryIntegerProperty<FavoriteItem>(_entities[1].properties[1]);

  /// see [FavoriteItem.bookData]
  static final bookData =
      QueryStringProperty<FavoriteItem>(_entities[1].properties[2]);

  /// see [FavoriteItem.isSynced]
  static final isSynced =
      QueryBooleanProperty<FavoriteItem>(_entities[1].properties[3]);

  /// see [FavoriteItem.updatedAt]
  static final updatedAt =
      QueryIntegerProperty<FavoriteItem>(_entities[1].properties[4]);
}

/// [NoteItem] entity fields to define ObjectBox queries.
class NoteItem_ {
  /// see [NoteItem.id]
  static final id = QueryIntegerProperty<NoteItem>(_entities[2].properties[0]);

  /// see [NoteItem.bid]
  static final bid = QueryIntegerProperty<NoteItem>(_entities[2].properties[1]);

  /// see [NoteItem.isSynced]
  static final isSynced =
      QueryBooleanProperty<NoteItem>(_entities[2].properties[2]);

  /// see [NoteItem.dbNoteType]
  static final dbNoteType =
      QueryIntegerProperty<NoteItem>(_entities[2].properties[3]);

  /// see [NoteItem.content]
  static final content =
      QueryStringProperty<NoteItem>(_entities[2].properties[4]);

  /// see [NoteItem.updatedAt]
  static final updatedAt =
      QueryIntegerProperty<NoteItem>(_entities[2].properties[5]);

  /// see [NoteItem.text]
  static final text = QueryStringProperty<NoteItem>(_entities[2].properties[6]);

  /// see [NoteItem.media]
  static final media =
      QueryStringProperty<NoteItem>(_entities[2].properties[7]);

  /// see [NoteItem.dbMediaType]
  static final dbMediaType =
      QueryIntegerProperty<NoteItem>(_entities[2].properties[8]);
}

/// [ProgressData] entity fields to define ObjectBox queries.
class ProgressData_ {
  /// see [ProgressData.id]
  static final id =
      QueryIntegerProperty<ProgressData>(_entities[3].properties[0]);

  /// see [ProgressData.bid]
  static final bid =
      QueryIntegerProperty<ProgressData>(_entities[3].properties[1]);

  /// see [ProgressData.steps]
  static final steps =
      QueryIntegerProperty<ProgressData>(_entities[3].properties[2]);

  /// see [ProgressData.total]
  static final total =
      QueryIntegerProperty<ProgressData>(_entities[3].properties[3]);

  /// see [ProgressData.courseID]
  static final courseID =
      QueryIntegerProperty<ProgressData>(_entities[3].properties[4]);

  /// see [ProgressData.courseName]
  static final courseName =
      QueryStringProperty<ProgressData>(_entities[3].properties[5]);

  /// see [ProgressData.lastChapterIndex]
  static final lastChapterIndex =
      QueryIntegerProperty<ProgressData>(_entities[3].properties[6]);

  /// see [ProgressData.chaptersOffset]
  static final chaptersOffset =
      QueryStringVectorProperty<ProgressData>(_entities[3].properties[7]);

  /// see [ProgressData.updatedAt]
  static final updatedAt =
      QueryIntegerProperty<ProgressData>(_entities[3].properties[8]);

  /// see [ProgressData.lastCompletedChapter]
  static final lastCompletedChapter =
      QueryStringVectorProperty<ProgressData>(_entities[3].properties[9]);
}

/// [Question] entity fields to define ObjectBox queries.
class Question_ {
  /// see [Question.id]
  static final id = QueryIntegerProperty<Question>(_entities[4].properties[0]);

  /// see [Question.qid]
  static final qid = QueryIntegerProperty<Question>(_entities[4].properties[1]);

  /// see [Question.bid]
  static final bid = QueryIntegerProperty<Question>(_entities[4].properties[2]);

  /// see [Question.choice]
  static final choice =
      QueryIntegerProperty<Question>(_entities[4].properties[3]);

  /// see [Question.updatedAt]
  static final updatedAt =
      QueryIntegerProperty<Question>(_entities[4].properties[4]);

  /// see [Question.step]
  static final step =
      QueryIntegerProperty<Question>(_entities[4].properties[5]);

  /// see [Question.content]
  static final content =
      QueryStringProperty<Question>(_entities[4].properties[6]);

  /// see [Question.isCorrect]
  static final isCorrect =
      QueryBooleanProperty<Question>(_entities[4].properties[7]);

  /// see [Question.title]
  static final title =
      QueryStringProperty<Question>(_entities[4].properties[8]);
}

/// [StepData] entity fields to define ObjectBox queries.
class StepData_ {
  /// see [StepData.id]
  static final id = QueryIntegerProperty<StepData>(_entities[5].properties[0]);

  /// see [StepData.sid]
  static final sid = QueryIntegerProperty<StepData>(_entities[5].properties[1]);

  /// see [StepData.isRead]
  static final isRead =
      QueryBooleanProperty<StepData>(_entities[5].properties[2]);
}
