import 'package:get_it/get_it.dart';
import 'package:mistralai_dart/mistralai_dart.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../../features/book_scanner/data/datasources/mistral_remote_datasource.dart';
import '../../features/book_scanner/data/repositories/book_repository_impl.dart';
import '../../features/book_scanner/domain/repositories/book_repository.dart';
import '../../features/book_scanner/domain/usecases/scan_books.dart';
import '../../features/book_scanner/presentation/bloc/book_scanner_bloc.dart';

import '../../features/library/data/datasources/books_remote_datasource.dart';
import '../../features/library/data/datasources/library_local_datasource.dart';
import '../../features/library/data/repositories/library_repository_impl.dart';
import '../../features/library/domain/repositories/library_repository.dart';
import '../../features/library/domain/usecases/get_books.dart';
import '../../features/library/domain/usecases/save_book.dart';
import '../../features/library/domain/usecases/search_books_online.dart';
import '../../features/library/domain/usecases/update_book.dart';
import '../../features/library/domain/usecases/delete_book.dart';
import '../../features/library/presentation/bloc/library_bloc.dart';
import '../../features/library/presentation/bloc/online_search_bloc/online_search_bloc.dart';

final sl = GetIt.instance; // sl = service locator

Future<void> init() async {
  // ─── External / API client & Local Storage ───
  sl.registerLazySingleton<MistralClient>(
    () => MistralClient.withApiKey(dotenv.env['MISTRAL_API_KEY']!),
  );

  sl.registerLazySingleton(() => http.Client());

  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);

  // ─── Data sources ───────────────────────────
  sl.registerLazySingleton<BookRemoteDataSource>(
    () => MistralRemoteDataSource(client: sl()),
  );
  sl.registerLazySingleton<LibraryLocalDataSource>(
    () => LibraryLocalDataSourceImpl(sharedPreferences: sl()),
  );
  sl.registerLazySingleton<BooksRemoteDataSource>(
    () => BooksRemoteDataSourceImpl(client: sl()),
  );

  // ─── Repositories ───────────────────────────
  sl.registerLazySingleton<BookRepository>(() => BookRepositoryImpl(sl()));
  sl.registerLazySingleton<LibraryRepository>(
    () => LibraryRepositoryImpl(
      localDataSource: sl(),
      remoteDataSource: sl(),
    ),
  );

  // ─── Use cases ──────────────────────────────
  sl.registerLazySingleton(() => ScanBooks(sl()));
  sl.registerLazySingleton(() => GetBooks(sl()));
  sl.registerLazySingleton(() => SaveBook(sl()));
  sl.registerLazySingleton(() => UpdateBook(sl()));
  sl.registerLazySingleton(() => DeleteBook(sl()));
  sl.registerLazySingleton(() => SearchBooksOnline(sl()));

  // ─── BLoC ───────────────────────────────────
  sl.registerFactory(() => BookScannerBloc(scanBooks: sl()));
  sl.registerFactory(
    () => LibraryBloc(
      getBooks: sl(),
      saveBook: sl(),
      updateBook: sl(),
      deleteBook: sl(),
    ),
  );
  sl.registerFactory(() => OnlineSearchBloc(searchBooksOnline: sl()));
}
