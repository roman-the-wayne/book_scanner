import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/theme_cubit.dart';
import '../../../book_scanner/domain/entities/book.dart';
import '../bloc/library_bloc.dart';
import '../bloc/library_event.dart';
import '../bloc/library_state.dart';
import '../bloc/online_search_bloc/online_search_bloc.dart';
import '../bloc/online_search_bloc/online_search_event.dart';
import '../bloc/online_search_bloc/online_search_state.dart';
import 'book_details_page.dart';

class LibraryPage extends StatelessWidget {
  const LibraryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const _LibraryView();
  }
}

class _LibraryView extends StatefulWidget {
  const _LibraryView();

  @override
  State<_LibraryView> createState() => _LibraryViewState();
}

class _LibraryViewState extends State<_LibraryView> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showAddBookBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) {
        return const AddBookTabsBottomSheet();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeMode = context.watch<ThemeCubit>().state;
    final isDark = themeMode == ThemeMode.dark ||
        (themeMode == ThemeMode.system &&
            MediaQuery.of(context).platformBrightness == Brightness.dark);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Моя библиотека'),
        actions: [
          // Переключатель темы
          IconButton(
            icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
            tooltip: 'Сменить тему',
            onPressed: () => context.read<ThemeCubit>().toggleTheme(),
          ),
          // Меню сортировки
          BlocBuilder<LibraryBloc, LibraryState>(
            builder: (context, state) {
              final currentSort = state is LibraryLoaded ? state.sortOption : SortOption.dateAdded;
              return PopupMenuButton<SortOption>(
                icon: const Icon(Icons.sort),
                tooltip: 'Сортировка',
                initialValue: currentSort,
                onSelected: (sort) {
                  context.read<LibraryBloc>().add(SortOptionChanged(sort));
                },
                itemBuilder: (context) => const [
                  PopupMenuItem(
                    value: SortOption.dateAdded,
                    child: Text('По дате добавления'),
                  ),
                  PopupMenuItem(
                    value: SortOption.title,
                    child: Text('По названию (А-Я)'),
                  ),
                  PopupMenuItem(
                    value: SortOption.author,
                    child: Text('По автору (А-Я)'),
                  ),
                  PopupMenuItem(
                    value: SortOption.rating,
                    child: Text('По рейтингу (высокие выше)'),
                  ),
                ],
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddBookBottomSheet(context),
        child: const Icon(Icons.add),
      ),
      body: BlocListener<LibraryBloc, LibraryState>(
        listener: (context, state) {
          // Показываем ошибки сети/БД, если они происходят асинхронно
          if (state is LibraryError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.red),
            );
          }
        },
        child: Column(
          children: [
            // Панель поиска и фильтров
            BlocBuilder<LibraryBloc, LibraryState>(
              builder: (context, state) {
                final currentQuery = state is LibraryLoaded ? state.searchQuery : '';
                final currentFilter = state is LibraryLoaded ? state.filterOption : FilterOption.all;
                
                // Синхронизируем контроллер с состоянием (если очистили извне)
                if (_searchController.text != currentQuery) {
                  _searchController.text = currentQuery;
                  _searchController.selection = TextSelection.fromPosition(
                    TextPosition(offset: _searchController.text.length),
                  );
                }

                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Поиск по вашей библиотеке...',
                          prefixIcon: const Icon(Icons.search),
                          suffixIcon: currentQuery.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () {
                                    _searchController.clear();
                                    context.read<LibraryBloc>().add(const SearchQueryChanged(''));
                                  },
                                )
                              : null,
                          isDense: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onChanged: (value) {
                          context.read<LibraryBloc>().add(SearchQueryChanged(value.trim()));
                        },
                      ),
                    ),

                    // Чипы фильтров
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Row(
                        children: [
                          FilterChip(
                            label: const Text('Все'),
                            selected: currentFilter == FilterOption.all,
                            onSelected: (_) => context.read<LibraryBloc>().add(const FilterOptionChanged(FilterOption.all)),
                          ),
                          const SizedBox(width: 8),
                          FilterChip(
                            label: const Text('Прочитано'),
                            selected: currentFilter == FilterOption.read,
                            onSelected: (_) => context.read<LibraryBloc>().add(const FilterOptionChanged(FilterOption.read)),
                          ),
                          const SizedBox(width: 8),
                          FilterChip(
                            label: const Text('Не прочитано'),
                            selected: currentFilter == FilterOption.unread,
                            onSelected: (_) => context.read<LibraryBloc>().add(const FilterOptionChanged(FilterOption.unread)),
                          ),
                          const SizedBox(width: 8),
                          FilterChip(
                            label: const Text('В долгу'),
                            selected: currentFilter == FilterOption.lent,
                            onSelected: (_) => context.read<LibraryBloc>().add(const FilterOptionChanged(FilterOption.lent)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                );
              },
            ),

            // Список книг
            Expanded(
              child: BlocBuilder<LibraryBloc, LibraryState>(
                builder: (context, state) {
                  if (state is LibraryLoading || state is LibraryInitial) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  
                  if (state is LibraryEmpty) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(24.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.auto_stories,
                              size: 80,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 16),
                            Text(
                              'Ваша библиотека пуста. Отсканируйте книги во вкладке поиска или добавьте вручную.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  if (state is LibraryLoaded) {
                    final displayBooks = state.displayedBooks;

                    if (displayBooks.isEmpty) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(24.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.auto_stories,
                                size: 80,
                                color: Colors.grey,
                              ),
                              SizedBox(height: 16),
                              Text(
                                'Книги по вашему запросу не найдены.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    return ListView.builder(
                      itemCount: displayBooks.length,
                      itemBuilder: (context, index) {
                        final book = displayBooks[index];
                        final bookId = book.id ?? book.title ?? index.toString();

                        return Dismissible(
                          key: Key(bookId),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            color: Colors.red,
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: const Icon(Icons.delete, color: Colors.white),
                          ),
                          confirmDismiss: (direction) async {
                            return await showDialog(
                              context: context,
                              builder: (BuildContext dialogContext) {
                                return AlertDialog(
                                  title: const Text('Удалить книгу'),
                                  content: const Text(
                                      'Вы уверены, что хотите удалить эту книгу из библиотеки?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.of(dialogContext).pop(false),
                                      child: const Text('Отмена'),
                                    ),
                                    FilledButton(
                                      onPressed: () =>
                                          Navigator.of(dialogContext).pop(true),
                                      child: const Text('Удалить'),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                          onDismissed: (direction) {
                            if (book.id != null) {
                              context.read<LibraryBloc>().add(DeleteBookEvent(book.id!));
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('Книга удалена из библиотеки')),
                              );
                            }
                          },
                          child: ListTile(
                            leading: ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: book.thumbnailUrl != null &&
                                      book.thumbnailUrl!.isNotEmpty
                                  ? CachedNetworkImage(
                                      imageUrl: book.thumbnailUrl!
                                          .replaceFirst('http:', 'https:'),
                                      width: 45,
                                      height: 60,
                                      fit: BoxFit.cover,
                                      placeholder: (context, url) => Container(
                                        width: 45,
                                        height: 60,
                                        color: theme.colorScheme.surfaceContainerHighest,
                                        child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                                      ),
                                      errorWidget: (context, url, error) => Container(
                                        width: 45,
                                        height: 60,
                                        color: theme.colorScheme.surfaceContainerHighest,
                                        child: const Icon(Icons.book),
                                      ),
                                    )
                                  : Container(
                                      width: 45,
                                      height: 60,
                                      color: theme.colorScheme.surfaceContainerHighest,
                                      child: const Icon(Icons.book),
                                    ),
                            ),
                            title: Text(
                              book.title ?? 'Без названия',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${book.author ?? 'Неизвестный автор'}${book.year != null ? ' • ${book.year}' : ''}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    if (book.rating != null && book.rating! > 0) ...[
                                      const Icon(Icons.star,
                                          size: 14, color: Colors.amber),
                                      const SizedBox(width: 2),
                                      Text(
                                        '${book.rating}',
                                        style: theme.textTheme.bodySmall,
                                      ),
                                      const SizedBox(width: 8),
                                    ],
                                    if (book.isRead)
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: Colors.green.withValues(alpha: 0.2),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: const Text(
                                          'Прочитано',
                                          style: TextStyle(
                                              fontSize: 10, color: Colors.green),
                                        ),
                                      ),
                                    if (book.isLent) ...[
                                      if (book.isRead) const SizedBox(width: 6),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: Colors.orange.withValues(alpha: 0.2),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          'В долгу (${book.borrowerName ?? '?'})',
                                          style: const TextStyle(
                                              fontSize: 10, color: Colors.orange),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ],
                            ),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => BookDetailsPage(book: book),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    );
                  }
                  
                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
class AddBookTabsBottomSheet extends StatelessWidget {
  const AddBookTabsBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<OnlineSearchBloc>(),
      child: DefaultTabController(
        length: 2,
        child: FractionallySizedBox(
          heightFactor: 0.9,
          child: Column(
            children: [
              const TabBar(
                tabs: [
                  Tab(text: 'Вручную', icon: Icon(Icons.edit_note)),
                  Tab(text: 'Из сети', icon: Icon(Icons.travel_explore)),
                ],
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    const ManualAddBookTab(),
                    const OnlineSearchTab(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ManualAddBookTab extends StatefulWidget {
  const ManualAddBookTab({super.key});

  @override
  State<ManualAddBookTab> createState() => _ManualAddBookTabState();
}

class _ManualAddBookTabState extends State<ManualAddBookTab> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _authorController = TextEditingController();
  final _yearController = TextEditingController();
  final _descController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    _yearController.dispose();
    _descController.dispose();
    super.dispose();
  }

  void _saveBook() {
    if (_formKey.currentState!.validate()) {
      final book = Book(
        title: _titleController.text.trim(),
        author: _authorController.text.trim().isNotEmpty
            ? _authorController.text.trim()
            : 'Неизвестный автор',
        year: int.tryParse(_yearController.text.trim()),
        description: _descController.text.trim().isNotEmpty
            ? _descController.text.trim()
            : null,
      );

      context.read<LibraryBloc>().add(SaveBookEvent(book));
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Книга успешно добавлена')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.only(
        left: 24.0,
        right: 24.0,
        top: 24.0,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24.0,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Название книги',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Пожалуйста, введите название';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _authorController,
              decoration: const InputDecoration(
                labelText: 'Автор',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _yearController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Год издания',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Описание / Заметки',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Отмена'),
                ),
                const SizedBox(width: 16),
                FilledButton(
                  onPressed: _saveBook,
                  child: const Text('Сохранить'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class OnlineSearchTab extends StatefulWidget {
  const OnlineSearchTab({super.key});

  @override
  State<OnlineSearchTab> createState() => _OnlineSearchTabState();
}

class _OnlineSearchTabState extends State<OnlineSearchTab> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _performSearch() {
    final query = _searchController.text.trim();
    if (query.isNotEmpty) {
      context.read<OnlineSearchBloc>().add(SearchBooksQueryEvent(query));
      FocusScope.of(context).unfocus(); // прячем клавиатуру
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    hintText: 'Поиск книги по автору или названию...',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                  onSubmitted: (_) => _performSearch(),
                ),
              ),
              const SizedBox(width: 8),
              FilledButton(
                onPressed: _performSearch,
                child: const Text('Найти'),
              ),
            ],
          ),
        ),
        Expanded(
          child: BlocBuilder<OnlineSearchBloc, OnlineSearchState>(
            builder: (context, searchState) {
              if (searchState is OnlineSearchInitial) {
                return const Center(child: Text('Введите запрос для поиска'));
              }
              if (searchState is OnlineSearchLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              if (searchState is OnlineSearchError) {
                final isNetworkError =
                    searchState.message.contains('интернет') ||
                        searchState.message.contains('SocketException') ||
                        searchState.message.contains('Failed host lookup');

                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          isNetworkError ? Icons.wifi_off : Icons.error_outline,
                          size: 60,
                          color: Colors.orange,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          searchState.message,
                          style: const TextStyle(fontSize: 15),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        FilledButton.icon(
                          onPressed: _performSearch,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Повторить'),
                        ),
                      ],
                    ),
                  ),
                );
              }
              if (searchState is OnlineSearchLoaded) {
                if (searchState.books.isEmpty) {
                  return const Center(child: Text('Ничего не найдено'));
                }
                return BlocBuilder<LibraryBloc, LibraryState>(
                  builder: (context, libraryState) {
                    final savedBooks = libraryState is LibraryLoaded
                        ? libraryState.books
                        : <Book>[];

                    return ListView.separated(
                      padding: const EdgeInsets.only(bottom: 24),
                      itemCount: searchState.books.length,
                      separatorBuilder: (context, index) => const Divider(),
                      itemBuilder: (context, index) {
                        final book = searchState.books[index];
                        final isSaved = savedBooks.any(
                          (b) =>
                              b.title != null &&
                              book.title != null &&
                              b.title!.trim().toLowerCase() ==
                                  book.title!.trim().toLowerCase() &&
                              b.author?.trim().toLowerCase() ==
                                  book.author?.trim().toLowerCase(),
                        );

                        return ListTile(
                          leading: book.thumbnailUrl != null && book.thumbnailUrl!.isNotEmpty
                              ? CachedNetworkImage(
                                  imageUrl: book.thumbnailUrl!.replaceFirst('http:', 'https:'),
                                  width: 50,
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) => const SizedBox(
                                    width: 50,
                                    child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                                  ),
                                  errorWidget: (context, url, error) => const Icon(Icons.book, size: 50),
                                )
                              : const Icon(Icons.book, size: 50),
                          title: Text(
                            book.title ?? 'Без названия',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Text(
                            '${book.author ?? 'Неизвестный автор'}${book.year != null ? ' • ${book.year}' : ''}',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: IconButton(
                            icon: Icon(
                              isSaved
                                  ? Icons.bookmark
                                  : Icons.bookmark_add_outlined,
                              color: isSaved ? Colors.indigo : null,
                            ),
                            onPressed: isSaved
                                ? null
                                : () {
                                    context.read<LibraryBloc>().add(
                                          SaveBookEvent(book),
                                        );
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                            'Книга добавлена в библиотеку'),
                                        duration: Duration(seconds: 2),
                                      ),
                                    );
                                  },
                          ),
                        );
                      },
                    );
                  },
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ),
      ],
    );
  }
}
