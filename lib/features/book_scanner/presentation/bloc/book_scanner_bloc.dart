import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/scan_books.dart';
import 'book_scanner_event.dart';
import 'book_scanner_state.dart';

class BookScannerBloc extends Bloc<BookScannerEvent, BookScannerState> {
  final ScanBooks scanBooks;

  BookScannerBloc({required this.scanBooks}) : super(BookScannerInitial()) {
    on<ScanRequested>(_onScanRequested);
  }

  Future<void> _onScanRequested(
    ScanRequested event,
    Emitter<BookScannerState> emit,
  ) async {
    emit(BookScannerLoading());
    final result = await scanBooks(event.image);
    result.fold(
      (failure) => emit(BookScannerError(failure.message)),
      (books) => emit(BookScannerLoaded(books)),
    );
  }
}
