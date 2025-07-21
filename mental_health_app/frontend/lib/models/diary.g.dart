// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'diary.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DiaryEntry _$DiaryEntryFromJson(Map<String, dynamic> json) => DiaryEntry(
      id: (json['id'] as num).toInt(),
      title: json['title'] as String,
      content: json['content'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      userId: (json['user_id'] as num).toInt(),
    );

Map<String, dynamic> _$DiaryEntryToJson(DiaryEntry instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'content': instance.content,
      'created_at': instance.createdAt.toIso8601String(),
      'user_id': instance.userId,
    };

DiaryEntryCreate _$DiaryEntryCreateFromJson(Map<String, dynamic> json) =>
    DiaryEntryCreate(
      title: json['title'] as String,
      content: json['content'] as String,
    );

Map<String, dynamic> _$DiaryEntryCreateToJson(DiaryEntryCreate instance) =>
    <String, dynamic>{
      'title': instance.title,
      'content': instance.content,
    };

DiaryEntryUpdate _$DiaryEntryUpdateFromJson(Map<String, dynamic> json) =>
    DiaryEntryUpdate(
      title: json['title'] as String?,
      content: json['content'] as String?,
    );

Map<String, dynamic> _$DiaryEntryUpdateToJson(DiaryEntryUpdate instance) =>
    <String, dynamic>{
      'title': instance.title,
      'content': instance.content,
    };
