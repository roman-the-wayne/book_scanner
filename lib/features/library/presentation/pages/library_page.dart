import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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

enum FilterOption { all, read, unread, lent }

enum SortOption { dateAdded, title, author, rating }

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
  String _searchQuery = '';
  FilterOption _filterOption = FilterOption.all;
  SortOption _sortOption = SortOption.dateAdded;

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

  List<Book> _filterAndSortBooks(List<Book> books) {
    // 1. Фильтрация по поисковому запросу
    var filtered = books.where((book) {
      if (_searchQuery.isEmpty) return true;
      final title = book.title?.toLowerCase() ?? '';
      final author = book.author?.toLowerCase() ?? '';
      final query = _searchQuery.toLowerCase();
      return title.contains(query) || author.contains(query);
    }).toList();

    // 2. Фильтрация по статусам
    if (_filterOption == FilterOption.read) {
      filtered = filtered.where((b) => b.isRead).toList();
    } else if (_filterOption == FilterOption.unread) {
      filtered = filtered.where((b) => !b.isRead).toList();
    } else if (_filterOption == FilterOption.lent) {
      filtered = filtered.where((b) => b.isLent).toList();
    }

    // 3. Сортировка
    filtered.sort((a, b) {
      switch (_sortOption) {
        case SortOption.title:
          return (a.title ?? '').compareTo(b.title ?? '');
        case SortOption.author:
          return (a.author ?? '').compareTo(b.author ?? '');
        case SortOption.rating:
          return (b.rating ?? 0).compareTo(a.rating ?? 0);
        case SortOption.dateAdded:
          return 0; // По умолчанию сохраняется порядок из БД
      }
    });

    return filtered;
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
          PopupMenuButton<SortOption>(
            icon: const Icon(Icons.sort),
            tooltip: 'Сортировка',
            onSelected: (sort) {
              setState(() {
                _sortOption = sort;
              });
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
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddBookBottomSheet(context),
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          // Панель поиска и фильтров
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Поиск по вашей библиотеке...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
                isDense: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.trim();
                });
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
                  selected: _filterOption == FilterOption.all,
                  onSelected: (_) =>
                      setState(() => _filterOption = FilterOption.all),
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text('Прочитано'),
                  selected: _filterOption == FilterOption.read,
                  onSelected: (_) =>
                      setState(() => _filterOption = FilterOption.read),
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text('Не прочитано'),
                  selected: _filterOption == FilterOption.unread,
                  onSelected: (_) =>
                      setState(() => _filterOption = FilterOption.unread),
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text('В долгу'),
                  selected: _filterOption == FilterOption.lent,
                  onSelected: (_) =>
                      setState(() => _filterOption = FilterOption.lent),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Список книг
          Expanded(
            child: BlocBuilder<LibraryBloc, LibraryState>(
              builder: (context, state) {
                if (state is LibraryLoading || state is LibraryInitial) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state is LibraryError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        state.message,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  );
                }

                final allBooks = state is LibraryLoaded
                    ? state.books
                    : <Book>[];

                final displayBooks = _filterAndSortBooks(allBooks);

                if (displayBooks.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.auto_stories,
                            size: 80,
                            color: Colors.grey,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            allBooks.isEmpty
                                ? 'Ваша библиотека пуста. Отсканируйте книги во вкладке поиска или добавьте вручную.'
                                : 'Книги по вашему запросу не найдены.',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
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
                          context
                              .read<LibraryBloc>()
                              .add(DeleteBookEvent(book.id!));
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
                              ? Image.network(
                                  book.thumbnailUrl!
                                      .replaceFirst('http:', 'https:'),
                                  width: 45,
                                  height: 60,
                                  fit: BoxFit.cover,
                                  errorBuilder:
                                      (context, error, stackTrace) =>
                                          Container(
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
                        // Адаптивная верстка длинных названий (Task 4)
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
                            // Бейджи статусов и рейтингов
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
                          // Клик открывает детальную карточку книги (Task 2)
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
              },
            ),
          ),
        ],
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
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'Ошибка: ${searchState.message}',
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
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
                          leading: book.thumbnailUrl != null
                              ? Image.network(
                                  book.thumbnailUrl!
                                      .replaceFirst('http:', 'https:'),
                                  width: 50,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      const Icon(Icons.book, size: 50),
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
