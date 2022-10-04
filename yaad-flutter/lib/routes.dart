import 'package:get/get.dart';
import 'package:yaad_app/pages/question.dart';

import './pages/book.dart';
import './pages/home.dart';
import './pages/lesson.dart';
import '../pages/book_details.dart';
import '../pages/favorites.dart';
import '../pages/notes.dart';
import '../pages/report.dart';
import '../pages/web_page.dart';

class Routes {
  static final routes = [
    GetPage(name: '/book/question', page: () => const QuestionPage()),
    GetPage(name: '/book/lesson', page: () => const LessonPage()),
    GetPage(name: '/book/info', page: () => BookDetailPage()),
    GetPage(name: '/book/:id', page: () => const BookPage()),
    GetPage(name: '/book', page: () => const BookPage()),
    GetPage(name: '/favorites', page: () => const FavoritesPage()),
    GetPage(name: '/report', page: () => ReportPage()),
    GetPage(name: '/notes/:id', page: () => const NotesPage()),
    GetPage(name: '/webView', page: () => const WebViewPage()),
    GetPage(name: '/', page: () => const HomePage()),
  ];
}
