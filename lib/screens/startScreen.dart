
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:quiz_app/screens/quizScreen.dart';

import '../main.dart';
import '../res/colors.dart';
import '../res/images.dart';
import '../res/textstyle.dart';


class start_Screen extends StatelessWidget {
  const start_Screen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        padding:  EdgeInsets.all(size.height*0.04),
        decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [blue, darkBlue],
            )),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Image.asset(
              balloon2,
              height: size.height*0.48,
              width: size.width*0.80,
            ),
            const SizedBox(height: 10),
            normalText(color: Colors.white, size: 20, text: "Welcome to our"),
            headingText(color: Colors.white, size: 34, text: "Quiz App"),
            const SizedBox(height: 12),
            normalText(
                color: Colors.white70,
                size: 18,
                text: "Do you feel confident? Here you'll face our most difficult questions!"),
            const Spacer(),
            Align(
              alignment: Alignment.center,
              child: GestureDetector(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const QuizScreen()));
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 7),
                  alignment: Alignment.center,
                  width: size.width ,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: headingText(color: blue, size: 18, text: "Continue"),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}



