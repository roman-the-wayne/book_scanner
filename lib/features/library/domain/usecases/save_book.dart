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
    return repository.saveBook(book);
  }
}
