import 'dart:convert';

import 'package:appmetrica_sdk/appmetrica_sdk.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

import '../controllers/auth_controller.dart';
import '../controllers/chapter_controller.dart';
import '../controllers/notes_controller.dart';
import '../helpers/utils.dart';
import '../models/chapter.dart' as chapter_model;
import '../models/common.dart';
import '../models/db.dart';
import '../objectbox.g.dart';
import 'lesson.dart';

class NotesPage extends StatefulWidget {
  const NotesPage({Key? key}) : super(key: key);

  @override
  State<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  final int bid = int.parse(Get.parameters['id'] ?? "0");
  final AuthController _authController = Get.find<AuthController>();
  final NotesController _notesController = Get.put(NotesController());
  final ChapterController _ = Get.put(ChapterController());
  final _textInputController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _textInputController.dispose();
    super.dispose();
  }

  Future<bool?> confirmDismiss(DismissDirection direction) async {
    return await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("حذف یادداشت؟"),
          actions: <Widget>[
            TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text("حذف کن")),
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text("انصراف"),
            ),
          ],
        );
      },
    );
  }

  void onDismissed(DismissDirection direction, NoteItem item) {
    _notesController.deleteNote(item);
    showSnackBar(
      context,
      "حذف شد",
      barType: SnackBarType.success,
    );
  }

  @override
  Widget build(BuildContext context) {
    AppmetricaSdk().reportEvent(
      name: 'NOTES_VIEW',
      attributes: <String, dynamic>{},
    );

    final Query<NoteItem> query =
        (_notesController.noteBox.query(NoteItem_.bid.equals(bid))
              ..order(NoteItem_.updatedAt, flags: Order.descending))
            .build();
    List<NoteItem> items = query.find();
    query.close();
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'جزوه',
          style: TextStyle(
              fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            (items.isEmpty)
                ? Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const <Widget>[
                            Icon(
                              FontAwesomeIcons.box,
                              size: 32.0,
                            ),
                            SizedBox(height: 24),
                            Text("یادداشتی وجود ندارد")
                          ],
                        ),
                      ),
                    ),
                  )
                : Expanded(
                    child: ListView.builder(
                      reverse: true,
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        final NoteItem _item = items[index];
                        if (_item.noteType == NoteType.Step &&
                            _item.content != null) {
                          return Dismissible(
                            key: UniqueKey(),
                            background: const DismissibleBackground(),
                            confirmDismiss: confirmDismiss,
                            onDismissed: (DismissDirection direction) {
                              onDismissed(direction, _item);
                            },
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                StepNoteItem(
                                    key: UniqueKey(), content: _item.content),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8.0),
                                  child: Text(
                                    TimeAgo.timeAgoSinceDate(_item.updatedAt),
                                    style: const TextStyle(fontSize: 10),
                                  ),
                                )
                              ],
                            ),
                          );
                        } else if (_item.noteType == NoteType.Note) {
                          return Dismissible(
                            key: UniqueKey(),
                            background: const DismissibleBackground(),
                            confirmDismiss: confirmDismiss,
                            onDismissed: (DismissDirection direction) {
                              onDismissed(direction, _item);
                            },
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                UserNoteItem(
                                    key: UniqueKey(),
                                    content: chapter_model.Content(
                                      id: 0,
                                      book: bid,
                                      isDraft: false,
                                      text: _item.text,
                                      media: _item.media,
                                      contentType: _item.mediaType,
                                    )),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8.0),
                                  child: Text(
                                    TimeAgo.timeAgoSinceDate(_item.updatedAt),
                                    style: const TextStyle(fontSize: 10),
                                  ),
                                )
                              ],
                            ),
                          );
                        } else {
                          return const SizedBox.shrink();
                        }
                      },
                    ),
                  ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: CircleAvatar(
                      foregroundImage: _authController.user?.avatar != null
                          ? CachedNetworkImageProvider(
                              _authController.user!.avatar ?? "")
                          : null,
                      key: UniqueKey(),
                    ),
                  ),
                  Flexible(
                    child: TextField(
                      controller: _textInputController,
                      keyboardType: TextInputType.multiline,
                      minLines: 1,
                      maxLines: 5,
                      decoration: const InputDecoration(
                          isDense: true,
                          contentPadding: EdgeInsets.all(8),
                          border: OutlineInputBorder(),
                          hintText: 'یادداشت جدید'),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      NoteItem _item = NoteItem(id: 0, bid: bid);
                      _item.noteType = NoteType.Note;
                      _item.text = _textInputController.text;
                      _item.mediaType = ContentType.T;
                      _notesController.saveNote(_item);
                      _textInputController.text = "";
                      FocusScope.of(context).unfocus();
                      setState(() {
                        items.add(_item);
                      });
                    },
                    icon: const FaIcon(FontAwesomeIcons.plusSquare),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

class StepNoteItem extends StatelessWidget {
  final String? content;

  const StepNoteItem({Key? key, required this.content}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (content == null) {
      // print("empty content");
      return const SizedBox.shrink();
    }
    final _step = chapter_model.Step.fromJson(jsonDecode(content!));
    return Container(
      margin: const EdgeInsets.only(top: 8),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        clipBehavior: Clip.hardEdge,
        child: ContentWidget(
          _step.content,
          type: _step.type ?? StepType.LESSON,
        ),
      ),
    );
  }
}

class UserNoteItem extends StatelessWidget {
  final chapter_model.Content content;

  const UserNoteItem({Key? key, required this.content}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        clipBehavior: Clip.hardEdge,
        child: ContentWidget(
          content,
          type: StepType.LESSON,
        ),
      ),
    );
  }
}

class DismissibleBackground extends StatelessWidget {
  const DismissibleBackground({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 20.0),
      color: Colors.red,
      child: const Icon(
        Icons.delete,
        color: Colors.white,
      ),
    );
  }
}
