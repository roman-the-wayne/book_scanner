import 'package:equatable/equatable.dart';
import '../../../book_scanner/domain/entities/book.dart';

enum FilterOption { all, read, unread, lent }
enum SortOption { dateAdded, title, author, rating }

abstract class LibraryState extends Equatable {
  const LibraryState();

  @override
  List<Object?> get props => [];
}

class LibraryInitial extends LibraryState {}

class LibraryLoading extends LibraryState {}

class LibraryLoaded extends LibraryState {
  final List<Book> allBooks;
  final List<Book> displayedBooks;
  final String searchQuery;
  final FilterOption filterOption;
  final SortOption sortOption;

  const LibraryLoaded({
    required this.allBooks,
    required this.displayedBooks,
    this.searchQuery = '',
    this.filterOption = FilterOption.all,
    this.sortOption = SortOption.dateAdded,
  });

  LibraryLoaded copyWith({
    List<Book>? allBooks,
    List<Book>? displayedBooks,
    String? searchQuery,
    FilterOption? filterOption,
    SortOption? sortOption,
  }) {
    return LibraryLoaded(
      allBooks: allBooks ?? this.allBooks,
      displayedBooks: displayedBooks ?? this.displayedBooks,
      searchQuery: searchQuery ?? this.searchQuery,
      filterOption: filterOption ?? this.filterOption,
      sortOption: sortOption ?? this.sortOption,
    );
  }

  // Для обратной совместимости с местами, где ожидался список `books`
  List<Book> get books => allBooks;

  @override
  List<Object?> get props => [
        allBooks,
        displayedBooks,
        searchQuery,
        filterOption,
        sortOption,
      ];
}

class LibraryEmpty extends LibraryState {}

class LibraryError extends LibraryState {
  final String message;

  const LibraryError(this.message);

  @override
  List<Object?> get props => [message];
}
