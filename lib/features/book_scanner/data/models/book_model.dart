import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/book.dart';

part 'book_model.freezed.dart';
part 'book_model.g.dart';

@freezed
sealed class BookModel with _$BookModel {
  const BookModel._(); // нужно, чтобы добавить свой метод toEntity()

  const factory BookModel({String? title, String? author, int? year}) =
      _BookModel;

  // Генерируется json_serializable
  factory BookModel.fromJson(Map<String, dynamic> json) =>
      _$BookModelFromJson(json);

  // Превращаем модель данных в доменную сущность
  Book toEntity() {
    return Book(title: title, author: author, year: year);
  }
}
