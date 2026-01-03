import 'dart:html' as html;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/responsive/responsive_layout.dart';
import '../../core/responsive/responsive_breakpoints.dart';
import '../../providers/business_provider.dart';
import '../../services/ai_client_service.dart';
import '../../models/ai_models.dart';
import '../../screens/autopilot/autopilot_chat_screen.dart';

/// Web-optimized AI Autopilot screen with chat interface, insights, and automation controls
/// Falls back to mobile autopilot on non-web platforms
class WebAutopilotScreen extends StatefulWidget {
  const WebAutopilotScreen({super.key});

  @override
  State<WebAutopilotScreen> createState() => _WebAutopilotScreenState();
}

class _WebAutopilotScreenState extends State<WebAutopilotScreen> {
  final AIClientService _aiService = AIClientService();
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _chatScrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  
  bool _isLoading = false;
  bool _isListening = false;
  bool _isServiceAvailable = false;
  BusinessInsightsResponse? _insights;
  html.SpeechRecognition? _speechRecognition;

  @override
  void initState() {
    super.initState();
    _initializeService();
    _initializeSpeechRecognition();
  }

  Future<void> _initializeService() async {
    try {
      await _aiService.initialize();
      final isAvailable = await _aiService.isServiceAvailable();
      if (mounted) {
        setState(() {
          _isServiceAvailable = isAvailable;
        });
      }
      
      if (isAvailable) {
        await _loadInsights();
      }
    } catch (e) {
    }
  }

  void _initializeSpeechRecognition() {
    if (!kIsWeb) return;
    
    try {
      _speechRecognition = html.SpeechRecognition();
      _speechRecognition!.continuous = false;
      _speechRecognition!.interimResults = false;
      _speechRecognition!.lang = 'en-US';
      
      _speechRecognition!.onResult.listen((event) {
        final results = event.results;
        if (results != null && results.isNotEmpty) {
          final result = results.last;
          if (result.length != null && result.length! > 0) {
            final transcript = result.item(0).transcript ?? '';
            if (mounted) {
              setState(() {
                _messageController.text = transcript;
              });
            }
          }
        }
      });
      
      _speechRecognition!.onEnd.listen((_) {
        if (mounted) {
          setState(() {
            _isListening = false;
          });
        }
      });
      
      _speechRecognition!.onError.listen((error) {
        if (mounted) {
          setState(() {
            _isListening = false;
          });
        }
      });
    } catch (e) {
    }
  }

  Future<void> _loadInsights() async {
    final businessProvider = Provider.of<BusinessProvider>(context, listen: false);
    if (businessProvider.business == null) return;
    
    try {
      final insights = await _aiService.getPredictiveInsights(
        businessProvider.business!.id,
      );
      if (mounted) {
        setState(() {
          _insights = insights;
        });
      }
    } catch (e) {
    }
  }

