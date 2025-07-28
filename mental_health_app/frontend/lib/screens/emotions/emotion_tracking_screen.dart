import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/chat.dart';
import '../../services/api_service.dart';

class EmotionTrackingScreen extends StatefulWidget {
  const EmotionTrackingScreen({super.key});

  @override
  State<EmotionTrackingScreen> createState() => _EmotionTrackingScreenState();
}

class _EmotionTrackingScreenState extends State<EmotionTrackingScreen> {
  EmotionTrend? _emotionTrend;
  bool _isLoading = false;
  int _selectedDays = 30;
  final List<int> _dayOptions = [7, 14, 30, 90];

  @override
  void initState() {
    super.initState();
    _loadEmotionTrend();
  }

  Future<void> _loadEmotionTrend() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final trend = await ApiService.getEmotionTrend(days: _selectedDays);
      setState(() {
        _emotionTrend = trend;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load emotion data: $e')),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _getMoodEmoji(double score) {
    if (score >= 0.6) return '😄';
    if (score >= 0.2) return '😊';
    if (score >= -0.2) return '😐';
    if (score >= -0.6) return '😞';
    return '😢';
  }

  Color _getMoodColor(double score) {
    if (score >= 0.6) return Colors.green[600]!;
    if (score >= 0.2) return Colors.green[300]!;
    if (score >= -0.2) return Colors.orange[300]!;
    if (score >= -0.6) return Colors.red[300]!;
    return Colors.red[600]!;
  }

  String _getMoodLabel(double score) {
    if (score >= 0.6) return 'Very Positive';
    if (score >= 0.2) return 'Positive';
    if (score >= -0.2) return 'Neutral';
    if (score >= -0.6) return 'Negative';
    return 'Very Negative';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Emotion Tracking'),
        actions: [
          IconButton(
            onPressed: _loadEmotionTrend,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _emotionTrend == null || _emotionTrend!.scores.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: _loadEmotionTrend,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildTimeSelector(),
                        const SizedBox(height: 20),
                        _buildOverviewCards(),
                        const SizedBox(height: 20),
                        _buildTrendChart(),
                        const SizedBox(height: 20),
                        _buildInsights(),
                        const SizedBox(height: 20),
                        _buildRecentEntries(),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.analytics_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No emotion data yet',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start chatting or writing diary entries\nto track your emotional trends',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeSelector() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Time Period',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _dayOptions.map((days) {
                  final isSelected = days == _selectedDays;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text('${days}d'),
                      selected: isSelected,
                      onSelected: (selected) {
                        if (selected) {
                          setState(() {
                            _selectedDays = days;
                          });
                          _loadEmotionTrend();
                        }
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewCards() {
    if (_emotionTrend == null) return const SizedBox();

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Average Mood',
            _getMoodEmoji(_emotionTrend!.average),
            _getMoodLabel(_emotionTrend!.average),
            _getMoodColor(_emotionTrend!.average),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            'Trend',
            _emotionTrend!.trendIcon,
            _emotionTrend!.trendLabel,
            _getTrendColor(),
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String emoji, String value, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              emoji,
              style: const TextStyle(fontSize: 32),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: color,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Color _getTrendColor() {
    if (_emotionTrend?.trend == 'improving') return Colors.green;
    if (_emotionTrend?.trend == 'declining') return Colors.red;
    return Colors.blue;
  }

  Widget _buildTrendChart() {
    if (_emotionTrend == null || _emotionTrend!.scores.isEmpty) {
      return const SizedBox();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Mood Trend',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: _buildSimpleChart(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSimpleChart() {
    final scores = _emotionTrend!.scores.take(20).toList(); // Show last 20 entries
    if (scores.isEmpty) return const SizedBox();

    return CustomPaint(
      painter: MoodChartPainter(scores),
      child: Container(),
    );
  }

  Widget _buildInsights() {
    if (_emotionTrend == null) return const SizedBox();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Insights',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _buildInsightRow(
              Icons.analytics,
              'Total Entries',
              '${_emotionTrend!.totalEntries}',
            ),
            _buildInsightRow(
              Icons.trending_up,
              'Volatility',
              '${(_emotionTrend!.volatility * 100).toStringAsFixed(1)}%',
            ),
            _buildInsightRow(
              Icons.category,
              'Classification',
              _emotionTrend!.classification,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInsightRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: TextStyle(color: Colors.grey[700]),
            ),
          ),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentEntries() {
    if (_emotionTrend == null || _emotionTrend!.scores.isEmpty) {
      return const SizedBox();
    }

    final recentScores = _emotionTrend!.scores.take(5).toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Recent Mood Entries',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ...recentScores.map((score) => _buildMoodEntry(score)),
          ],
        ),
      ),
    );
  }

  Widget _buildMoodEntry(EmotionScore score) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Text(
            _getMoodEmoji(score.score),
            style: const TextStyle(fontSize: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getMoodLabel(score.score),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${DateFormat('MMM d, HH:mm').format(score.date)} • ${score.contentType}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: _getMoodColor(score.score).withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              score.score.toStringAsFixed(2),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: _getMoodColor(score.score),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class MoodChartPainter extends CustomPainter {
  final List<EmotionScore> scores;

  MoodChartPainter(this.scores);

  @override
  void paint(Canvas canvas, Size size) {
    if (scores.isEmpty) return;

    final paint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final path = Path();
    final pointPaint = Paint()
      ..style = PaintingStyle.fill;

    final maxScore = 1.0;
    final minScore = -1.0;
    final scoreRange = maxScore - minScore;

    for (int i = 0; i < scores.length; i++) {
      final x = (i / (scores.length - 1)) * size.width;
      final normalizedScore = (scores[i].score - minScore) / scoreRange;
      final y = size.height - (normalizedScore * size.height);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }

      // Draw points
      pointPaint.color = _getColorForScore(scores[i].score);
      canvas.drawCircle(Offset(x, y), 4, pointPaint);
    }

    canvas.drawPath(path, paint);

    // Draw reference lines
    final linePaint = Paint()
      ..color = Colors.grey.withOpacity(0.3)
      ..strokeWidth = 1;

    // Zero line
    final zeroY = size.height - ((0 - minScore) / scoreRange * size.height);
    canvas.drawLine(Offset(0, zeroY), Offset(size.width, zeroY), linePaint);
  }

  Color _getColorForScore(double score) {
    if (score >= 0.6) return Colors.green[600]!;
    if (score >= 0.2) return Colors.green[300]!;
    if (score >= -0.2) return Colors.orange[300]!;
    if (score >= -0.6) return Colors.red[300]!;
    return Colors.red[600]!;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}