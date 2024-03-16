import 'package:http/http.dart' as http;
import 'dart:convert';

class HttpConnection {
  Map<String, String> headers;
  HttpConnection(
      {key,
      this.headers = const {
        'Content-Type': 'application/json',
      }});
  final String baseUrl = "http://192.168.100.7:5000/api";

  Future get({required String url, Map<String, String>? headers}) async {
    var response = await http.get(
      Uri.parse(baseUrl + url),
      headers: headers,
    );
    return response;
  }

  Future post({
    required String url,
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  }) async {
    var response = await http.post(
      Uri.parse(baseUrl + url),
      headers: headers,
      body: json.encode(body),
    );
    return response;
  }
}
