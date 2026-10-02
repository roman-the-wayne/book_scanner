import 'package:equatable/equatable.dart';

abstract class OnlineSearchEvent extends Equatable {
  const OnlineSearchEvent();

  @override
  List<Object?> get props => [];
}

class SearchBooksQueryEvent extends OnlineSearchEvent {
  final String query;

  const SearchBooksQueryEvent(this.query);

  @override
  List<Object?> get props => [query];
}

class ClearSearchEvent extends OnlineSearchEvent {}
