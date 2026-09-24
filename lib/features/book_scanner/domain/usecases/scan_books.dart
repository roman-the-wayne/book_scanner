import 'dart:io';
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/book.dart';
import '../repositories/book_repository.dart';

class ScanBooks implements UseCase<List<Book>, File> {
  final BookRepository repository;
  ScanBooks(this.repository);

  @override
  Future<Either<Failure, List<Book>>> call(File params) async {
    return repository.scanBooks(params);
  }
}
