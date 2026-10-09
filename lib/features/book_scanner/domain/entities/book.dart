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
  final String? genre;
  final String? publisher;
  final String? city;
  final int? pages;
  final String? isbn;
  final String? udc;
  final String? bbk;
  final bool isWishlist;

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
    this.genre,
    this.publisher,
    this.city,
    this.pages,
    this.isbn,
    this.udc,
    this.bbk,
    this.isWishlist = false,
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
    String? genre,
    String? publisher,
    String? city,
    int? pages,
    String? isbn,
    String? udc,
    String? bbk,
    bool? isWishlist,
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
      genre: genre ?? this.genre,
      publisher: publisher ?? this.publisher,
      city: city ?? this.city,
      pages: pages ?? this.pages,
      isbn: isbn ?? this.isbn,
      udc: udc ?? this.udc,
      bbk: bbk ?? this.bbk,
      isWishlist: isWishlist ?? this.isWishlist,
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
        genre,
        publisher,
        city,
        pages,
        isbn,
        udc,
        bbk,
        isWishlist,
      ];
}
