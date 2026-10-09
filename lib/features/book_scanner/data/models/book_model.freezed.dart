// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'book_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$BookModel {

 String? get id; String? get title; String? get author; int? get year; String? get description; String? get thumbnailUrl; bool get isRead; bool get isLent; String? get borrowerName; int? get rating; String? get genre; String? get publisher; String? get city; int? get pages; String? get isbn; String? get udc; String? get bbk; bool get isWishlist;
/// Create a copy of BookModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BookModelCopyWith<BookModel> get copyWith => _$BookModelCopyWithImpl<BookModel>(this as BookModel, _$identity);

  /// Serializes this BookModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as BookModel;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BookModel&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.title, _this.title) || other.title == _this.title)&&(identical(other.author, _this.author) || other.author == _this.author)&&(identical(other.year, _this.year) || other.year == _this.year)&&(identical(other.description, _this.description) || other.description == _this.description)&&(identical(other.thumbnailUrl, _this.thumbnailUrl) || other.thumbnailUrl == _this.thumbnailUrl)&&(identical(other.isRead, _this.isRead) || other.isRead == _this.isRead)&&(identical(other.isLent, _this.isLent) || other.isLent == _this.isLent)&&(identical(other.borrowerName, _this.borrowerName) || other.borrowerName == _this.borrowerName)&&(identical(other.rating, _this.rating) || other.rating == _this.rating)&&(identical(other.genre, _this.genre) || other.genre == _this.genre)&&(identical(other.publisher, _this.publisher) || other.publisher == _this.publisher)&&(identical(other.city, _this.city) || other.city == _this.city)&&(identical(other.pages, _this.pages) || other.pages == _this.pages)&&(identical(other.isbn, _this.isbn) || other.isbn == _this.isbn)&&(identical(other.udc, _this.udc) || other.udc == _this.udc)&&(identical(other.bbk, _this.bbk) || other.bbk == _this.bbk)&&(identical(other.isWishlist, _this.isWishlist) || other.isWishlist == _this.isWishlist));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as BookModel;
  return Object.hash(runtimeType,_this.id,_this.title,_this.author,_this.year,_this.description,_this.thumbnailUrl,_this.isRead,_this.isLent,_this.borrowerName,_this.rating,_this.genre,_this.publisher,_this.city,_this.pages,_this.isbn,_this.udc,_this.bbk,_this.isWishlist);
}

@override
String toString() {
  final _this = this as BookModel;
  return 'BookModel(id: ${_this.id}, title: ${_this.title}, author: ${_this.author}, year: ${_this.year}, description: ${_this.description}, thumbnailUrl: ${_this.thumbnailUrl}, isRead: ${_this.isRead}, isLent: ${_this.isLent}, borrowerName: ${_this.borrowerName}, rating: ${_this.rating}, genre: ${_this.genre}, publisher: ${_this.publisher}, city: ${_this.city}, pages: ${_this.pages}, isbn: ${_this.isbn}, udc: ${_this.udc}, bbk: ${_this.bbk}, isWishlist: ${_this.isWishlist})';
}


}

