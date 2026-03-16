import 'dart:convert';
import 'package:http/http.dart' as http;
import 'post_model.dart';

class ApiService {
  // Using the more reliable endpoint
  final String baseUrl = "https://jsonplaceholder.org/posts";

  // Fetch all posts with a 10s timeout to prevent infinite loading
  Future<List<Post>> fetchPosts() async {
    try {
      final response = await http.get(Uri.parse(baseUrl)).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        List<dynamic> body = json.decode(response.body);
        return body.map((dynamic item) => Post.fromJson(item)).toList();
      }
    } catch (e) {
      print("Fetch Error: $e");
    }
    return [];
  }

  // Create post with try-catch to ignore network-related client exceptions
  Future<void> createPost(String title, String body) async {
    try {
      await http.post(
        Uri.parse(baseUrl),
        headers: {"Content-type": "application/json; charset=UTF-8"},
        body: jsonEncode({'title': title, 'content': body, 'userId': 1}),
      ).timeout(const Duration(seconds: 5));
    } catch (e) {
      print("Create Error (Handled): $e");
    }
  }

  // Update post
  Future<void> updatePost(int id, String title, String body) async {
    try {
      await http.put(
        Uri.parse('$baseUrl/$id'),
        headers: {"Content-type": "application/json; charset=UTF-8"},
        body: jsonEncode({'id': id, 'title': title, 'content': body}),
      ).timeout(const Duration(seconds: 5));
    } catch (e) {
      print("Update Error (Handled): $e");
    }
  }

  // Delete post
  Future<void> deletePost(int id) async {
    try {
      await http.delete(Uri.parse('$baseUrl/$id')).timeout(const Duration(seconds: 5));
    } catch (e) {
      print("Delete Error (Handled): $e");
    }
  }
}