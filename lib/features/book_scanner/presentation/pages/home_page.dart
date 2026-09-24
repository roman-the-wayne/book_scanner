import 'dart:io';

import 'package:book_scanner/features/book_scanner/presentation/bloc/book_scanner_bloc.dart';
import 'package:book_scanner/features/book_scanner/presentation/bloc/book_scanner_event.dart';
import 'package:book_scanner/features/book_scanner/presentation/bloc/book_scanner_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/di/injection_container.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<BookScannerBloc>(),
      child: const _HomeView(),
    );
  }
}

class _HomeView extends StatelessWidget {
  const _HomeView();

  Future<void> _pickImage(BuildContext context) async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 90, // не сжимай сильно
      maxWidth: 1600,
    );
    if (picked == null) return;
    context.read<BookScannerBloc>().add(ScanRequested(File(picked.path)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('сканер книг')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _pickImage(context),
        child: const Icon(Icons.add_a_photo),
      ),
      body: BlocBuilder<BookScannerBloc, BookScannerState>(
        builder: (context, state) {
          if (state is BookScannerLoading)
            return const Center(child: CircularProgressIndicator());
          if (state is BookScannerError)
            return Center(child: Text(state.message));
          if (state is BookScannerLoaded) {
            return ListView.builder(
              itemCount: state.books.length,
              itemBuilder: (_, i) {
                final book = state.books[i];
                return ListTile(
                  title: Text(book.title!),
                  subtitle: Text(
                    '${book.author}${book.year != null ? ' • ${book.year}' : ''}',
                  ),
                );
              },
            );
          }

          return const Center(child: Text('Выберите фото'));
        },
      ),
    );
  }
}
