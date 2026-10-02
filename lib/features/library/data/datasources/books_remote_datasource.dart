import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../../book_scanner/data/models/book_model.dart';

abstract class BooksRemoteDataSource {
  Future<List<BookModel>> searchBooks(String query);
}

class BooksRemoteDataSourceImpl implements BooksRemoteDataSource {
  final http.Client client;

  BooksRemoteDataSourceImpl({required this.client});

  @override
  Future<List<BookModel>> searchBooks(String query) async {
    // Перешли на OpenLibrary, так как Google Books без ключа отдает 429 Too Many Requests
    final url = 'https://openlibrary.org/search.json?q=${Uri.encodeComponent(query)}&limit=10';
    debugPrint('BooksRemoteDataSource: Requesting URL: $url');

    try {
      final response = await client.get(Uri.parse(url));
      debugPrint('BooksRemoteDataSource: Response status code: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final docs = data['docs'] as List<dynamic>? ?? [];
        debugPrint('BooksRemoteDataSource: Found ${docs.length} items');

        final List<BookModel> parsedBooks = [];

        for (final item in docs) {
          try {
            if (item is! Map) continue;

            final title = item['title']?.toString();
            
            final authorsRaw = item['author_name'];
            String? authors;
            if (authorsRaw is List) {
              authors = authorsRaw.join(', ');
            } else if (authorsRaw != null) {
              authors = authorsRaw.toString();
            }

            int? year;
            final yearRaw = item['first_publish_year'];
            if (yearRaw is int) {
              year = yearRaw;
            } else if (yearRaw != null) {
              year = int.tryParse(yearRaw.toString());
            }

            // OpenLibrary хранит ID обложек в поле cover_i
            String? thumbnailUrl;
            final coverId = item['cover_i'];
            if (coverId != null) {
              thumbnailUrl = 'https://covers.openlibrary.org/b/id/$coverId-M.jpg';
            }

            parsedBooks.add(BookModel(
              id: item['key']?.toString(), // OpenLibrary ID (e.g. /works/OL...)
              title: title,
              author: authors,
              year: year,
              description: null, // OpenLibrary search не отдает description списком, оставляем пустым
              thumbnailUrl: thumbnailUrl,
            ));
          } catch (e, stackTrace) {
            debugPrint('BooksRemoteDataSource: Error parsing single book item: $e');
            debugPrint(stackTrace.toString());
          }
        }

        return parsedBooks;
      } else if (response.statusCode == 429) {
        throw Exception('Превышен лимит запросов к серверу (429). Попробуйте позже.');
      } else {
        debugPrint('BooksRemoteDataSource: API Error Body: ${response.body}');
        throw Exception('Ошибка загрузки: статус ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      debugPrint('BooksRemoteDataSource: Exception during network call or parsing: $e');
      debugPrint(stackTrace.toString());
      rethrow;
    }
  }
}
