import 'package:flutter/material.dart';
import 'view/home_view.dart';
import 'view/add_post_view.dart';
import 'view/profile_view.dart';
import 'view/message_view.dart';

import '../../services/firebase/post_service.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final PostService firestoreService = PostService();
  final ScrollController _scrollController = ScrollController();

  Map<String, dynamic> users = {};

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        // fetch data atau get data
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 3,
        child: Scaffold(
            appBar: AppBar(
              title: const Text('haijuga'),
              actions: [
                IconButton(
                  icon: Icon(Icons.notifications),
                  onPressed: () {},
                ),
              ],
            ),
            body: TabBarView(
              children: [
                // home view
                HomeView(),
                // message view
                // MessageView(),
                // add post view
                AddPostView(),
                // profile view
                ProfileView()
              ],
            ),
            bottomNavigationBar: const TabBar(
              tabs: [
                Tab(icon: Icon(Icons.home)),
                // Tab(icon: Icon(Icons.message)),
                Tab(icon: Icon(Icons.add)),
                Tab(icon: Icon(Icons.person))
              ],
            )));
  }
}
