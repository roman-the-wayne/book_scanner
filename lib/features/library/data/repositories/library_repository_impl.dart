import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../book_scanner/data/models/book_model.dart';
import '../../../book_scanner/domain/entities/book.dart';
import '../../domain/repositories/library_repository.dart';
import '../datasources/library_local_datasource.dart';
import '../datasources/books_remote_datasource.dart';

class LibraryRepositoryImpl implements LibraryRepository {
  final LibraryLocalDataSource localDataSource;
  final BooksRemoteDataSource remoteDataSource;

  LibraryRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
  });

  @override
  Future<Either<Failure, List<Book>>> getBooks() async {
    try {
      final bookModels = await localDataSource.getBooks();
      final books = bookModels.map((model) => model.toEntity()).toList();
      return Right(books);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> saveBook(Book book) async {
    try {
      final model = BookModel.fromEntity(book);
      await localDataSource.saveBook(model);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateBook(Book book) async {
    try {
      final model = BookModel.fromEntity(book);
      await localDataSource.updateBook(model);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteBook(String id) async {
    try {
      await localDataSource.deleteBook(id);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Book>>> searchBooksOnline(String query) async {
    try {
      final bookModels = await remoteDataSource.searchBooks(query);
      final books = bookModels.map((model) => model.toEntity()).toList();
      return Right(books);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
