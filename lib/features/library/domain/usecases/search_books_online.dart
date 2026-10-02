import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../book_scanner/domain/entities/book.dart';
import '../repositories/library_repository.dart';

class SearchBooksOnline implements UseCase<List<Book>, String> {
  final LibraryRepository repository;

  SearchBooksOnline(this.repository);

  @override
  Future<Either<Failure, List<Book>>> call(String query) async {
    return repository.searchBooksOnline(query);
  }
}
