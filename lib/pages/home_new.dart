import 'package:flutter/material.dart';

class HomeNew extends StatefulWidget {
  const HomeNew({super.key});

  @override
  State<HomeNew> createState() => _HomeNewState();
}

class _HomeNewState extends State<HomeNew> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home New'),
      ),
      body: Center(
        child: ListView.builder(
            itemCount: 6,
            itemBuilder: (context, jumlah) {
              return ListTile(
                title: Text('test'),
                subtitle: Text('sub $jumlah'),
              );
            }),
      ),
    );
  }
}
