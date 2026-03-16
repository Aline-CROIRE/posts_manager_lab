import 'dart:convert';
import 'package:http/http.dart' as http;
import 'post_model.dart';

class ApiService {
  final String baseUrl = "https://jsonplaceholder.typicode.com/posts";

  Future<List<Post>> fetchPosts() async {
    final response = await http.get(
      Uri.parse(baseUrl),
      headers: {
        "Accept": "*/*",
        "Connection": "keep-alive",
        "User-Agent": "PostmanRuntime/7.26.8", // This is a common API testing tool
      },
    );
    
    if (response.statusCode == 200) {
      List<dynamic> body = json.decode(response.body);
      return body.map((dynamic item) => Post.fromJson(item)).toList();
    } else {
      throw Exception("Status Code: ${response.statusCode}");
    }
  }

  Future<void> createPost(String title, String body) async {
    await http.post(Uri.parse(baseUrl), 
      headers: {"Content-type": "application/json; charset=UTF-8", "User-Agent": "Mozilla/5.0"},
      body: jsonEncode({'title': title, 'body': body, 'userId': 1}),
    );
  }

  Future<void> updatePost(int id, String title, String body) async {
    await http.put(Uri.parse('$baseUrl/$id'),
      headers: {"Content-type": "application/json; charset=UTF-8", "User-Agent": "Mozilla/5.0"},
      body: jsonEncode({'id': id, 'title': title, 'body': body, 'userId': 1}),
    );
  }

  Future<void> deletePost(int id) async {
    await http.delete(Uri.parse('$baseUrl/$id'), headers: {"User-Agent": "Mozilla/5.0"});
  }
}