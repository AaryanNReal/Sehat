import 'dart:async';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';


class StrengthTrainingPage extends StatelessWidget {
  const StrengthTrainingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Strength Training'),
            SizedBox(height: 10,),
          
          ],
        ),

        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        
      ),
      
      body: ListView(
        
        padding: const EdgeInsets.all(16),
        children: [
         
          _buildExerciseCard(context, "Push-ups", PushUpsPage()),
          _buildExerciseCard(context, "Squats", SquatsPage()),
          _buildExerciseCard(context, "Plank", PlankPage()),
          _buildExerciseCard(context, "Lunges", LungesPage()),
          _buildExerciseCard(context, "Glute Bridge", GluteBridgePage()),
          _buildExerciseCard(context, "Mountain Climbers", MountainClimbersPage()),
          _buildExerciseCard(context, "Leg Raises", LegRaisesPage()),
          _buildExerciseCard(context, "Burpees", BurpeesPage()),
        ],
      ),
    );
  }

  Widget _buildExerciseCard(BuildContext context, String title, Widget page) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => page));
      },
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: Colors.teal,
        margin: const EdgeInsets.symmetric(vertical: 10),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 10),
              Text(
                'Tap to see more details and start your timer!',
                style: TextStyle(color: Colors.grey[400]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ExercisePage extends StatefulWidget {
  final String exerciseName;
  final String exerciseDetails;
  final double caloriesPerMinute;
  final String benefits;
  final String image;

  const ExercisePage({super.key, 
    required this.exerciseName,
    required this.exerciseDetails,
    required this.caloriesPerMinute,
    required this.benefits,
    required this.image,
  });

  @override
  _ExercisePageState createState() => _ExercisePageState();
}

class _ExercisePageState extends State<ExercisePage> {
  Timer? _timer;
  int _timeLeft = 0;
  bool isRunning = false;
  final TextEditingController _timeController = TextEditingController();
  final AudioPlayer audioPlayer = AudioPlayer();

  void startTimer() {
    _timeLeft = 0;

    setState(() {
      isRunning = true;
    });

    if (_timer != null) {
      _timer!.cancel();
    }
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_timeLeft < 1000) {
          _timeLeft++;
        } else {
          _timer?.cancel();
          isRunning = false;
          play();
        }
      });
    });
  }

  void stop() {
    setState(() {
      isRunning = false;
    });
    _timer?.cancel();
    play();
    _showRepsDialog();
  }

  void play() {
    audioPlayer.play(AssetSource("sound/button.mp3"));
  }

  void _showRepsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        TextEditingController repsController = TextEditingController();
        return AlertDialog(
          title: const Text('Enter Repetitions'),
          content: TextField(
            controller: repsController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: "Number of repetitions",
            ),
          ),
          actions: [
            ElevatedButton(
              child: const Text('OK'),
              onPressed: () {
                int repetitions = int.tryParse(repsController.text) ?? 0;
                double caloriesBurned = calculateCaloriesBurned(repetitions);
                Navigator.of(context).pop();
                _showCaloriesDialog(repetitions, caloriesBurned);
              },
            ),
          ],
        );
      },
    );
  }

  void _showCaloriesDialog(int repetitions, double caloriesBurned) {
    showDialog(
      
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('${widget.exerciseName} Summary'),
          content: Text('You did $repetitions repetitions.\nCalories burned: ${caloriesBurned.toStringAsFixed(2)} kcal.'),
          actions: [
            ElevatedButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  double calculateCaloriesBurned(int repetitions) {
    // For this example, assuming that calories burned is based on time elapsed and repetitions
    double timeInMinutes = _timeLeft / 60;
    return widget.caloriesPerMinute * timeInMinutes;
  }

  @override
  void dispose() {
    audioPlayer.stop();
    _timer?.cancel();
    _timeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.exerciseName),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Card(
              color: Colors.black,
              elevation: 10,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text(
                      widget.exerciseName,
                      style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      widget.exerciseDetails,
                      style: const TextStyle(fontSize: 16, color: Colors.white),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "Benefits: ${widget.benefits}",
                      style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.bold),
                    ),
                    Image.asset(
                      widget.image,
                      height: 300,
                    ),
                    Container(
                      color: Colors.white,
                      height: 1.0,
                      width: double.infinity,
                    ),
                    const SizedBox(height: 20),
                    if (!isRunning)
                      ElevatedButton(
                        onPressed: startTimer,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                        ),
                        child: Text('Start Timer'),
                      ),
                    if (isRunning)
                      Column(
                        children: [
                          const CircularProgressIndicator(
                            color: Colors.white,
                          ),
                          const SizedBox(height: 15),
                          Text('Time : $_timeLeft s',
                              style: const TextStyle(color: Colors.white)),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: stop,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.black,
                            ),
                            child: Text("Stop"),
                          )
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PushUpsPage extends StatelessWidget {
  const PushUpsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ExercisePage(
      exerciseName: "Push-ups",
      exerciseDetails: "Start in a plank position. Lower your body until your chest nearly touches the floor, then push yourself back up.",
      caloriesPerMinute: 7.0,
      benefits: "Works chest, shoulders, and triceps.",
      image: 'assets/pushup.gif',
    );
  }
}

class SquatsPage extends StatelessWidget {
  const SquatsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ExercisePage(
      exerciseName: "Squats",
      exerciseDetails: "Stand with your feet shoulder-width apart. Lower your hips down and back as if sitting in a chair.",
      caloriesPerMinute: 6.0,
      benefits: "Strengthens quads, hamstrings, and glutes.",
      image: 'assets/squat.gif',
    );
  }
}

