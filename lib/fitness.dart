import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:async';


class Fitness extends StatelessWidget {
  const Fitness({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar:AppBar(
        backgroundColor: Colors.white,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          Text("Cardio",style: TextStyle(fontSize: 25,fontWeight:FontWeight.w500),),
          SizedBox(height: 10,),
         
        ],)
      ),
      body:ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const SizedBox(height: 10,),
         
            _buildcardiocard(context, "Walking", const Walking()),
            _buildcardiocard(context, "Running", const running()),
            _buildcardiocard(context, "Cycling", const cycling()),
            _buildcardiocard(context, "Skipping", const Skipping())
          ],
        ),);
      
    
      
  }
   

  Widget _buildcardiocard(BuildContext context,String Cardio,Widget page){
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
                Cardio,
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

class CardioPage extends StatefulWidget {
  final String cardioName;
  final String cardioDetails;
  final String image;
  final double caloriesPerMinute;
  final String audio;
  

  const CardioPage({super.key, 
    required this.cardioName,
    required this.cardioDetails,
    required this.image,
    required this.caloriesPerMinute,
    required this.audio
  });

  @override
  _CardioPageState createState() => _CardioPageState();
}

class _CardioPageState extends State<CardioPage> {
  Timer? _timer;
  int _timeLeft = 0;
  bool isRunning = false;

  double _caloriesBurned = 0.0;
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool calories = false;
  void startTimer() {
    _caloriesBurned = 0;
    _timeLeft = 0;
    setState(() {
      isRunning=true;
    });
    if (_timer != null) {
      _timer!.cancel();
    }
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_timeLeft<1000) {
          _timeLeft++;
        } else {
          _timer?.cancel();
          isRunning = false;
        
        }
      });
    });
  }
    Future<void> playSound() async {
    await _audioPlayer.play(AssetSource(widget.audio));
  }

  void stop() {
  _caloriesBurned = _timeLeft * widget.caloriesPerMinute;
  playSound();
  
  setState(() {
    isRunning = false;
    calories = true; // Show calories burned.
  });

  // Hide calories after 5 seconds.
  Timer(const Duration(seconds: 5), () {
    setState(() {
      calories = false;
    });
  });
}

  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
     appBar: AppBar(
      title: Text(widget.cardioName),
      backgroundColor:Colors.white ,
    ),
     body: SingleChildScrollView(
      child: Padding(padding: const EdgeInsets.all(16),
      child: Column(
        
        children: [
          Padding(padding: const EdgeInsets.only(right: 250),
          child: 
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.cardioName,style:const TextStyle(fontSize: 26,fontWeight: FontWeight.bold))
            ],
          ),
          ),

          
          const SizedBox(height: 10),
          
            const SizedBox(height: 20),
            
          Card(
            
            color: Colors.black,
            child: Padding(padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                
                Text(widget.cardioDetails,style: const TextStyle(color: Colors.white,fontSize: 18),),
                const SizedBox(height: 20,),
                Card(
                  child: Image.asset(widget.image,height: 250,),
                ),
                const SizedBox(height: 30,),
                Container(
              color:Colors.white,
              height: 1.0,
              width: double.infinity,
            ),
            const SizedBox(height: 20,),
                 if(!isRunning)
           ElevatedButton(
              onPressed: () {
                  startTimer();
                  setState(() {
                    calories=false;
                  });
            
                },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
              
              child: Text('Start Timer',style: TextStyle(color: Colors.black),),
            ),
            const SizedBox(height: 20,),
            if (isRunning)
              Column(
               
                children: [
                  const CircularProgressIndicator(color: Colors.white,),
                  const SizedBox(height: 25),
                  Text('Time : $_timeLeft s', style: const TextStyle(color: Colors.white,fontSize: 20)),
                  const SizedBox(height: 20,),
                  ElevatedButton(onPressed: stop,style: ElevatedButton.styleFrom(backgroundColor: Colors.white), child: const Text("Stop",style: TextStyle(color: Colors.black),),
                  )
                ],
              ),
            
           Column(
            children: [
            if(calories)
                  Text('Calories Burned : $_caloriesBurned',style: const TextStyle(fontSize: 18,color: Colors.white),),]
           ),
              ],  
            ),
            
            ),),
        ],
      ),),
    ));
  }
}




class Walking extends StatelessWidget {
  const Walking({super.key});

  @override
  Widget build(BuildContext context) {
    return CardioPage(cardioName: "Walking ",
     cardioDetails:"Walking is a simple, low-impact exercise that improves cardiovascular health, strengthens muscles, and boosts mood. It can be done almost anywhere, requiring no special equipment, making it an easy way to stay active daily", 
     caloriesPerMinute: 4.5,image: "assets/walking.gif",audio: "sound/button.mp3",);
  }
}

class running extends StatelessWidget {
  const running({super.key});

  @override
  Widget build(BuildContext context) {
    return CardioPage(cardioName: "Running",
     cardioDetails:"Running is a high-intensity cardiovascular exercise that helps improve endurance, strengthen muscles, and boost overall fitness. It engages the entire body and burns calories at a faster rate than walking.",
      caloriesPerMinute: 12.5,image: "assets/running.gif",audio: "sound/button.mp3",);
  }
}

class cycling extends StatelessWidget {
  const cycling({super.key});

  @override
  Widget build(BuildContext context) {
    return CardioPage(cardioName: "Cycling",
     cardioDetails:"Cycling is an excellent low-impact cardiovascular exercise that strengthens leg muscles, improves endurance, and boosts heart health. It's also a great option for burning calories at varying intensities.",
    caloriesPerMinute: 9.8,image: "assets/cycle.gif",audio: "sound/button.mp3",);
  }
} 

class Skipping extends StatelessWidget {
  const Skipping({super.key});

  @override
  Widget build(BuildContext context) {
    return CardioPage(cardioName:"Skipping",
     cardioDetails:"Skipping (jump rope) is a high-intensity exercise that improves cardiovascular fitness, coordination, and strengthens various muscle groups. It's highly effective for burning calories quickly.", 
     caloriesPerMinute: 13,image: "assets/jump.gif",audio: "sound/button.mp3",);
  }
} 

