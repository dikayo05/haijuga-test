import 'package:flutter/material.dart';
import 'pages/signin/signin_page.dart';

// firebase
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

// cloudinary
import 'package:cloudinary_url_gen/cloudinary.dart';
import 'package:cloudinary_flutter/cloudinary_context.dart';
import 'package:cloudinary_flutter/image/cld_image.dart';
import 'package:cloudinary_flutter/cloudinary_object.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // CloudinaryObject.fromCloudName(cloudName: 'dwxuluzp6');
  CloudinaryContext.cloudinary =
      Cloudinary.fromCloudName(cloudName: 'dwxuluzp6');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'haijuga',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: SigninPage(),
    );
  }
}
