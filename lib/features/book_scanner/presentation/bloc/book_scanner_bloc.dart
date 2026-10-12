import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../library/domain/usecases/enrich_book.dart';
import '../../domain/entities/book.dart';
import '../../domain/usecases/scan_books.dart';
import 'book_scanner_event.dart';
import 'book_scanner_state.dart';

class BookScannerBloc extends Bloc<BookScannerEvent, BookScannerState> {
  final ScanBooks scanBooks;
  final EnrichBook enrichBook;

  BookScannerBloc({
    required this.scanBooks,
    required this.enrichBook,
  }) : super(BookScannerInitial()) {
    on<ScanRequested>(_onScanRequested);
  }

  Future<void> _onScanRequested(
    ScanRequested event,
    Emitter<BookScannerState> emit,
  ) async {
    emit(const BookScannerLoading());
    final result = await scanBooks(event.image);

    await result.fold(
      (failure) async => emit(BookScannerError(failure.message)),
      (scannedBooks) async {
        if (scannedBooks.isEmpty) {
          emit(const BookScannerLoaded([]));
          return;
        }

        emit(BookScannerLoading(totalBooks: scannedBooks.length, enrichedCount: 0));

        // Ограничиваем параллелизм (по 3 запроса за раз), чтобы не словить Rate Limit, 
        // но при этом не ждать каждую книгу по цепочке.
        const maxConcurrency = 3;
        final List<Book> enrichedBooks = List<Book>.from(scannedBooks);
        int completedCount = 0;

        // Функция для обработки одного куска (worker)
        Future<void> processBook(int index) async {
          final book = scannedBooks[index];
          final enrichResult = await enrichBook(book);
          
          final finalBook = enrichResult.fold(
            (_) => book, // При ошибке оставляем исходную книгу
            (enriched) => enriched,
          );
          
          enrichedBooks[index] = finalBook;
        }

        // Запускаем воркеры батчами по `maxConcurrency`
        for (int i = 0; i < scannedBooks.length; i += maxConcurrency) {
          final end = (i + maxConcurrency < scannedBooks.length) ? i + maxConcurrency : scannedBooks.length;
          final batch = <Future<void>>[];
          
          for (int j = i; j < end; j++) {
            batch.add(processBook(j));
          }
          
          // Ждем завершения текущей пачки
          await Future.wait(batch);
          
          completedCount += batch.length;
          
          // Обновляем UI с прогрессом
          emit(BookScannerLoading(
            totalBooks: scannedBooks.length, 
            enrichedCount: completedCount
          ));
        }

        emit(BookScannerLoaded(enrichedBooks));
      },
    );
  }
}
