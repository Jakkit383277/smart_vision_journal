// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

part of 'app_router.dart';

/// generated route for
/// [AddNotePage]
class AddNoteRoute extends PageRouteInfo<void> {
  const AddNoteRoute({List<PageRouteInfo>? children})
      : super(AddNoteRoute.name, initialChildren: children);

  static const String name = 'AddNoteRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const AddNotePage();
    },
  );
}

/// generated route for
/// [HomePage]
class HomeRoute extends PageRouteInfo<void> {
  const HomeRoute({List<PageRouteInfo>? children})
      : super(HomeRoute.name, initialChildren: children);

  static const String name = 'HomeRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const HomePage();
    },
  );
}

/// generated route for
/// [NoteDetailPage]
class NoteDetailRoute extends PageRouteInfo<NoteDetailRouteArgs> {
  NoteDetailRoute({Key? key, required Note note, List<PageRouteInfo>? children})
      : super(
          NoteDetailRoute.name,
          args: NoteDetailRouteArgs(key: key, note: note),
          initialChildren: children,
        );

  static const String name = 'NoteDetailRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<NoteDetailRouteArgs>();
      return NoteDetailPage(key: args.key, note: args.note);
    },
  );
}

class NoteDetailRouteArgs {
  const NoteDetailRouteArgs({this.key, required this.note});

  final Key? key;

  final Note note;

  @override
  String toString() {
    return 'NoteDetailRouteArgs{key: $key, note: $note}';
  }
}
