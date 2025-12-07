import 'package:flutter/material.dart';
import '../models/ai_models.dart';
import '../utils/app_theme.dart';

class PredictiveInsightsWidget extends StatelessWidget {
  final List<BusinessInsight> insights;
  final bool isLoading;
  final String? error;
  final VoidCallback? onRefresh;
  final Function(BusinessInsight)? onInsightTap;

  const PredictiveInsightsWidget({
    super.key,
    required this.insights,
    this.isLoading = false,
    this.error,
    this.onRefresh,
    this.onInsightTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            const SizedBox(height: 16),
            if (isLoading)
              _buildLoadingState()
            else if (error != null)
              _buildErrorState(context)
            else if (insights.isEmpty)
              _buildEmptyState()
            else
              _buildInsightsList(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.insights, color: AppTheme.primaryColor, size: 24),
        const SizedBox(width: 8),
        const Expanded(
          child: Text(
            'AI Business Insights',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        if (onRefresh != null)
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: onRefresh,
            tooltip: 'Refresh insights',
          ),
      ],
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Analyzing your business data...'),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              error!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
            if (onRefresh != null) ...[
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: onRefresh,
                child: const Text('Try Again'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            const Icon(Icons.lightbulb_outline, size: 48, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'No insights available',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            const Text(
              'Add more transactions to get AI-powered insights',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInsightsList() {
    return Column(
      children:
          insights
              .take(3)
              .map((insight) => _buildInsightCard(insight))
              .toList(),
    );
  }

  Widget _buildInsightCard(BusinessInsight insight) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => onInsightTap?.call(insight),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
            color: _getInsightBackgroundColor(insight.type),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    _getInsightIcon(insight.type),
                    color: _getInsightColor(insight.type),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      insight.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  _buildImpactBadge(insight.impactScore ?? 0.0),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                insight.description,
                style: const TextStyle(color: Colors.grey, fontSize: 13),
              ),
              if (insight.recommendations.isNotEmpty) ...[
                const SizedBox(height: 8),
                ...insight.recommendations
                    .take(2)
                    .map(
                      (recommendation) => Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.arrow_right,
                              size: 16,
                              color: Colors.grey,
                            ),
                            Expanded(
                              child: Text(
                                recommendation,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImpactBadge(double impactScore) {
    Color badgeColor;
    String badgeText;

    if (impactScore >= 0.8) {
      badgeColor = AppTheme.errorColor;
      badgeText = 'High';
    } else if (impactScore >= 0.5) {
      badgeColor = Colors.orange;
      badgeText = 'Medium';
    } else {
      badgeColor = AppTheme.successColor;
      badgeText = 'Low';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: badgeColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: badgeColor.withValues(alpha: 0.3)),
      ),
      child: Text(
        badgeText,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: badgeColor,
        ),
      ),
    );
  }

  Color _getInsightBackgroundColor(InsightType type) {
    switch (type) {
      case InsightType.cashFlowPrediction:
        return Colors.blue.withValues(alpha: 0.05);
      case InsightType.customerAnalysis:
        return Colors.green.withValues(alpha: 0.05);
      case InsightType.workingCapital:
        return Colors.orange.withValues(alpha: 0.05);
      case InsightType.expenseTrend:
        return Colors.red.withValues(alpha: 0.05);
      case InsightType.revenueForecast:
        return Colors.purple.withValues(alpha: 0.05);
      case InsightType.general:
        return Colors.grey.withValues(alpha: 0.05);
    }
  }

  Color _getInsightColor(InsightType type) {
    switch (type) {
      case InsightType.cashFlowPrediction:
        return Colors.blue;
      case InsightType.customerAnalysis:
        return Colors.green;
      case InsightType.workingCapital:
        return Colors.orange;
      case InsightType.expenseTrend:
        return Colors.red;
      case InsightType.revenueForecast:
        return Colors.purple;
      case InsightType.general:
        return Colors.grey;
    }
  }

  IconData _getInsightIcon(InsightType type) {
    switch (type) {
      case InsightType.cashFlowPrediction:
        return Icons.trending_up;
      case InsightType.customerAnalysis:
        return Icons.people;
      case InsightType.workingCapital:
        return Icons.account_balance;
      case InsightType.expenseTrend:
        return Icons.warning;
      case InsightType.revenueForecast:
        return Icons.trending_up;
      case InsightType.general:
        return Icons.info;
    }
  }
}
