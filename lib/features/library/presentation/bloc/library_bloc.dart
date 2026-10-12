import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../book_scanner/domain/entities/book.dart';
import '../../domain/usecases/delete_book.dart';
import '../../domain/usecases/enrich_book.dart';
import '../../domain/usecases/get_books.dart';
import '../../domain/usecases/save_book.dart';
import '../../domain/usecases/update_book.dart';
import 'library_event.dart';
import 'library_state.dart';

class LibraryBloc extends Bloc<LibraryEvent, LibraryState> {
  final GetBooks getBooks;
  final SaveBook saveBook;
  final UpdateBook updateBook;
  final DeleteBook deleteBook;
  final EnrichBook enrichBook;

  LibraryBloc({
    required this.getBooks,
    required this.saveBook,
    required this.updateBook,
    required this.deleteBook,
    required this.enrichBook,
  }) : super(LibraryInitial()) {
    on<LoadLibrary>(_onLoadLibrary);
    on<SaveBookEvent>(_onSaveBook);
    on<UpdateBookEvent>(_onUpdateBook);
    on<DeleteBookEvent>(_onDeleteBook);
    on<EnrichBookEvent>(_onEnrichBook);
    on<SearchQueryChanged>(_onSearchQueryChanged);
    on<FilterOptionChanged>(_onFilterOptionChanged);
    on<SortOptionChanged>(_onSortOptionChanged);
  }

  List<Book> _applyFiltersAndSort(
    List<Book> books,
    String query,
    FilterOption filter,
    SortOption sort,
  ) {
    var filtered = books.where((book) {
      if (query.isEmpty) return true;
      final title = book.title?.toLowerCase() ?? '';
      final author = book.author?.toLowerCase() ?? '';
      final lowerQuery = query.toLowerCase();
      return title.contains(lowerQuery) || author.contains(lowerQuery);
    }).toList();

    switch (filter) {
      case FilterOption.read:
        filtered = filtered.where((b) => b.isRead).toList();
        break;
      case FilterOption.unread:
        filtered = filtered.where((b) => !b.isRead).toList();
        break;
      case FilterOption.lent:
        filtered = filtered.where((b) => b.isLent).toList();
        break;
      case FilterOption.all:
        break;
    }

    filtered.sort((a, b) {
      switch (sort) {
        case SortOption.title:
          return (a.title ?? '').compareTo(b.title ?? '');
        case SortOption.author:
          return (a.author ?? '').compareTo(b.author ?? '');
        case SortOption.rating:
          return (b.rating ?? 0).compareTo(a.rating ?? 0);
        case SortOption.dateAdded:
          return 0; // Сохраняется исходный порядок из базы
      }
    });

    return filtered;
  }

  Future<void> _onLoadLibrary(
    LoadLibrary event,
    Emitter<LibraryState> emit,
  ) async {
    // Если у нас уже есть стейт, сохраняем текущие параметры фильтрации
    final currentState = state is LibraryLoaded ? state as LibraryLoaded : null;
    emit(LibraryLoading());
    
    final result = await getBooks(const NoParams());
    result.fold(
      (failure) => emit(LibraryError(failure.message)),
      (books) {
        if (books.isEmpty) {
          emit(LibraryEmpty());
        } else {
          final query = currentState?.searchQuery ?? '';
          final filter = currentState?.filterOption ?? FilterOption.all;
          final sort = currentState?.sortOption ?? SortOption.dateAdded;
          
          emit(LibraryLoaded(
            allBooks: books,
            displayedBooks: _applyFiltersAndSort(books, query, filter, sort),
            searchQuery: query,
            filterOption: filter,
            sortOption: sort,
          ));
        }
      },
    );
  }

