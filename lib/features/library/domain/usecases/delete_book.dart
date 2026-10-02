import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/library_repository.dart';

class DeleteBook implements UseCase<void, String> {
  final LibraryRepository repository;

  DeleteBook(this.repository);

  @override
  Future<Either<Failure, void>> call(String id) async {
    return repository.deleteBook(id);
  }
}
