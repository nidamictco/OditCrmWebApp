import 'package:flutter/material.dart';
import 'package:login_2_it_solution/feature/auth/screen/login.dart';
import 'package:login_2_it_solution/feature/dashboard/dashboard.dart';
import 'package:login_2_it_solution/feature/rightside_menu/lead_category/lead_category.dart';
import 'package:login_2_it_solution/feature/sidebar/main_screen.dart';
import 'package:sizer/sizer.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return Sizer(
      builder: (context, orientation, deviceType) {
        return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Oxdo',
        theme: ThemeData(colorScheme: .fromSeed(seedColor: Colors.deepPurple)),
        home: MainScreen(),
      );
    }
    );
  }
}


class Test extends StatefulWidget {
  const Test({super.key});

  @override
  State<Test> createState() => _TestState();
}

class _TestState extends State<Test> {
  @override
  Widget build(BuildContext context) {
    return 
Scaffold(
  appBar: AppBar(
    actions: [
      PopupMenuButton<String>(
        onSelected: (value) {
          print(value);
        },
        itemBuilder: (context) => [
          PopupMenuItem(value: "A", child: Text("A")),
          PopupMenuItem(value: "B", child: Text("B")),
        ],
      ),
    ],
  ),
);;
  }
}