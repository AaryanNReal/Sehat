import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pedometer/pedometer.dart';
import 'package:permission_handler/permission_handler.dart';
import 'goal.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

class Ghar extends StatefulWidget {
  const Ghar({super.key});

  @override
  State<Ghar> createState() => _GharState();
}

class _GharState extends State<Ghar> {
  int steps = 0;
  late Stream<StepCount> _stepCountStream;
  String status = "Unknown";
  String plan = "";  // This will hold the diet plan
  bool clicked = false;
  String _userName = '';
  User? _user;
  DateTime? lastResetDate;
  
   @override
  void initState() {
    super.initState();
    stepsdone();
    _loadData();
    initstepscount();
    _loadUser();
    _scheduleDailyReset(); // Schedule the daily reset at midnight
  }

  // Request permission and initialize step counter
  Future<void> stepsdone() async {
    if (await Permission.activityRecognition.request().isGranted) {
      initstepscount();
    } else {
      setState(() {
        status = "Permission Denied";
      });
    }
  }

  // Initialize step counter
  void initstepscount() {
    _stepCountStream = Pedometer.stepCountStream;
    _stepCountStream.listen(stepscount).onError(error);
  }

  // Listen to step count changes
  void stepscount(StepCount event) {
    setState(() {
      steps = event.steps;
    });
    _saveData(); // Save the updated step count
    _checkReset(); // Check if steps should be reset
  }

  void error(error) {
    setState(() {
      status = "Step Count Not Available";
    });
  }

  // Load data from SharedPreferences
  Future<void> _loadData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      plan = prefs.getString("plan") ?? "";
      steps = prefs.getInt('steps') ?? 0;
      lastResetDate = DateTime.tryParse(prefs.getString('lastResetDate') ?? '');
    });
  }

  // Save data to SharedPreferences
  Future<void> _saveData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString("plan", plan);
    await prefs.setInt("steps", steps);
    await prefs.setString('lastResetDate', lastResetDate?.toIso8601String() ?? '');
  }

  // Reset the steps if 24 hours have passed
  void _checkReset() {
    DateTime now = DateTime.now();
    if (lastResetDate == null || now.difference(lastResetDate!).inHours >= 24) {
      setState(() {
        steps = 0;
        lastResetDate = now;
      });
      _saveData(); // Save the reset date and steps
    }
  }

  // Schedule a daily reset at midnight
  void _scheduleDailyReset() {
    DateTime now = DateTime.now();
    DateTime nextResetTime = DateTime(now.year, now.month, now.day + 1); // Midnight

    Timer(Duration(seconds: nextResetTime.difference(now).inSeconds), () {
      setState(() {
        steps = 0;
        lastResetDate = DateTime.now();
      });
      _saveData(); // Save the reset data
      _scheduleDailyReset(); // Schedule the next reset
    });
  }

  // Load user from FirebaseAuth
  Future<void> _loadUser() async {
    setState(() {
      _user = FirebaseAuth.instance.currentUser;
    });

    if (_user != null) {
      DocumentSnapshot doc = await FirebaseFirestore.instance.collection('users').doc(_user!.uid).get();
      setState(() {
        _userName = doc['name'] ?? '';
      });
    }
  }

  // Change page to diet plan screen and save returned plan
  void changePage() async {
    final dietPlan = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => DietPlanScreen()),
    );

    if (dietPlan != null) {
      setState(() {
        plan = dietPlan; // Update the plan with the returned diet plan
        clicked = true;  // Mark button as clicked
      });
      _saveData();  // Save the updated diet plan
    } else {
      print("No diet plan returned");  // Debug: Check if dietPlan is null
    }
  }

  // Load user from FirebaseAuth
 
  // Sign out user
  
 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("Home"),
       
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_userName.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Welcome To Sehat $_userName",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),
                    
                  ],
                ),
             
              SizedBox(height: 10),
              Padding(
                padding: EdgeInsets.only(left: 77),
                child: buildStepCounter(),
              ),
              const SizedBox(height: 10),
              const Divider(color: Colors.black),
              const SizedBox(height: 10),
              BuildGoal(),
              const Divider(color: Colors.black),
                
            ],
          ),
        ),
      ),
    );
  }

  // Widget to display step counter
  Widget buildStepCounter() {
    return Card(
      elevation: 5,
      color: Colors.teal,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text("Steps Walked Today", style: TextStyle(fontSize: 18, color: Colors.white)),
            const SizedBox(height: 10),
            Text(
              steps.toString(),
              style: const TextStyle(fontSize: 35, color: Colors.white, fontWeight: FontWeight.w900),
            ),
          ],
        ),
      ),
    );
  }

  // Widget to display goal information
  Widget BuildGoal() {
    return Column(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(padding: EdgeInsets.only(left: 100),
            child: Column(
              children: [
        if(plan.isEmpty)
        Text("Create A Diet Plan",style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold),),
         SizedBox(height: 10,),
        
        
        if(plan.isEmpty)
        ElevatedButton(
          onPressed: changePage,
          style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
          child: Text("Goals ", style: TextStyle(color: Colors.white)),
        ),
              ]
            )
            )
        ],
        
        
        ),
        const SizedBox(height: 5),
        if (plan.isNotEmpty)
          Card(
            elevation: 5,
            color: Colors.teal[100],
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(plan, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                  SizedBox(height: 15,),
                    ElevatedButton(
          onPressed: changePage,
          style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
          child: Text("Reset Goals", style: TextStyle(color: Colors.white)),
        ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}  