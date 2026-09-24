import 'dart:io';
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/book.dart';
import '../../domain/repositories/book_repository.dart';
import '../datasources/mistral_remote_datasource.dart';

class BookRepositoryImpl implements BookRepository {
  final BookRemoteDataSource remoteDataSource; // ← абстракция, не Mistral...

  BookRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, List<Book>>> scanBooks(File image) async {
    try {
      final result = await remoteDataSource.scanBooks(image);
      return Right(result.map((m) => m.toEntity()).toList());
    } on ServerFailure catch (e) {
      // ← Exception, не Failure
      return Left(ServerFailure(e.message)); // конвертируем в Failure
    } catch (e) {
      return Left(ServerFailure('Неизвестная ошибка: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> saveBook(Book book) async {
    throw UnimplementedError();
    // TODO(реализуем, когда подключим Supabase)
  }

  @override
  Future<Either<Failure, List<Book>>> getBooks() async {
    throw UnimplementedError(); // TODO
  }
}
