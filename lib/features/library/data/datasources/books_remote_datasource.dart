import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import '../../../book_scanner/data/models/book_model.dart';

abstract class BooksRemoteDataSource {
  Future<List<BookModel>> searchBooks(String query);
  Future<BookModel> enrichBook(BookModel book);
}

class BooksRemoteDataSourceImpl implements BooksRemoteDataSource {
  final Dio dio;

  BooksRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<BookModel>> searchBooks(String query) async {
    try {
      final googleResults = await _searchGoogleBooks(query);
      if (googleResults.isNotEmpty) return googleResults;
      return await _searchOpenLibrary(query);
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.connectionError ||
          e.error is SocketException) {
        throw const SocketException('Отсутствует подключение к интернету. Проверьте соединение.');
      }
      debugPrint('DioException in Google Books ($e). Falling back to OpenLibrary...');
      return await _searchOpenLibrary(query);
    } on SocketException {
      throw const SocketException('Отсутствует подключение к интернету. Проверьте соединение.');
    } catch (e) {
      debugPrint('Google Books failed ($e). Falling back to OpenLibrary...');
      return await _searchOpenLibrary(query);
    }
  }

  @override
  Future<BookModel> enrichBook(BookModel book) async {
    final title = book.title?.trim();
    final author = book.author?.trim();
    final isbn = book.isbn?.trim();

    List<BookModel> results = [];

    // 1. Поиск по ISBN
    if (isbn != null && isbn.isNotEmpty) {
      try {
        results = await searchBooks('isbn:$isbn');
      } catch (e) {
        debugPrint('Enrichment by ISBN failed: $e');
      }
    }

    // 2. Поиск по автору и названию
    if (results.isEmpty && title != null && title.isNotEmpty) {
      try {
        String query;
        if (author != null && author.isNotEmpty) {
          query = 'intitle:"$title" inauthor:"$author"';
        } else {
          query = 'intitle:"$title"';
        }
        results = await searchBooks(query);
      } catch (e) {
        debugPrint('Enrichment by structured query failed: $e');
      }
    }

    // 3. Резервный свободный поиск
    if (results.isEmpty && ((title != null && title.isNotEmpty) || (author != null && author.isNotEmpty))) {
      try {
        final query = '${title ?? ''} ${author ?? ''}'.trim();
        results = await searchBooks(query);
      } catch (e) {
        debugPrint('Enrichment by free text failed: $e');
      }
    }

    if (results.isEmpty) {
      throw Exception('Книга не найдена во внешних библиотеках (Google Books / OpenLibrary)');
    }

    // Выбираем результат с обложкой и описанием, если таковой имеется
    final match = results.firstWhere(
      (b) => (b.thumbnailUrl != null && b.thumbnailUrl!.isNotEmpty) || (b.description != null && b.description!.isNotEmpty),
      orElse: () => results.first,
    );

    final enriched = book.copyWith(
      title: (book.title == null || book.title!.isEmpty) ? match.title : book.title,
      author: (book.author == null || book.author!.isEmpty) ? match.author : book.author,
      year: book.year ?? match.year,
      description: (book.description == null || book.description!.isEmpty) ? match.description : book.description,
      thumbnailUrl: (book.thumbnailUrl == null || book.thumbnailUrl!.isEmpty) ? match.thumbnailUrl : book.thumbnailUrl,
      genre: (book.genre == null || book.genre!.isEmpty) ? match.genre : book.genre,
      publisher: (book.publisher == null || book.publisher!.isEmpty) ? match.publisher : book.publisher,
      city: (book.city == null || book.city!.isEmpty) ? match.city : book.city,
      pages: book.pages ?? match.pages,
      isbn: (book.isbn == null || book.isbn!.isEmpty) ? match.isbn : book.isbn,
      udc: (book.udc == null || book.udc!.isEmpty) ? match.udc : book.udc,
      bbk: (book.bbk == null || book.bbk!.isEmpty) ? match.bbk : book.bbk,
    );

    if (enriched == book) {
      throw Exception('Новых сведений о книге не найдено в сети');
    }

    return enriched;
  }

  Future<List<BookModel>> _searchGoogleBooks(String query) async {
    final uri = 'https://www.googleapis.com/books/v1/volumes';
    debugPrint('BooksRemoteDataSource: Requesting Google Books for: $query');

    final response = await dio.get<Map<String, dynamic>>(
      uri,
      queryParameters: {
        'q': query,
        'maxResults': 10,
      },
      options: Options(
        headers: {
          'User-Agent': 'BookScannerApp/1.0',
          'Accept': 'application/json',
        },
      ),
    );

    if (response.statusCode == 200 && response.data != null) {
      final data = response.data!;
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
            thumbnailUrl = imageLinks['thumbnail']?.toString() ??
                imageLinks['smallThumbnail']?.toString() ??
                imageLinks['medium']?.toString() ??
                imageLinks['large']?.toString();
            if (thumbnailUrl != null) {
              if (thumbnailUrl.startsWith('http:')) {
                thumbnailUrl = thumbnailUrl.replaceFirst('http:', 'https:');
              }
              thumbnailUrl = thumbnailUrl.replaceAll('&edge=curl', '');
            }
          }

          final publisher = volumeInfo['publisher']?.toString();

          int? pages;
          final pageCountRaw = volumeInfo['pageCount'];
          if (pageCountRaw is int) {
            pages = pageCountRaw;
          } else if (pageCountRaw != null) {
            pages = int.tryParse(pageCountRaw.toString());
          }

          String? genre;
          final categoriesRaw = volumeInfo['categories'];
          if (categoriesRaw is List) {
            genre = categoriesRaw.join(', ');
          } else if (categoriesRaw != null) {
            genre = categoriesRaw.toString();
          }

          String? isbn;
          final industryIdentifiers = volumeInfo['industryIdentifiers'];
          if (industryIdentifiers is List) {
            for (final idObj in industryIdentifiers) {
              if (idObj is Map) {
                final type = idObj['type']?.toString();
                final identifier = idObj['identifier']?.toString();
                if (type == 'ISBN_13' || type == 'ISBN_10') {
                  isbn = identifier;
                  if (type == 'ISBN_13') break;
                }
              }
            }
          }

          parsedBooks.add(BookModel(
            id: item['id']?.toString(),
            title: title,
            author: authors,
            year: year,
            description: description,
            thumbnailUrl: thumbnailUrl,
            publisher: publisher,
            pages: pages,
            genre: genre,
            isbn: isbn,
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
    final uri = 'https://openlibrary.org/search.json';
    debugPrint('BooksRemoteDataSource: Requesting OpenLibrary for: $query');

    final response = await dio.get<Map<String, dynamic>>(
      uri,
      queryParameters: {
        'q': query,
        'limit': 10,
      },
      options: Options(
        headers: {
          'User-Agent': 'BookScannerApp/1.0',
          'Accept': 'application/json',
        },
      ),
    );

    if (response.statusCode == 200 && response.data != null) {
      final data = response.data!;
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
            thumbnailUrl = 'https://covers.openlibrary.org/b/id/$coverId-L.jpg';
          }

          final publisherRaw = item['publisher'];
          String? publisher;
          if (publisherRaw is List && publisherRaw.isNotEmpty) {
            publisher = publisherRaw.first.toString();
          }

          String? genre;
          final subjectsRaw = item['subject'];
          if (subjectsRaw is List && subjectsRaw.isNotEmpty) {
            genre = subjectsRaw.take(3).join(', ');
          }

          int? pages;
          final pagesRaw = item['number_of_pages_median'];
          if (pagesRaw is int) {
            pages = pagesRaw;
          }

          String? isbn;
          final isbnRaw = item['isbn'];
          if (isbnRaw is List && isbnRaw.isNotEmpty) {
            isbn = isbnRaw.first.toString();
          }

          parsedBooks.add(BookModel(
            id: item['key']?.toString(),
            title: title,
            author: authors,
            year: year,
            description: null,
            thumbnailUrl: thumbnailUrl,
            publisher: publisher,
            genre: genre,
            pages: pages,
            isbn: isbn,
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
