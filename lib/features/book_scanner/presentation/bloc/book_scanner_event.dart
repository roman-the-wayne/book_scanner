import 'dart:io';
import 'package:equatable/equatable.dart';

abstract class BookScannerEvent extends Equatable {
  const BookScannerEvent();
  @override
  List<Object?> get props => [];
}

class ScanRequested extends BookScannerEvent {
  final File image;
  const ScanRequested(this.image);
  @override
  List<Object?> get props => [image];
}
