enum ContentType { V, I, A, T }

final contentTypeValues = EnumValues({
  "I": ContentType.I,
  "V": ContentType.V,
  "A": ContentType.A,
  "T": ContentType.T
});

enum StepType { LESSON, QUESTION }

final stepTypeValues =
    EnumValues({"lesson": StepType.LESSON, "question": StepType.QUESTION});

class EnumValues<T> {
  Map<String, T> map;
  Map<T, String>? reverseMap;

  EnumValues(this.map);

  Map<T, String>? get reverse {
    if (reverseMap == null) {
      reverseMap = map.map((k, v) => new MapEntry(v, k));
    }
    return reverseMap;
  }
}

class Book {
  Book(
      {required this.id,
      required this.title,
      required this.subtitle,
      required this.author,
      required this.about,
      required this.image,
      this.video,
      required this.price,
      required this.discount,
      required this.rate,
      required this.rateCount,
      required this.stepCount,
      required this.purchaseCount,
      this.userRate,
      required this.isPromoted,
      required this.isDraft,
      required this.isPurchased,
      required this.publisher,
      required this.course,
      required this.niveau,
      this.comments})
      : this.isFree = price == 0;

  int id;
  String title;
  String subtitle;
  String author;
  String about;
  String image;
  String? video;
  int price;
  double discount;
  double rate;
  int rateCount;
  int stepCount;
  int purchaseCount;
  int? userRate;
  bool isPromoted;
  bool isDraft;
  bool isPurchased;
  Publisher publisher;
  Course course;
  Niveau niveau;
  bool isFree;
  List<Comment>? comments;

  factory Book.fromJson(Map<String, dynamic> json) => Book(
        id: json["id"],
        title: json["title"],
        subtitle: json["subtitle"],
        author: json["author"],
        about: json["about"],
        image: json["image"],
        video: json["video"],
        price: json["price"],
        discount: json["discount"],
        rate: json["rate"],
        rateCount: json["rate_count"],
        stepCount: json["step_count"],
        purchaseCount: json["purchase_count"],
        userRate: json["user_rate"],
        isPromoted: json["is_promoted"],
        isDraft: json["is_draft"],
        isPurchased: json["is_purchased"],
        publisher: Publisher.fromJson(json["publisher"]),
        course: Course.fromJson(json["course"]),
        niveau: Niveau.fromJson(json["niveau"]),
        comments: json["comments"] != null
            ? List<Comment>.from(
                json["comments"].map((x) => Comment.fromJson(x)))
            : null,
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "subtitle": subtitle,
        "author": author,
        "about": about,
        "image": image,
        "video": video,
        "price": price,
        "discount": discount,
        "rate": rate,
        "rate_count": rateCount,
        "step_count": stepCount,
        "purchase_count": purchaseCount,
        "user_rate": userRate,
        "is_promoted": isPromoted,
        "is_draft": isDraft,
        "is_purchased": isPurchased,
        "publisher": publisher.toJson(),
        "course": course.toJson(),
        "niveau": niveau.toJson(),
        "comments": comments != null
            ? List<dynamic>.from(comments!.map((x) => x.toJson()))
            : null,
      };
}

class Comment {
  Comment({
    required this.id,
    required this.user,
    required this.rate,
    required this.text,
    required this.book,
    this.parent,
  });

  int id;
  Author user;
  int rate;
  String text;
  int book;
  int? parent;

  factory Comment.fromJson(Map<String, dynamic> json) => Comment(
        id: json["id"],
        user: Author.fromJson(json["user"]),
        rate: json["rate"],
        text: json["text"],
        book: json["book"],
        parent: json["parent"] == null ? null : json["parent"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "user": user.toJson(),
        "rate": rate,
        "text": text,
        "book": book,
        "parent": parent == null ? null : parent,
      };
}

class Author {
  Author({
    required this.id,
    this.name,
    this.avatar,
  });

  int id;
  String? name;
  String? avatar;

  factory Author.fromJson(Map<String, dynamic> json) => Author(
        id: json["id"],
        name: json["name"],
        avatar: json["avatar"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "avatar": avatar,
      };
}

class Course {
  Course({
    required this.id,
    required this.title,
  });

  int id;
  String title;

  factory Course.fromJson(Map<String, dynamic> json) => Course(
        id: json["id"],
        title: json["title"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
      };
}

class Niveau {
  Niveau({
    required this.id,
    required this.title,
  });

  int id;
  String title;

  factory Niveau.fromJson(Map<String, dynamic> json) => Niveau(
        id: json["id"],
        title: json["title"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
      };
}

class Publisher {
  Publisher({
    required this.id,
    this.logo,
    required this.title,
  });

  int id;
  String? logo;
  String title;

  factory Publisher.fromJson(Map<String, dynamic> json) => Publisher(
        id: json["id"],
        logo: json["logo"],
        title: json["title"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "logo": logo,
        "title": title,
      };
}

class Slide {
  Slide({
    required this.id,
    this.title,
    this.url,
    required this.row,
    required this.media,
  });

  int id;
  String? title;
  String? url;
  int row;
  String media;

  factory Slide.fromJson(Map<String, dynamic> json) => Slide(
        id: json["id"],
        title: json["title"],
        url: json["url"],
        row: json["row"],
        media: json["media"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "url": url,
        "row": row,
        "media": media,
      };
}

class CommentList {
  CommentList({
    required this.count,
    this.next,
    this.previous,
    required this.results,
  });

  int count;
  String? next;
  String? previous;
  List<Comment> results;

  factory CommentList.fromJson(Map<String, dynamic> json) => CommentList(
        count: json["count"],
        next: json["next"],
        previous: json["previous"],
        results:
            List<Comment>.from(json["results"].map((x) => Comment.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "count": count,
        "next": next,
        "previous": previous,
        "results": List<Comment>.from(results.map((x) => x.toJson())),
      };
}
