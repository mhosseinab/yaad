import 'package:get/get.dart';

import '../main.dart';
import '../models/db.dart';
import '../objectbox.g.dart';

class FavoriteController extends GetxController {
  final Box<FavoriteItem> favBox = objectBox.store.box<FavoriteItem>();

  List<FavoriteItem> getAllFav() {
    return favBox.getAll();
  }

  defFromFav(FavoriteItem item) {
    favBox.remove(item.id);
  }
}
