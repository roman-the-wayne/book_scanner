import 'package:equatable/equatable.dart';
import '../../../../book_scanner/domain/entities/book.dart';

abstract class OnlineSearchState extends Equatable {
  const OnlineSearchState();

  @override
  List<Object?> get props => [];
}

class OnlineSearchInitial extends OnlineSearchState {}

class OnlineSearchLoading extends OnlineSearchState {}

class OnlineSearchLoaded extends OnlineSearchState {
  final List<Book> books;

  const OnlineSearchLoaded({required this.books});

  @override
  List<Object?> get props => [books];
}

class OnlineSearchError extends OnlineSearchState {
  final String message;

  const OnlineSearchError(this.message);

  @override
  List<Object?> get props => [message];
}
