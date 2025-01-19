import 'dart:async';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';

import '../controller/quizData_controller.dart';
import '../dataModel/quizModel.dart';
import 'resultScreen.dart';
import '../res/colors.dart';
import '../res/images.dart';
import '../res/textstyle.dart';

class QuizScreen extends ConsumerStatefulWidget {
  const QuizScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<QuizScreen> createState() => _QuizScreenState();
}

//
class _QuizScreenState extends ConsumerState<QuizScreen> {
  int _currentQuestionIndex = 0;
  int correctanswers = 0;
  int _score = 0;
  int seconds = 30;
  int correctAnswMarks = 4;
  int negativeMarks = 1;
  Timer? timer;
  var optionsColor = [
    Colors.white,
    Colors.white,
    Colors.white,
    Colors.white,
    Colors.white,
  ];

  resetColors() {
    optionsColor = [
      Colors.white,
      Colors.white,
      Colors.white,
      Colors.white,
      Colors.white,
    ];
  }

  @override
  void initState() {
    super.initState();
    startTimer();

  }

  @override
  void dispose() {
    timer!.cancel();
    super.dispose();
  }

  startTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (seconds > 0) {
          seconds--;
        } else {
          ref.read(userAnswersProvider.notifier).selectAnswer(_currentQuestionIndex, "Not Answered");

          _submitAnswer(false);
        }
      });
    });
  }

  void _submitAnswer(bool isCorrect) {

    setState(() {
      resetColors();
      timer!.cancel();
      seconds = 30;
      startTimer();
      if (isCorrect) {
        _score = _score + correctAnswMarks;
        correctanswers++;
      } else {
        _score = _score - negativeMarks;
      }
      if (_currentQuestionIndex < 9) {
        _currentQuestionIndex++;
      } else {
        timer!.cancel();

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ResultScreen(
              score: _score,
              total: 40,
              correctquestions: correctanswers,
            ),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    final quizAsync = ref.watch(quizProvider);
    final userAnswers = ref.watch(userAnswersProvider);

    return Scaffold(
      body: Container(
        width: double.infinity,
      height: double.infinity,
      padding:  EdgeInsets.symmetric(horizontal: size.height*0.02,vertical: size.height*0.05),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.blue.shade800, Colors.purple.shade800],
        ),
      ),
        child: quizAsync.when(
                data: (quiz) {
        // final quizdata = snapshot.data!;
        final questions = quiz.questions;
        // final question = questions[_currentQuestionIndex];
        final question = userAnswers[_currentQuestionIndex];
        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(50),
                        border: Border.all(color: lightgrey, width: 2),
                      ),
                      child: IconButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          icon: const Icon(
                            CupertinoIcons.xmark,
                            color: Colors.white,
                            size: 28,
                          )),
                    ),
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        normalText(color: Colors.white, size: 24, text: "$seconds"),
                        SizedBox(
                          width: 80,
                          height: 80,
                          child: CircularProgressIndicator(
                            value: seconds / 60,
                            valueColor: const AlwaysStoppedAnimation(Colors.white),
                            backgroundColor: Colors.white.withOpacity(0.2),

                          ),
                        ),
                      ],
                    ),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: lightgrey, width: 2),
                      ),
                      child: TextButton.icon(
                          onPressed: null,
                          icon: const Icon(CupertinoIcons.heart_fill, color: Colors.white, size: 18),
                          label: normalText(color: Colors.white, size: 14, text: "Like")),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  "Question ${_currentQuestionIndex + 1} of ${questions.length}",
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w400,
                  ),
                ),

                const SizedBox(height: 20),
                LinearProgressIndicator(
                  backgroundColor: Colors.white.withOpacity(0.2),
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  value: (_currentQuestionIndex + 1) / questions.length,
                ),
                const SizedBox(height: 16),
                Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Text(
                      question.description,
                      textAlign: TextAlign.justify,
                        softWrap: true,
                      style: GoogleFonts.poppins(
                        color: Colors.black87,
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                ListView.builder(
                  shrinkWrap: true,
                  itemCount: question.options.length,
                  itemBuilder: (BuildContext context, int index) {
                    bool correctAnser = question.options[index].isCorrect;
                    return GestureDetector(
                      onTap: () {
                        ref.read(userAnswersProvider.notifier).selectAnswer(_currentQuestionIndex, question.options[index].description);
                        setState(( ) {
                          if (correctAnser) {
                            optionsColor[index] = Colors.green;
                            Future.delayed(const Duration(seconds: 1), () {
                              _submitAnswer(correctAnser);
                            });
                          } else {
                            optionsColor[index] = Colors.red;
                            Future.delayed(const Duration(seconds: 1), () {
                              _submitAnswer(correctAnser);
                            });
                          }
                        });
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 14),
                        alignment: Alignment.center,
                        width: size.width - 100,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: optionsColor[index],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: headingText(color: blue, size: 18, text: question.options[index].description),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
                },
                loading: () => Center(child: CircularProgressIndicator()),
                error: (error, stack) => Center(child: Text('Error: $error')),
              ),
      ),
    );
  }
}

