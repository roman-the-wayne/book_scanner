import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../book_scanner/domain/entities/book.dart';

abstract class LibraryRepository {
  Future<Either<Failure, List<Book>>> getBooks();
  Future<Either<Failure, void>> saveBook(Book book);
  Future<Either<Failure, void>> updateBook(Book book);
  Future<Either<Failure, void>> deleteBook(String id);
  Future<Either<Failure, List<Book>>> searchBooksOnline(String query);
  Future<Either<Failure, Book>> enrichBook(Book book);
}
