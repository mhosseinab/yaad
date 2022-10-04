import 'dart:convert';

import 'package:get/get.dart';

import './auth_controller.dart';
import '../main.dart';
import '../models/Common.dart';
import '../models/db.dart';
import '../objectbox.g.dart';
import '../services/backend.dart';

class BookController extends GetxController {
  final AuthController _authController = Get.find<AuthController>();
  final Box<FavoriteItem> favBox = objectbox.store.box<FavoriteItem>();
  final Box<ProgressData> progressBox = objectbox.store.box<ProgressData>();

  var isLoggedIn;
  var isLoading = false.obs;
  var error = false.obs;
  var isFav = false.obs;
  Book? book;

  @override
  void onInit() {
    isLoggedIn = _authController.isLoggedIn;
    super.onInit();
  }

  @override
  void onClose() {
    // TODO: implement onClose
    super.onClose();
  }

  Future<String> getBookPaymentURL(int bookID) async {
    isLoading.value = true;
    String? url = await BackendService.getBuyBookPaymentURL(
        _authController.token.val, bookID);
    isLoading.value = false;
    return url ?? "";
  }

  Future<Book?> fetchBook(String? bookID) async {
    book =
        await BackendService.fetchBook(_authController.token.val, bookID ?? "");
    if (book != null) isFav.value = getFave(book!.id) != null;
    setBookProgressTotal(
        book!.id, book!.stepCount, book!.course.id, book!.course.title);
    return book;
  }

  Future<bool> submitRating(int bid, double rating) {
    return BackendService.submitRating(
        _authController.token.val,
        jsonEncode(<String, dynamic>{
          'book': bid,
          'rate': rating.toInt(),
        }));
  }

  Future<bool> submitComment(String text, int rate) async {
    isLoading.value = true;
    error.value = false;
    bool success = await BackendService.submitComment(
        _authController.token.val,
        jsonEncode(<String, dynamic>{
          'book': book != null ? book!.id : 0,
          'text': text,
          'rate': rate,
        }));
    isLoading.value = false;
    error.value = !success;
    return success;
  }

  FavoriteItem? getFave(int bid) {
    final Query<FavoriteItem> query =
        (favBox.query(FavoriteItem_.bid.equals(bid))).build();

    final result = query.findFirst();

    query.close();

    return result;
  }

  defFromFave(int bid) {
    FavoriteItem? item = getFave(bid);
    if (item != null) {
      favBox.remove(item.id);
    }
    isFav.value = false;
  }

  addToFave(int bid) {
    FavoriteItem? item = getFave(bid);
    if (item == null) {
      favBox.put(FavoriteItem(id: 0, bid: bid, bookData: jsonEncode(book)));
    }
    isFav.value = true;
  }

  ProgressData? getProgress(int bid) {
    final Query<ProgressData> query =
        (progressBox.query(ProgressData_.bid.equals(bid))).build();

    final result = query.findFirst();

    query.close();

    return result;
  }

  void setBookProgressTotal(
      int bid, int total, int courseID, String courseName) {
    ProgressData? prg = getProgress(bid);
    if (prg == null) {
      progressBox.put(ProgressData(
          id: 0,
          bid: bid,
          total: total,
          courseID: courseID,
          courseName: courseName,
          steps: 0));
    } else {
      prg.total = total;
      prg.courseID = courseID;
      progressBox.put(prg);
    }
  }
}