  Future<void> _onSearchQueryChanged(
    SearchQueryChanged event,
    Emitter<LibraryState> emit,
  ) async {
    if (state is LibraryLoaded) {
      final currentState = state as LibraryLoaded;
      final displayed = _applyFiltersAndSort(
        currentState.allBooks,
        event.query,
        currentState.filterOption,
        currentState.sortOption,
      );
      emit(currentState.copyWith(
        searchQuery: event.query,
        displayedBooks: displayed,
      ));
    }
  }

  Future<void> _onFilterOptionChanged(
    FilterOptionChanged event,
    Emitter<LibraryState> emit,
  ) async {
    if (state is LibraryLoaded) {
      final currentState = state as LibraryLoaded;
      final displayed = _applyFiltersAndSort(
        currentState.allBooks,
        currentState.searchQuery,
        event.filterOption,
        currentState.sortOption,
      );
      emit(currentState.copyWith(
        filterOption: event.filterOption,
        displayedBooks: displayed,
      ));
    }
  }

  Future<void> _onSortOptionChanged(
    SortOptionChanged event,
    Emitter<LibraryState> emit,
  ) async {
    if (state is LibraryLoaded) {
      final currentState = state as LibraryLoaded;
      final displayed = _applyFiltersAndSort(
        currentState.allBooks,
        currentState.searchQuery,
        currentState.filterOption,
        event.sortOption,
      );
      emit(currentState.copyWith(
        sortOption: event.sortOption,
        displayedBooks: displayed,
      ));
    }
  }

  Future<void> _onSaveBook(
    SaveBookEvent event,
    Emitter<LibraryState> emit,
  ) async {
    final result = await saveBook(event.book);
    result.fold(
      (failure) => emit(LibraryError(failure.message)),
      (_) => add(LoadLibrary()),
    );
  }

  Future<void> _onUpdateBook(
    UpdateBookEvent event,
    Emitter<LibraryState> emit,
  ) async {
    if (state is LibraryLoaded) {
      final currentState = state as LibraryLoaded;
      // Оптимистичное обновление
      final newAllBooks = currentState.allBooks.map((b) => b.id == event.book.id ? event.book : b).toList();
      final newDisplayed = _applyFiltersAndSort(
        newAllBooks,
        currentState.searchQuery,
        currentState.filterOption,
        currentState.sortOption,
      );
      emit(currentState.copyWith(allBooks: newAllBooks, displayedBooks: newDisplayed));
    }

    final result = await updateBook(event.book);
    result.fold(
      (failure) {
        emit(LibraryError(failure.message));
        add(LoadLibrary()); // Откат
      },
      (_) => null,
    );
  }

  Future<void> _onDeleteBook(
    DeleteBookEvent event,
    Emitter<LibraryState> emit,
  ) async {
    if (state is LibraryLoaded) {
      final currentState = state as LibraryLoaded;
      // Оптимистичное удаление
      final newAllBooks = currentState.allBooks.where((b) => b.id != event.id).toList();
      
      if (newAllBooks.isEmpty) {
        emit(LibraryEmpty());
      } else {
        final newDisplayed = _applyFiltersAndSort(
          newAllBooks,
          currentState.searchQuery,
          currentState.filterOption,
          currentState.sortOption,
        );
        emit(currentState.copyWith(allBooks: newAllBooks, displayedBooks: newDisplayed));
      }
    }

    final result = await deleteBook(event.id);
    result.fold(
      (failure) {
        emit(LibraryError(failure.message));
        add(LoadLibrary()); // Откат
      },
      (_) => null, // Всё прошло успешно, UI уже обновлен
    );
  }

  Future<void> _onEnrichBook(
    EnrichBookEvent event,
    Emitter<LibraryState> emit,
  ) async {
    final enrichResult = await enrichBook(event.book);
    await enrichResult.fold(
      (failure) async => emit(LibraryError(failure.message)),
      (enrichedBook) async {
        final updateResult = await updateBook(enrichedBook);
        updateResult.fold(
          (failure) => emit(LibraryError(failure.message)),
          (_) => add(LoadLibrary()),
        );
      },
    );
  }
}
