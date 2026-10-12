import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../book_scanner/domain/entities/book.dart';
import '../repositories/library_repository.dart';

class EnrichBook implements UseCase<Book, Book> {
  final LibraryRepository repository;

  EnrichBook(this.repository);

  @override
  Future<Either<Failure, Book>> call(Book book) async {
    return await repository.enrichBook(book);
  }
}
