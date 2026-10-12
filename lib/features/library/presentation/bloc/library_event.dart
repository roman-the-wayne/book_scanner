import 'package:equatable/equatable.dart';
import '../../../book_scanner/domain/entities/book.dart';

abstract class LibraryEvent extends Equatable {
  const LibraryEvent();

  @override
  List<Object?> get props => [];
}

class LoadLibrary extends LibraryEvent {}

class SaveBookEvent extends LibraryEvent {
  final Book book;

  const SaveBookEvent(this.book);

  @override
  List<Object?> get props => [book];
}

class UpdateBookEvent extends LibraryEvent {
  final Book book;

  const UpdateBookEvent(this.book);

  @override
  List<Object?> get props => [book];
}

class DeleteBookEvent extends LibraryEvent {
  final String id;

  const DeleteBookEvent(this.id);

  @override
  List<Object?> get props => [id];
}

class EnrichBookEvent extends LibraryEvent {
  final Book book;

  const EnrichBookEvent(this.book);

  @override
  List<Object?> get props => [book];
}