/// @nodoc
abstract mixin class $BookModelCopyWith<$Res>  {
  factory $BookModelCopyWith(BookModel value, $Res Function(BookModel) _then) = _$BookModelCopyWithImpl;
@useResult
$Res call({
 String? id, String? title, String? author, int? year, String? description, String? thumbnailUrl, bool isRead, bool isLent, String? borrowerName, int? rating, String? genre, String? publisher, String? city, int? pages, String? isbn, String? udc, String? bbk, bool isWishlist
});




}
/// @nodoc
class _$BookModelCopyWithImpl<$Res>
    implements $BookModelCopyWith<$Res> {
  _$BookModelCopyWithImpl(this._self, this._then);

  final BookModel _self;
  final $Res Function(BookModel) _then;

/// Create a copy of BookModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = freezed,Object? title = freezed,Object? author = freezed,Object? year = freezed,Object? description = freezed,Object? thumbnailUrl = freezed,Object? isRead = null,Object? isLent = null,Object? borrowerName = freezed,Object? rating = freezed,Object? genre = freezed,Object? publisher = freezed,Object? city = freezed,Object? pages = freezed,Object? isbn = freezed,Object? udc = freezed,Object? bbk = freezed,Object? isWishlist = null,}) {
  return _then(BookModel(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String?,author: freezed == author ? _self.author : author // ignore: cast_nullable_to_non_nullable
as String?,year: freezed == year ? _self.year : year // ignore: cast_nullable_to_non_nullable
as int?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,thumbnailUrl: freezed == thumbnailUrl ? _self.thumbnailUrl : thumbnailUrl // ignore: cast_nullable_to_non_nullable
as String?,isRead: null == isRead ? _self.isRead : isRead // ignore: cast_nullable_to_non_nullable
as bool,isLent: null == isLent ? _self.isLent : isLent // ignore: cast_nullable_to_non_nullable
as bool,borrowerName: freezed == borrowerName ? _self.borrowerName : borrowerName // ignore: cast_nullable_to_non_nullable
as String?,rating: freezed == rating ? _self.rating : rating // ignore: cast_nullable_to_non_nullable
as int?,genre: freezed == genre ? _self.genre : genre // ignore: cast_nullable_to_non_nullable
as String?,publisher: freezed == publisher ? _self.publisher : publisher // ignore: cast_nullable_to_non_nullable
as String?,city: freezed == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as String?,pages: freezed == pages ? _self.pages : pages // ignore: cast_nullable_to_non_nullable
as int?,isbn: freezed == isbn ? _self.isbn : isbn // ignore: cast_nullable_to_non_nullable
as String?,udc: freezed == udc ? _self.udc : udc // ignore: cast_nullable_to_non_nullable
as String?,bbk: freezed == bbk ? _self.bbk : bbk // ignore: cast_nullable_to_non_nullable
as String?,isWishlist: null == isWishlist ? _self.isWishlist : isWishlist // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [BookModel].
extension BookModelPatterns on BookModel {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BookModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BookModel() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BookModel value)  $default,){
final _that = this;
switch (_that) {
case _BookModel():
return $default(_that);}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BookModel value)?  $default,){
final _that = this;
switch (_that) {
case _BookModel() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? id,  String? title,  String? author,  int? year,  String? description,  String? thumbnailUrl,  bool isRead,  bool isLent,  String? borrowerName,  int? rating,  String? genre,  String? publisher,  String? city,  int? pages,  String? isbn,  String? udc,  String? bbk,  bool isWishlist)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BookModel() when $default != null:
return $default(_that.id,_that.title,_that.author,_that.year,_that.description,_that.thumbnailUrl,_that.isRead,_that.isLent,_that.borrowerName,_that.rating,_that.genre,_that.publisher,_that.city,_that.pages,_that.isbn,_that.udc,_that.bbk,_that.isWishlist);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? id,  String? title,  String? author,  int? year,  String? description,  String? thumbnailUrl,  bool isRead,  bool isLent,  String? borrowerName,  int? rating,  String? genre,  String? publisher,  String? city,  int? pages,  String? isbn,  String? udc,  String? bbk,  bool isWishlist)  $default,) {final _that = this;
switch (_that) {
case _BookModel():
return $default(_that.id,_that.title,_that.author,_that.year,_that.description,_that.thumbnailUrl,_that.isRead,_that.isLent,_that.borrowerName,_that.rating,_that.genre,_that.publisher,_that.city,_that.pages,_that.isbn,_that.udc,_that.bbk,_that.isWishlist);}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? id,  String? title,  String? author,  int? year,  String? description,  String? thumbnailUrl,  bool isRead,  bool isLent,  String? borrowerName,  int? rating,  String? genre,  String? publisher,  String? city,  int? pages,  String? isbn,  String? udc,  String? bbk,  bool isWishlist)?  $default,) {final _that = this;
switch (_that) {
case _BookModel() when $default != null:
return $default(_that.id,_that.title,_that.author,_that.year,_that.description,_that.thumbnailUrl,_that.isRead,_that.isLent,_that.borrowerName,_that.rating,_that.genre,_that.publisher,_that.city,_that.pages,_that.isbn,_that.udc,_that.bbk,_that.isWishlist);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _BookModel extends BookModel {
  const _BookModel({this.id, this.title, this.author, this.year, this.description, this.thumbnailUrl, this.isRead = false, this.isLent = false, this.borrowerName, this.rating, this.genre, this.publisher, this.city, this.pages, this.isbn, this.udc, this.bbk, this.isWishlist = false}): super._();
  factory _BookModel.fromJson(Map<String, dynamic> json) => _$BookModelFromJson(json);

@override final  String? id;
@override final  String? title;
@override final  String? author;
@override final  int? year;
@override final  String? description;
@override final  String? thumbnailUrl;
@override@JsonKey() final  bool isRead;
@override@JsonKey() final  bool isLent;
@override final  String? borrowerName;
@override final  int? rating;
@override final  String? genre;
@override final  String? publisher;
@override final  String? city;
@override final  int? pages;
@override final  String? isbn;
@override final  String? udc;
@override final  String? bbk;
@override@JsonKey() final  bool isWishlist;

/// Create a copy of BookModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BookModelCopyWith<_BookModel> get copyWith => __$BookModelCopyWithImpl<_BookModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BookModelToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _BookModel&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.author, author) || other.author == author)&&(identical(other.year, year) || other.year == year)&&(identical(other.description, description) || other.description == description)&&(identical(other.thumbnailUrl, thumbnailUrl) || other.thumbnailUrl == thumbnailUrl)&&(identical(other.isRead, isRead) || other.isRead == isRead)&&(identical(other.isLent, isLent) || other.isLent == isLent)&&(identical(other.borrowerName, borrowerName) || other.borrowerName == borrowerName)&&(identical(other.rating, rating) || other.rating == rating)&&(identical(other.genre, genre) || other.genre == genre)&&(identical(other.publisher, publisher) || other.publisher == publisher)&&(identical(other.city, city) || other.city == city)&&(identical(other.pages, pages) || other.pages == pages)&&(identical(other.isbn, isbn) || other.isbn == isbn)&&(identical(other.udc, udc) || other.udc == udc)&&(identical(other.bbk, bbk) || other.bbk == bbk)&&(identical(other.isWishlist, isWishlist) || other.isWishlist == isWishlist));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,title,author,year,description,thumbnailUrl,isRead,isLent,borrowerName,rating,genre,publisher,city,pages,isbn,udc,bbk,isWishlist);
}

@override
String toString() {
    return 'BookModel(id: $id, title: $title, author: $author, year: $year, description: $description, thumbnailUrl: $thumbnailUrl, isRead: $isRead, isLent: $isLent, borrowerName: $borrowerName, rating: $rating, genre: $genre, publisher: $publisher, city: $city, pages: $pages, isbn: $isbn, udc: $udc, bbk: $bbk, isWishlist: $isWishlist)';
}


}

/// @nodoc
abstract mixin class _$BookModelCopyWith<$Res> implements $BookModelCopyWith<$Res> {
  factory _$BookModelCopyWith(_BookModel value, $Res Function(_BookModel) _then) = __$BookModelCopyWithImpl;
@override @useResult
$Res call({
 String? id, String? title, String? author, int? year, String? description, String? thumbnailUrl, bool isRead, bool isLent, String? borrowerName, int? rating, String? genre, String? publisher, String? city, int? pages, String? isbn, String? udc, String? bbk, bool isWishlist
});




}
/// @nodoc
class __$BookModelCopyWithImpl<$Res>
    implements _$BookModelCopyWith<$Res> {
  __$BookModelCopyWithImpl(this._self, this._then);

  final _BookModel _self;
  final $Res Function(_BookModel) _then;

/// Create a copy of BookModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = freezed,Object? title = freezed,Object? author = freezed,Object? year = freezed,Object? description = freezed,Object? thumbnailUrl = freezed,Object? isRead = null,Object? isLent = null,Object? borrowerName = freezed,Object? rating = freezed,Object? genre = freezed,Object? publisher = freezed,Object? city = freezed,Object? pages = freezed,Object? isbn = freezed,Object? udc = freezed,Object? bbk = freezed,Object? isWishlist = null,}) {
  return _then(_BookModel(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String?,author: freezed == author ? _self.author : author // ignore: cast_nullable_to_non_nullable
as String?,year: freezed == year ? _self.year : year // ignore: cast_nullable_to_non_nullable
as int?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,thumbnailUrl: freezed == thumbnailUrl ? _self.thumbnailUrl : thumbnailUrl // ignore: cast_nullable_to_non_nullable
as String?,isRead: null == isRead ? _self.isRead : isRead // ignore: cast_nullable_to_non_nullable
as bool,isLent: null == isLent ? _self.isLent : isLent // ignore: cast_nullable_to_non_nullable
as bool,borrowerName: freezed == borrowerName ? _self.borrowerName : borrowerName // ignore: cast_nullable_to_non_nullable
as String?,rating: freezed == rating ? _self.rating : rating // ignore: cast_nullable_to_non_nullable
as int?,genre: freezed == genre ? _self.genre : genre // ignore: cast_nullable_to_non_nullable
as String?,publisher: freezed == publisher ? _self.publisher : publisher // ignore: cast_nullable_to_non_nullable
as String?,city: freezed == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as String?,pages: freezed == pages ? _self.pages : pages // ignore: cast_nullable_to_non_nullable
as int?,isbn: freezed == isbn ? _self.isbn : isbn // ignore: cast_nullable_to_non_nullable
as String?,udc: freezed == udc ? _self.udc : udc // ignore: cast_nullable_to_non_nullable
as String?,bbk: freezed == bbk ? _self.bbk : bbk // ignore: cast_nullable_to_non_nullable
as String?,isWishlist: null == isWishlist ? _self.isWishlist : isWishlist // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
