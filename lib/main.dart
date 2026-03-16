import 'package:flutter/material.dart';
import 'api_service.dart';
import 'post_model.dart';

void main() => runApp(const MaterialApp(home: PostsScreen()));

class PostsScreen extends StatefulWidget {
  const PostsScreen({super.key});
  @override
  State<PostsScreen> createState() => _PostsScreenState();
}

class _PostsScreenState extends State<PostsScreen> {
  final ApiService apiService = ApiService();
  List<Post> posts = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPosts();
  }

 Future<void> _loadPosts() async {
    try {
      setState(() => isLoading = true);
      final fetchedPosts = await apiService.fetchPosts();
      setState(() {
        posts = fetchedPosts;
        isLoading = false;
      });
    } catch (e) {
      print("Error loading posts: $e"); // THIS WILL TELL US THE PROBLEM
      setState(() => isLoading = false);
      // Show an error on the screen
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Posts Manager")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: posts.length,
              itemBuilder: (context, index) {
                final post = posts[index];
                return ListTile(
                  title: Text(post.title),
                  subtitle: Text(post.body),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () async {
                          await apiService.updatePost(post.id, "Updated", "Updated");
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Post Updated!")));
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () async {
                          await apiService.deletePost(post.id);
                          setState(() => posts.removeAt(index));
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Post Deleted!")));
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () async {
          await apiService.createPost("New Title", "New Body");
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Post Created!")));
        },
      ),
    );
  }
}