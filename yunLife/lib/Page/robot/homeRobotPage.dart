import 'package:flutter/material.dart';
import 'package:http/http.dart' as http; // Import HTTP package
import 'dart:convert'; // Import for JSON encoding and decoding
import 'package:speech_to_text/speech_to_text.dart'
    as stt; // Import speech-to-text package
import 'package:permission_handler/permission_handler.dart'; // Import permission handler for microphone permissions
import 'package:intl/intl.dart'; // Import for time formatting
import 'package:yunLife/setting.dart'; // Import settings for the API key and server URL

// Define the different zstates for the robot's image
enum ImageState { nap, awake, answer, complete }

class homeRobotPage extends StatefulWidget {
  const homeRobotPage({super.key});

  @override
  _homeRobotPageState createState() => _homeRobotPageState();
}

class _homeRobotPageState extends State<homeRobotPage> {
  // Initial state is 'nap'
  ImageState _imageState = ImageState.nap;
  bool _isChatVisible = false;
  final TextEditingController _textController = TextEditingController();
  final List<Map<String, dynamic>> _messages = []; // Store messages with time
  bool _isTyping = false; // Instead of _isLoading
  late stt.SpeechToText _speech; // Speech-to-text instance
  bool _isListening = false;
  String _speechText = '';

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText(); // Initialize speech-to-text
    _checkPermissions(); // Check for microphone permissions
  }

  // Check microphone permission
  Future<void> _checkPermissions() async {
    var status = await Permission.microphone.status;
    if (status.isDenied) {
      await Permission.microphone
          .request(); // Request permission if not granted
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

  // Function to start/stop speech recognition
  void _startListening() async {
    // Ensure microphone permissions are granted
    var permissionStatus = await Permission.microphone.status;
    if (!permissionStatus.isGranted) {
      await Permission.microphone
          .request(); // Request permission if not granted
      return;
    }

    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (status) => print('onStatus: $status'),
        onError: (errorNotification) => print('onError: $errorNotification'),
      );

      if (available) {
        setState(() {
          _isListening = true;
        });

        _speech.listen(
          onResult: (val) => setState(() {
            _speechText = val.recognizedWords;
            _textController.text =
                _speechText; // Update the input field with recognized text
          }),
          listenFor: const Duration(seconds: 10), // Set listening duration
          pauseFor: const Duration(
              seconds: 5), // Time to wait for a pause before stopping
          cancelOnError: true,
          partialResults: false,
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

  // Function to send a message
  void _sendMessage() async {
    if (_textController.text.isEmpty) return;

    String userInput = _textController.text;
    String time = DateFormat('HH:mm').format(DateTime.now()); // Format time

    setState(() {
      _messages.add({'text': 'You: $userInput', 'time': time});
      _isTyping = true; // Show Yun Yun typing indicator
      _imageState = ImageState.answer;
    });

    _textController.clear();
    try {
      String response = await _getChatResponse(userInput);
      setState(() {
        String time = DateFormat('HH:mm').format(DateTime.now());
        _messages.add({'text': 'Robot: $response', 'time': time});
        _imageState = ImageState.complete;
      });
    } catch (e) {
      setState(() {
        String time = DateFormat('HH:mm').format(DateTime.now());
        _messages.add({'text': 'Error: $e', 'time': time});
        _imageState = ImageState.complete;
      });
    } finally {
      setState(() {
        _isTyping = false; // Remove Yun Yun typing indicator
      });
    }
  }

  // Function to get ChatGPT response from the server
  Future<String> _getChatResponse(String userInput) async {
    final response = await http.post(
      Uri.parse('$SERVER_IP/ask'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'prompt': userInput}),
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      return responseData['response'];
    } else {
      throw Exception('Failed to load response from server');
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
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    const SizedBox(height: 5),
                    GestureDetector(
                      onTap: _onImageTap, // Handle image tap
                      child: SizedBox(
                        height: 300,
                        width: 300,
                        child: Image.asset(
                          _getImageAsset(),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(height: 2),
                    // Show chat interface if _isChatVisible is true
                    if (_isChatVisible)
                      Column(
                        children: [
                          Container(
                            height: MediaQuery.of(context).size.height * 0.3,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.brown),
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            child: ListView.builder(
                              reverse:
                                  true, // Show latest messages at the bottom
                              padding: const EdgeInsets.all(8.0),
                              itemCount: _messages.length +
                                  (_isTyping
                                      ? 1
                                      : 0), // Add 1 for typing indicator if active
                              itemBuilder: (context, index) {
                                if (index == 0 && _isTyping) {
                                  return _buildTypingIndicator(); // Show typing indicator
                                }
                                final message = _messages[_messages.length -
                                    1 -
                                    index +
                                    (_isTyping ? 1 : 0)];
                                bool isUser =
                                    message['text'].startsWith('You:');
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
                                              ? Colors.brown[100]
                                              : Colors.brown[200],
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                        ),
                                        child: Text(
                                          message['text']
                                              .substring(isUser ? 4 : 7),
                                          style: TextStyle(
                                            color: Colors.brown[800],
                                          ),
                                        ),
                                      ),
                                      Text(
                                        message['time'],
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(
                              height: 10), // Add space between chat and input
                          Padding(
                            padding: const EdgeInsets.only(
                                left: 62.0), // 左邊添加 60 像素的內邊距
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
                                  onPressed:
                                      _sendMessage, // Disable button while loading
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
          // 麥克風圖示應該顯示在左下角，當且僅當圖片狀態是 "awake"
          if (_imageState != ImageState.nap)
            Positioned(
              bottom: 10,
              left: 10, // 將麥克風圖示移到左下角
              child: GestureDetector(
                onTap: _startListening, // Start listening when mic is tapped
                child: Container(
                  padding:
                      const EdgeInsets.all(10.0), // Padding around the icon
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.grey[300], // 圓形背景顏色
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 5,
                        offset: Offset(0, 2), // 阴影偏移
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
