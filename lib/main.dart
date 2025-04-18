import 'package:biftech/provider/auth_provider.dart';
import 'package:biftech/provider/reels_provider.dart';
import 'package:biftech/screens/flowchart.dart';
import 'package:biftech/screens/home_screen.dart';
import 'package:biftech/screens/login_screen.dart';
import 'package:biftech/screens/register_screen.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'provider/flow_chart_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ReelsProvider()),
        ChangeNotifierProvider(create: (_) => FlowChartProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()..initialize()),
      ],
      child: MaterialApp(
        title: 'Auth Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          scaffoldBackgroundColor: Colors.white,
        ),
        initialRoute: '/login',
        routes: {
          '/login': (context) => LoginScreen(),
          '/register': (context) => RegisterScreen(),
          '/home': (context) => HomeScreen(),
        },
      ),
    );
  }
}
