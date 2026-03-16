import 'package:flutter/material.dart';
import 'api_service.dart';
import 'post_model.dart';
import 'post_detail.dart';

final GlobalKey<ScaffoldMessengerState> snackbarKey = GlobalKey<ScaffoldMessengerState>();

void main() => runApp(MaterialApp(
      scaffoldMessengerKey: snackbarKey,
      debugShowCheckedModeBanner: false,
      home: const PostsScreen(),
    ));

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
  void initState() { super.initState(); _fetchData(); }

  Future<void> _fetchData() async {
    final data = await apiService.fetchPosts();
    setState(() { posts = data; isLoading = false; });
  }

  void _showSnackBar(String msg) {
    snackbarKey.currentState?.showSnackBar(SnackBar(
      content: Text(msg),
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.deepPurple,
      elevation: 10,
    ));
  }

  void _showPostDialog({Post? post, int? index}) {
    final titleController = TextEditingController(text: post?.title ?? '');
    final bodyController = TextEditingController(text: post?.body ?? '');

    showModalBottomSheet(
      context: context, isScrollControlled: true, backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom + 20, left: 20, right: 20, top: 20),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text(post == null ? "Add New Post" : "Edit Post", style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          TextField(controller: titleController, decoration: const InputDecoration(labelText: "Title")),
          TextField(controller: bodyController, maxLines: 3, decoration: const InputDecoration(labelText: "Description")),
          const SizedBox(height: 20),
          InkWell(
            onTap: () async {
              String title = titleController.text;
              Navigator.pop(context);
              if (post == null) {
                await apiService.createPost(title, bodyController.text);
                setState(() => posts.insert(0, Post(id: 999, title: title, body: bodyController.text)));
                _showSnackBar("Post '$title' created!");
              } else {
                await apiService.updatePost(post.id, title, bodyController.text);
                setState(() => posts[index!] = Post(id: post.id, title: title, body: bodyController.text));
                _showSnackBar("Post '$title' updated!");
              }
            },
            child: Container(
              width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 15),
              decoration: BoxDecoration(gradient: const LinearGradient(colors: [Colors.deepPurple, Colors.blueAccent]), borderRadius: BorderRadius.circular(15)),
              child: const Center(child: Text("SUBMIT", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
            ),
          )
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(decoration: const BoxDecoration(gradient: LinearGradient(colors: [Colors.deepPurple, Colors.blueAccent]))),
        title: const Text("Posts Manager", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: isLoading ? const Center(child: CircularProgressIndicator()) : ListView.builder(
        itemCount: posts.length,
        itemBuilder: (context, index) {
          final post = posts[index];
          return Card(margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5), child: ListTile(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => PostDetail(post: post))),
            title: Text(post.title, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(post.body, maxLines: 2),
            trailing: Row(mainAxisSize: MainAxisSize.min, children: [
              IconButton(icon: const Icon(Icons.edit, color: Colors.blue), onPressed: () => _showPostDialog(post: post, index: index)),
              IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () async {
                String title = post.title;
                await apiService.deletePost(post.id);
                setState(() => posts.removeAt(index));
                _showSnackBar("Post '$title' deleted!");
              }),
            ]),
          ));
        },
      ),
      floatingActionButton: FloatingActionButton(onPressed: () => _showPostDialog(), backgroundColor: Colors.deepPurple, child: const Icon(Icons.add, color: Colors.white)),
    );
  }
}