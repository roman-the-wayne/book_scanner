import 'package:equatable/equatable.dart';

class Book extends Equatable {
  final String? id;
  final String? title;
  final String? author;
  final int? year;
  final String? description;
  final String? thumbnailUrl;

  const Book({
    this.id,
    required this.title,
    required this.author,
    this.year,
    this.description,
    this.thumbnailUrl,
  });

  Book copyWith({
    String? id,
    String? title,
    String? author,
    int? year,
    String? description,
    String? thumbnailUrl,
  }) {
    return Book(
      id: id ?? this.id,
      title: title ?? this.title,
      author: author ?? this.author,
      year: year ?? this.year,
      description: description ?? this.description,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
    );
  }

  @override
  List<Object?> get props => [id, title, author, year, description, thumbnailUrl];
}
