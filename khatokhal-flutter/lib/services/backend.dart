import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/Chapter.dart';
import '../models/ChapterList.dart';
import '../models/Common.dart';
import '../models/Store.dart';
import '../models/User.dart';

class BackendService {
  static var client = http.Client();
  static const String BASE_URL = "https://srv.yaad.app";
  static const Map<String, String> HEADERS = {
    "Content-Type": "application/json",
    "Accept-Encoding": "gzip, deflate, br",
  };
  static Future<StoreHome?> fetchStoreHome() {
    return client
        .get(Uri.parse(BASE_URL + '/khatokhal/store/rows/'), headers: HEADERS)
        .then((response) {
      if (response.statusCode == 200) {
        final body = utf8.decode(response.bodyBytes);
        return storeHomeFromJson(body);
      } else {
        return null;
      }
    }).catchError((err) {
      print("ERR: $err");
      throw err;
    });
  }

  static Future<Chapters?> fetchChapters(String token, int bookId) {
    return client
        .get(
      Uri.parse(BASE_URL + '/khatokhal/chapter/?book=$bookId&o=row'),
      headers: token.isNotEmpty
          ? {...HEADERS, 'Authorization': 'Token $token'}
          : HEADERS,
    )
        .then((response) {
      if (response.statusCode == 200) {
        final body = utf8.decode(response.bodyBytes);
        return chaptersFromJson(body);
      } else {
        return null;
      }
    }).catchError((err) {
      print("ERR: $err");
      return null;
    });
  }

  static Future<ChapterList?> fetchChapterList(int bookId) {
    return client
        .get(
      Uri.parse(BASE_URL + '/khatokhal/chapter/list/?book=$bookId&o=row'),
      headers: HEADERS,
    )
        .then((response) {
      if (response.statusCode == 200) {
        final body = utf8.decode(response.bodyBytes);
        return chapterListFromJson(body);
      } else {
        return null;
      }
    }).catchError((err) {
      print("ERR: $err");
      return null;
    });
  }

  static Future<TokenRequest?> getLoginCode(String mobile) {
    print(mobile);
    return client
        .post(
      Uri.parse(BASE_URL + '/accounts/get/token/'),
      headers: HEADERS,
      body: jsonEncode(<String, String>{
        'mobile': mobile,
      }),
    )
        .then((response) {
      if (response.statusCode == 200) {
        final body = utf8.decode(response.bodyBytes);
        return tokenRequestFromJson(body);
      } else {
        return null;
      }
    }).catchError((err) {
      print("ERR: $err");
      return null;
    });
  }

  static Future<LoginResponse?> loginWithCode(String uuid, String code) {
    print("$uuid -> $code");
    return client
        .post(
      Uri.parse(BASE_URL + '/accounts/verify/token/'),
      headers: HEADERS,
      body: jsonEncode(<String, String>{
        'uuid': uuid,
        'token': code,
      }),
    )
        .then((response) {
      print(response.statusCode);
      if (response.statusCode == 200) {
        final body = utf8.decode(response.bodyBytes);
        print(body);
        return loginResponseFromJson(body);
      } else {
        print(response.body);
        return null;
      }
    }).catchError((err) {
      print("ERR: $err");
      return null;
    });
  }

  static Future<String?> getBuyBookPaymentURL(String token, int bid) {
    return client
        .get(
      Uri.parse(BASE_URL + '/khatokhal/buy/book/$bid/'),
      headers: token.isNotEmpty
          ? {...HEADERS, 'Authorization': 'Token $token'}
          : HEADERS,
    )
        .then((response) {
      // print(response.body);
      if (response.statusCode == 200) {
        final body = utf8.decode(response.bodyBytes);
        final decoded = json.decode(body);
        return decoded["url"].toString();
      } else {
        // print(response.body);
        //TODO: precess already purchased
        return null;
      }
    }).catchError((err) {
      print("ERR: $err");
      return null;
    });
  }

