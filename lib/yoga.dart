import 'dart:async';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class YogaApp extends StatefulWidget {
  const YogaApp({super.key});

  @override
  State<YogaApp> createState() => _YogaAppState();
}

class _YogaAppState extends State<YogaApp> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: const Text("Yoga"),
        backgroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(" Yoga Positions", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25, backgroundColor: Colors.grey[200]),),
          const SizedBox(height: 20,),
          _buildyogacard(context, "ताड़ासन (Tadasana) - Mountain Pose", "Tap to see more details and start your timer!", const Mountain()),
          _buildyogacard(context, "वृक्षासन (Vrksasana) - Tree Pose", "Tap to see more details and start your timer!", const Tree()),
          _buildyogacard(context, "बालासन (Balasana) - Child's Pose", "Tap to see more details and start your timer!", const Child()),
          _buildyogacard(context, "काटिचक्रासन (Kati Chakrasana) - Waist Rotating Pose", "Tap to see more details and start your timer!", const Rotate()),
          _buildyogacard(context, "सुखासन - Sukhasana", "Tap to see more details and start your timer!", const Blanket()),
          _buildyogacard(context, "वज्रासन - वज्रासन", "Tap to see more details and start your timer!", const Bound()),
        ],
      ),
    );
  }
}

Widget _buildyogacard(BuildContext context, String yogaPos, String yogaDetails, Widget page) {
  return GestureDetector(
    onTap: () {
      Navigator.push(context, MaterialPageRoute(builder: (context) => page));
    },
    child: Card(
      color: Colors.teal,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(yogaPos, style: const TextStyle(fontSize: 18, color: Colors.white)),
            const SizedBox(height: 10),
            Text(yogaDetails, style: const TextStyle(color: Colors.white, fontSize: 15)),
          ],
        ),
      ),
    ),
  );
}

class Yoga extends StatefulWidget {
  final String yogaName;
  final String Header;
  final String detail;
  final String videoUrl;

  const Yoga({super.key, 
    required this.yogaName,
    required this.Header,
    required this.detail,
    required this.videoUrl
  });

  @override
  YogaPage createState() => YogaPage();
}

class YogaPage extends State<Yoga> {
  bool isRunning = false;
  int _timeElapsed = 0;
  Timer? _timer;
  final AudioPlayer _audioPlayer = AudioPlayer();
  
  late YoutubePlayerController _youtubeController;

