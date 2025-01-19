import 'dart:async';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:quiz_app/screens/startScreen.dart';

import '../controller/quizData_controller.dart';
import '../dataModel/quizModel.dart';
import '../res/colors.dart';
import '../res/images.dart';
import '../res/textstyle.dart';

class ResultScreen extends ConsumerWidget {
  final int score;
  final int total;
  final int correctquestions;

  const ResultScreen({Key? key, required this.score, required this.total, required this.correctquestions}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAnswers = ref.watch(userAnswersProvider);

    return Scaffold(
      body: WillPopScope(
        onWillPop: () async {
          // Navigate to the homepage
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (context) => start_Screen(),
            ),
                (Route<dynamic> route) => false,
          );
          // Return `false` to prevent the default back navigation
          return false;
        },
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.blue.shade800, Colors.purple.shade800],
            ),
          ),
          child: SafeArea(
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Text(
                          'Quiz Results',
                          style: GoogleFonts.poppins(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Column(
                            children: [
                              Text(
                                '$correctquestions',
                                style: GoogleFonts.poppins(
                                  fontSize: 48,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                'out of 10 correct',
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton.icon(
                          onPressed: (){
                            Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(
                              builder: (context) => start_Screen(),
                            ),
                            (Route<dynamic> route) => false,
                          );
                          },
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.blue.shade800,
                            backgroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 30, vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          icon: const Icon(Icons.refresh),
                          label: Text(
                            'Retake Quiz',
                            style: GoogleFonts.poppins(fontSize: 18),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Text(
                      'Summary',
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                        (context, index) => ShowSummeryItem(userAnswers[index] ,index: index,),
                    childCount: userAnswers.length,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ShowSummeryItem extends StatelessWidget {
  const ShowSummeryItem(this.question, {super.key, required this.index});

  final Question question;
  final int index;

  @override
  Widget build(BuildContext context) {
    final correctOption =
    question.options.firstWhere((option) => option.isCorrect);

    final isCorrect = question.selectedAnswer == correctOption.description;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      color: isCorrect
          ? Colors.green.withOpacity(0.1)
          : Colors.red.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  backgroundColor: isCorrect ? Colors.green : Colors.red,
                  child: Text(
                    ( index+1).toString(),
                    style: GoogleFonts.poppins(color: Colors.white),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                   question.description,
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildAnswerRow('Your Answer:', question.selectedAnswer ?? "Not Answered",
                isCorrect ? Colors.green : Colors.red),
            const SizedBox(height: 8),

            _buildAnswerRow('Correct Answer:',
                correctOption.description, Colors.green),
          ],
        ),
      ),
    );
  }

  Widget _buildAnswerRow(String label, String answer, Color color) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.white70,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            answer,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ),
      ],
    );
  }
}