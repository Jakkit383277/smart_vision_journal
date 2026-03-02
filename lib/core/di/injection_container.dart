import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:hive/hive.dart';
import '../../features/journal/data/datasources/cache_data_source.dart';
import '../../features/journal/data/datasources/local_data_source.dart';
import '../../features/journal/data/datasources/remote_data_source.dart';
import '../../features/journal/data/repositories/note_repository_impl.dart';
import '../../features/journal/domain/repositories/note_repository.dart';
import '../../features/journal/domain/usecases/add_note.dart';
import '../../features/journal/domain/usecases/delete_note.dart';
import '../../features/journal/domain/usecases/get_all_notes.dart';
import '../../features/journal/domain/usecases/summarize_note.dart';
import '../../features/journal/domain/usecases/update_note.dart';
import '../../features/journal/presentation/bloc/note_bloc.dart';
import '../network/dio_client.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // ==================
  // BLoC (Factory - สร้างใหม่ทุกครั้ง)
  // ==================
  sl.registerFactory(
    () => NoteBloc(
      getAllNotes: sl(),
      addNote: sl(),
      updateNote: sl(),
      deleteNote: sl(),
      summarizeNote: sl(),
    ),
  );

  // ==================
  // Use Cases
  // ==================
  sl.registerLazySingleton(() => GetAllNotes(sl()));
  sl.registerLazySingleton(() => AddNote(sl()));
  sl.registerLazySingleton(() => UpdateNote(sl()));
  sl.registerLazySingleton(() => DeleteNote(sl()));
  sl.registerLazySingleton(() => SummarizeNote(sl()));

  // ==================
  // Repository
  // ==================
  sl.registerLazySingleton<NoteRepository>(
    () => NoteRepositoryImpl(
      localDataSource: sl(),
      cacheDataSource: sl(),
      remoteDataSource: sl(),
    ),
  );

  // ==================
  // Data Sources
  // ==================
  sl.registerLazySingleton<NoteLocalDataSource>(
    () => NoteLocalDataSourceImpl(),
  );

  sl.registerLazySingleton<NoteCacheDataSource>(
    () => NoteCacheDataSourceImpl(Hive.box('notes_cache')),
  );

  sl.registerLazySingleton<NoteRemoteDataSource>(
    () => NoteRemoteDataSourceImpl(sl()),
  );

  // ==================
  // External (Singleton)
  // ==================
  sl.registerLazySingleton<Dio>(() => DioClient.getInstance());
}