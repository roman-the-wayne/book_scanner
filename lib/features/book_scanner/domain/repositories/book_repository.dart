import 'dart:io';
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/book.dart';

abstract class BookRepository {
  /// Распознать книги на фото
  Future<Either<Failure, List<Book>>> scanBooks(File image);
}
