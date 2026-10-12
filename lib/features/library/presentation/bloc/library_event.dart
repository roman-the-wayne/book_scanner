import 'package:equatable/equatable.dart';
import '../../../book_scanner/domain/entities/book.dart';
import 'library_state.dart';

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

class SearchQueryChanged extends LibraryEvent {
  final String query;

  const SearchQueryChanged(this.query);

  @override
  List<Object?> get props => [query];
}

class FilterOptionChanged extends LibraryEvent {
  final FilterOption filterOption;

  const FilterOptionChanged(this.filterOption);

  @override
  List<Object?> get props => [filterOption];
}

class SortOptionChanged extends LibraryEvent {
  final SortOption sortOption;

  const SortOptionChanged(this.sortOption);

  @override
  List<Object?> get props => [sortOption];
}
