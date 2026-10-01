import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_bottom_nav_bar.dart';
import '../../../core/widgets/app_profile_avatar.dart';
import '../../../core/routing/app_navigation.dart';
import '../../../core/providers/cycle_provider.dart';

class _ChatMessage {
  final String text;
  final bool isUser;
  const _ChatMessage({required this.text, required this.isUser});
}

class LunaryAiScreen extends StatefulWidget {
  const LunaryAiScreen({Key? key}) : super(key: key);

  @override
  State<LunaryAiScreen> createState() => _LunaryAiScreenState();
}

class _LunaryAiScreenState extends State<LunaryAiScreen> {
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<_ChatMessage> _messages = [];
  bool _isTyping = false;

  static const List<String> _suggestions = [
    'What phase am I in?',
    'When is my next period?',
    'Am I fertile now?',
    'How to relieve cramps?',
    'Foods for my phase',
    'Help with mood swings',
  ];

  @override
  void initState() {
    super.initState();
    _messages.add(const _ChatMessage(
      isUser: false,
      text: "Hi Awa! I'm Lunary AI 🌙\n\nAsk me anything about your cycle, symptoms, nutrition, or mood. Tap a suggestion below to get started.",
    ));
  }

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  Future<void> _send(String raw) async {
    final text = raw.trim();
    if (text.isEmpty || _isTyping) return;

    setState(() {
      _messages.add(_ChatMessage(text: text, isUser: true));
      _isTyping = true;
    });
    _inputController.clear();
    _scrollToBottom();

    // Simulasi AI "berpikir"
    await Future.delayed(const Duration(milliseconds: 1400));
    if (!mounted) return;

    final reply = _generateReply(text);
    setState(() {
      _isTyping = false;
      _messages.add(_ChatMessage(text: reply, isUser: false));
    });
    _scrollToBottom();
  }

  bool _has(String text, List<String> keys) => keys.any((k) => text.contains(k));

  String _phaseTip(CyclePhase phase) {
    switch (phase) {
      case CyclePhase.period:
        return 'Rest when you need to, stay warm, and eat iron-rich foods like spinach and lentils.';
      case CyclePhase.follicular:
        return 'Your energy is rising. It is a great time for workouts and starting new things.';
      case CyclePhase.fertile:
        return 'You are in your fertile window, and your energy is usually at its peak.';
      case CyclePhase.luteal:
        return 'Progesterone is higher now. Prioritize sleep, magnesium-rich snacks, and gentle exercise.';
      case CyclePhase.none:
        return 'Log your period in the Calendar tab so I can personalize my answers.';
    }
  }

  String _generateReply(String input) {
    final cycle = context.read<CycleProvider>();
    final t = input.toLowerCase();
    final hasData = cycle.hasCycleData;
    final phase = cycle.currentPhase;
    final label = cycle.currentPhaseLabel;
    final day = cycle.currentCycleDay;
    final daysLeft = cycle.daysUntilNextPeriod;

    if (_has(t, ['phase', 'fase', 'where am i', 'today'])) {
      if (!hasData) {
        return "I don't have any cycle data yet. Log your period in the Calendar tab and I'll tell you exactly which phase you're in.";
      }
      return "Right now you're in the $label, on day $day of your cycle.\n\n${_phaseTip(phase)}";
    }

    if (_has(t, ['next period', 'when is my', 'haid', 'late', 'due'])) {
      if (!hasData || daysLeft == null) {
        return "I can't predict your next period yet. Log your last period in the Calendar tab first.";
      }
      if (daysLeft == 0) {
        return 'Your next period is expected today. Keep supplies handy and take it easy 💜';
      }
      return 'Your next period is predicted in about $daysLeft day${daysLeft == 1 ? '' : 's'}. Predictions get more accurate the more cycles you log.';
    }

    if (_has(t, ['fertile', 'pregnan', 'ovulat', 'subur', 'hamil'])) {
      if (!hasData) {
        return 'Log your period first, then I can estimate your fertile window.';
      }
      if (phase == CyclePhase.fertile) {
        return "Yes, you're in your fertile window right now, so the chance of getting pregnant is high. Ovulation is usually around the middle of the window.";
      }
      return "You're in the $label, so the chance of getting pregnant is low right now. Remember this is only an estimate, not a contraceptive method.";
    }

    if (_has(t, ['cramp', 'pain', 'kram', 'nyeri', 'hurt', 'ache'])) {
      return 'To ease period cramps you can try:\n\n'
          '• A warm compress on your lower belly for 15–20 minutes\n'
          '• Warm ginger or chamomile tea\n'
          '• Gentle stretches like Child\'s Pose or Cat-Cow\n'
          '• Staying hydrated\n\n'
          'If the pain is severe or stops you from doing daily activities, please see a doctor.';
    }

    if (_has(t, ['food', 'eat', 'diet', 'nutrition', 'makan', 'nutrisi'])) {
      switch (phase) {
        case CyclePhase.period:
          return 'During your period, focus on iron: spinach, lean meat, lentils, and eggs. Pair them with vitamin C (oranges, tomatoes) to help absorption.';
        case CyclePhase.follicular:
          return 'In the follicular phase, go for fresh vegetables, whole grains, and fermented foods to support rising estrogen.';
        case CyclePhase.fertile:
          return 'Around ovulation, light and fiber-rich meals work well: leafy greens, berries, nuts, and plenty of water.';
        case CyclePhase.luteal:
          return 'In the luteal phase, magnesium helps: dark chocolate, bananas, avocado, and nuts. Cut back on caffeine and sugar to ease PMS.';
        case CyclePhase.none:
          return 'A balanced plate with iron, magnesium, and omega-3 (salmon, chia seeds) supports your cycle. Log your period and I can tailor this to your phase.';
      }
    }

    if (_has(t, ['mood', 'sad', 'anxious', 'anxiety', 'stress', 'emotion', 'irritable', 'pms'])) {
      return 'Hormone shifts can really affect your mood, and what you feel is valid 💜\n\n'
          '• Take a 20-minute walk to boost endorphins\n'
          '• Limit caffeine and sugar\n'
          '• Aim for 7–8 hours of sleep\n'
          '• Journal or talk to someone you trust\n\n'
          'If low mood lasts for weeks, consider talking to a professional.';
    }

    if (_has(t, ['exercise', 'workout', 'yoga', 'sport', 'olahraga'])) {
      return 'Match your workout to your phase:\n\n'
          '• Period: gentle yoga or walking\n'
          '• Follicular: strength training and cardio\n'
          '• Fertile: high-energy workouts\n'
          '• Luteal: pilates, swimming, or light cardio\n\n'
          'Right now (${hasData ? label : 'no data'}): ${_phaseTip(phase)}';
    }

    if (_has(t, ['sleep', 'tired', 'fatigue', 'tidur', 'lelah'])) {
      return 'Feeling tired is common, especially during your period and the late luteal phase. Keep a regular sleep schedule, avoid screens before bed, and eat iron-rich foods. If you feel extremely exhausted, a doctor can check for iron deficiency.';
    }

    if (_has(t, ['hello', 'hi', 'hey', 'halo', 'thanks', 'thank'])) {
      return "Hi Awa! 🌙 I'm here whenever you need me. Ask me about your phase, period prediction, cramps, food, or mood.";
    }

    return "That's a good question! I'm still learning, so my answers are simulated for now. Try asking about your phase, next period, fertile window, cramps, nutrition, or mood.";
  }

