import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/book.dart';

part 'book_model.freezed.dart';
part 'book_model.g.dart';

@freezed
sealed class BookModel with _$BookModel {
  const BookModel._();

  const factory BookModel({
    String? id,
    String? title,
    String? author,
    int? year,
    String? description,
    String? thumbnailUrl,
    @Default(false) bool isRead,
    @Default(false) bool isLent,
    String? borrowerName,
    int? rating,
    String? genre,
    String? publisher,
    String? city,
    int? pages,
    String? isbn,
    String? udc,
    String? bbk,
    @Default(false) bool isWishlist,
  }) = _BookModel;

  factory BookModel.fromJson(Map<String, dynamic> json) =>
      _$BookModelFromJson(json);

  Book toEntity() {
    return Book(
      id: id,
      title: title,
      author: author,
      year: year,
      description: description,
      thumbnailUrl: thumbnailUrl,
      isRead: isRead,
      isLent: isLent,
      borrowerName: borrowerName,
      rating: rating,
      genre: genre,
      publisher: publisher,
      city: city,
      pages: pages,
      isbn: isbn,
      udc: udc,
      bbk: bbk,
      isWishlist: isWishlist,
    );
  }

  factory BookModel.fromEntity(Book book) {
    return BookModel(
      id: book.id,
      title: book.title,
      author: book.author,
      year: book.year,
      description: book.description,
      thumbnailUrl: book.thumbnailUrl,
      isRead: book.isRead,
      isLent: book.isLent,
      borrowerName: book.borrowerName,
      rating: book.rating,
      genre: book.genre,
      publisher: book.publisher,
      city: book.city,
      pages: book.pages,
      isbn: book.isbn,
      udc: book.udc,
      bbk: book.bbk,
      isWishlist: book.isWishlist,
    );
  }
}
