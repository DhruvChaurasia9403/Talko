// File: Model/LocalMessageModel.dart
import 'package:isar/isar.dart';

part 'LocalMessageModel.g.dart';

@collection
class LocalMessageModel {
  Id id = Isar.autoIncrement;

  @Index(type: IndexType.value)
  String? firestoreMessageId;

  @Index(type: IndexType.value)
  String? roomId; // <-- THIS WAS MISSING!

  String? message;
  String? senderId;
  String? receiverId;
  DateTime? timestamp;

  String? imageUrl;

  @Index(type: IndexType.value)
  String? syncStatus; // "pending", "synced"
}