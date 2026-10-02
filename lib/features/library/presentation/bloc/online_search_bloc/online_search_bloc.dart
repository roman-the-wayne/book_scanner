import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/search_books_online.dart';
import 'online_search_event.dart';
import 'online_search_state.dart';

class OnlineSearchBloc extends Bloc<OnlineSearchEvent, OnlineSearchState> {
  final SearchBooksOnline searchBooksOnline;

  OnlineSearchBloc({required this.searchBooksOnline})
      : super(OnlineSearchInitial()) {
    on<SearchBooksQueryEvent>(_onSearchBooks);
    on<ClearSearchEvent>((event, emit) => emit(OnlineSearchInitial()));
  }

  Future<void> _onSearchBooks(
    SearchBooksQueryEvent event,
    Emitter<OnlineSearchState> emit,
  ) async {
    final query = event.query.trim();
    if (query.isEmpty) {
      emit(OnlineSearchInitial());
      return;
    }

    emit(OnlineSearchLoading());
    final result = await searchBooksOnline(query);
    
    result.fold(
      (failure) => emit(OnlineSearchError(failure.message)),
      (books) => emit(OnlineSearchLoaded(books: books)),
    );
  }
}