class PlankPage extends StatelessWidget {
  const PlankPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ExercisePage(
      exerciseName: "Plank",
      exerciseDetails: "Hold a push-up position, keeping your body in a straight line from head to heels.",
      caloriesPerMinute: 5.0,
      benefits: "Strengthens the core, shoulders, and glutes.",
      image: 'assets/plank.gif',
    );
  }
}

class LungesPage extends StatelessWidget {
  const LungesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ExercisePage(
      exerciseName: "Lunges",
      exerciseDetails: "Step forward with one leg, lowering your hips until both knees are bent at about a 90-degree angle.",
      caloriesPerMinute: 6.5,
      benefits: "Targets quads, hamstrings, and glutes.",
      image: 'assets/lunges.gif',
    );
  }
}

class GluteBridgePage extends StatelessWidget {
  const GluteBridgePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ExercisePage(
      exerciseName: "Glute Bridge",
      exerciseDetails: "Lie on your back with knees bent and feet flat on the floor. Lift your hips to form a straight line from shoulders to knees.",
      caloriesPerMinute: 5.5,
      benefits: "Strengthens the glutes and lower back.",
      image: 'assets/gluets.gif',
    );
  }
}

class MountainClimbersPage extends StatelessWidget {
  const MountainClimbersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ExercisePage(
      exerciseName: "Mountain Climbers",
      exerciseDetails: "Start in a push-up position and alternate bringing your knees toward your chest in a running motion.",
      caloriesPerMinute: 9.0,
      benefits: "Improves cardiovascular fitness and strengthens core and lower body.",
      image: 'assets/climbers.gif',
    );
  }
}

class LegRaisesPage extends StatelessWidget {
  const LegRaisesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ExercisePage(
      exerciseName: "Leg Raises",
      exerciseDetails: "Lie on your back with legs extended. Lift them towards the ceiling, then lower back down.",
      caloriesPerMinute: 4.5,
      benefits: "Strengthens lower abs and hip flexors.",
      image: 'assets/leg.gif',
    );
  }
}

class BurpeesPage extends StatelessWidget {
  const BurpeesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ExercisePage(
      exerciseName: "Burpees",
      exerciseDetails: "Begin standing, drop into a squat, kick your feet back into a push-up position, and return to standing with a jump.",
      caloriesPerMinute: 10.0,
      benefits: "Full-body workout that improves strength and endurance.",
      image: 'assets/burpes.gif',
    );
  }
}
