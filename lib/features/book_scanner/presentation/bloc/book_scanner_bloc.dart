import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../library/domain/usecases/enrich_book.dart';
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
    emit(BookScannerLoading());
    final result = await scanBooks(event.image);

    await result.fold(
      (failure) async => emit(BookScannerError(failure.message)),
      (scannedBooks) async {
        // Автоматически обогащаем каждую найденную нейросетью книгу через внешние API
        final enrichedBooks = await Future.wait(
          scannedBooks.map((book) async {
            final enrichResult = await enrichBook(book);
            return enrichResult.fold(
              (_) => book, // При ошибке оставляем исходную книгу
              (enriched) => enriched,
            );
          }),
        );
        emit(BookScannerLoaded(enrichedBooks));
      },
    );
  }
}
