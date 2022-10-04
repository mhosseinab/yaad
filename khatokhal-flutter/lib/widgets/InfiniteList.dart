import 'package:flutter/material.dart';

typedef Future<List<T>> RequestFn<T>(int nextIndex);
typedef Widget ItemBuilder<T>(BuildContext context, T item, int index);

class InfiniteList<T> extends StatefulWidget {
  final RequestFn<T> onRequest;
  final ItemBuilder<T> itemBuilder;

  const InfiniteList(
      {Key? key, required this.onRequest, required this.itemBuilder})
      : super(key: key);

  @override
  _InfiniteListState<T> createState() => _InfiniteListState<T>();
}

class _InfiniteListState<T> extends State<InfiniteList<T>> {
  List<T> items = [];
  bool isFinished = false;
  _getMoreItems(int length) async {
    var moreItems = await widget.onRequest(length);
    if (moreItems.length > 0)
      setState(() => items = [...items, ...moreItems]);
    else
      setState(() {
        isFinished = true;
      });
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemBuilder: (context, index) {
        print('build');
        if (index < items.length) {
          return widget.itemBuilder(context, items[index], index);
        } else {
          if (isFinished) return SizedBox.shrink();
          _getMoreItems(items.length);
          return const SizedBox(
            height: 16,
            child: Center(child: LinearProgressIndicator()),
          );
        }
      },
      itemCount: items.length + 1,
    );
  }
}
