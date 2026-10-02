import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../book_scanner/domain/entities/book.dart';
import '../bloc/library_bloc.dart';
import '../bloc/library_event.dart';
import '../bloc/library_state.dart';
import '../bloc/online_search_bloc/online_search_bloc.dart';
import '../bloc/online_search_bloc/online_search_event.dart';
import '../bloc/online_search_bloc/online_search_state.dart';
import '../../../../core/di/injection_container.dart';

class LibraryPage extends StatelessWidget {
  const LibraryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const _LibraryView();
  }
}

class _LibraryView extends StatelessWidget {
  const _LibraryView();

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

  void _showEditDialog(BuildContext context, Book book) {
    final titleController = TextEditingController(text: book.title ?? '');
    final authorController = TextEditingController(text: book.author ?? '');
    final yearController =
        TextEditingController(text: book.year?.toString() ?? '');
    final descController = TextEditingController(text: book.description ?? '');

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Редактировать книгу'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: 'Название'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: authorController,
                  decoration: const InputDecoration(labelText: 'Автор'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: yearController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Год издания'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descController,
                  maxLines: 3,
                  decoration:
                      const InputDecoration(labelText: 'Описание / Заметки'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Отмена'),
            ),
            FilledButton(
              onPressed: () {
                final updatedBook = book.copyWith(
                  title: titleController.text.trim(),
                  author: authorController.text.trim(),
                  year: int.tryParse(yearController.text.trim()),
                  description: descController.text.trim().isNotEmpty
                      ? descController.text.trim()
                      : null,
                );
                context.read<LibraryBloc>().add(UpdateBookEvent(updatedBook));
                Navigator.of(dialogContext).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Книга обновлена')),
                );
              },
              child: const Text('Сохранить'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Моя библиотека'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddBookBottomSheet(context),
        child: const Icon(Icons.add),
      ),
      body: BlocBuilder<LibraryBloc, LibraryState>(
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
          if (state is LibraryEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
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
            final books = state.books;
            if (books.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
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
            return ListView.builder(
              itemCount: books.length,
              itemBuilder: (context, index) {
                final book = books[index];
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
                    leading: book.thumbnailUrl != null &&
                            book.thumbnailUrl!.isNotEmpty
                        ? Image.network(
                            book.thumbnailUrl!.replaceFirst('http:', 'https:'),
                            width: 50,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(Icons.book, size: 50),
                          )
                        : const Icon(Icons.book, size: 50),
                    title: Text(book.title ?? 'Без названия'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${book.author ?? 'Неизвестный автор'}${book.year != null ? ' • ${book.year}' : ''}',
                        ),
                        if (book.description != null &&
                            book.description!.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 4.0),
                            child: Text(
                              book.description!,
                              style: Theme.of(context).textTheme.bodySmall,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                      ],
                    ),
                    isThreeLine: book.description != null &&
                        book.description!.isNotEmpty,
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.indigo),
                          onPressed: () => _showEditDialog(context, book),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline,
                              color: Colors.red),
                          onPressed: () async {
                            final confirm = await showDialog<bool>(
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
                            if (confirm == true &&
                                book.id != null &&
                                context.mounted) {
                              context
                                  .read<LibraryBloc>()
                                  .add(DeleteBookEvent(book.id!));
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('Книга удалена из библиотеки')),
                              );
                            }
                          },
                        ),
                      ],
                    ),
                    onTap: () => _showEditDialog(context, book),
                  ),
                );
              },
            );
          }

          return const SizedBox.shrink();
        },
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
