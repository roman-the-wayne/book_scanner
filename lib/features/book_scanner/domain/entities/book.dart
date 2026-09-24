import 'package:equatable/equatable.dart';

class Book extends Equatable {
  final String? title;
  final String? author;
  final int? year;

  const Book({required this.title, required this.author, this.year});

  @override
  List<Object?> get props => [title, author, year];
}
