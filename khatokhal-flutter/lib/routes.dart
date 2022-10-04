import 'package:get/get.dart';

import './pages/Book.dart';
import './pages/Home.dart';
import './pages/Lesson.dart';
import '../pages/BookDetails.dart';
import '../pages/Favorites.dart';
import '../pages/Notes.dart';
import '../pages/Report.dart';
import '../pages/WebPage.dart';

class Routes {
  static final routes = [
    GetPage(name: '/book/lesson', page: () => LessonPage()),
    GetPage(name: '/book/info', page: () => BookDetailPage()),
    GetPage(name: '/book/:id', page: () => BookPage()),
    GetPage(name: '/book', page: () => BookPage()),
    GetPage(name: '/favorites', page: () => FavoritesPage()),
    GetPage(name: '/report', page: () => ReportPage()),
    GetPage(name: '/notes/:id', page: () => NotesPage()),
    GetPage(name: '/webView', page: () => WebViewPage()),
    GetPage(name: '/', page: () => HomePage()),
  ];
}
