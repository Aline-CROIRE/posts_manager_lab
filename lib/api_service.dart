import 'dart:convert';
import 'package:http/http.dart' as http;
import 'post_model.dart';

class ApiService {
  final String baseUrl = "https://jsonplaceholder.org/posts";

  Future<List<Post>> fetchPosts() async {
    final response = await http.get(Uri.parse(baseUrl));
    if (response.statusCode == 200) {
      List<dynamic> body = json.decode(response.body);
      return body.map((dynamic item) => Post.fromJson(item)).toList();
    }
    return [];
  }

  Future<void> createPost(String title, String body) async {
    await http.post(Uri.parse(baseUrl),
        headers: {"Content-type": "application/json; charset=UTF-8"},
        body: jsonEncode({'title': title, 'content': body, 'userId': 1}));
  }

  Future<void> updatePost(int id, String title, String body) async {
    await http.put(Uri.parse('$baseUrl/$id'),
        headers: {"Content-type": "application/json; charset=UTF-8"},
        body: jsonEncode({'id': id, 'title': title, 'content': body}));
  }

  Future<void> deletePost(int id) async {
    await http.delete(Uri.parse('$baseUrl/$id'));
  }
}