  void startTimer() {
    if (_timer != null) {
      _timer!.cancel();
    }

    setState(() {
      _timeElapsed = 0;
      isRunning = true;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_timeElapsed < 10000) {
          _timeElapsed++;
        } else {
          _timer?.cancel();
          _playSound();
          setState(() {
            isRunning = false;
          });
        }
      });
    });
  }

  void stop() {
    if (isRunning) {
      setState(() {
        isRunning = false;
        _timer?.cancel();
      });
      _playSound();
    }
  }

  void _playSound() {
    _audioPlayer.play(AssetSource('sound/button.mp3'));
  }

  @override
  void initState() {
    super.initState();
    _youtubeController = YoutubePlayerController(
      initialVideoId: YoutubePlayer.convertUrlToId(widget.videoUrl)!,
      flags: const YoutubePlayerFlags(autoPlay: false, mute: false),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _audioPlayer.dispose();
    _youtubeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: Text(widget.Header),
        backgroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              Text(widget.Header, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.all(0),
                child: Card(
                  elevation: 5,
                  color: Colors.black,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Text(widget.detail, style: const TextStyle(color: Colors.white, fontSize: 16)),
                        const SizedBox(height: 25),
                        Container(
                          color: Colors.black,
                          height: 300, // Adjust as needed
                          width: double.infinity, // Adjust as needed
                          child: YoutubePlayer(
                            controller: _youtubeController
                          
                          ),
                        ),
                      Container(
                        width: double.infinity,
                        height: 1,
                        color: Colors.white,

                      ),
                      const SizedBox(height: 20,),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            
                           Column(
                            
                children: [
            
                  if (!isRunning)
                    Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: ElevatedButton(
                        onPressed: startTimer,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          shape: const BeveledRectangleBorder(),
                        ),
                        child: Text("Start The Timer", style: TextStyle(color: Colors.black)),
                      ),
                    ),
                  if (isRunning)
                    Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: Column(
                        children: [
                          const SizedBox(
                            height: 50,
                            width: 50,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 5,
                            ),
                          ),
                          const SizedBox(height: 15),
                          Text("Time Elapsed: ${_timeElapsed}s", style: const TextStyle(fontSize: 15,color: Colors.white)),
                          const SizedBox(height: 15),
                          ElevatedButton(
                            onPressed: stop,
                            style: ElevatedButton.styleFrom(
                              shape: const BeveledRectangleBorder(),
                              backgroundColor: Colors.white,
                            ),
                            child: Text("Stop", style: TextStyle(color: Colors.black)),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
                          ],
                        ),
                      ],
                    ),
                    
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class Mountain extends StatefulWidget {
  const Mountain({super.key});

  @override
  State<Mountain> createState() => _MountainState();
}

class _MountainState extends State<Mountain> {
  @override
  Widget build(BuildContext context) {
    return Yoga(
      yogaName: "ताड़ासन (Tadasana) - Mountain Pose",
      Header: "Tadasana - Mountain Pose",
      detail: """The Mountain Pose (Tadasana) offers several benefits for both physical and mental well-being. Here are some of the key benefits:
                  1. Improves Posture
                  2. Enhances Balance and Stability
                  3. Strengthens Legs and Core
                  4. Increases Awareness
                  5. Reduces Back Pain""",
      videoUrl: "https://youtu.be/5NxDs-ovJU8?si=RkF13HXvLLi59HlT", 
    );
  }
}

class Tree extends StatefulWidget {
  const Tree({super.key});

  @override
  State<Tree> createState() => _TreeState();
}

class _TreeState extends State<Tree> {
  @override
  Widget build(BuildContext context) {
    return Yoga(yogaName:"Vrksasana - Tree Pose" , Header:"Vrksasana - Tree Pose", detail:"""Vrksasana, or Tree Pose, is a popular yoga pose that offers a variety of physical and mental benefits. Here are some of the key benefits:
                  1. Improves Balance
                  2. Strengthens Legs
                  3. Increases Flexibility
                  4. Enhances Posture
                  5. Strengthens Core""", 
videoUrl: "https://youtu.be/wdln9qWYloU?si=rqUBRcCMACGUEzek");
  }
}

class Child extends StatefulWidget {
  const Child({super.key});

  @override
  State<Child> createState() => _ChildState();
}

class _ChildState extends State<Child> {
  @override
  Widget build(BuildContext context) {
    return Yoga(yogaName: "Balasana - Child's Pose", Header: "Balasana - Child's Pose", detail: """Child's Pose is a restorative yoga posture that is often used to relax and rejuvenate the body. It is commonly practiced at the beginning or end of a yoga session to promote relaxation and calmness.
          Benefits: 1.Stretches the Back
                          2. Relieves Tension
                          3. Calms the Mind
                          4.  Improves Flexibility
                          5.  Soothes Digestive System""",
     videoUrl: "https://youtu.be/kH12QrSGedM?si=gwI_pUe9APeiLVR4");
  }
}

class Rotate extends StatefulWidget {
  const Rotate({super.key});

  @override
  State<Rotate> createState() => _RotateState();
}

class _RotateState extends State<Rotate> {
  @override
  Widget build(BuildContext context) {
    return Yoga(yogaName:"Kati Chakrasana - Waist Rotating Pose", 
    Header:"Kati Chakrasana - Waist Rotating Pose",
     detail: """Kati Chakrasana is a yoga posture that helps in enhancing flexibility and improving core strength. It involves rotating the waist, which can aid in digestion and alleviate stiffness in the body.
Benefits: 1. Enhances Spinal Flexibility
                2. Improves Core Strength
                3. Aids in Digestion
                4. Reduces Waist Stiffness
                5. Stimulates Internal Organs"""
               
,
     videoUrl: "https://youtu.be/z_4OA56wH7c?si=Wc4Bkp1BbNNjtopu");
  }
}

class Blanket extends StatefulWidget {
  const Blanket({super.key});

  @override
  State<Blanket> createState() => _BlanketState();
}

class _BlanketState extends State<Blanket> {
  @override
  Widget build(BuildContext context) {
    return Yoga(yogaName: "Sukhasana",
     Header: " Sukhasana",
      detail: """Sukhasana is a simple seated yoga pose that encourages relaxation and enhances mental clarity. It is often used in meditation and promotes a sense of inner calm.+
Benefits:
1. Promotes Relaxation
2. Improves Flexibility in Hips and Knees
3. Enhances Mental Clarity
4. Encourages Proper Posture
5. Relieves Stress""",
     videoUrl:"https://youtu.be/ngi5pWhOTZc?si=p_jijpPnqUx3pjlI" );
  }
}

class Bound extends StatefulWidget {
  const Bound({super.key});

  @override
  State<Bound> createState() => _BoundState();
}

class _BoundState extends State<Bound> {
  @override
  Widget build(BuildContext context) {
    return Yoga(yogaName: "वज्रासन - वज्रासन", 
    Header: "वज्रासन - वज्रासन", 
    detail: """Vajrasana is a seated yoga posture that helps in improving digestion and calming the mind. It is often practiced after meals and provides a stable base for meditation.
Benefits:
1. Aids Digestion
2. Calms the Mind
3. Strengthens the Legs
4. Improves Posture
5. Reduces Stress
""", 
    videoUrl: "https://youtu.be/qLsZLHCWPlE?si=f7igihlVSSkz8g9g");
  }
}
