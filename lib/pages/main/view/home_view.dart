import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../services/firebase/firestore_service.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final firestoreService = FirestoreService();

  Widget menuPopup(String docId) {
    return PopupMenuButton<String>(
      onSelected: (String value) {
        if (value == 'edit') {
          print('Edit');
        } else if (value == 'delete') {
          firestoreService.deletePost(docId);
        }
      },
      itemBuilder: (BuildContext context) {
        return [
          PopupMenuItem(
            value: 'edit',
            child: Text('Edit'),
          ),
          PopupMenuItem(
            value: 'delete',
            child: Text('Hapus'),
          ),
          PopupMenuItem(
            value: 'report',
            child: Text('Laporkan'),
          ),
        ];
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: firestoreService.getPostsStream(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List postsList = snapshot.data!.docs;
            return ListView.builder(
                itemCount: postsList.length,
                itemBuilder: (context, index) {
                  DocumentSnapshot documen = postsList[index];
                  String docId = documen.id;
                  Map<String, dynamic> post =
                      documen.data() as Map<String, dynamic>;
                  return Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [Text(post['user_id']), menuPopup(docId)],
                      ),
                      Text(post['caption']),
                      Image.network(post['media']),
                    ],
                  );
                });
          } else {
            return Text('hah kosong');
          }
        });
  }
}
