import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../book_scanner/data/models/book_model.dart';

// Выносим тяжелые операции парсинга в top-level функции для запуска в изолятах
List<BookModel> _decodeBooksInBackground(String jsonString) {
  final List<dynamic> jsonList = json.decode(jsonString);
  return jsonList
      .map((jsonItem) => BookModel.fromJson(jsonItem as Map<String, dynamic>))
      .toList();
}

String _encodeBooksInBackground(List<BookModel> books) {
  final jsonList = books.map((b) => b.toJson()).toList();
  return json.encode(jsonList);
}

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
    if (jsonString == null || jsonString.isEmpty) {
      return [];
    }
    // Выполняем десериализацию в фоновом потоке, чтобы не морозить UI (ListView)
    return await compute(_decodeBooksInBackground, jsonString);
  }

  @override
  Future<void> saveBook(BookModel book) async {
    final books = await getBooks();
    // ID должен генерироваться в Domain слое, а не здесь. 
    // Data layer отвечает только за хранение.
    books.add(book);
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
    // Выполняем сериализацию в фоновом потоке
    final jsonString = await compute(_encodeBooksInBackground, books);
    await sharedPreferences.setString(cachedBooksKey, jsonString);
  }
}