  void _toggleVoiceInput() {
    if (_speechRecognition == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Voice input is not supported in this browser'),
        ),
      );
      return;
    }
    
    setState(() {
      _isListening = !_isListening;
    });
    
    if (_isListening) {
      _speechRecognition!.start();
    } else {
      _speechRecognition!.stop();
    }
  }

  Future<void> _sendMessage() async {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;
    
    final businessProvider = Provider.of<BusinessProvider>(context, listen: false);
    if (businessProvider.business == null) return;
    
    setState(() {
      _messages.add(ChatMessage(
        text: message,
        isUser: true,
        timestamp: DateTime.now(),
      ));
      _messageController.clear();
      _isLoading = true;
    });
    
    _scrollToBottom();
    
    try {
      final response = await _aiService.generateText(
        message,
        context: {
          'business_id': businessProvider.business!.id,
          'business_name': businessProvider.business!.name,
        },
      );
      
      if (mounted) {
        setState(() {
          _messages.add(ChatMessage(
            text: response,
            isUser: false,
            timestamp: DateTime.now(),
          ));
          _isLoading = false;
        });
        _scrollToBottom();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _messages.add(ChatMessage(
            text: 'Sorry, I encountered an error. Please try again.',
            isUser: false,
            timestamp: DateTime.now(),
            isError: true,
          ));
          _isLoading = false;
        });
      }
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_chatScrollController.hasClients) {
        _chatScrollController.animateTo(
          _chatScrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _chatScrollController.dispose();
    _speechRecognition?.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Use mobile autopilot for non-web platforms
    if (!kIsWeb) {
      return const AutoPilotChatScreen();
    }

    return ResponsiveLayout(
      mobile: _buildMobileLayout(),
      tablet: _buildTabletLayout(),
      desktop: _buildDesktopLayout(),
    );
  }

  Widget _buildMobileLayout() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Autopilot'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Column(
        children: [
          Expanded(child: _buildChatInterface()),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildTabletLayout() {
    return Scaffold(
      body: Row(
        children: [
          Expanded(
            flex: 2,
            child: Column(
              children: [
                Expanded(child: _buildChatInterface()),
                _buildMessageInput(),
              ],
            ),
          ),
          Expanded(
            child: _buildInsightsPanel(),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isLargeDesktop = ResponsiveBreakpoints.isLargeDesktop(constraints.maxWidth);
        
        return Row(
          children: [
            // Chat interface - main area
            Expanded(
              flex: isLargeDesktop ? 5 : 4,
              child: Column(
                children: [
                  _buildChatHeader(),
                  Expanded(child: _buildChatInterface()),
                  _buildMessageInput(),
                ],
              ),
            ),
            
            // Insights and controls sidebar
            Expanded(
              flex: 3,
              child: _buildInsightsPanel(),
            ),
            
            // Conversation history - only on large desktop
            if (isLargeDesktop)
              Expanded(
                flex: 2,
                child: _buildConversationHistory(),
              ),
          ],
        );
      },
    );
  }

  Widget _buildChatHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.deepPurple.shade50,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade300),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.deepPurple,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.smart_toy,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'AI Autopilot',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: _isServiceAvailable ? Colors.green : Colors.red,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _isServiceAvailable ? 'Online' : 'Offline',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatInterface() {
    if (_messages.isEmpty) {
      return _buildEmptyState();
    }
    
    return Container(
      color: Colors.grey.shade50,
      child: ListView.builder(
        controller: _chatScrollController,
        padding: const EdgeInsets.all(24),
        itemCount: _messages.length + (_isLoading ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == _messages.length) {
            return _buildTypingIndicator();
          }
          return _buildMessageBubble(_messages[index]);
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 24),
          Text(
            'Start a conversation',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Ask me anything about your business',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 32),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            alignment: WrapAlignment.center,
            children: [
              _buildSuggestionChip('Show me today\'s revenue'),
              _buildSuggestionChip('Who are my top customers?'),
              _buildSuggestionChip('What invoices are overdue?'),
              _buildSuggestionChip('Analyze my cash flow'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionChip(String text) {
    return ActionChip(
      label: Text(text),
      onPressed: () {
        _messageController.text = text;
        _sendMessage();
      },
      backgroundColor: Colors.deepPurple.shade50,
      labelStyle: TextStyle(color: Colors.deepPurple.shade700),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints: const BoxConstraints(maxWidth: 600),
        decoration: BoxDecoration(
          color: message.isUser
              ? Colors.deepPurple
              : message.isError
                  ? Colors.red.shade50
                  : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message.text,
              style: TextStyle(
                color: message.isUser
                    ? Colors.white
                    : message.isError
                        ? Colors.red.shade900
                        : Colors.black87,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _formatTime(message.timestamp),
              style: TextStyle(
                color: message.isUser
                    ? Colors.white70
                    : Colors.grey.shade600,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDot(0),
            const SizedBox(width: 4),
            _buildDot(1),
            const SizedBox(width: 4),
            _buildDot(2),
          ],
        ),
      ),
    );
  }

  Widget _buildDot(int index) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 600),
      builder: (context, value, child) {
        final delay = index * 0.2;
        final animValue = (value - delay).clamp(0.0, 1.0);
        return Opacity(
          opacity: 0.3 + (animValue * 0.7),
          child: Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: Colors.deepPurple,
              shape: BoxShape.circle,
            ),
          ),
        );
      },
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Colors.grey.shade300),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: 'Type your message...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: const BorderSide(color: Colors.deepPurple),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
              ),
              onSubmitted: (_) => _sendMessage(),
              maxLines: null,
            ),
          ),
          const SizedBox(width: 12),
          IconButton(
            onPressed: _toggleVoiceInput,
            icon: Icon(
              _isListening ? Icons.mic : Icons.mic_none,
              color: _isListening ? Colors.red : Colors.deepPurple,
            ),
            tooltip: 'Voice input',
            iconSize: 28,
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: _isLoading ? null : _sendMessage,
            icon: const Icon(Icons.send),
            color: Colors.deepPurple,
            tooltip: 'Send message',
            iconSize: 28,
          ),
        ],
      ),
    );
  }

  Widget _buildInsightsPanel() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          left: BorderSide(color: Colors.grey.shade300),
        ),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Business Insights',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            if (_insights != null && _insights!.insights.isNotEmpty)
              ..._insights!.insights.map((insight) => _buildInsightCard(insight))
            else
              _buildLoadingInsights(),
            const SizedBox(height: 32),
            const Text(
              'Automation Controls',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildAutomationControls(),
          ],
        ),
      ),
    );
  }

  Widget _buildInsightCard(BusinessInsight insight) {
    IconData icon;
    Color color;
    
    switch (insight.type) {
      case InsightType.cashFlowPrediction:
        icon = Icons.account_balance_wallet;
        color = Colors.blue;
        break;
      case InsightType.revenueForecast:
        icon = Icons.trending_up;
        color = Colors.green;
        break;
      case InsightType.expenseTrend:
        icon = Icons.trending_down;
        color = Colors.orange;
        break;
      case InsightType.customerAnalysis:
        icon = Icons.people;
        color = Colors.purple;
        break;
      case InsightType.workingCapital:
        icon = Icons.warning;
        color = Colors.red;
        break;
      default:
        icon = Icons.lightbulb;
        color = Colors.amber;
    }
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    insight.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              insight.description,
              style: TextStyle(
                color: Colors.grey.shade700,
                fontSize: 14,
              ),
            ),
            if (insight.recommendations.isNotEmpty) ...[
              const SizedBox(height: 12),
              ...insight.recommendations.map((rec) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.check_circle,
                      size: 16,
                      color: Colors.green.shade600,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        rec,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade800,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingInsights() {
    return Center(
      child: Column(
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(
            'Loading insights...',
            style: TextStyle(color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _buildAutomationControls() {
    return Column(
      children: [
        _buildAutomationToggle(
          'Auto Payment Reminders',
          'Automatically send reminders for overdue invoices',
          true,
          (value) {},
        ),
        _buildAutomationToggle(
          'Cash Flow Monitoring',
          'Monitor and alert on cash flow issues',
          true,
          (value) {},
        ),
        _buildAutomationToggle(
          'Smart Recommendations',
          'Get AI-powered business recommendations',
          true,
          (value) {},
        ),
        _buildAutomationToggle(
          'Fraud Detection',
          'Automatically detect suspicious transactions',
          false,
          (value) {},
        ),
      ],
    );
  }

  Widget _buildAutomationToggle(
    String title,
    String description,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            Switch(
              value: value,
              onChanged: onChanged,
              activeColor: Colors.deepPurple,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConversationHistory() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        border: Border(
          left: BorderSide(color: Colors.grey.shade300),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    'History',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: () {},
                  tooltip: 'Refresh',
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: 5,
              itemBuilder: (context, index) {
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: const Icon(Icons.chat_bubble_outline),
                    title: Text('Conversation ${index + 1}'),
                    subtitle: Text('${DateTime.now().subtract(Duration(days: index)).toString().split(' ')[0]}'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {},
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final bool isError;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.isError = false,
  });
}
