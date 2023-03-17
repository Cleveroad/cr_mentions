import 'package:cr_mentions_example/pages/add_text_page.dart';
import 'package:cr_mentions_example/pages/saved_text_page.dart';
import 'package:cr_mentions_example/pages/simple_example_page.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const Example());
}

class Example extends StatelessWidget {
  const Example({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MainPage(),
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  static const items = [
    BottomNavigationBarItem(
      label: 'Add Text',
      icon: Icon(Icons.comment),
    ),
    BottomNavigationBarItem(
      label: 'Saved Text',
      icon: Icon(Icons.list),
    ),
    BottomNavigationBarItem(
      label: 'Short example',
      icon: Icon(Icons.short_text),
    ),
  ];

  static const _pages = [
    AddTextPage(),
    SavedTextPage(),
    SimpleExamplePage(),
  ];

  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        items: items,
        currentIndex: _currentIndex,
        selectedItemColor: Colors.deepOrange,
        unselectedItemColor: Colors.grey,
        onTap: _onTapped,
      ),
      body: _pages[_currentIndex],
    );
  }

  void _onTapped(int index) {
    setState(() => _currentIndex = index);
  }
}
