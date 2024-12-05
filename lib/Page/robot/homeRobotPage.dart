import 'package:flutter/material.dart';
import 'package:http/http.dart' as http; // Import HTTP package
import 'dart:convert'; // Import for JSON encoding and decoding
import 'package:speech_to_text/speech_to_text.dart'
    as stt; // Import speech-to-text package
import 'package:permission_handler/permission_handler.dart'; // Import permission handler for microphone permissions
import 'package:intl/intl.dart'; // Import for time formatting
import 'package:yunlife/global.dart';
import 'package:yunlife/setting.dart'; // Import settings for the API key and server URL
import 'package:url_launcher/url_launcher.dart'; // Import for launching URLs

// Define the different states for the robot's image
enum ImageState { nap, awake, answer, complete }

class homeRobotPage extends StatefulWidget {
  const homeRobotPage({super.key});

  @override
  _HomeRobotPageState createState() => _HomeRobotPageState();
}

class _HomeRobotPageState extends State<homeRobotPage> {
  ImageState _imageState = ImageState.nap;
  bool _isChatVisible = false;
  final TextEditingController _textController = TextEditingController();
  final List<Map<String, dynamic>> _messages = []; // Store messages with time
  bool _isTyping = false; // Instead of _isLoading
  late stt.SpeechToText _speech; // Speech-to-text instance
  bool _isListening = false; // To track mic status
  String _speechText = ''; // Stores the recognized speech
  final String _currentLocaleId = 'en_US'; // Default to English
  String time = DateFormat('HH:mm').format(DateTime.now());

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText(); // Initialize speech-to-text
    _checkPermissions(); // Check for microphone permissions
    _getAvailableLocales(); // Check available languages
    _botHelloWorld();
  }

  void _botHelloWorld() {
    _messages.add({
      'text':
          'Robot: 哈囉！我是yunyun，是你的校園助理，\n你可以問我有關社團、行事曆、課堂評價和教室位置的資訊，\n有任何問題都可以問我喔！',
      'time': time
    });
  }

  // Check microphone permission
  Future<void> _checkPermissions() async {
    var status = await Permission.microphone.status;
    if (status.isDenied) {
      await Permission.microphone
          .request(); // Request permission if not granted
    }
  }

  // List available locales (languages)
  Future<void> _getAvailableLocales() async {
    List<stt.LocaleName> locales = await _speech.locales();
    print(
        "Available locales: ${locales.map((locale) => locale.localeId).toList()}");
  }

  Future<String> _getChatResponse(String userInput) async {
    final response = await http.post(
      Uri.parse('$SERVER_IP/ask'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'prompt': userInput, 'username': globalUsername}),
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      return responseData['response'];
    } else if (response.statusCode == 401) {
      return "請先登錄系統已使用個人行事曆功能。";
    } else {
      throw Exception('Failed to load  response from server');
    }
  }

  // Start/stop speech recognition
  void _startListening() async {
    var permissionStatus = await Permission.microphone.status;
    if (!permissionStatus.isGranted) {
      await Permission.microphone.request();
      return;
    }

    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (status) => print('onStatus: $status'),
        onError: (errorNotification) {
          print('onError: $errorNotification');
          setState(() {
            _isListening = false;
          });
        },
      );

      if (available) {
        setState(() {
          _isListening = true;
        });

        _speech.listen(
          onResult: (val) => setState(() {
            _speechText = val.recognizedWords; // Capture recognized words
            print("Recognized words: $_speechText"); // Debugging
            _textController.text = _speechText; // Update the input field
          }),
          localeId: _currentLocaleId,
        );
      } else {
        setState(() {
          _isListening = false;
        });
      }
    } else {
      setState(() {
        _isListening = false;
      });
      _speech.stop();
    }
  }

  // Function to handle image tap (nap -> awake)
  void _onImageTap() {
    if (_imageState == ImageState.nap) {
      setState(() {
        _imageState = ImageState.awake;
        _isChatVisible = true; // Show the chat interface
      });
    }
  }

  // Function to open a map URL
  Future<void> openMap(String url) async {
    Uri mapUrl = Uri.parse(url);

    if (await canLaunchUrl(mapUrl)) {
      await launchUrl(mapUrl,
          mode: LaunchMode.externalApplication); // Open map in Google Maps
    } else {
      throw 'Could not launch $url';
    }
  }

  // Function to send a message
  void _sendMessage() async {
    if (_textController.text.isEmpty) return;

    // Unfocus the text field to hide the keyboard
    FocusScope.of(context).unfocus();

    String userInput = _textController.text;

    setState(() {
      _messages.add({'text': 'You: $userInput', 'time': time});
      _isTyping = true;
      _imageState = ImageState.answer;
    });

    _textController.clear();
    try {
      String response = await _getChatResponse(userInput);

      // Check if the response contains a map link
      if (response.contains('https://www.google.com/maps')) {
        setState(() {
          String time = DateFormat('HH:mm').format(DateTime.now());
          _messages.add({
            'text': 'Robot: Click to open map',
            'time': time,
            'url': response
          });
          _imageState = ImageState.complete;
        });
      } else {
        setState(() {
          String time = DateFormat('HH:mm').format(DateTime.now());
          _messages.add({'text': 'Robot: $response', 'time': time});
          _imageState = ImageState.complete;
        });
      }
    } catch (e) {
      setState(() {
        String time = DateFormat('HH:mm').format(DateTime.now());
        _messages.add({'text': 'Error: $e', 'time': time});
        _imageState = ImageState.complete;
      });
    } finally {
      setState(() {
        _isTyping = false;
      });
    }
  }

  // Function to get the current image asset based on the image state
  String _getImageAsset() {
    switch (_imageState) {
      case ImageState.nap:
        return 'asst/images/nap.gif';
      case ImageState.awake:
        return 'asst/images/wake.gif';
      case ImageState.answer:
        return 'asst/images/response.gif';
      case ImageState.complete:
        return 'asst/images/complete.gif';
      default:
        return 'asst/images/nap.gif';
    }
  }

  // Widget to display the typing indicator
  Widget _buildTypingIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: const [
        Text("Yun Yun 正在輸入", style: TextStyle(color: Colors.brown)),
        SizedBox(width: 5),
        SizedBox(
          width: 10,
          height: 10,
          child: CircularProgressIndicator(strokeWidth: 1.5),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(6.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: _onImageTap, // Handle image tap
                      child: SizedBox(
                        height: 280,
                        width: 280,
                        child: Image.asset(
                          _getImageAsset(),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(height: 5),
                    if (!_isChatVisible)
                      Text(
                        '點擊助理以喚醒',
                        style:
                            TextStyle(fontSize: 24, color: Color(0xFF9B979C)),
                      )
                    else
                      Column(
                        children: [
                          Container(
                            height: MediaQuery.of(context).size.height * 0.35,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.brown),
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            child: ListView.builder(
                              reverse: true,
                              padding: const EdgeInsets.all(8.0),
                              itemCount: _messages.length + (_isTyping ? 1 : 0),
                              itemBuilder: (context, index) {
                                if (index == 0 && _isTyping) {
                                  return _buildTypingIndicator();
                                }
                                final message = _messages[_messages.length -
                                    1 -
                                    index +
                                    (_isTyping ? 1 : 0)];
                                bool isUser =
                                    message['text'].startsWith('You:');

                                if (message.containsKey('url')) {
                                  return Align(
                                    alignment: isUser
                                        ? Alignment.centerRight
                                        : Alignment.centerLeft,
                                    child: GestureDetector(
                                      onTap: () => openMap(message['url']),
                                      child: Text(
                                        'Click to open map',
                                        style: TextStyle(
                                          color: Colors.blue,
                                          decoration: TextDecoration.underline,
                                        ),
                                      ),
                                    ),
                                  );
                                }

                                return Align(
                                  alignment: isUser
                                      ? Alignment.centerRight
                                      : Alignment.centerLeft,
                                  child: Column(
                                    crossAxisAlignment: isUser
                                        ? CrossAxisAlignment.end
                                        : CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(10.0),
                                        margin: const EdgeInsets.symmetric(
                                            vertical: 5.0),
                                        decoration: BoxDecoration(
                                          color: isUser
                                              ? Colors.brown[50]
                                              : Colors.brown[180],
                                          border: Border.all(
                                            color: Colors.brown,
                                            width: 1.0,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                        ),
                                        child: Text(
                                          message['text']
                                              .substring(isUser ? 4 : 7),
                                          style: TextStyle(
                                              color: Colors.brown[800]),
                                        ),
                                      ),
                                      Text(
                                        message['time'],
                                        style: TextStyle(
                                            fontSize: 10, color: Colors.grey),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 8),
                          Padding(
                            padding: const EdgeInsets.only(left: 62.0),
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 4,
                                  child: TextField(
                                    controller: _textController,
                                    decoration: const InputDecoration(
                                      labelText: '輸入你的問題',
                                      border: OutlineInputBorder(),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8.0),
                                IconButton(
                                  icon: const Icon(Icons.send),
                                  color: Colors.brown[300],
                                  onPressed: _sendMessage,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ),
          if (_imageState != ImageState.nap)
            Positioned(
              bottom: 10,
              left: 10,
              child: GestureDetector(
                onTap: _startListening,
                child: Container(
                  padding: const EdgeInsets.all(10.0),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.grey[300],
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 5,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.mic,
                    color: _isListening ? Colors.red : Colors.black,
                    size: 30,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
