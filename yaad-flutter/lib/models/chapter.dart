// ignore: file_names
// ignore: file_names
import 'dart:convert';

import 'common.dart';

Chapters chaptersFromJson(String str) => Chapters.fromJson(json.decode(str));

String chaptersToJson(Chapters data) => json.encode(data.toJson());

class Chapters {
  Chapters({
    required this.count,
    this.next,
    this.previous,
    required this.results,
  });

  int count;
  String? next;
  String? previous;
  List<Result> results;

  factory Chapters.fromJson(Map<String, dynamic> json) => Chapters(
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
    required this.row,
    required this.steps,
    required this.isDraft,
    required this.book,
  });

  int id;
  String? title;
  int row;
  List<List<Step>> steps;
  bool isDraft;
  int book;

  factory Result.fromJson(Map<String, dynamic> json) => Result(
        id: json["id"],
        title: json["title"],
        row: json["row"],
        steps: List<List<Step>>.from(json["steps"]
            .map((x) => List<Step>.from(x.map((x) => Step.fromJson(x))))),
        isDraft: json["is_draft"],
        book: json["book"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "row": row,
        "steps": List<dynamic>.from(
            steps.map((x) => List<dynamic>.from(x.map((x) => x.toJson())))),
        "is_draft": isDraft,
        "book": book,
      };
}

class Step {
  Step({
    required this.id,
    this.content,
    required this.contentId,
    required this.contentType,
    required this.type,
  });

  int id;
  Content? content;
  int contentId;
  int contentType;
  StepType? type;

  factory Step.fromJson(Map<String, dynamic> json) => Step(
        id: json["id"],
        content:
            json["content"] == null ? null : Content.fromJson(json["content"]),
        contentId: json["content_id"],
        contentType: json["content_type"],
        type: stepTypeValues.map[json["type"]],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "content": content == null ? null : content!.toJson(),
        "content_id": contentId,
        "content_type": contentType,
        "type": stepTypeValues.reverse![type],
      };
}

class Content {
  Content({
    required this.id,
    this.media,
    this.title,
    this.text,
    this.contentType,
    required this.isDraft,
    required this.book,
    this.answer,
    this.answerChoices,
  });

  int id;
  String? media;
  String? title;
  String? text;
  ContentType? contentType;
  bool isDraft;
  int book;
  Answer? answer;
  List<AnswerChoice>? answerChoices;

  factory Content.fromJson(Map<String, dynamic> json) => Content(
        id: json["id"],
        media: json["media"],
        title: json["title"],
        text: json["text"],
        contentType: contentTypeValues.map[json["content_type"]],
        isDraft: json["is_draft"],
        book: json["book"],
        answer: json["answer"] == null ? null : Answer.fromJson(json["answer"]),
        answerChoices: json["answer_choices"] == null
            ? null
            : List<AnswerChoice>.from(
                json["answer_choices"].map((x) => AnswerChoice.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "media": media,
        "title": title,
        "text": text,
        "content_type": contentTypeValues.reverse![contentType],
        "is_draft": isDraft,
        "book": book,
        "answer": answer == null ? null : answer!.toJson(),
        "answer_choices": answerChoices == null
            ? null
            : List<dynamic>.from(answerChoices!.map((x) => x.toJson())),
      };
}

class Answer {
  Answer({
    this.text,
    required this.contentType,
    this.media,
  });

  String? text;
  ContentType? contentType;
  String? media;

  factory Answer.fromJson(Map<String, dynamic> json) => Answer(
        text: json["text"],
        contentType: contentTypeValues.map[json["content_type"]],
        media: json["media"],
      );

  Map<String, dynamic> toJson() => {
        "text": text,
        "content_type": contentTypeValues.reverse![contentType],
        "media": media,
      };
}

class AnswerChoice {
  AnswerChoice({
    this.text,
    this.type,
    required this.isCorrect,
  });

  String? text;
  ContentType? type;
  bool isCorrect;

  factory AnswerChoice.fromJson(Map<String, dynamic> json) => AnswerChoice(
        text: json["text"],
        type: contentTypeValues.map[json["type"]],
        isCorrect: json["is_correct"],
      );

  Map<String, dynamic> toJson() => {
        "text": text,
        "type": contentTypeValues.reverse![type],
        "is_correct": isCorrect,
      };
}
