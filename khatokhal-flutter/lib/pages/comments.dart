import 'package:appmetrica_sdk/appmetrica_sdk.dart';
import 'package:flutter/material.dart';

import '../models/Common.dart';
import '../services/backend.dart';
import '../widgets/InfiniteList.dart';
import '../widgets/common.dart';

class CommentsPage extends StatefulWidget {
  final int bid;
  CommentsPage({required this.bid});

  @override
  State<CommentsPage> createState() => _CommentsPageState(bid);
}

class _CommentsPageState extends State<CommentsPage> {
  final int bid;

  _CommentsPageState(this.bid);

  int page = 1;
  bool isFinished = false;
  Future<List<Comment>> requestItems(int nextPage) async {
    if (isFinished) return <Comment>[];
    CommentList? response = await BackendService.getComments(null, bid, page);
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
        'bid': bid,
      },
    );
    return Container(
      padding: EdgeInsets.all(16.0),
      // Use ListView.builder
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            "نظرات",
            style: Theme.of(context).textTheme.headline2,
          ),
          SizedBox(height: 16.0),
          Expanded(
            child: InfiniteList<Comment>(
              onRequest: requestItems,
              itemBuilder: (context, item, index) => CommentListTile(item),
            ),
          ),
          SizedBox(height: 16.0),
          AddCommentButton(),
        ],
      ),
    );
  }
}
