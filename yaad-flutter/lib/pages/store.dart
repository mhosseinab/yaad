import 'dart:math' as math;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

import '../helpers/utils.dart';
import '../models/common.dart';
import '../models/store.dart';
import '../services/backend.dart';
import '../widgets/common.dart';

class StorePage extends StatelessWidget {
  final _bucket = PageStorageBucket();

  StorePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: BackendService.fetchStoreHome(),
      builder: (context, AsyncSnapshot<StoreHome?> snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasError || snapshot.data == null) {
            debugPrint("[ERROR] ${snapshot.error}");
            return Column(
              children: const <Widget>[
                Center(
                  heightFactor: 10,
                  child: Text(
                    "خطا در اتصال به سرور",
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ],
            );
          }
          // debugPrint(snapshot.data!.results.length.toString());
          return PageStorage(
            bucket: _bucket,
            child: CustomScrollView(
              key: const PageStorageKey('STORE'),
              slivers: [
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => HorizontalListSliver(
                        row: snapshot.data!.results.elementAt(index)),
                    childCount: snapshot.data!.results.length,
                  ),
                ),
              ],
            ),
          );
        } else {
          return Column(
            children: const <Widget>[
              Expanded(
                child: Center(
                  heightFactor: 10,
                  child: LoadingAnimation(),
                ),
              ),
            ],
          );
        }
      },
    );
  }
}

class HorizontalListSliver extends StatelessWidget {
  final Result row;

  HorizontalListSliver({Key? key, required this.row}) : super(key: key);

  final _bucket = PageStorageBucket();

  @override
  Widget build(BuildContext context) {
    // debugPrint("Sliver build");

    final MediaQueryData _mq = MediaQuery.of(context);
    final double _width = math.min(_mq.size.width - _mq.size.width * 0.20, 450);
    final bool isSlide = row.itemType == RowType.Slide;
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        children: [
          row.showTitle
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.only(right: 20, top: 16),
                      child: Text(
                        row.title ?? "",
                        style: Theme.of(context).textTheme.headline2,
                      ),
                    ),
                  ],
                )
              : const SizedBox(),
          SizedBox(
            height: isSlide ? _width * 0.66 + 20 : _width * 0.666 + 20,
            child: PageStorage(
              bucket: _bucket,
              child: CustomScrollView(
                key: PageStorageKey('ROW_${row.id}'),
                scrollDirection: Axis.horizontal,
                slivers: [
                  (isSlide && row.slides?.length == 1)
                      ? SliverToBoxAdapter(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Container(
                                width: MediaQuery.of(context).size.width,
                                alignment: Alignment.center,
                                padding: const EdgeInsets.all(8.0),
                                child: StoreSlideItem(
                                  aspectRatio: 2,
                                  width: MediaQuery.of(context).size.width,
                                  key: UniqueKey(),
                                  slide: row.slides!.first,
                                ),
                              ),
                            ],
                          ),
                        )
                      : SliverFixedExtentList(
                          itemExtent: _width,
                          delegate: SliverChildBuilderDelegate(
                            (context, index) => isSlide
                                ? StoreSlideItem(
                                    aspectRatio: 2,
                                    width: _width,
                                    key: UniqueKey(),
                                    slide: row.slides!.elementAt(index),
                                  )
                                : StoreBookItem(
                                    key: UniqueKey(),
                                    book: row.books!.elementAt(index),
                                  ),
                            childCount: isSlide
                                ? row.slides!.length
                                : row.books!.length,
                          ),
                        ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class StoreBookItem extends StatelessWidget {
  final Book book;

  const StoreBookItem({Key? key, required this.book}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Get.toNamed('/book/${book.id}', preventDuplicates: true);
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        // 7
        child: Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Stack(
                alignment: Alignment.topRight,
                children: [
                  AspectRatio(
                    aspectRatio: 2,
                    child: CachedNetworkImage(
                      fit: BoxFit.cover,
                      imageUrl: book.image,
                      placeholder: (context, url) => const ImageLoadingWidget(),
                      errorWidget: (context, url, error) => const ErrorIcon(),
                    ),
                  ),
                  if (book.isFree || book.discount != 0)
                    DiscountBadge(
                      child: Text(
                        book.isFree
                            ? 'رایگان'
                            : book.discount < 100
                                ? '% ${book.discount.toInt()}'
                                : '${book.discount.toInt()} تومان',
                        style:
                            const TextStyle(color: Colors.white, fontSize: 11),
                      ),
                    ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.only(
                top: 8,
                left: 8,
                right: 8,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        book.title,
                        overflow: TextOverflow.fade,
                        maxLines: 1,
                        style: Theme.of(context).textTheme.headline4,
                      ),
                      Text(
                        book.subtitle,
                        overflow: TextOverflow.fade,
                        maxLines: 1,
                        style: Theme.of(context).textTheme.headline6,
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      const FaIcon(
                        FontAwesomeIcons.solidStar,
                        color: Colors.black87,
                        size: 12,
                      ),
                      const SizedBox(height: 5),
                      Text(
                        book.rate.toStringAsFixed(1),
                        style: Theme.of(context).textTheme.subtitle1,
                      )
                    ],
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

class StoreSlideItem extends StatelessWidget {
  final Slide slide;
  final double width;
  final double aspectRatio;

  const StoreSlideItem({
    Key? key,
    required this.slide,
    required this.width,
    required this.aspectRatio,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        openURL(context, slide.url);
      },
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Container(
          width: width,
          height: width / aspectRatio,
          clipBehavior: Clip.hardEdge,
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.all(
              Radius.circular(20.0),
            ),
          ),
          child: Stack(
            alignment: Alignment.bottomRight,
            children: [
              SizedBox.expand(
                child: CachedNetworkImage(
                  fit: BoxFit.cover,
                  imageUrl: slide.media,
                  placeholder: (context, url) => const ImageLoadingWidget(),
                  errorWidget: (context, url, error) => const ErrorIcon(),
                ),
              ),
              if (slide.title != null)
                Container(
                  color: Colors.black54,
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  child: Text(
                    slide.title ?? "",
                    textAlign: TextAlign.center,
                    style: Theme.of(context)
                        .textTheme
                        .headline2!
                        .copyWith(color: Colors.white, fontSize: 14),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
