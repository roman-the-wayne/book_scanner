import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/usecases/delete_book.dart';
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

  LibraryBloc({
    required this.getBooks,
    required this.saveBook,
    required this.updateBook,
    required this.deleteBook,
  }) : super(LibraryInitial()) {
    on<LoadLibrary>(_onLoadLibrary);
    on<SaveBookEvent>(_onSaveBook);
    on<UpdateBookEvent>(_onUpdateBook);
    on<DeleteBookEvent>(_onDeleteBook);
  }

  Future<void> _onLoadLibrary(
    LoadLibrary event,
    Emitter<LibraryState> emit,
  ) async {
    emit(LibraryLoading());
    final result = await getBooks(const NoParams());
    result.fold(
      (failure) => emit(LibraryError(failure.message)),
      (books) {
        if (books.isEmpty) {
          emit(LibraryEmpty());
        } else {
          emit(LibraryLoaded(books: books));
        }
      },
    );
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
    final result = await updateBook(event.book);
    result.fold(
      (failure) => emit(LibraryError(failure.message)),
      (_) => add(LoadLibrary()),
    );
  }

  Future<void> _onDeleteBook(
    DeleteBookEvent event,
    Emitter<LibraryState> emit,
  ) async {
    final result = await deleteBook(event.id);
    result.fold(
      (failure) => emit(LibraryError(failure.message)),
      (_) => add(LoadLibrary()),
    );
  }
}
