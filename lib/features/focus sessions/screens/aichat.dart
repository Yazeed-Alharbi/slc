import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:slc/common/styles/colors.dart';
import 'package:slc/common/widgets/nativealertdialog.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
// A simple chat message model.
class ChatMessage {
  final String content;
  final String sender; // 'user' or 'ai'
  final AnimationController?
      animationController; // Add controller for animations
  ChatMessage({
    required this.content,
    required this.sender,
    this.animationController,
  });
}

class AiChatScreen extends StatefulWidget {
  const AiChatScreen({Key? key}) : super(key: key);

  @override
  _AiChatScreenState createState() => _AiChatScreenState();
}

class _AiChatScreenState extends State<AiChatScreen>
    with TickerProviderStateMixin {
  final List<ChatMessage> _messages = [];
  bool _isTyping = false;
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  AnimationController? _typingDotsController;

  // Remove hardcoded colors - we'll use theme colors instead
  late Color _primaryColor;
  late Color _secondaryColor;
  late Color _backgroundColor;
  late Color _textOnPrimaryColor;
  late Color _textOnSecondaryColor;

  @override
  void initState() {
    super.initState();
    // Create controller for typing dots
    _typingDotsController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Get colors from theme
    _primaryColor = Theme.of(context).colorScheme.primary;
    _secondaryColor = Theme.of(context).colorScheme.surfaceVariant;
    _backgroundColor = Theme.of(context).scaffoldBackgroundColor;
    _textOnPrimaryColor = Theme.of(context).colorScheme.onPrimary;
    _textOnSecondaryColor = Theme.of(context).colorScheme.onSurfaceVariant;
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    _typingDotsController?.dispose();

    // Dispose all message animation controllers
    for (var message in _messages) {
      message.animationController?.dispose();
    }

    super.dispose();
  }

  // Create a message with animation controller
  ChatMessage _createAnimatedMessage(String text, String sender) {
    final controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 700),
    );

    final message = ChatMessage(
      content: text,
      sender: sender,
      animationController: controller,
    );

    // Start the animation
    controller.forward();
    return message;
  }

  // Sends a message to OpenAI API and appends the response.
  Future<void> _sendMessage({String? text}) async {
    if (text == null || text.trim().isEmpty) return;

    // Append the user's message with animation
    final userMessage = _createAnimatedMessage(text.trim(), 'user');

    setState(() {
      _messages.add(userMessage);
      _isTyping = true;
    });

    // Scroll after adding the user's message and typing indicator
    _scrollToBottom();

    final apiKey = dotenv.env['OPENAI_API_KEY'] ?? '';
    // Build conversation history formatted for the API.
    final List<Map<String, String>> conversation = _messages.map((m) {
      return {
        'role': m.sender == 'user' ? 'user' : 'assistant',
        'content': m.content,
      };
    }).toList();

    // Prepare API call.
    final uri = Uri.parse('https://api.openai.com/v1/chat/completions');
    try {
      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          'model': 'gpt-4o-mini',
          'messages': conversation,
        }),
      );

      if (response.statusCode == 200) {
        final decodedBody = utf8.decode(response.bodyBytes);
        final data = jsonDecode(decodedBody);
        final aiResponse = data['choices'][0]['message']['content'] as String;

        // Create AI message with animation
        final aiMessage = _createAnimatedMessage(aiResponse.trim(), 'ai');

        setState(() {
          _messages.add(aiMessage);
          _isTyping = false;
        });

        // Scroll again after adding the AI response
        _scrollToBottom();
      } else {
        setState(() => _isTyping = false);
        _showErrorSnackBar('Error generating response.');
      }
    } catch (e) {
      setState(() => _isTyping = false);
      _showErrorSnackBar('Error connecting to AI service.');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.redAccent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        margin: EdgeInsets.all(8),
      ),
    );
  }

  void _scrollToBottom() {
    // Wait for the frame to be built and then scroll
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Add a small delay to ensure animations have started and layout is updated
      Future.delayed(const Duration(milliseconds: 100), () {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    });
  }

  Widget _buildInputArea({bool isLandscape = false}) {
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 15,
        vertical: isLandscape ? 4 : 8,
      ),
      decoration: BoxDecoration(
        color: Colors.transparent,
        border: Border(
          top: BorderSide(
            color: const Color.fromARGB(70, 158, 158, 158),
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: _secondaryColor.withOpacity(0.5),
                borderRadius: BorderRadius.circular(24),
                border:
                    Border.all(color: const Color.fromARGB(70, 158, 158, 158)),
              ),
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: _textController,
                decoration: InputDecoration(
                  hintText: l10n?.messageAI ?? 'Message SLC AI...',
                  hintStyle: TextStyle(color: Colors.grey[500]),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    vertical: isLandscape ? 8 : 14,
                  ),
                ),
                maxLines: isLandscape ? 1 : 5,
                minLines: 1,
                textCapitalization: TextCapitalization.sentences,
                onSubmitted: (text) {
                  if (text.isNotEmpty) {
                    _sendMessage(text: text);
                    _textController.clear();
                  }
                },
              ),
            ),
          ),
          SizedBox(width: 8),
          Material(
            color: _primaryColor,
            borderRadius: BorderRadius.circular(24),
            child: InkWell(
              borderRadius: BorderRadius.circular(24),
              onTap: () {
                String text = _textController.text;
                if (text.isNotEmpty) {
                  _textController.clear();
                  _sendMessage(text: text);
                }
              },
              child: Container(
                padding: EdgeInsets.all(isLandscape ? 10 : 14),
                child: Icon(
                  Icons.send_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Container(
      padding: EdgeInsets.all(16),
      alignment: Alignment.centerLeft,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 18),
        decoration: BoxDecoration(
          color: _secondaryColor,
          borderRadius: BorderRadius.circular(18),
        ),
        child: AnimatedBuilder(
          animation: _typingDotsController!,
          builder: (context, child) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildAnimatedDot(0.0),
                SizedBox(width: 4),
                _buildAnimatedDot(0.2),
                SizedBox(width: 4),
                _buildAnimatedDot(0.4),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildAnimatedDot(double delay) {
    // Create a bouncing effect using a delayed curve
    final delayedAnimation = CurvedAnimation(
      parent: _typingDotsController!,
      curve: Interval(
        delay,
        delay + 0.5,
        curve: Curves.easeOutCubic,
      ),
    );

    return AnimatedBuilder(
      animation: delayedAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, -4 * delayedAnimation.value),
          child: Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: Colors.grey[600],
              shape: BoxShape.circle,
            ),
          ),
        );
      },
    );
  }

  Widget _buildMessage(ChatMessage message, int index,
      {double maxWidth = 0.75}) {
    bool isUser = message.sender == 'user';

    return SizeTransition(
      sizeFactor: CurvedAnimation(
        parent: message.animationController!,
        curve: Curves.easeOutQuint,
      ),
      child: SlideTransition(
        position: Tween<Offset>(
          begin: Offset(isUser ? 0.3 : -0.3, 0),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: message.animationController!,
          curve: Curves.elasticOut,
        )),
        child: FadeTransition(
          opacity: CurvedAnimation(
            parent: message.animationController!,
            curve: Curves.easeIn,
          ),
          child: Container(
            margin: EdgeInsets.only(
              left: isUser
                  ? MediaQuery.of(context).size.width * (1 - maxWidth) - 16
                  : 16,
              right: isUser
                  ? 16
                  : MediaQuery.of(context).size.width * (1 - maxWidth) - 16,
              top: 4,
              bottom: 4,
            ),
            alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * maxWidth,
              ),
              child: Material(
                elevation: 1,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(isUser ? 16 : 4),
                  topRight: Radius.circular(isUser ? 4 : 16),
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
                color: isUser ? _primaryColor : _secondaryColor,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: SelectableText(
                    message.content,
                    style: TextStyle(
                      color: isUser ? Colors.white : _textOnSecondaryColor,
                      fontSize: 15,
                    ),
                    toolbarOptions: ToolbarOptions(
                      copy: true,
                      selectAll: true,
                      cut: false,
                      paste: false,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    // Use OrientationBuilder to handle different layouts
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        title: Text(
          l10n?.aiAssistant ?? "AI Assistant",
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: _backgroundColor,
        foregroundColor: Theme.of(context).brightness == Brightness.light
            ? Colors.black
            : Colors.white,
        actions: [
          IconButton(
            onPressed: () {
              NativeAlertDialog.show(
                  context: context,
                  title: l10n?.newChat ?? "New Chat",
                  content: l10n?.newChatConfirmation ??
                      "Are you sure you want to start a new chat? This will clear the current conversation",
                  confirmText: l10n?.newChat ?? "New Chat",
                  cancelText: l10n?.cancel ?? "Cancel",
                  onConfirm: () {
                    setState(() {
                      _messages.clear();
                      _isTyping = false;
                    });
                  });
            },
            icon: Icon(Icons.add),
            style: IconButton.styleFrom(overlayColor: Colors.transparent),
          )
        ],
      ),
      // Add a GestureDetector to dismiss keyboard when tapping outside
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SafeArea(
          child: OrientationBuilder(
            builder: (context, orientation) {
              return Column(
                children: [
                  Expanded(
                    child: _messages.isEmpty
                        ? _buildWelcomeScreen()
                        : ListView.builder(
                            controller: _scrollController,
                            padding: EdgeInsets.only(top: 16, bottom: 16),
                            itemCount: _messages.length + (_isTyping ? 1 : 0),
                            itemBuilder: (context, index) {
                              if (_isTyping && index == _messages.length) {
                                return _buildTypingIndicator();
                              }
                              final message = _messages[index];
                              return _buildMessage(
                                message,
                                index,
                                // Adjust message width based on orientation
                                maxWidth: orientation == Orientation.landscape
                                    ? 0.5
                                    : 0.75,
                              );
                            },
                          ),
                  ),
                  _buildInputArea(
                      isLandscape: orientation == Orientation.landscape),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeScreen() {
    final l10n = AppLocalizations.of(context);
    final orientation = MediaQuery.of(context).orientation;
    final isLandscape = orientation == Orientation.landscape;

    return Center(
      child: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(isLandscape ? 16 : 24),
          child: isLandscape
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.lightbulb_outline,
                      size: 60,
                      color: _primaryColor,
                    ),
                    SizedBox(width: 16),
                    Flexible(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n?.aiAssistantTitle ?? "SLC AI Assistant",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            l10n?.askAnything ??
                                "Ask me anything about your courses, study techniques, or learning strategies.",
                            textAlign: TextAlign.start,
                            style: TextStyle(fontSize: 14),
                          ),
                          SizedBox(height: 16),
                          OutlinedButton.icon(
                            onPressed: () {
                              _sendMessage(
                                  text: l10n?.helloAI ??
                                      "Hello! How can you help with my studies?");
                            },
                            icon: Icon(Icons.chat_outlined),
                            label: Text(l10n?.startConversation ??
                                "Start a conversation"),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: _primaryColor,
                              padding: EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
                              ),
                              side: BorderSide(color: _primaryColor),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                )
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.lightbulb_outline,
                      size: 72,
                      color: _primaryColor.withOpacity(0.7),
                    ),
                    SizedBox(height: 24),
                    Text(
                      l10n?.aiAssistantTitle ?? "SLC AI Assistant",
                      style: Theme.of(context)
                          .textTheme
                          .headlineLarge
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 16),
                    Text(
                        l10n?.askAnything ??
                            "Ask me anything about your courses, study techniques, or learning strategies.",
                        textAlign: TextAlign.center,
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall
                            ?.copyWith(fontSize: 16)),
                    SizedBox(height: 32),
                    OutlinedButton.icon(
                      onPressed: () {
                        _sendMessage(
                            text: l10n?.helloAI ??
                                "Hello! How can you help with my studies?");
                      },
                      icon: Icon(Icons.chat_outlined),
                      label: Text(l10n?.startConversation ??
                          "Start a conversation"),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: _primaryColor,
                        padding:
                            EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        side: BorderSide(color: _primaryColor),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
