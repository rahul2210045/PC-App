import 'package:http/http.dart' as http;

Future<bool> verifyAccessToken(String? accessToken) async {
  final String url = 'https://pc.anaskhan.site/api/verify_token';

  try {
    http.Response response = await http.get(
      Uri.parse(url),
      headers: {'Authorization': accessToken!},
    );
    if (response.statusCode == 200) {
      print('Response body: ${response.body}');
      return true;
    } else {
      print('Response status: ${response.statusCode}');
      return false;
    }
  } catch (e) {
    print('Error: $e');
    return false;
  }
}