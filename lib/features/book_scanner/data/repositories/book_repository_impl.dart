import 'dart:io';
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/book.dart';
import '../../domain/repositories/book_repository.dart';
import '../datasources/mistral_remote_datasource.dart';

class BookRepositoryImpl implements BookRepository {
  final BookRemoteDataSource remoteDataSource;

  BookRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, List<Book>>> scanBooks(File image) async {
    try {
      final result = await remoteDataSource.scanBooks(image);
      return Right(result.map((m) => m.toEntity()).toList());
    } on NetworkFailure catch (e) {
      return Left(NetworkFailure(e.message));
    } on ServerFailure catch (e) {
      return Left(ServerFailure(e.message));
    } on SocketException {
      return const Left(
          NetworkFailure('Отсутствует подключение к интернету. Проверьте соединение.'));
    } catch (e) {
      if (e.toString().contains('SocketException') ||
          e.toString().contains('Failed host lookup')) {
        return const Left(NetworkFailure(
            'Отсутствует подключение к интернету. Проверьте соединение.'));
      }
      return Left(ServerFailure('Неизвестная ошибка: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> saveBook(Book book) async {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, List<Book>>> getBooks() async {
    throw UnimplementedError();
  }
}
