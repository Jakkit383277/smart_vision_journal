import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../app/router/app_router.dart';
import '../../../../core/services/theme_service.dart';
import '../../domain/entities/note.dart';
import '../bloc/note_bloc.dart';
import '../bloc/note_event.dart';
import '../bloc/note_state.dart';
import '../widgets/note_card.dart';

@RoutePage()
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const _HomeView();
  }
}

class _HomeView extends StatelessWidget {
  const _HomeView();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final themeService = ThemeServiceProvider.of(context);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Sliver AppBar สวยๆ
          SliverAppBar(
            expandedHeight: 120,
            floating: false,
            pinned: true,
            backgroundColor: theme.colorScheme.primary,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding:
                  const EdgeInsets.only(left: 16, bottom: 16),
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.menu_book_rounded,
                        color: Colors.white, size: 18),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Smart Vision Journal',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDark
                        ? [
                            const Color(0xFF0D2137),
                            const Color(0xFF1565C0)
                          ]
                        : [
                            const Color(0xFF1565C0),
                            const Color(0xFF42A5F5)
                          ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: Icon(
                    themeService.isDarkMode
                        ? Icons.light_mode_rounded
                        : Icons.dark_mode_rounded,
                    key: ValueKey(themeService.isDarkMode),
                    color: Colors.white,
                  ),
                ),
                onPressed: () => themeService.toggleTheme(),
                tooltip: 'สลับธีม',
              ),
              IconButton(
                icon: const Icon(Icons.refresh_rounded,
                    color: Colors.white),
                onPressed: () =>
                    context.read<NoteBloc>().add(const LoadNotes()),
              ),
            ],
          ),

          // Stats Bar
          SliverToBoxAdapter(
            child: BlocBuilder<NoteBloc, NoteState>(
              builder: (context, state) {
                int count = 0;
                int aiCount = 0;
                if (state is NoteLoaded) {
                  count = state.notes.length;
                  aiCount = state.notes
                      .where((n) => n.aiSummary != null)
                      .length;
                }
                return Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isDark
                          ? [
                              const Color(0xFF0D2137),
                              const Color(0xFF1565C0)
                                  .withValues(alpha: 0.5)
                            ]
                          : [
                              const Color(0xFF1565C0),
                              const Color(0xFF42A5F5)
                            ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color:
                            const Color(0xFF1565C0).withValues(alpha: 0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      _StatItem(
                        icon: Icons.note_outlined,
                        label: 'บันทึกทั้งหมด',
                        value: '$count',
                      ),
                      Container(
                        width: 1,
                        height: 40,
                        color: Colors.white.withValues(alpha: 0.3),
                      ),
                      _StatItem(
                        icon: Icons.auto_awesome,
                        label: 'สรุปด้วย AI',
                        value: '$aiCount',
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          // Notes List
          BlocBuilder<NoteBloc, NoteState>(
            builder: (context, state) {
              if (state is NoteLoading) {
                return const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              if (state is NoteError) {
                return SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline,
                            size: 64,
                            color: theme.colorScheme.error),
                        const SizedBox(height: 16),
                        Text(state.message,
                            textAlign: TextAlign.center),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () => context
                              .read<NoteBloc>()
                              .add(const LoadNotes()),
                          icon: const Icon(Icons.refresh),
                          label: const Text('ลองใหม่'),
                        ),
                      ],
                    ),
                  ),
                );
              }

              List<Note> notes = [];
              if (state is NoteLoaded) notes = state.notes;
              if (state is NoteSummarized) notes = state.notes;
              if (state is NoteSummarizing) notes = state.notes;

              if (notes.isEmpty) {
                return SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 600),
                          curve: Curves.easeInOut,
                          padding: const EdgeInsets.all(28),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                const Color(0xFF1565C0)
                                    .withValues(alpha: 0.1),
                                const Color(0xFF42A5F5)
                                    .withValues(alpha: 0.1),
                              ],
                            ),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.note_add_outlined,
                            size: 72,
                            color: Color(0xFF1565C0),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text('ยังไม่มีบันทึก',
                            style: theme.textTheme.headlineSmall
                                ?.copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Text(
                          'กดปุ่ม + เพื่อเพิ่มบันทึกแรกของคุณ',
                          style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.outline),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return SliverPadding(
                padding: const EdgeInsets.only(bottom: 100),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final note = notes[index];
                      return NoteCard(
                        note: note,
                        onTap: () => context.router
                            .push(NoteDetailRoute(note: note)),
                        onDelete: () {
                          if (note.id != null) {
                            context.read<NoteBloc>().add(
                                DeleteNoteEvent(id: note.id!));
                          }
                        },
                      );
                    },
                    childCount: notes.length,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.router.push(const AddNoteRoute()),
        icon: const Icon(Icons.add_rounded),
        label: const Text('บันทึกใหม่',
            style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 4,
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white, size: 22),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.8),
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}