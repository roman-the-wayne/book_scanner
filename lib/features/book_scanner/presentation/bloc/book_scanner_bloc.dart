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

        final List<Book> enrichedBooks = [];
        
        // Обогащаем книги последовательно, а не через Future.wait, 
        // чтобы избежать Rate Limit от внешних API и таймаутов.
        for (int i = 0; i < scannedBooks.length; i++) {
          final book = scannedBooks[i];
          final enrichResult = await enrichBook(book);
          
          final finalBook = enrichResult.fold(
            (_) => book, // При ошибке оставляем исходную книгу (без обогащения)
            (enriched) => enriched,
          );
          
          enrichedBooks.add(finalBook);
          
          // Обновляем прогресс обогащения
          emit(BookScannerLoading(
            totalBooks: scannedBooks.length, 
            enrichedCount: i + 1
          ));
          
          // Небольшая задержка между запросами для лояльности к публичным API (Google Books / OpenLibrary)
          if (i < scannedBooks.length - 1) {
            await Future.delayed(const Duration(milliseconds: 300));
          }
        }

        emit(BookScannerLoaded(enrichedBooks));
      },
    );
  }
}
