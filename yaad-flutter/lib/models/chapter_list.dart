import 'dart:convert';

ChapterList chapterListFromJson(String str) =>
    ChapterList.fromJson(json.decode(str));

String chapterListToJson(ChapterList data) => json.encode(data.toJson());

class ChapterList {
  ChapterList({
    required this.count,
    this.next,
    this.previous,
    required this.results,
  });

  int count;
  String? next;
  String? previous;
  List<ChapterInfo> results;

  factory ChapterList.fromJson(Map<String, dynamic> json) => ChapterList(
        count: json["count"],
        next: json["next"],
        previous: json["previous"],
        results: List<ChapterInfo>.from(
            json["results"].map((x) => ChapterInfo.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "count": count,
        "next": next,
        "previous": previous,
        "results": List<dynamic>.from(results.map((x) => x.toJson())),
      };
}

class ChapterInfo {
  ChapterInfo({
    required this.id,
    required this.stepCount,
    required this.title,
  });

  int id;
  int stepCount;
  String title;

  factory ChapterInfo.fromJson(Map<String, dynamic> json) => ChapterInfo(
        id: json["id"],
        stepCount: json["step_count"],
        title: json["title"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "step_count": stepCount,
        "title": title,
      };
}
