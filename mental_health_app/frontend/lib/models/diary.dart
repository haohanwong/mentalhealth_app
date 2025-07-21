import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';

part 'diary.g.dart';

@JsonSerializable()
class DiaryEntry extends Equatable {
  final int id;
  final String title;
  final String content;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'user_id')
  final int userId;

  const DiaryEntry({
    required this.id,
    required this.title,
    required this.content,
    required this.createdAt,
    required this.userId,
  });

  factory DiaryEntry.fromJson(Map<String, dynamic> json) => _$DiaryEntryFromJson(json);
  Map<String, dynamic> toJson() => _$DiaryEntryToJson(this);

  @override
  List<Object> get props => [id, title, content, createdAt, userId];
}

@JsonSerializable()
class DiaryEntryCreate {
  final String title;
  final String content;

  const DiaryEntryCreate({
    required this.title,
    required this.content,
  });

  factory DiaryEntryCreate.fromJson(Map<String, dynamic> json) => _$DiaryEntryCreateFromJson(json);
  Map<String, dynamic> toJson() => _$DiaryEntryCreateToJson(this);
}

@JsonSerializable()
class DiaryEntryUpdate {
  final String? title;
  final String? content;

  const DiaryEntryUpdate({
    this.title,
    this.content,
  });

  factory DiaryEntryUpdate.fromJson(Map<String, dynamic> json) => _$DiaryEntryUpdateFromJson(json);
  Map<String, dynamic> toJson() => _$DiaryEntryUpdateToJson(this);
}