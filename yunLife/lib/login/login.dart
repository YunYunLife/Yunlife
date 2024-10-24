import 'dart:convert';
import 'package:http/http.dart' as http;

Future<bool> verifyUserCredentials(String inputUsername, String inputPassword) async {
  try {
    final response = await http.get(Uri.parse('http://yunlifeserver.glitch.me/student_account'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> decoded = json.decode(response.body) as Map<String, dynamic>;
      final List<dynamic> dataList = decoded['greetings'] as List<dynamic>;

      for (var account in dataList) {
        String username = account['帳號'];
        String password = account['密碼'];

        if (username == inputUsername && password == inputPassword) {
          return true; 
        }
      }

      return false; 
    } else {
      throw Exception('Failed to load student accounts');
    }
  } catch (e) {
    print('Error: $e');
    return false;
  }
}
