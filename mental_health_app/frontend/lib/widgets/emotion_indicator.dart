import 'package:flutter/material.dart';
import '../models/chat.dart';

class EmotionIndicator extends StatelessWidget {
  final SentimentAnalysis sentiment;
  final bool showDetails;

  const EmotionIndicator({
    super.key,
    required this.sentiment,
    this.showDetails = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _getBackgroundColor(),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _getBorderColor(), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Text(
                sentiment.emoji,
                style: const TextStyle(fontSize: 24),
              ),
              const SizedBox(width: 8),
              Text(
                sentiment.label,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: _getTextColor(),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getScoreColor(),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${(sentiment.score * 100).toInt()}%',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          if (showDetails) ...[
            const SizedBox(height: 12),
            _buildDetailRow('Polarity', sentiment.polarity, Icons.trending_flat),
            const SizedBox(height: 8),
            _buildDetailRow('Subjectivity', sentiment.subjectivity, Icons.person),
            const SizedBox(height: 8),
            _buildDetailRow('Confidence', sentiment.confidence, Icons.check_circle),
            if (sentiment.keywordsFound.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                'Keywords:',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: _getTextColor(),
                ),
              ),
              const SizedBox(height: 4),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: sentiment.keywordsFound.map((keyword) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      keyword,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black87,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, double value, IconData icon) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: _getTextColor().withOpacity(0.7),
        ),
        const SizedBox(width: 8),
        Text(
          '$label:',
          style: TextStyle(
            fontSize: 14,
            color: _getTextColor().withOpacity(0.7),
          ),
        ),
        const Spacer(),
        Container(
          width: 100,
          height: 6,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(3),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: value.abs().clamp(0.0, 1.0),
            child: Container(
              decoration: BoxDecoration(
                color: _getProgressColor(value),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 40,
          child: Text(
            value.toStringAsFixed(2),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: _getTextColor(),
            ),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }

  Color _getBackgroundColor() {
    switch (sentiment.classification) {
      case 'very_positive':
        return Colors.green[50]!;
      case 'positive':
        return Colors.lightGreen[50]!;
      case 'neutral':
        return Colors.grey[50]!;
      case 'negative':
        return Colors.orange[50]!;
      case 'very_negative':
        return Colors.red[50]!;
      default:
        return Colors.grey[50]!;
    }
  }

  Color _getBorderColor() {
    switch (sentiment.classification) {
      case 'very_positive':
        return Colors.green[200]!;
      case 'positive':
        return Colors.lightGreen[200]!;
      case 'neutral':
        return Colors.grey[300]!;
      case 'negative':
        return Colors.orange[200]!;
      case 'very_negative':
        return Colors.red[200]!;
      default:
        return Colors.grey[300]!;
    }
  }

  Color _getTextColor() {
    switch (sentiment.classification) {
      case 'very_positive':
        return Colors.green[800]!;
      case 'positive':
        return Colors.lightGreen[800]!;
      case 'neutral':
        return Colors.grey[800]!;
      case 'negative':
        return Colors.orange[800]!;
      case 'very_negative':
        return Colors.red[800]!;
      default:
        return Colors.grey[800]!;
    }
  }

  Color _getScoreColor() {
    switch (sentiment.classification) {
      case 'very_positive':
        return Colors.green;
      case 'positive':
        return Colors.lightGreen;
      case 'neutral':
        return Colors.grey;
      case 'negative':
        return Colors.orange;
      case 'very_negative':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Color _getProgressColor(double value) {
    if (value > 0.5) return Colors.green;
    if (value > 0) return Colors.lightGreen;
    if (value > -0.5) return Colors.orange;
    return Colors.red;
  }
}

class EmotionSummaryCard extends StatelessWidget {
  final EmotionTrend emotionTrend;

  const EmotionSummaryCard({
    super.key,
    required this.emotionTrend,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  emotionTrend.trendIcon,
                  style: const TextStyle(fontSize: 24),
                ),
                const SizedBox(width: 8),
                Text(
                  'Emotion Trend',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    'Trend',
                    emotionTrend.trendLabel,
                    Icons.trending_up,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    'Average',
                    emotionTrend.average.toStringAsFixed(1),
                    Icons.analytics,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    'Volatility',
                    emotionTrend.volatility.toStringAsFixed(1),
                    Icons.waves,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    'Entries',
                    emotionTrend.totalEntries.toString(),
                    Icons.message,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: Colors.grey[600]),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}