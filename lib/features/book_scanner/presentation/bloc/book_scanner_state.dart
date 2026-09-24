import 'package:equatable/equatable.dart';
import '../../domain/entities/book.dart';

abstract class BookScannerState extends Equatable {
  const BookScannerState();
  @override
  List<Object?> get props => [];
}

class BookScannerInitial extends BookScannerState {}

class BookScannerLoading extends BookScannerState {}

class BookScannerLoaded extends BookScannerState {
  final List<Book> books;
  const BookScannerLoaded(this.books);
  @override
  List<Object?> get props => [books];
}

class BookScannerError extends BookScannerState {
  final String message;
  const BookScannerError(this.message);
  @override
  List<Object?> get props => [message];
}
