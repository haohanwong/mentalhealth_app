import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';

part 'chat.g.dart';

@JsonSerializable()
class ChatMessage extends Equatable {
  final int id;
  final String message;
  final String response;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'user_id')
  final int userId;

  const ChatMessage({
    required this.id,
    required this.message,
    required this.response,
    required this.createdAt,
    required this.userId,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) => _$ChatMessageFromJson(json);
  Map<String, dynamic> toJson() => _$ChatMessageToJson(this);

  @override
  List<Object> get props => [id, message, response, createdAt, userId];
}

@JsonSerializable()
class ChatMessageCreate {
  final String message;

  const ChatMessageCreate({
    required this.message,
  });

  factory ChatMessageCreate.fromJson(Map<String, dynamic> json) => _$ChatMessageCreateFromJson(json);
  Map<String, dynamic> toJson() => _$ChatMessageCreateToJson(this);
}

@JsonSerializable()
class SentimentAnalysis extends Equatable {
  final double score;
  final double polarity;
  final double subjectivity;
  final String classification;
  final double confidence;
  @JsonKey(name: 'keywords_found')
  final List<String> keywordsFound;

  const SentimentAnalysis({
    required this.score,
    required this.polarity,
    required this.subjectivity,
    required this.classification,
    required this.confidence,
    required this.keywordsFound,
  });

  factory SentimentAnalysis.fromJson(Map<String, dynamic> json) => _$SentimentAnalysisFromJson(json);
  Map<String, dynamic> toJson() => _$SentimentAnalysisToJson(this);

  @override
  List<Object> get props => [score, polarity, subjectivity, classification, confidence, keywordsFound];

  String get emoji {
    switch (classification) {
      case 'very_positive':
        return '😄';
      case 'positive':
        return '😊';
      case 'neutral':
        return '😐';
      case 'negative':
        return '😞';
      case 'very_negative':
        return '😢';
      default:
        return '😐';
    }
  }

  String get label {
    switch (classification) {
      case 'very_positive':
        return 'Very Positive';
      case 'positive':
        return 'Positive';
      case 'neutral':
        return 'Neutral';
      case 'negative':
        return 'Negative';
      case 'very_negative':
        return 'Very Negative';
      default:
        return 'Neutral';
    }
  }
}

@JsonSerializable()
class ChatResponse extends Equatable {
  final String response;
  @JsonKey(name: 'sentiment_analysis')
  final SentimentAnalysis sentimentAnalysis;
  @JsonKey(name: 'chat_id')
  final int chatId;

  const ChatResponse({
    required this.response,
    required this.sentimentAnalysis,
    required this.chatId,
  });

  factory ChatResponse.fromJson(Map<String, dynamic> json) => _$ChatResponseFromJson(json);
  Map<String, dynamic> toJson() => _$ChatResponseToJson(this);

  @override
  List<Object> get props => [response, sentimentAnalysis, chatId];
}

@JsonSerializable()
class EmotionScore extends Equatable {
  final double score;
  final DateTime date;
  @JsonKey(name: 'content_type')
  final String contentType;
  @JsonKey(name: 'content_id')
  final int contentId;

  const EmotionScore({
    required this.score,
    required this.date,
    required this.contentType,
    required this.contentId,
  });

  factory EmotionScore.fromJson(Map<String, dynamic> json) => _$EmotionScoreFromJson(json);
  Map<String, dynamic> toJson() => _$EmotionScoreToJson(this);

  @override
  List<Object> get props => [score, date, contentType, contentId];
}

@JsonSerializable()
class EmotionTrend extends Equatable {
  final String trend;
  final double average;
  final double volatility;
  @JsonKey(name: 'total_entries')
  final int totalEntries;
  final String classification;
  final List<EmotionScore> scores;

  const EmotionTrend({
    required this.trend,
    required this.average,
    required this.volatility,
    required this.totalEntries,
    required this.classification,
    required this.scores,
  });

  factory EmotionTrend.fromJson(Map<String, dynamic> json) => _$EmotionTrendFromJson(json);
  Map<String, dynamic> toJson() => _$EmotionTrendToJson(this);

  @override
  List<Object> get props => [trend, average, volatility, totalEntries, classification, scores];

  String get trendIcon {
    switch (trend) {
      case 'improving':
        return '📈';
      case 'declining':
        return '📉';
      case 'stable':
        return '➡️';
      default:
        return '❓';
    }
  }

  String get trendLabel {
    switch (trend) {
      case 'improving':
        return 'Improving';
      case 'declining':
        return 'Declining';
      case 'stable':
        return 'Stable';
      default:
        return 'Insufficient Data';
    }
  }
}