import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import '../../features/journal/domain/entities/note.dart';
import '../../features/journal/presentation/pages/home_page.dart';
import '../../features/journal/presentation/pages/add_note_page.dart';
import '../../features/journal/presentation/pages/note_detail_page.dart';

part 'app_router.gr.dart';

@AutoRouterConfig()
class AppRouter extends RootStackRouter {
  @override
  List<AutoRoute> get routes => [
        AutoRoute(page: HomeRoute.page, initial: true),
        AutoRoute(page: AddNoteRoute.page),
        AutoRoute(page: NoteDetailRoute.page),
      ];
}