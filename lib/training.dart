import 'package:card/fitness.dart';
import 'package:card/strenght.dart';
import 'package:flutter/material.dart';

class Training extends StatefulWidget {
  const Training({super.key});

  @override
  State<Training> createState() => _TrainingState();
}

class _TrainingState extends State<Training> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("Home Workout"),
        backgroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                buildcard(context,"Cardio","""Cardio exercises offer numerous health benefits, including:

Heart Health: Cardio strengthens the heart, improving its efficiency and lowering the risk of heart disease and stroke.

Improved Lung Capacity: Cardio enhances lung function, increasing oxygen intake and stamina.""",const Fitness()),
                buildcard(context,"Home Workout","""
Home workouts can offer several health benefits:

Increased Strength and Flexibility: Bodyweight exercises, resistance bands, and other home workout tools can improve muscle strength, flexibility, and overall fitness.

Enhanced Immune Function: Regular physical activity can boost the immune system, helping the body fight off infections and illnesses.""",StrengthTrainingPage())
              ],
            ),)
          ],
        ),
      ),
    );
  }


  Widget buildcard(BuildContext context, String Type , String Details , Widget Page){
    return Card(
      color: const Color.fromARGB(255, 10, 176, 160),
      child:Padding(padding: const EdgeInsets.all(16), 
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
        
          Text(Type,style: const TextStyle(fontSize: 18,fontWeight: FontWeight.bold,color: Color.fromARGB(255, 243, 243, 243)),),
          const SizedBox(height: 10,),
          Text(Details,style: const TextStyle(fontWeight: FontWeight.bold,color: Colors.white),),
          const SizedBox(height: 15,),
          Padding(padding: const EdgeInsets.only(),
          child: 
          ElevatedButton(
            onPressed:(){Navigator.push(context, MaterialPageRoute(builder: (context) => Page));},
            style: ElevatedButton.styleFrom(backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            shape: const BeveledRectangleBorder()),
            child: Text('Start ${Type} Today'),
            
            ),
          )
        ],
      ),
      )
    
    );
}

}