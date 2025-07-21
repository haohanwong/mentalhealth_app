// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChatMessage _$ChatMessageFromJson(Map<String, dynamic> json) => ChatMessage(
      id: (json['id'] as num).toInt(),
      message: json['message'] as String,
      response: json['response'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      userId: (json['user_id'] as num).toInt(),
    );

Map<String, dynamic> _$ChatMessageToJson(ChatMessage instance) =>
    <String, dynamic>{
      'id': instance.id,
      'message': instance.message,
      'response': instance.response,
      'created_at': instance.createdAt.toIso8601String(),
      'user_id': instance.userId,
    };

ChatMessageCreate _$ChatMessageCreateFromJson(Map<String, dynamic> json) =>
    ChatMessageCreate(
      message: json['message'] as String,
    );

Map<String, dynamic> _$ChatMessageCreateToJson(ChatMessageCreate instance) =>
    <String, dynamic>{
      'message': instance.message,
    };

SentimentAnalysis _$SentimentAnalysisFromJson(Map<String, dynamic> json) =>
    SentimentAnalysis(
      score: (json['score'] as num).toDouble(),
      polarity: (json['polarity'] as num).toDouble(),
      subjectivity: (json['subjectivity'] as num).toDouble(),
      classification: json['classification'] as String,
      confidence: (json['confidence'] as num).toDouble(),
      keywordsFound: (json['keywords_found'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$SentimentAnalysisToJson(SentimentAnalysis instance) =>
    <String, dynamic>{
      'score': instance.score,
      'polarity': instance.polarity,
      'subjectivity': instance.subjectivity,
      'classification': instance.classification,
      'confidence': instance.confidence,
      'keywords_found': instance.keywordsFound,
    };

ChatResponse _$ChatResponseFromJson(Map<String, dynamic> json) => ChatResponse(
      response: json['response'] as String,
      sentimentAnalysis: SentimentAnalysis.fromJson(
          json['sentiment_analysis'] as Map<String, dynamic>),
      chatId: (json['chat_id'] as num).toInt(),
    );

Map<String, dynamic> _$ChatResponseToJson(ChatResponse instance) =>
    <String, dynamic>{
      'response': instance.response,
      'sentiment_analysis': instance.sentimentAnalysis,
      'chat_id': instance.chatId,
    };

EmotionScore _$EmotionScoreFromJson(Map<String, dynamic> json) => EmotionScore(
      score: (json['score'] as num).toDouble(),
      date: DateTime.parse(json['date'] as String),
      contentType: json['content_type'] as String,
      contentId: (json['content_id'] as num).toInt(),
    );

Map<String, dynamic> _$EmotionScoreToJson(EmotionScore instance) =>
    <String, dynamic>{
      'score': instance.score,
      'date': instance.date.toIso8601String(),
      'content_type': instance.contentType,
      'content_id': instance.contentId,
    };

EmotionTrend _$EmotionTrendFromJson(Map<String, dynamic> json) => EmotionTrend(
      trend: json['trend'] as String,
      average: (json['average'] as num).toDouble(),
      volatility: (json['volatility'] as num).toDouble(),
      totalEntries: (json['total_entries'] as num).toInt(),
      classification: json['classification'] as String,
      scores: (json['scores'] as List<dynamic>)
          .map((e) => EmotionScore.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$EmotionTrendToJson(EmotionTrend instance) =>
    <String, dynamic>{
      'trend': instance.trend,
      'average': instance.average,
      'volatility': instance.volatility,
      'total_entries': instance.totalEntries,
      'classification': instance.classification,
      'scores': instance.scores,
    };
