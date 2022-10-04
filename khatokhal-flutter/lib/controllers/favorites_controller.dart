import 'package:get/get.dart';

import '../main.dart';
import '../models/db.dart';
import '../objectbox.g.dart';

class FavoriteController extends GetxController {
  final Box<FavoriteItem> favBox = objectbox.store.box<FavoriteItem>();

  @override
  void onInit() {
    super.onInit();
  }

  @override
  void onClose() {
    super.onClose();
  }

  List<FavoriteItem> getAllFav() {
    return favBox.getAll();
  }

  defFromFav(FavoriteItem item) {
    favBox.remove(item.id);
  }
}