// class QuizScreen extends StatefulWidget {
//   const QuizScreen({Key? key}) : super(key: key);
//
//   @override
//   State<QuizScreen> createState() => _QuizScreenState();
// }
// //
// class _QuizScreenState extends State<QuizScreen> {
//   late Future<Quiz> _quizData;
//   int _currentQuestionIndex = 0;
//   int correctanswers = 0;
//   int _score = 0;
//   int seconds = 30;
//   int correctAnswMarks=4;
//   int negativeMarks=1;
//   Timer? timer;
//   var optionsColor = [
//     Colors.white,
//     Colors.white,
//     Colors.white,
//     Colors.white,
//     Colors.white,
//   ];
//   resetColors() {
//     optionsColor = [
//       Colors.white,
//       Colors.white,
//       Colors.white,
//       Colors.white,
//       Colors.white,
//     ];
//   }
//
//   @override
//   void initState() {
//     super.initState();
//     startTimer();
//
//     _quizData = fetchQuizData();
//   }
//
//   @override
//   void dispose() {
//     timer!.cancel();
//     super.dispose();
//   }
//
//   startTimer() {
//     timer = Timer.periodic(const Duration(seconds: 1), (timer) {
//       setState(() {
//         if (seconds > 0) {
//           seconds--;
//         } else {
//           _submitAnswer(false);
//         }
//       });
//     });
//   }
//
//   void _submitAnswer(bool isCorrect) {
//     setState(() {
//
//       resetColors();
//       timer!.cancel();
//       seconds = 30;
//       startTimer();
//       if (isCorrect) {
//
//         _score= _score+correctAnswMarks;
//         correctanswers++;
//       }
//       else{
//         _score=_score-negativeMarks;
//       }
//       if (_currentQuestionIndex < 9) {
//         _currentQuestionIndex++;
//       } else {
//         timer!.cancel();
//
//         Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (context) => ResultsScreen(score: _score ,total: 40,correctquestions: correctanswers,),
//           ),
//         );
//       }
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     var size = MediaQuery
//         .of(context)
//         .size;
//     return Scaffold(
//       body: SafeArea(
//         child: Container( width: double.infinity,
//           height: double.infinity,
//           padding: const EdgeInsets.all(12),
//           decoration: BoxDecoration(
//             gradient: LinearGradient(
//               begin: Alignment.topLeft,
//               end: Alignment.bottomRight,
//               colors: [Colors.blue.shade800, Colors.purple.shade800],
//             ),
//           ),
//           // decoration: const BoxDecoration(
//           //     gradient: LinearGradient(
//           //       begin: Alignment.topCenter,
//           //       end: Alignment.bottomCenter,
//           //       colors: [blue, darkBlue],
//           //     )),
//           child: FutureBuilder<Quiz>(
//             future: _quizData,
//             builder: (context, snapshot) {
//               if (snapshot.connectionState == ConnectionState.waiting) {
//                 return const Center(child: CircularProgressIndicator());
//               } else if (snapshot.hasError) {
//                 return Center(child: Text('Error: ${snapshot.error}'));
//               } else if (snapshot.hasData) {
//                 final quizdata = snapshot.data!;
//                 final questions = quizdata.questions;
//                 final question = questions[_currentQuestionIndex];
//
//                 return SingleChildScrollView(
//                   child: Padding(
//                     padding: const EdgeInsets.all(16.0),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.stretch,
//                       children: [
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             Container(
//                               decoration: BoxDecoration(
//                                 borderRadius: BorderRadius.circular(50),
//                                 border: Border.all(color: lightgrey, width: 2),
//                               ),
//                               child: IconButton(
//                                   onPressed: () {
//                                     Navigator.pop(context);
//                                   },
//                                   icon: const Icon(
//                                     CupertinoIcons.xmark,
//                                     color: Colors.white,
//                                     size: 28,
//                                   )),
//                             ),
//                             Stack(
//                               alignment: Alignment.center,
//                               children: [
//                                 normalText(
//                                     color: Colors.white,
//                                     size: 24,
//                                     text: "$seconds"),
//                                 SizedBox(
//                                   width: 80,
//                                   height: 80,
//                                   child: CircularProgressIndicator(
//                                     value: seconds / 60,
//                                     valueColor:
//                                     const AlwaysStoppedAnimation(Colors.white),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                             Container(
//                               decoration: BoxDecoration(
//                                 borderRadius: BorderRadius.circular(16),
//                                 border: Border.all(color: lightgrey, width: 2),
//                               ),
//                               child: TextButton.icon(
//                                   onPressed: null,
//                                   icon: const Icon(CupertinoIcons.heart_fill,
//                                       color: Colors.white, size: 18),
//                                   label: normalText(
//                                       color: Colors.white, size: 14, text: "Like")),
//                             ),
//                           ],
//                         ),
//                         const SizedBox(height: 20),
//                         Text(
//                           "Question ${_currentQuestionIndex + 1} of ${questions.length}",
//                           style: GoogleFonts.poppins(
//                             color: Colors.white,
//                             fontSize: 18,
//                             fontWeight: FontWeight.w400,
//                           ),
//                         ),
//
//                         const SizedBox(height: 20),
//                         LinearProgressIndicator(
//                           backgroundColor: Colors.white.withOpacity(0.2),
//                           valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
//                           value: (_currentQuestionIndex + 1) / questions.length,
//                         ),
//                         const SizedBox(height: 16),
//                         Card(
//                           elevation: 8,
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(15),
//                           ),
//                           color: Colors.white,
//                           child: Padding(
//                             padding: const EdgeInsets.all(14),
//                             child: Text(
//                               question.description,
//                               style: GoogleFonts.poppins(
//                                 color: Colors.black87,
//                                 fontSize: 20,
//                                 fontWeight: FontWeight.w500,
//                               ),
//                             ),
//                           ),
//                         ),
//                         // Text(
//                         //   question.description,
//                         //   softWrap: true,
//                         //   // textAlign: TextAlign.center,
//                         //   style: const TextStyle(fontSize: 20,color: Colors.white, fontWeight: FontWeight.w800),
//                         // ),
//                         const SizedBox(height: 16),
//                         // ...question.options.map((answer) => ElevatedButton(
//                         //   onPressed: () => _submitAnswer(answer.isCorrect),
//                         //   child: Text(answer.description),
//                         // )),
//                         //
//                         // const SizedBox(height: 20),
//                         ListView.builder(
//                           shrinkWrap: true,
//                           itemCount: question.options.length,
//                           itemBuilder: (BuildContext context, int index) {
//
//                             bool correctAnser =question.options[index].isCorrect;
//                             return GestureDetector(
//                               onTap: () {
//                                 setState(() {
//                                   if (correctAnser) {
//                                     optionsColor[index] = Colors.green;
//                                     Future.delayed(const Duration(seconds: 1), () {
//                                       _submitAnswer(correctAnser);
//                                     });
//
//                                   } else {
//                                     optionsColor[index] = Colors.red;
//                                     Future.delayed(const Duration(seconds: 1), () {
//                                       _submitAnswer(correctAnser);
//                                     });
//                                   }
//
//                                   // if (currentQuestionIndex < data.length - 1) {
//                                   //   Future.delayed(const Duration(seconds: 1), () {
//                                   //     gotoNextQuestion();
//                                   //   });
//                                   // } else {
//                                   //   timer!.cancel();
//                                   //   //here you can do whatever you want with the results
//                                   // }
//                                 });
//                               },
//                               child: Container(
//                                 margin: const EdgeInsets.only(bottom: 14),
//                                 alignment: Alignment.center,
//                                 width: size.width - 100,
//                                 padding: const EdgeInsets.all(16),
//                                 decoration: BoxDecoration(
//                                   color: optionsColor[index],
//                                   borderRadius: BorderRadius.circular(12),
//                                 ),
//                                 child: headingText(
//                                     color: blue,
//                                     size: 18,
//                                     text: question.options[index].description
//                                 ),
//                               ),
//                             );
//                           },
//                         ),
//                       ],
//                     ),
//                   ),
//                 );
//               } else {
//                 return const Center(child: Text('No data available'));
//               }
//             },
//           ),
//         ),
//       ),
//     );
//   }
// }
