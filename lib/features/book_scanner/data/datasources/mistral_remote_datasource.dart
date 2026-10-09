import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:mistralai_dart/mistralai_dart.dart';

import '../../../../core/error/failures.dart';
import '../models/book_model.dart';

abstract class BookRemoteDataSource {
  Future<List<BookModel>> scanBooks(File image);
}

class MistralRemoteDataSource implements BookRemoteDataSource {
  final MistralClient client;

  MistralRemoteDataSource({required this.client});

  // Официальная Vision-модель от Mistral AI
  static const _model = 'pixtral-12b-2409';

  static const _prompt = '''
Ты — сканер книг. На фото книга (корешок, обложка или титульная страница). Язык книг — преимущественно русский.
Внимательно прочитай текст и извлеки метаданные. Если какой-то параметр не виден на фото или ты не уверен, ставь null.

Верни СТРОГО JSON-массив объектов без markdown-оформления и без лишнего текста:
[{
  "title": string,
  "author": string|null,
  "year": number|null,
  "genre": string|null,
  "publisher": string|null,
  "city": string|null,
  "pages": number|null,
  "isbn": string|null,
  "udc": string|null,
  "bbk": string|null
}]

Если книг на фото нет — верни [].
''';

  @override
  Future<List<BookModel>> scanBooks(File image) async {
    try {
      // 1. Читаем файл и кодируем в base64 data-URL
      final bytes = await image.readAsBytes();
      final mime = _mimeFromPath(image.path);
      final dataUrl = 'data:$mime;base64,${base64Encode(bytes)}';

      // 2. Запрос с текстом + картинкой к мультимодальной модели Pixtral
      final response = await client.chat.create(
        request: ChatCompletionRequest(
          model: _model,
          messages: [
            ChatMessage.userMultimodal([
              ContentPart.text(_prompt),
              ContentPart.imageUrl(dataUrl),
            ]),
          ],
          temperature: 0.1,
        ),
      );

      // 3. Достаём текст и парсим
      final raw = response.text?.trim() ?? '';
      if (kDebugMode) {
        print('MISTRAL RAW: $raw');
      }
      final cleaned = _stripFences(raw);
      final decoded = jsonDecode(cleaned) as List<dynamic>;

      return decoded
          .map((e) => BookModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on SocketException {
      throw const NetworkFailure(
          'Отсутствует подключение к интернету. Проверьте соединение.');
    } on FormatException catch (e) {
      throw ServerFailure('Не удалось разобрать ответ модели: ${e.message}');
    } catch (e) {
      final errStr = e.toString();
      if (errStr.contains('SocketException') ||
          errStr.contains('Failed host lookup') ||
          errStr.contains('No address associated with hostname')) {
        throw const NetworkFailure(
            'Отсутствует подключение к интернету. Проверьте соединение.');
      }
      debugPrint('Mistral scan error: $errStr');
      throw ServerFailure('Ошибка распознавания: $e');
    }
  }

  String _mimeFromPath(String path) {
    final p = path.toLowerCase();
    if (p.endsWith('.png')) return 'image/png';
    if (p.endsWith('.webp')) return 'image/webp';
    if (p.endsWith('.gif')) return 'image/gif';
    return 'image/jpeg';
  }

  /// Gemini/Mistral иногда оборачивают JSON в ```json ... ```
  String _stripFences(String s) {
    var t = s.trim();
    if (t.startsWith('```')) {
      t = t.replaceFirst(RegExp(r'^```(json)?'), '').trim();
      if (t.endsWith('```')) t = t.substring(0, t.length - 3).trim();
    }
    return t;
  }
}
