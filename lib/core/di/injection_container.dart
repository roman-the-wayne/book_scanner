import 'package:get_it/get_it.dart';
import 'package:mistralai_dart/mistralai_dart.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../../features/book_scanner/data/datasources/mistral_remote_datasource.dart';
import '../../features/book_scanner/data/repositories/book_repository_impl.dart';
import '../../features/book_scanner/domain/repositories/book_repository.dart';
import '../../features/book_scanner/domain/usecases/scan_books.dart';
import '../../features/book_scanner/presentation/bloc/book_scanner_bloc.dart';

final sl = GetIt.instance; // sl = service locator

Future<void> init() async {
  // ─── External / API client ──────────────────
  sl.registerLazySingleton<MistralClient>(
    () => MistralClient.withApiKey(dotenv.env['MISTRAL_API_KEY']!),
  );

  // ─── Data sources ───────────────────────────
  sl.registerLazySingleton<BookRemoteDataSource>(
    () => MistralRemoteDataSource(client: sl()),
  );

  // ─── Repositories ───────────────────────────
  sl.registerLazySingleton<BookRepository>(() => BookRepositoryImpl(sl()));

  // ─── Use cases ──────────────────────────────
  sl.registerLazySingleton(() => ScanBooks(sl()));

  // ─── BLoC ───────────────────────────────────
  sl.registerFactory(() => BookScannerBloc(scanBooks: sl()));
}
