// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'book_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_BookModel _$BookModelFromJson(Map<String, dynamic> json) => _BookModel(
  title: json['title'] as String?,
  author: json['author'] as String?,
  year: (json['year'] as num?)?.toInt(),
);

Map<String, dynamic> _$BookModelToJson(_BookModel instance) =>
    <String, dynamic>{
      'title': instance.title,
      'author': instance.author,
      'year': instance.year,
    };
