import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/providers/language_provider.dart';

class LiveChatPage extends StatefulWidget {
  const LiveChatPage({super.key});

  @override
  State<LiveChatPage> createState() => _LiveChatPageState();
}

class _LiveChatPageState extends State<LiveChatPage> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, dynamic>> _messages = [];

  @override
  void initState() {
    super.initState();
    // Simulate initial bot message
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final lang = Provider.of<LanguageProvider>(context, listen: false);
      setState(() {
        _messages.add({
          'text': lang.t('chat_greeting'),
          'isMe': false,
          'isAction': false,
        });
        // Quick Actions
        _messages.add({
          'text': lang.t('chat_quick_options'),
          'isMe': false,
          'isAction': true,
          'options': [
            {'icon': '📦', 'label': lang.t('help_orders')},
            {'icon': '💳', 'label': lang.t('help_payment')},
            {'icon': '🔄', 'label': lang.t('help_routine')},
            {'icon': '📍', 'label': 'Alamat'},
            {'icon': '', 'label': 'Lainnya'},
          ]
        });
      });
    });
  }

  void _sendMessage(String text) {
    if (text.trim().isEmpty) return;
    setState(() {
      _messages.add({
        'text': text,
        'isMe': true,
        'isAction': false,
      });
      _controller.clear();
    });

    // Simulate bot thinking then replying
    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;
      setState(() {
        _messages.add({
          'text': 'Mohon tunggu sebentar, CS kami akan segera membantu Anda. (Ini hanya simulasi chat)',
          'isMe': false,
          'isAction': false,
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const CircleAvatar(
              backgroundColor: Colors.white,
              radius: 16,
              child: Icon(Icons.support_agent, color: Colors.blue, size: 20),
            ),
            const SizedBox(width: 12),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('DepoSusu CS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Text('Online', style: TextStyle(fontSize: 12, color: Colors.green)),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                if (msg['isAction'] == true) {
                  return _buildActionChips(msg['options'] as List<Map<String, String>>);
                }
                return _buildChatBubble(msg['text'] as String, msg['isMe'] as bool);
              },
            ),
          ),
          _buildChatInput(lang),
        ],
      ),
    );
  }

  Widget _buildChatBubble(String text, bool isMe) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isMe ? Theme.of(context).primaryColor : Colors.grey.shade200,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: isMe ? const Radius.circular(16) : const Radius.circular(4),
            bottomRight: isMe ? const Radius.circular(4) : const Radius.circular(16),
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isMe ? Colors.white : Colors.black87,
            height: 1.4,
          ),
        ),
      ),
    );
  }

  Widget _buildActionChips(List<Map<String, String>> options) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: options.map((opt) {
          final label = opt['label']!;
          final icon = opt['icon']!;
          return ActionChip(
            label: Text(
              icon.isEmpty ? label : '$icon $label',
              style: TextStyle(color: Theme.of(context).primaryColor),
            ),
            backgroundColor: Colors.white,
            side: BorderSide(color: Theme.of(context).primaryColor),
            onPressed: () => _sendMessage(label),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildChatInput(LanguageProvider lang) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            offset: const Offset(0, -4),
            blurRadius: 16,
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                decoration: InputDecoration(
                  hintText: lang.t('chat_type_message'),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  fillColor: Colors.grey.shade100,
                  filled: true,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                onSubmitted: _sendMessage,
              ),
            ),
            const SizedBox(width: 8),
            CircleAvatar(
              backgroundColor: Theme.of(context).primaryColor,
              radius: 24,
              child: IconButton(
                icon: const Icon(Icons.send, color: Colors.white),
                onPressed: () => _sendMessage(_controller.text),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
