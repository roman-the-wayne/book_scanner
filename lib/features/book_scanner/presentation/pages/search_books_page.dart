import 'dart:io';

import 'package:book_scanner/features/book_scanner/domain/entities/book.dart';
import 'package:book_scanner/features/book_scanner/presentation/bloc/book_scanner_bloc.dart';
import 'package:book_scanner/features/book_scanner/presentation/bloc/book_scanner_event.dart';
import 'package:book_scanner/features/book_scanner/presentation/bloc/book_scanner_state.dart';
import 'package:book_scanner/features/library/presentation/bloc/library_bloc.dart';
import 'package:book_scanner/features/library/presentation/bloc/library_event.dart';
import 'package:book_scanner/features/library/presentation/bloc/library_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/di/injection_container.dart';

class SearchBooksPage extends StatelessWidget {
  const SearchBooksPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<BookScannerBloc>(),
      child: const _SearchBooksView(),
    );
  }
}

class _SearchBooksView extends StatelessWidget {
  const _SearchBooksView();

  Future<void> _pickImage(BuildContext context) async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
      maxWidth: 1024,
      maxHeight: 1024,
    );
    if (picked == null) return;
    if (!context.mounted) return;
    context.read<BookScannerBloc>().add(ScanRequested(File(picked.path)));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Поиск книг по фото')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _pickImage(context),
        child: const Icon(Icons.add_a_photo),
      ),
      body: BlocBuilder<BookScannerBloc, BookScannerState>(
        builder: (context, scanState) {
          if (scanState is BookScannerLoading) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Распознаем и обогащаем данные с фото...'),
                ],
              ),
            );
          }
          if (scanState is BookScannerError) {
            final isNetworkError = scanState.message.contains('интернет') ||
                scanState.message.contains('SocketException') ||
                scanState.message.contains('Failed host lookup');

            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      isNetworkError ? Icons.wifi_off : Icons.error_outline,
                      size: 60,
                      color: Colors.orange,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      scanState.message,
                      style: const TextStyle(fontSize: 15),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      onPressed: () => _pickImage(context),
                      icon: const Icon(Icons.photo_library),
                      label: const Text('Выбрать фото заново'),
                    ),
                  ],
                ),
              ),
            );
          }
          if (scanState is BookScannerLoaded) {
            if (scanState.books.isEmpty) {
              return const Center(
                child: Text('Книги не найдены на фото'),
              );
            }
            return BlocBuilder<LibraryBloc, LibraryState>(
              builder: (context, libraryState) {
                final savedBooks = libraryState is LibraryLoaded
                    ? libraryState.books
                    : <Book>[];

                return ListView.separated(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: scanState.books.length,
                  separatorBuilder: (context, index) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final book = scanState.books[index];
                    final isSaved = savedBooks.any(
                      (b) =>
                          b.title != null &&
                          book.title != null &&
                          b.title!.trim().toLowerCase() ==
                              book.title!.trim().toLowerCase() &&
                          b.author?.trim().toLowerCase() ==
                              book.author?.trim().toLowerCase(),
                    );

                    final hasThumbnail = book.thumbnailUrl != null &&
                        book.thumbnailUrl!.isNotEmpty;

                    final subtitleParts = <String>[];
                    if (book.author != null && book.author!.isNotEmpty) {
                      subtitleParts.add(book.author!);
                    }
                    if (book.year != null) {
                      subtitleParts.add('${book.year} г.');
                    }
                    if (book.publisher != null && book.publisher!.isNotEmpty) {
                      subtitleParts.add(book.publisher!);
                    }
                    if (book.genre != null && book.genre!.isNotEmpty) {
                      subtitleParts.add(book.genre!);
                    }

                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: hasThumbnail
                            ? Image.network(
                                book.thumbnailUrl!.replaceFirst('http:', 'https:'),
                                width: 48,
                                height: 72,
                                fit: BoxFit.cover,
                                errorBuilder: (ctx, err, stack) => Container(
                                  width: 48,
                                  height: 72,
                                  color: theme.colorScheme.surfaceContainerHighest,
                                  child: const Icon(Icons.book, size: 28),
                                ),
                              )
                            : Container(
                                width: 48,
                                height: 72,
                                color: theme.colorScheme.surfaceContainerHighest,
                                child: const Icon(Icons.book, size: 28),
                              ),
                      ),
                      title: Text(
                        book.title ?? 'Без названия',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        subtitleParts.isNotEmpty
                            ? subtitleParts.join(' • ')
                            : 'Сведения отсутствуют',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: IconButton(
                        icon: Icon(
                          isSaved ? Icons.bookmark : Icons.bookmark_add_outlined,
                          color: isSaved
                              ? theme.colorScheme.primary
                              : null,
                        ),
                        onPressed: isSaved
                            ? null
                            : () {
                                context.read<LibraryBloc>().add(SaveBookEvent(book));
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Книга добавлена в библиотеку'),
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                              },
                      ),
                    );
                  },
                );
              },
            );
          }

          return const Center(
            child: Text('Выберите фото книги для распознавания'),
          );
        },
      ),
    );
  }
}
