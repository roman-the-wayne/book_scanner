import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../book_scanner/domain/entities/book.dart';
import '../bloc/library_bloc.dart';
import '../bloc/library_event.dart';

class BookDetailsPage extends StatefulWidget {
  final Book book;

  const BookDetailsPage({super.key, required this.book});

  @override
  State<BookDetailsPage> createState() => _BookDetailsPageState();
}

class _BookDetailsPageState extends State<BookDetailsPage> {
  late Book _currentBook;

  @override
  void initState() {
    super.initState();
    _currentBook = widget.book;
  }

  void _updateBook(Book updatedBook) {
    setState(() {
      _currentBook = updatedBook;
    });
    context.read<LibraryBloc>().add(UpdateBookEvent(updatedBook));
  }

  void _showBorrowerDialog() {
    final borrowerController =
        TextEditingController(text: _currentBook.borrowerName ?? '');

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Кому вы отдали книгу?'),
          content: TextField(
            controller: borrowerController,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: 'Имя / контакты должника',
              hintText: 'например, Алексей',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Отмена'),
            ),
            FilledButton(
              onPressed: () {
                final borrower = borrowerController.text.trim();
                final updated = _currentBook.copyWith(
                  isLent: true,
                  borrowerName: borrower.isNotEmpty ? borrower : 'Не указан',
                );
                _updateBook(updated);
                Navigator.of(dialogContext).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Статус книги обновлен')),
                );
              },
              child: const Text('Сохранить'),
            ),
          ],
        );
      },
    );
  }

  void _showEditDialog() {
    final titleController =
        TextEditingController(text: _currentBook.title ?? '');
    final authorController =
        TextEditingController(text: _currentBook.author ?? '');
    final yearController =
        TextEditingController(text: _currentBook.year?.toString() ?? '');
    final genreController =
        TextEditingController(text: _currentBook.genre ?? '');
    final publisherController =
        TextEditingController(text: _currentBook.publisher ?? '');
    final cityController =
        TextEditingController(text: _currentBook.city ?? '');
    final pagesController =
        TextEditingController(text: _currentBook.pages?.toString() ?? '');
    final isbnController =
        TextEditingController(text: _currentBook.isbn ?? '');
    final udcController = TextEditingController(text: _currentBook.udc ?? '');
    final bbkController = TextEditingController(text: _currentBook.bbk ?? '');
    final descController =
        TextEditingController(text: _currentBook.description ?? '');

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Редактировать информацию'),
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
                  controller: genreController,
                  decoration: const InputDecoration(labelText: 'Жанр'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: publisherController,
                  decoration: const InputDecoration(labelText: 'Издательство'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: cityController,
                  decoration: const InputDecoration(labelText: 'Город издания'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: pagesController,
                  keyboardType: TextInputType.number,
                  decoration:
                      const InputDecoration(labelText: 'Количество страниц'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: isbnController,
                  decoration: const InputDecoration(labelText: 'ISBN'),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: udcController,
                        decoration: const InputDecoration(labelText: 'УДК'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: bbkController,
                        decoration: const InputDecoration(labelText: 'ББК'),
                      ),
                    ),
                  ],
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
                final updated = _currentBook.copyWith(
                  title: titleController.text.trim(),
                  author: authorController.text.trim(),
                  year: int.tryParse(yearController.text.trim()),
                  genre: genreController.text.trim().isNotEmpty
                      ? genreController.text.trim()
                      : null,
                  publisher: publisherController.text.trim().isNotEmpty
                      ? publisherController.text.trim()
                      : null,
                  city: cityController.text.trim().isNotEmpty
                      ? cityController.text.trim()
                      : null,
                  pages: int.tryParse(pagesController.text.trim()),
                  isbn: isbnController.text.trim().isNotEmpty
                      ? isbnController.text.trim()
                      : null,
                  udc: udcController.text.trim().isNotEmpty
                      ? udcController.text.trim()
                      : null,
                  bbk: bbkController.text.trim().isNotEmpty
                      ? bbkController.text.trim()
                      : null,
                  description: descController.text.trim().isNotEmpty
                      ? descController.text.trim()
                      : null,
                );
                _updateBook(updated);
                Navigator.of(dialogContext).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Информация обновлена')),
                );
              },
              child: const Text('Сохранить'),
            ),
          ],
        );
      },
    );
  }

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Удалить книгу'),
          content: const Text(
              'Вы уверены, что хотите удалить эту книгу из вашей библиотеки?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Отмена'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () {
                if (_currentBook.id != null) {
                  context
                      .read<LibraryBloc>()
                      .add(DeleteBookEvent(_currentBook.id!));
                }
                Navigator.of(dialogContext).pop();
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Книга удалена')),
                );
              },
              child: const Text('Удалить'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 10),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: Theme.of(context).textTheme.bodyMedium,
                children: [
                  TextSpan(
                    text: '$label: ',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(text: value),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Карточка книги'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'Редактировать',
            onPressed: _showEditDialog,
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
            tooltip: 'Удалить',
            onPressed: _confirmDelete,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Обложка
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: _currentBook.thumbnailUrl != null &&
                        _currentBook.thumbnailUrl!.isNotEmpty
                    ? Image.network(
                        _currentBook.thumbnailUrl!
                            .replaceFirst('http:', 'https:'),
                        height: 220,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            Container(
                          height: 180,
                          width: 130,
                          color: theme.colorScheme.surfaceContainerHighest,
                          child: const Icon(Icons.book, size: 70),
                        ),
                      )
                    : Container(
                        height: 180,
                        width: 130,
                        color: theme.colorScheme.surfaceContainerHighest,
                        child: const Icon(Icons.book, size: 70),
                      ),
              ),
            ),
            const SizedBox(height: 20),

            // Заголовок
            Text(
              _currentBook.title ?? 'Без названия',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),

            // Автор и год
            Text(
              '${_currentBook.author ?? 'Неизвестный автор'}${_currentBook.year != null ? ' • ${_currentBook.year} г.' : ''}',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 20),

            const Divider(),
            const SizedBox(height: 12),

            // Расширенные метаданные
            Text(
              'Сведения об издании',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 8),
            Card(
              elevation: 0,
              color: theme.colorScheme.surfaceContainerLow,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  children: [
                    if (_currentBook.genre != null &&
                        _currentBook.genre!.isNotEmpty)
                      _buildInfoRow(Icons.category_outlined, 'Жанр',
                          _currentBook.genre!),
                    if (_currentBook.publisher != null &&
                        _currentBook.publisher!.isNotEmpty)
                      _buildInfoRow(
                        Icons.business_outlined,
                        'Издательство',
                        '${_currentBook.publisher!}${_currentBook.city != null ? ' (${_currentBook.city})' : ''}',
                      ),
                    if (_currentBook.pages != null)
                      _buildInfoRow(Icons.menu_book_outlined, 'Объем',
                          '${_currentBook.pages} стр.'),
                    if (_currentBook.isbn != null &&
                        _currentBook.isbn!.isNotEmpty)
                      _buildInfoRow(
                          Icons.qr_code_outlined, 'ISBN', _currentBook.isbn!),
                    if (_currentBook.udc != null &&
                        _currentBook.udc!.isNotEmpty)
                      _buildInfoRow(Icons.tag, 'УДК', _currentBook.udc!),
                    if (_currentBook.bbk != null &&
                        _currentBook.bbk!.isNotEmpty)
                      _buildInfoRow(Icons.tag, 'ББК', _currentBook.bbk!),
                    if ((_currentBook.genre == null ||
                            _currentBook.genre!.isEmpty) &&
                        (_currentBook.publisher == null ||
                            _currentBook.publisher!.isEmpty) &&
                        _currentBook.pages == null &&
                        (_currentBook.isbn == null ||
                            _currentBook.isbn!.isEmpty) &&
                        (_currentBook.udc == null ||
                            _currentBook.udc!.isEmpty) &&
                        (_currentBook.bbk == null || _currentBook.bbk!.isEmpty))
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 6.0),
                        child: Text(
                          'Дополнительные метаданные не указаны. Отредактируйте вручную.',
                          style: TextStyle(fontStyle: FontStyle.italic),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Блок Рейтинга
            Text(
              'Оценка книги',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 6),
            Row(
              children: List.generate(5, (index) {
                final starRating = index + 1;
                final isSelected = (_currentBook.rating ?? 0) >= starRating;
                return IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: Icon(
                    isSelected ? Icons.star : Icons.star_border,
                    color: isSelected ? Colors.amber : Colors.grey,
                    size: 32,
                  ),
                  onPressed: () {
                    final newRating =
                        _currentBook.rating == starRating ? 0 : starRating;
                    _updateBook(_currentBook.copyWith(rating: newRating));
                  },
                );
              }),
            ),

            const SizedBox(height: 16),

            // Статусы
            Text(
              'Статусы',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: [
                // Статус "Прочитано"
                FilterChip(
                  label:
                      Text(_currentBook.isRead ? 'Прочитано' : 'Не прочитано'),
                  selected: _currentBook.isRead,
                  avatar: Icon(
                    _currentBook.isRead
                        ? Icons.check_circle
                        : Icons.radio_button_unchecked,
                    size: 18,
                  ),
                  onSelected: (selected) {
                    _updateBook(_currentBook.copyWith(isRead: selected));
                  },
                ),

                // Статус "В долгу"
                FilterChip(
                  label: Text(
                    _currentBook.isLent
                        ? 'В долгу (${_currentBook.borrowerName ?? 'Не указан'})'
                        : 'У меня',
                  ),
                  selected: _currentBook.isLent,
                  avatar: Icon(
                    _currentBook.isLent
                        ? Icons.person_off
                        : Icons.check_circle_outline,
                    size: 18,
                  ),
                  onSelected: (selected) {
                    if (selected) {
                      _showBorrowerDialog();
                    } else {
                      _updateBook(_currentBook.copyWith(
                        isLent: false,
                        borrowerName: null,
                      ));
                    }
                  },
                ),
              ],
            ),

            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 12),

            // Заметки / Описание
            Text(
              'Описание и заметки',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _currentBook.description != null &&
                      _currentBook.description!.isNotEmpty
                  ? _currentBook.description!
                  : 'Заметки/описание отсутствуют.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: _currentBook.description == null ||
                        _currentBook.description!.isEmpty
                    ? theme.colorScheme.outline
                    : theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
