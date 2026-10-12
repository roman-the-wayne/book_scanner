import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../book_scanner/domain/entities/book.dart';
import '../repositories/library_repository.dart';

class SaveBook implements UseCase<void, Book> {
  final LibraryRepository repository;

  SaveBook(this.repository);

  @override
  Future<Either<Failure, void>> call(Book book) async {
    // Генерация бизнес-идентификатора происходит в Domain слое,
    // если книга создана локально и еще не имеет ID.
    final bookToSave = (book.id == null || book.id!.isEmpty)
        ? book.copyWith(id: DateTime.now().millisecondsSinceEpoch.toString())
        : book;

    return repository.saveBook(bookToSave);
  }
}
