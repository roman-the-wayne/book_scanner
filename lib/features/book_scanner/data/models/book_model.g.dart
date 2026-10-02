// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'book_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_BookModel _$BookModelFromJson(Map<String, dynamic> json) => _BookModel(
  id: json['id'] as String?,
  title: json['title'] as String?,
  author: json['author'] as String?,
  year: (json['year'] as num?)?.toInt(),
  description: json['description'] as String?,
  thumbnailUrl: json['thumbnailUrl'] as String?,
  isRead: json['isRead'] as bool? ?? false,
  isLent: json['isLent'] as bool? ?? false,
  borrowerName: json['borrowerName'] as String?,
  rating: (json['rating'] as num?)?.toInt(),
);

Map<String, dynamic> _$BookModelToJson(_BookModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'author': instance.author,
      'year': instance.year,
      'description': instance.description,
      'thumbnailUrl': instance.thumbnailUrl,
      'isRead': instance.isRead,
      'isLent': instance.isLent,
      'borrowerName': instance.borrowerName,
      'rating': instance.rating,
    };
