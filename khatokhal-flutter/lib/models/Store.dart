// To parse this JSON data, do
//
//     final storeHome = storeHomeFromJson(jsonString);

import 'dart:convert';

import 'Common.dart';

StoreHome storeHomeFromJson(String str) => StoreHome.fromJson(json.decode(str));

String storeHomeToJson(StoreHome data) => json.encode(data.toJson());

class StoreHome {
  StoreHome({
    required this.count,
    this.next,
    this.previous,
    required this.results,
  });

  int count;
  dynamic next;
  dynamic previous;
  List<Result> results;

  factory StoreHome.fromJson(Map<String, dynamic> json) => StoreHome(
        count: json["count"],
        next: json["next"],
        previous: json["previous"],
        results:
            List<Result>.from(json["results"].map((x) => Result.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "count": count,
        "next": next,
        "previous": previous,
        "results": List<dynamic>.from(results.map((x) => x.toJson())),
      };
}

class Result {
  Result({
    required this.id,
    this.title,
    this.slides,
    this.books,
    required this.showTitle,
    required this.itemType,
    required this.row,
  });

  int id;
  String? title;
  bool showTitle;
  List<Slide>? slides;
  List<Book>? books;
  RowType itemType;
  int row;

  factory Result.fromJson(Map<String, dynamic> json) => Result(
        id: json["id"],
        title: json["title"],
        showTitle: json["show_title"],
        books: json["item_type"] == 'B'
            ? List<Book>.from(json["items"].map((x) => Book.fromJson(x)))
            : null,
        slides: json["item_type"] == 'S'
            ? List<Slide>.from(json["items"].map((x) => Slide.fromJson(x)))
            : null,
        itemType: rowTypeValues.map[json["item_type"]] ?? RowType.UNKNOWN,
        row: json["row"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "show_title": showTitle,
        "items": books != null
            ? List<Book>.from(books!.map((x) => x.toJson()))
            : List<Slide>.from(slides!.map((x) => x.toJson())),
        "item_type": rowTypeValues.reverse![itemType],
        "row": row,
      };
}

enum RowType { Slide, Book, UNKNOWN }

final rowTypeValues = EnumValues({"S": RowType.Slide, "B": RowType.Book});
