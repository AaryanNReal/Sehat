import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';


class DietPlanScreen extends StatefulWidget {
  const DietPlanScreen({super.key});

  @override
  _DietPlanScreenState createState() => _DietPlanScreenState();
}

class _DietPlanScreenState extends State<DietPlanScreen> {
  User? _user;

  int _age = 0;
  double _weight = 0.0;
  double _height = 0.0;
  double _bmi = 0.0;
  String _dietPreference = 'Non-Veg'; // Default diet preference
  String _dietPlan = '';
  bool _planGenerated = false; // Tracks if the plan has been generated

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
    _loadStoredDietPlan();
  }

  // Load user profile information from Firestore
 Future<void> _loadUserProfile() async {
  _user = FirebaseAuth.instance.currentUser;

  if (_user != null) {
    DocumentSnapshot userData = await FirebaseFirestore.instance.collection('users').doc(_user!.uid).get();

    setState(() {

      _age = userData['age'] ?? 0;
      _weight = (userData['weight'] ?? 0).toDouble(); // Weight in kg
      _height = (userData['height'] ?? 0).toDouble(); // Height in cm

      // Convert height from cm to meters and calculate BMI
      _bmi = _calculateBMI();

      // Debug print statements to check the conversion and BMI
      print('Weight: $_weight kg');
      print('Height: $_height cm');
      print('BMI: $_bmi');
    });
  }
}


  // Calculate BMI using the retrieved weight and height
 // Calculate BMI using the retrieved weight and height (convert height from cm to meters)
double _calculateBMI() {
  double heightInMeters = _height / 100; // Convert height from cm to meters
  if (heightInMeters > 0 && _weight > 0) {
    return _weight / (heightInMeters * heightInMeters); // BMI formula
  }
  return 0.0;
}


  // Load stored diet plan from SharedPreferences
  Future<void> _loadStoredDietPlan() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _dietPlan = prefs.getString('plan') ?? '';
      _planGenerated = _dietPlan.isNotEmpty;
    });
  }

  // Save the generated diet plan to SharedPreferences
  Future<void> _saveDietPlan() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('plan', _dietPlan);
  }

  // Generate a new diet plan based on user information
  String _generateDietPlan() {
    double heightInMeters = _height / 100;
    double calorieNeeds = 10 * _weight + 6.25 * (heightInMeters * 100) - 5 * _age + 5;

    double calorieAdjustment = 0;
    String dietPlan = '';

    if (_bmi < 18.5) {
      calorieAdjustment = 300;
      dietPlan = 'You are underweight. Increase your calorie intake by about 300-500 calories per day.\n';
    } else if (_bmi >= 18.5 && _bmi < 24.9) {
      dietPlan = 'You are in the healthy weight range. Maintain your current calorie intake.\n';
    } else {
      calorieAdjustment = -500;
      dietPlan = 'You are overweight. Reduce your calorie intake by about 300-500 calories per day.\n';
    }

    calorieNeeds += calorieAdjustment;

    double proteinIntake = 0.8 * _weight;
    if (_bmi < 18.5) {
      proteinIntake = 1.2 * _weight;
    } else if (_bmi >= 25) {
      proteinIntake = 1.0 * _weight;
    }

    double fatIntake = (calorieNeeds * 0.25) / 9;
    double carbIntake = (calorieNeeds - (proteinIntake * 4) - (fatIntake * 9)) / 4;

    dietPlan += '\nYour Daily Nutritional Requirements:\n';
    dietPlan += '• Calories: ${calorieNeeds.toStringAsFixed(0)} kcal\n';
    dietPlan += '• Protein: ${proteinIntake.toStringAsFixed(1)} grams\n';
    dietPlan += '• Fats: ${fatIntake.toStringAsFixed(1)} grams\n';
    dietPlan += '• Carbohydrates: ${carbIntake.toStringAsFixed(1)} grams\n';

    dietPlan += '\nRecommended Diet:\n';

    if (_dietPreference == 'Non-Veg') {
      dietPlan += '''
- Chicken breast, lean meats, fish
- Eggs for breakfast or snacks
- Dairy: yogurt, cheese, milk
- Vegetables: spinach, broccoli, kale
- Whole grains: oats, brown rice, quinoa
- Healthy fats: nuts, seeds, olive oil
''';
    } else if (_dietPreference == 'Veg') {
      dietPlan += '''
- Dairy: yogurt, paneer, milk (exclude eggs)
- Legumes: lentils, chickpeas, beans
- Vegetables: spinach, broccoli, sweet potatoes
- Whole grains: quinoa, oats, brown rice
- Healthy fats: nuts, seeds, olive oil
''';
    } else if (_dietPreference == 'Vegan') {
      dietPlan += '''
- Plant-based proteins: tofu, tempeh, lentils, beans
- Dairy alternatives: almond milk, soy yogurt
- Vegetables: kale, spinach, sweet potatoes, broccoli
- Whole grains: quinoa, oats, brown rice
- Healthy fats: avocados, nuts, seeds, olive oil
''';
    }

    return dietPlan;
  }

  // Update the diet plan when needed
  void _updateDietPlan() {
    if (_weight > 0 && _height > 0 && _bmi > 0) {
      setState(() {
        _dietPlan = _generateDietPlan();
        _planGenerated = true;
        _saveDietPlan(); // Save updated diet plan to SharedPreferences
      });

      // Pass the updated diet plan back to the previous screen (if needed)
      Navigator.pop(context, _dietPlan);
    } else {
      // Show an error message if profile info is missing
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please Create A Profile First'),
        ),
      );
    }
  }

  // Navigate to ProfilePage to allow the user to edit their profile


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Diet Plan'),
        backgroundColor: Colors.teal,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
        
            const SizedBox(height: 10),
            Card(
              elevation: 4.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              color: Colors.teal[50],
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('User Information', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    Text('Age: $_age', style: const TextStyle(fontSize: 16)),
                    Text('Height: ${_height.toStringAsFixed(2)} m', style: const TextStyle(fontSize: 16)),
                    Text('Weight: ${_weight.toStringAsFixed(2)} kg', style: const TextStyle(fontSize: 16)),
                    Text('BMI: ${_bmi.toStringAsFixed(2)}', style: const TextStyle(fontSize: 16)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (!_planGenerated)
              DropdownButton<String>(
                value: _dietPreference,
                items: <String>['Non-Veg', 'Veg', 'Vegan'].map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _dietPreference = newValue!;
                    _updateDietPlan();
                  });
                },
                isExpanded: true,
                hint: const Text('Select Diet Preference', style: TextStyle(fontSize: 16)),
                style: const TextStyle(color: Colors.teal, fontSize: 16),
                dropdownColor: Colors.white,
              ),
            const SizedBox(height: 16),
            Card(
              elevation: 4.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              color: Colors.teal[50],
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Diet Plan', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    Text(_dietPlan.isEmpty ? 'No diet plan generated yet.' : _dietPlan, style: const TextStyle(fontSize: 16)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (_planGenerated)
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _planGenerated = false;
                    _dietPlan = ''; // Clear the diet plan to generate a new one
                  });
                  _saveDietPlan(); // Save the cleared state to SharedPreferences
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Generate New Plan', style: TextStyle(fontSize: 16)),
              ),
          ],
        ),
      ),
    );
  }
}
