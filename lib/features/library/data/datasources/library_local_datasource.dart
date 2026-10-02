import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../book_scanner/data/models/book_model.dart';

abstract class LibraryLocalDataSource {
  Future<List<BookModel>> getBooks();
  Future<void> saveBook(BookModel book);
  Future<void> updateBook(BookModel book);
  Future<void> deleteBook(String id);
}

class LibraryLocalDataSourceImpl implements LibraryLocalDataSource {
  final SharedPreferences sharedPreferences;
  static const String cachedBooksKey = 'CACHED_BOOKS_KEY';

  LibraryLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<List<BookModel>> getBooks() async {
    final jsonString = sharedPreferences.getString(cachedBooksKey);
    if (jsonString == null) {
      return [];
    }
    final List<dynamic> jsonList = json.decode(jsonString);
    return jsonList
        .map((jsonItem) => BookModel.fromJson(jsonItem as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> saveBook(BookModel book) async {
    final books = await getBooks();
    final bookToSave = book.id == null || book.id!.isEmpty
        ? book.copyWith(id: DateTime.now().millisecondsSinceEpoch.toString())
        : book;
    books.add(bookToSave);
    await _saveBooksList(books);
  }

  @override
  Future<void> updateBook(BookModel book) async {
    final books = await getBooks();
    final index = books.indexWhere((b) => b.id == book.id);
    if (index != -1) {
      books[index] = book;
      await _saveBooksList(books);
    } else {
      throw Exception('Book not found for update');
    }
  }

  @override
  Future<void> deleteBook(String id) async {
    final books = await getBooks();
    books.removeWhere((b) => b.id == id);
    await _saveBooksList(books);
  }

  Future<void> _saveBooksList(List<BookModel> books) async {
    final jsonList = books.map((b) => b.toJson()).toList();
    await sharedPreferences.setString(cachedBooksKey, json.encode(jsonList));
  }
}
