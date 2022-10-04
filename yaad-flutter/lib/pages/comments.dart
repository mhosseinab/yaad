import 'package:appmetrica_sdk/appmetrica_sdk.dart';
import 'package:flutter/material.dart';

import '../models/common.dart';
import '../services/backend.dart';
import '../widgets/common.dart';
import '../widgets/infinite_list.dart';

class CommentsPage extends StatefulWidget {
  final int bid;
  const CommentsPage({Key? key, required this.bid}) : super(key: key);

  @override
  State<CommentsPage> createState() => _CommentsPageState();
}

class _CommentsPageState extends State<CommentsPage> {
  _CommentsPageState();

  int page = 1;
  bool isFinished = false;
  Future<List<Comment>> requestItems(int nextPage) async {
    if (isFinished) return <Comment>[];
    CommentList? response =
        await BackendService.getComments(null, widget.bid, page);
    if (response != null && response.next != null) {
      page += 1;
    } else {
      isFinished = true;
    }
    return response == null ? <Comment>[] : response.results;
  }

  @override
  Widget build(BuildContext context) {
    AppmetricaSdk().reportEvent(
      name: 'BOOK_VIEW',
      attributes: <String, dynamic>{
        'bid': widget.bid,
      },
    );
    return Container(
      padding: const EdgeInsets.all(16.0),
      // Use ListView.builder
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            "نظرات",
            style: Theme.of(context).textTheme.headline2,
          ),
          const SizedBox(height: 16.0),
          Expanded(
            child: InfiniteList<Comment>(
              onRequest: requestItems,
              itemBuilder: (context, item, index) => CommentListTile(item),
            ),
          ),
          const SizedBox(height: 16.0),
          AddCommentButton(),
        ],
      ),
    );
  }
}
