import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite/sqflite.dart';
import 'package:dio/dio.dart';
import 'package:smart_turakurgan/core/db/local_database.dart';
import 'package:smart_turakurgan/core/auth/auth_notifier.dart';
import 'package:smart_turakurgan/core/theme/colors.dart';
import 'package:smart_turakurgan/core/config/app_config.dart';
import 'package:smart_turakurgan/l10n/app_localizations.dart';

class AiMessage {
  final String role; // 'user' | 'model'
  final String content;
  const AiMessage({required this.role, required this.content});
}

final aiMessagesProvider = StateNotifierProvider<AiMessagesNotifier, List<AiMessage>>(
  AiMessagesNotifier.new,
);

class AiMessagesNotifier extends StateNotifier<List<AiMessage>> {
  final Ref ref;
  AiMessagesNotifier(this.ref) : super([]) {
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final db = await LocalDatabase.instance;
    final rows = await db.query(
      'ai_chat',
      orderBy: 'id ASC',
      limit: AppConfig.aiChatHistoryLimit,
    );
    state = rows.map((r) => AiMessage(role: r['role'] as String, content: r['content'] as String)).toList();
  }

  Future<void> sendMessage(String text) async {
    final userMsg = AiMessage(role: 'user', content: text);
    state = [...state, userMsg];

    // Save to local DB
    final db = await LocalDatabase.instance;
    await db.insert('ai_chat', {
      'role': 'user',
      'content': text,
      'created_at': DateTime.now().toIso8601String(),
    });
    await _trimHistory(db);

    // Call AI edge function
    try {
      final dio = ref.read(dioProvider);
      final history = state
          .where((m) => m.role != 'model' || state.indexOf(m) > state.length - 10)
          .map((m) => {'role': m.role, 'content': m.content})
          .toList();

      final resp = await dio.post('/ai-chat', data: {'messages': history});
      final reply = resp.data['reply'] as String? ?? 'Javob olinmadi.';

      final modelMsg = AiMessage(role: 'model', content: reply);
      state = [...state, modelMsg];

      await db.insert('ai_chat', {
        'role': 'model',
        'content': reply,
        'created_at': DateTime.now().toIso8601String(),
      });
      await _trimHistory(db);
    } catch (e) {
      String errText = 'Xatolik yuz berdi. Internet aloqasini tekshiring.';
      if (e is DioException) {
        final status = e.response?.statusCode;
        if (status == 401 || status == 403) {
          errText = 'Autentifikatsiya xatosi. Iltimos, qayta kiring.';
        } else if (status == 429) {
          errText = 'AI xizmati hozirda band. Bir oz kutib, qayta urinib ko\'ring.';
        } else if (status != null && status >= 500) {
          errText = 'Server xatosi ($status). Birozdan keyin qayta urinib ko\'ring.';
        }
      }
      final errMsg = AiMessage(role: 'model', content: errText);
      state = [...state, errMsg];
    }
  }

  Future<void> _trimHistory(Database db) async {
    final count = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM ai_chat'));
    if ((count ?? 0) > AppConfig.aiChatHistoryLimit) {
      await db.rawDelete(
          'DELETE FROM ai_chat WHERE id IN (SELECT id FROM ai_chat ORDER BY id ASC LIMIT ?)',
          [(count! - AppConfig.aiChatHistoryLimit)]);
    }
  }

  Future<void> clear() async {
    final db = await LocalDatabase.instance;
    await db.delete('ai_chat');
    state = [];
  }
}

class AiAssistantScreen extends ConsumerStatefulWidget {
  const AiAssistantScreen({super.key});

  @override
  ConsumerState<AiAssistantScreen> createState() => _AiAssistantScreenState();
}

class _AiAssistantScreenState extends ConsumerState<AiAssistantScreen> {
  final _ctrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  bool _sending = false;

  static const _quickQuestions = [
    'aiQuick1',
    'aiQuick2',
    'aiQuick3',
  ];

  List<String> _localizedQuickQuestions(AppLocalizations l10n) => [
    l10n.aiQuick1,
    l10n.aiQuick2,
    l10n.aiQuick3,
  ];

  @override
  void dispose() {
    _ctrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  Future<void> _send(String text) async {
    if (text.trim().isEmpty) return;
    _ctrl.clear();
    setState(() => _sending = true);
    await ref.read(aiMessagesProvider.notifier).sendMessage(text);
    if (mounted) setState(() => _sending = false);
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final messages = ref.watch(aiMessagesProvider);
    final l10n = AppLocalizations.of(context);
    final quickQs = _localizedQuickQuestions(l10n);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.aiAssistant),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () => ref.read(aiMessagesProvider.notifier).clear(),
            tooltip: 'Tarixni tozalash',
          ),
        ],
      ),
      backgroundColor: kColorCream,
      body: Column(
        children: [
          // Quick questions
          if (messages.isEmpty)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.auto_awesome, size: 48, color: kColorPrimary),
                    const SizedBox(height: 12),
                    Text(l10n.aiAssistant,
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500, color: kColorInk)),
                    const SizedBox(height: 6),
                    const Text('Turakurgan tumani bo\'yicha savollaringizga javob beraman',
                        style: TextStyle(fontSize: 13, color: kColorTextMuted),
                        textAlign: TextAlign.center),
                    const SizedBox(height: 28),
                    ...quickQs.map((q) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: GestureDetector(
                            onTap: () => _send(q),
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              decoration: BoxDecoration(
                                color: kColorWhite,
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: const [
                                  BoxShadow(color: Color(0x0C000000), blurRadius: 10, offset: Offset(0, 3)),
                                ],
                              ),
                              child: Text(q,
                                  style: const TextStyle(fontSize: 14, color: kColorInk)),
                            ),
                          ),
                        )),
                  ],
                ),
              ),
            )
          else
            Expanded(
              child: ListView.builder(
                controller: _scrollCtrl,
                padding: const EdgeInsets.all(16),
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  final msg = messages[index];
                  return _ChatBubble(message: msg);
                },
              ),
            ),
          if (_sending)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Row(children: [
                SizedBox(
                  width: 20, height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: kColorPrimary),
                ),
                SizedBox(width: 8),
                Text('Javob yozilmoqda...', style: TextStyle(fontSize: 13, color: kColorTextMuted)),
              ]),
            ),
          // Input bar
          Container(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
            decoration: const BoxDecoration(
              color: kColorWhite,
              border: Border(top: BorderSide(color: kColorStone, width: 0.5)),
            ),
            child: SafeArea(
              top: false,
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _ctrl,
                      textInputAction: TextInputAction.send,
                      onSubmitted: _send,
                      decoration: InputDecoration(
                        hintText: l10n.aiHint,
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
                        isDense: true,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: _sending ? null : () => _send(_ctrl.text),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: kColorPrimary,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.send, color: kColorWhite, size: 18),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  final AiMessage message;
  const _ChatBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final isUser = message.role == 'user';
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isUser ? kColorPrimary : kColorWhite,
          borderRadius: BorderRadius.circular(12),
          boxShadow: isUser ? null : [
            const BoxShadow(color: Color(0x0C000000), blurRadius: 10, offset: Offset(0, 3)),
          ],
        ),
        child: Text(
          message.content,
          style: TextStyle(
            fontSize: 14,
            color: isUser ? kColorWhite : kColorInk,
            height: 1.5,
          ),
        ),
      ),
    );
  }
}