  @override
  Widget build(BuildContext context) {
    final keyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(child: _buildMessageList()),
              _buildSuggestions(),
              _buildInputBar(),
              if (!keyboardOpen)
                AppBottomNavBar(
                  currentTab: AppNavTab.lunaryAi,
                  onTabSelected: (tab) {
                    if (tab == AppNavTab.lunaryAi) return;
                    handleAppNavTap(context, tab);
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      child: Row(
        children: [
          _aiAvatar(size: 44),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Lunary AI',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkText,
                    letterSpacing: -0.5,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Demo mode • not medical advice',
                  style: TextStyle(fontSize: 12, color: AppColors.darkerSubText),
                ),
              ],
            ),
          ),
          AppProfileAvatar(onTap: () => handleAppNavTap(context, AppNavTab.profile)),
        ],
      ),
    );
  }

  Widget _aiAvatar({double size = 32}) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [AppColors.primaryPink, AppColors.primaryPurple],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: SizedBox(
          width: size * 0.5,
          height: size * 0.5,
          child: CustomPaint(
            painter: LunaryCrescentPainter(baseColor: Colors.white),
          ),
        ),
      ),
    );
  }

  Widget _buildMessageList() {
    final itemCount = _messages.length + (_isTyping ? 1 : 0);

    return ListView.builder(
      controller: _scrollController,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        if (index == _messages.length) return _buildTypingBubble();
        return _buildBubble(_messages[index]);
      },
    );
  }

  Widget _buildBubble(_ChatMessage msg) {
    final isUser = msg.isUser;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser) ...[
            _aiAvatar(),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
              decoration: BoxDecoration(
                color: isUser ? AppColors.primaryPink : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(20),
                  topRight: const Radius.circular(20),
                  bottomLeft: Radius.circular(isUser ? 20 : 6),
                  bottomRight: Radius.circular(isUser ? 6 : 20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Text(
                msg.text,
                style: TextStyle(
                  fontSize: 14,
                  height: 1.4,
                  color: isUser ? Colors.white : AppColors.darkText,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypingBubble() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _aiAvatar(),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
                bottomLeft: Radius.circular(6),
                bottomRight: Radius.circular(20),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: const _TypingDots(),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestions() {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        itemCount: _suggestions.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          return GestureDetector(
            onTap: () => _send(_suggestions[i]),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.primaryPurple.withOpacity(0.3)),
              ),
              child: Text(
                _suggestions[i],
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryPurple,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInputBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(26),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: TextField(
                controller: _inputController,
                textInputAction: TextInputAction.send,
                onSubmitted: _send,
                style: const TextStyle(fontSize: 14, color: AppColors.darkText),
                decoration: const InputDecoration(
                  hintText: 'Ask Lunary AI...',
                  hintStyle: TextStyle(fontSize: 14, color: AppColors.subText),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: () => _send(_inputController.text),
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _isTyping ? AppColors.primaryPink.withOpacity(0.5) : AppColors.primaryPink,
              ),
              child: const Icon(Icons.send_rounded, color: Colors.white, size: 22),
            ),
          ),
        ],
      ),
    );
  }
}

/// Tiga titik animasi "sedang mengetik"
class _TypingDots extends StatefulWidget {
  const _TypingDots();

  @override
  State<_TypingDots> createState() => _TypingDotsState();
}

class _TypingDotsState extends State<_TypingDots> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (i) {
            final wave = (math.sin(_controller.value * 2 * math.pi - i * 0.9) + 1) / 2;
            return Container(
              width: 7,
              height: 7,
              margin: EdgeInsets.only(right: i == 2 ? 0 : 5),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primaryPurple.withOpacity(0.3 + 0.7 * wave),
              ),
            );
          }),
        );
      },
    );
  }
}