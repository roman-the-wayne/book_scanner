import 'dart:async';
import 'dart:convert';
import 'dart:io';
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
    try {
      // 1. Пробуем сначала Google Books API
      return await _searchGoogleBooks(query);
    } on SocketException {
      throw const SocketException(
          'Отсутствует подключение к интернету. Проверьте соединение.');
    } on http.ClientException catch (e) {
      if (e.message.contains('Failed host lookup') ||
          e.message.contains('SocketException')) {
        throw const SocketException(
            'Отсутствует подключение к интернету. Проверьте соединение.');
      }
      debugPrint('Google Books ClientException ($e). Falling back to OpenLibrary...');
      return await _searchOpenLibrary(query);
    } catch (e) {
      debugPrint('Google Books failed ($e). Falling back to OpenLibrary...');
      return await _searchOpenLibrary(query);
    }
  }

  Future<List<BookModel>> _searchGoogleBooks(String query) async {
    final uri = Uri.https('www.googleapis.com', '/books/v1/volumes', {
      'q': query,
      'maxResults': '10',
    });
    debugPrint('BooksRemoteDataSource: Requesting Google Books: $uri');

    final response = await client.get(
      uri,
      headers: {
        'User-Agent': 'BookScannerApp/1.0',
        'Accept': 'application/json',
      },
    ).timeout(const Duration(seconds: 8));

    debugPrint('Google Books response status: ${response.statusCode}');

    if (response.statusCode == 200) {
      final String decodedBody = utf8.decode(response.bodyBytes);
      final Map<String, dynamic> data = json.decode(decodedBody);
      final items = data['items'] as List<dynamic>? ?? [];

      final List<BookModel> parsedBooks = [];

      for (final item in items) {
        try {
          if (item is! Map) continue;
          final volumeInfo = item['volumeInfo'];
          if (volumeInfo is! Map) continue;

          final title = volumeInfo['title']?.toString();

          final authorsRaw = volumeInfo['authors'];
          String? authors;
          if (authorsRaw is List) {
            authors = authorsRaw.join(', ');
          } else if (authorsRaw != null) {
            authors = authorsRaw.toString();
          }

          final publishedDate = volumeInfo['publishedDate']?.toString();
          int? year;
          if (publishedDate != null && publishedDate.length >= 4) {
            year = int.tryParse(publishedDate.substring(0, 4));
          }

          final description = volumeInfo['description']?.toString();

          final imageLinks = volumeInfo['imageLinks'];
          String? thumbnailUrl;
          if (imageLinks is Map) {
            thumbnailUrl = imageLinks['thumbnail']?.toString();
          }

          parsedBooks.add(BookModel(
            id: item['id']?.toString(),
            title: title,
            author: authors,
            year: year,
            description: description,
            thumbnailUrl: thumbnailUrl,
          ));
        } catch (e) {
          debugPrint('Error parsing Google Book item: $e');
        }
      }

      return parsedBooks;
    } else {
      throw Exception('Google Books status code: ${response.statusCode}');
    }
  }

  Future<List<BookModel>> _searchOpenLibrary(String query) async {
    final uri = Uri.https('openlibrary.org', '/search.json', {
      'q': query,
      'limit': '10',
    });
    debugPrint('BooksRemoteDataSource: Requesting OpenLibrary: $uri');

    final response = await client.get(
      uri,
      headers: {
        'User-Agent': 'BookScannerApp/1.0',
        'Accept': 'application/json',
      },
    ).timeout(const Duration(seconds: 8));

    debugPrint('OpenLibrary response status: ${response.statusCode}');

    if (response.statusCode == 200) {
      final String decodedBody = utf8.decode(response.bodyBytes);
      final Map<String, dynamic> data = json.decode(decodedBody);
      final docs = data['docs'] as List<dynamic>? ?? [];

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

          String? thumbnailUrl;
          final coverId = item['cover_i'];
          if (coverId != null) {
            thumbnailUrl = 'https://covers.openlibrary.org/b/id/$coverId-M.jpg';
          }

          parsedBooks.add(BookModel(
            id: item['key']?.toString(),
            title: title,
            author: authors,
            year: year,
            description: null,
            thumbnailUrl: thumbnailUrl,
          ));
        } catch (e) {
          debugPrint('Error parsing OpenLibrary item: $e');
        }
      }

      return parsedBooks;
    } else {
      throw Exception('OpenLibrary status code: ${response.statusCode}');
    }
  }
}
