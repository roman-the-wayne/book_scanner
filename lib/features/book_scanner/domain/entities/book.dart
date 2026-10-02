import 'package:equatable/equatable.dart';

class Book extends Equatable {
  final String? id;
  final String? title;
  final String? author;
  final int? year;
  final String? description;
  final String? thumbnailUrl;
  final bool isRead;
  final bool isLent;
  final String? borrowerName;
  final int? rating;

  const Book({
    this.id,
    required this.title,
    required this.author,
    this.year,
    this.description,
    this.thumbnailUrl,
    this.isRead = false,
    this.isLent = false,
    this.borrowerName,
    this.rating,
  });

  Book copyWith({
    String? id,
    String? title,
    String? author,
    int? year,
    String? description,
    String? thumbnailUrl,
    bool? isRead,
    bool? isLent,
    String? borrowerName,
    int? rating,
  }) {
    return Book(
      id: id ?? this.id,
      title: title ?? this.title,
      author: author ?? this.author,
      year: year ?? this.year,
      description: description ?? this.description,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      isRead: isRead ?? this.isRead,
      isLent: isLent ?? this.isLent,
      borrowerName: borrowerName ?? this.borrowerName,
      rating: rating ?? this.rating,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        author,
        year,
        description,
        thumbnailUrl,
        isRead,
        isLent,
        borrowerName,
        rating,
      ];
}
