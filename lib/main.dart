import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'router.dart';
import 'services/firebase_service.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const AlphaEdgeApp());
}

class AlphaEdgeApp extends StatelessWidget {
  const AlphaEdgeApp({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = AuthService();
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: auth),
        Provider(create: (_) => FirestoreService()),
      ],
      child: Builder(
        builder: (context) {
          final router = createRouter(context.read<AuthService>());
          return MaterialApp.router(
            title: 'AlphaEdge Capital',
            debugShowCheckedModeBanner: false,
            theme: AETheme.theme,
            routerConfig: router,
          );
        },
      ),
    );
  }
}
