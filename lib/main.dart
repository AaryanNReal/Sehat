import 'package:card/training.dart';
import 'package:card/yoga.dart';
import 'package:firebase_core/firebase_core.dart';
import 'homepage.dart';
import 'search.dart';
import 'package:flutter/material.dart';
import 'Profile_page.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(SehatApp());
}
class SehatApp extends StatelessWidget {
  const SehatApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(),
      theme: ThemeData(
        primarySwatch: Colors.green,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const Ghar(),
    const Training(),
    const YogaApp(),
    ProfilePage()
  ];

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body:
       _pages[_currentIndex],
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: Colors.teal,
          currentIndex: _currentIndex,
          onTap: onTabTapped,
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
              backgroundColor: Colors.teal
            ),
            BottomNavigationBarItem(
                icon: Icon(Icons.run_circle_outlined), 
                label: "Home Workout",
                backgroundColor: Colors.teal),
              BottomNavigationBarItem(icon:Icon(Icons.accessibility_new),label: "Yoga",backgroundColor: Colors.teal),
              BottomNavigationBarItem(icon:Icon(Icons.person),label: "Profile",backgroundColor: Colors.teal)
                

            
          ],
        ),
        floatingActionButton: FloatingActionButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SearchPage()),
              );
            },
            backgroundColor: Colors.teal[100],
            child: Icon(Icons.qr_code_scanner,color: Colors.grey[800],)));
  }
}




