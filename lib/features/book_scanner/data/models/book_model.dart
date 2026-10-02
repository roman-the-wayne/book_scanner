import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/book.dart';

part 'book_model.freezed.dart';
part 'book_model.g.dart';

@freezed
sealed class BookModel with _$BookModel {
  const BookModel._(); // нужно, чтобы добавить свой метод toEntity()

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
  }) = _BookModel;

  // Генерируется json_serializable
  factory BookModel.fromJson(Map<String, dynamic> json) =>
      _$BookModelFromJson(json);

  // Превращаем модель данных в доменную сущность
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
    );
  }
}