  static Future<LoggedInUser?> checkToken(String token, int uid) {
    return client
        .get(
      Uri.parse(BASE_URL + '/accounts/profile/$uid/'),
      headers: token.isNotEmpty
          ? {...HEADERS, 'Authorization': 'Token $token'}
          : HEADERS,
    )
        .then((response) {
      if (response.statusCode == 200) {
        final body = utf8.decode(response.bodyBytes);
        print(body);
        return LoggedInUser.fromJson(json.decode(body));
      } else {
        print("${response.statusCode} ${response.body}");
        return null;
      }
    }).catchError((err) {
      print("ERR: $err");
      return null;
    });
  }

  static Future<Book?> fetchBook(String token, String bid) {
    return client
        .get(
      Uri.parse(BASE_URL + '/khatokhal/book/$bid/'),
      headers: token.isNotEmpty
          ? {...HEADERS, 'Authorization': 'Token $token'}
          : HEADERS,
    )
        .then((response) {
      // print(response.body);
      if (response.statusCode == 200) {
        final body = utf8.decode(response.bodyBytes);
        return Book.fromJson(json.decode(body));
      } else {
        return null;
      }
    }).catchError((err) {
      print("ERR: $err");
      return null;
    });
  }

  static Future<List<Book>> fetchPurchases(String token) {
    return client
        .get(
      Uri.parse(BASE_URL + '/khatokhal/purchases/'),
      headers: token.isNotEmpty
          ? {...HEADERS, 'Authorization': 'Token $token'}
          : HEADERS,
    )
        .then((response) {
      // print(response.body);
      if (response.statusCode == 200) {
        final body = utf8.decode(response.bodyBytes);
        var json = jsonDecode(body);
        return List<Book>.from(json["books"].map((x) => Book.fromJson(x)));
      } else {
        return <Book>[];
      }
    }).catchError((err) {
      print("ERR: $err");
      return <Book>[];
    });
  }

  static Future<LoggedInUser?> setProfile(String token, int uid, String data) {
    // print(data);
    return client
        .put(
      Uri.parse(BASE_URL + '/accounts/profile/$uid/'),
      headers: token.isNotEmpty
          ? {...HEADERS, 'Authorization': 'Token $token'}
          : HEADERS,
      body: data,
    )
        .then((response) {
      // print(response.body);
      if (response.statusCode == 200) {
        final body = utf8.decode(response.bodyBytes);
        return LoggedInUser.fromJson(json.decode(body));
      } else {
        return null;
      }
    }).catchError((err) {
      print("ERR: $err");
      return null;
    });
  }

  static Future<bool> submitRating(String token, String data) {
    return client
        .post(
      Uri.parse(BASE_URL + '/khatokhal/book/rate/'),
      headers: token.isNotEmpty
          ? {...HEADERS, 'Authorization': 'Token $token'}
          : HEADERS,
      body: data,
    )
        .then((response) {
      print(response.body);
      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    }).catchError((err) {
      print("ERR: $err");
      return false;
    });
  }

  static Future<bool> submitComment(String token, String data) {
    return client
        .post(
      Uri.parse(BASE_URL + '/khatokhal/book/comment/'),
      headers: token.isNotEmpty
          ? {...HEADERS, 'Authorization': 'Token $token'}
          : HEADERS,
      body: data,
    )
        .then((response) {
      print(response.body);
      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    }).catchError((err) {
      print("ERR: $err");
      return false;
    });
  }

  static Future<CommentList?> getComments(String? token, int bid, int page) {
    // print('getComments');
    return client
        .get(
      Uri.parse(BASE_URL +
          '/khatokhal/book/comment/?book=$bid&no_parent=1&page=$page'),
      headers: token != null && token.isNotEmpty
          ? {...HEADERS, 'Authorization': 'Token $token'}
          : HEADERS,
    )
        .then((response) {
      // print(response.body);
      if (response.statusCode == 200) {
        final String body = utf8.decode(response.bodyBytes);
        return CommentList.fromJson(jsonDecode(body));
      } else {
        return null;
      }
    }).catchError((err) {
      print("ERR: $err");
      return null;
    });
  }
}
