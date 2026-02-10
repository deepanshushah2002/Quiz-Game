// main.dart
import 'package:flutter/material.dart';
import 'dart:async';

void main() {
  runApp(const QuizApp());
}

class QuizApp extends StatelessWidget {
  const QuizApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Quiz Game',
      theme: ThemeData(
        primarySwatch: Colors.purple,
        brightness: Brightness.dark,
      ),
      home: const QuizHomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class Question {
  final String questionText;
  final List<String> options;
  final int correctAnswerIndex;

  Question({
    required this.questionText,
    required this.options,
    required this.correctAnswerIndex,
  });
}

class QuizHomePage extends StatefulWidget {
  const QuizHomePage({Key? key}) : super(key: key);

  @override
  State<QuizHomePage> createState() => _QuizHomePageState();
}

class _QuizHomePageState extends State<QuizHomePage>
    with TickerProviderStateMixin {
  // Questions List
  final List<Question> _questions = [
    Question(
      questionText: 'What is the capital of France?',
      options: ['London', 'Berlin', 'Paris', 'Madrid'],
      correctAnswerIndex: 2,
    ),
    Question(
      questionText: 'Which planet is known as the Red Planet?',
      options: ['Venus', 'Mars', 'Jupiter', 'Saturn'],
      correctAnswerIndex: 1,
    ),
    Question(
      questionText: 'What is 2 + 2?',
      options: ['3', '4', '5', '6'],
      correctAnswerIndex: 1,
    ),
    Question(
      questionText: 'Who painted the Mona Lisa?',
      options: ['Van Gogh', 'Picasso', 'Da Vinci', 'Michelangelo'],
      correctAnswerIndex: 2,
    ),
    Question(
      questionText: 'What is the largest ocean on Earth?',
      options: ['Atlantic', 'Indian', 'Arctic', 'Pacific'],
      correctAnswerIndex: 3,
    ),
  ];

  // Game State
  String _playerName = '';
  int _currentQuestionIndex = 0;
  int _score = 0;
  bool _answered = false;
  int? _selectedAnswerIndex;
  bool _quizCompleted = false;
  bool _isNameEntered = false;
  bool _isCountingDown = false;
  int _countdownValue = 3;

  // Animation Controllers
  late AnimationController _questionController;
  late AnimationController _optionController;
  late AnimationController _scoreController;
  late AnimationController _countdownController;

  late Animation<double> _questionAnimation;
  late Animation<double> _optionAnimation;
  late Animation<double> _scoreAnimation;
  late Animation<double> _countdownAnimation;

  Timer? _countdownTimer;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    _questionController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _optionController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _scoreController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _countdownController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _questionAnimation = CurvedAnimation(
      parent: _questionController,
      curve: Curves.easeInOut,
    );

    _optionAnimation = CurvedAnimation(
      parent: _optionController,
      curve: Curves.elasticOut,
    );

    _scoreAnimation = CurvedAnimation(
      parent: _scoreController,
      curve: Curves.bounceOut,
    );

    _countdownAnimation = CurvedAnimation(
      parent: _countdownController,
      curve: Curves.elasticOut,
    );
  }

  void _startCountdown() {
    setState(() {
      _isCountingDown = true;
      _countdownValue = 3;
    });
    _countdownController.forward();

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdownValue > 1) {
        setState(() {
          _countdownValue--;
        });
        _countdownController.forward(from: 0);
      } else {
        timer.cancel();
        setState(() {
          _isCountingDown = false;
        });
        _startQuiz();
      }
    });
  }

  void _startQuiz() {
    _questionController.forward();
    _optionController.forward();
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _questionController.dispose();
    _optionController.dispose();
    _scoreController.dispose();
    _countdownController.dispose();
    super.dispose();
  }

  void _selectAnswer(int index) {
    if (_answered) return;

    setState(() {
      _selectedAnswerIndex = index;
      _answered = true;
      if (index == _questions[_currentQuestionIndex].correctAnswerIndex) {
        _score++;
        _scoreController.forward(from: 0);
      }
    });
  }

  void _nextQuestion() {
    if (_currentQuestionIndex < _questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
        _answered = false;
        _selectedAnswerIndex = null;
      });
      _questionController.reset();
      _optionController.reset();
      _questionController.forward();
      _optionController.forward();
    } else {
      setState(() {
        _quizCompleted = true;
      });
    }
  }

  void _restartQuiz() {
    setState(() {
      _currentQuestionIndex = 0;
      _score = 0;
      _answered = false;
      _selectedAnswerIndex = null;
      _quizCompleted = false;
      _isNameEntered = false;
    });
  }

  Color _getOptionColor(int index) {
    if (!_answered) return Colors.purple.shade700;
    if (index == _questions[_currentQuestionIndex].correctAnswerIndex) {
      return Colors.green;
    }
    if (index == _selectedAnswerIndex) {
      return Colors.red;
    }
    return Colors.purple.shade700;
  }

  @override
  Widget build(BuildContext context) {
    // 1. Name Entry Screen
    if (!_isNameEntered) {
      return Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.purple.shade900, Colors.blue.shade900],
            ),
          ),
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.quiz,
                    size: 100,
                    color: Colors.amber,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Quiz Master',
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 50),
                  Card(
                    elevation: 10,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(25),
                      child: Column(
                        children: [
                          TextField(
                            decoration: InputDecoration(
                              labelText: 'Enter Your Name',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              prefixIcon: const Icon(Icons.person),
                            ),
                            style: const TextStyle(fontSize: 18),
                            onChanged: (value) {
                              _playerName = value;
                            },
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () {
                                if (_playerName.trim().isEmpty) {
                                  _playerName = 'Player';
                                }
                                setState(() {
                                  _isNameEntered = true;
                                });
                                _startCountdown();
                              },
                              icon: const Icon(Icons.play_arrow),
                              label: const Text(
                                'START GAME',
                                style: TextStyle(fontSize: 18),
                              ),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 15),
                                backgroundColor: Colors.amber,
                                foregroundColor: Colors.black,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    // 2. Countdown Screen
    if (_isCountingDown) {
      return Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.purple.shade900, Colors.blue.shade900],
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Get Ready, $_playerName!',
                  style: const TextStyle(
                    fontSize: 28,
                    color: Colors.white,
                    fontWeight: FontWeight.w300,
                  ),
                ),
                const SizedBox(height: 30),
                ScaleTransition(
                  scale: _countdownAnimation,
                  child: Text(
                    _countdownValue.toString(),
                    style: const TextStyle(
                      fontSize: 150,
                      fontWeight: FontWeight.bold,
                      color: Colors.amber,
                      shadows: [
                        Shadow(
                          blurRadius: 20,
                          color: Colors.black45,
                          offset: Offset(5, 5),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // 3. Quiz Completed Screen
    if (_quizCompleted) {
      return Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.purple.shade900, Colors.blue.shade900],
            ),
          ),
          child: Center(
            child: ScaleTransition(
              scale: _scoreAnimation,
              child: Card(
                margin: const EdgeInsets.all(20),
                elevation: 10,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(40),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.emoji_events,
                        size: 100,
                        color: Colors.amber,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        '$_playerName!',
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Quiz Completed!',
                        style: TextStyle(
                          fontSize: 24,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Your Score: $_score / ${_questions.length}',
                        style: const TextStyle(
                          fontSize: 24,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        '${((_score / _questions.length) * 100).toStringAsFixed(0)}%',
                        style: TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: Colors.purple.shade700,
                        ),
                      ),
                      const SizedBox(height: 30),
                      ElevatedButton.icon(
                        onPressed: () {
                          _restartQuiz();
                          _scoreController.forward(from: 0);
                        },
                        icon: const Icon(Icons.refresh),
                        label: const Text('Play Again'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 30,
                            vertical: 15,
                          ),
                          textStyle: const TextStyle(fontSize: 18),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    // 4. Main Quiz Screen
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.purple.shade900, Colors.blue.shade900],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header with Player Name
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ScaleTransition(
                      scale: _scoreAnimation,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 15,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.star, color: Colors.amber),
                            const SizedBox(width: 5),
                            Text(
                              '$_score',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 15,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _playerName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 15,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${_currentQuestionIndex + 1}/${_questions.length}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Progress Bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: (_currentQuestionIndex + 1) / _questions.length,
                    backgroundColor: Colors.white.withOpacity(0.2),
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.amber),
                    minHeight: 10,
                  ),
                ),
                const SizedBox(height: 40),

                // Question Card
                FadeTransition(
                  opacity: _questionAnimation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, -0.3),
                      end: Offset.zero,
                    ).animate(_questionAnimation),
                    child: Card(
                      elevation: 8,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(25),
                        child: Text(
                          _questions[_currentQuestionIndex].questionText,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 40),

                // Options
                Expanded(
                  child: ListView.builder(
                    key: ValueKey(_currentQuestionIndex),
                    itemCount: _questions[_currentQuestionIndex].options.length,
                    itemBuilder: (context, index) {
                      return SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(1.5, 0),
                          end: Offset.zero,
                        ).animate(
                          CurvedAnimation(
                            parent: _optionController,
                            curve: Interval(
                              index * 0.2,
                              0.6 + (index * 0.2),
                              curve: Curves.easeOut,
                            ),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 15),
                          child: InkWell(
                            onTap: () => _selectAnswer(index),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: _getOptionColor(index),
                                borderRadius: BorderRadius.circular(15),
                                border: Border.all(
                                  color: _selectedAnswerIndex == index
                                      ? Colors.white
                                      : Colors.transparent,
                                  width: 3,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.3),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Center(
                                      child: Text(
                                        String.fromCharCode(65 + index),
                                        style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 15),
                                  Expanded(
                                    child: Text(
                                      _questions[_currentQuestionIndex].options[index],
                                      style: const TextStyle(
                                        fontSize: 18,
                                        color: Colors.white,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  if (_answered &&
                                      index ==
                                          _questions[_currentQuestionIndex]
                                              .correctAnswerIndex)
                                    const Icon(
                                      Icons.check_circle,
                                      color: Colors.white,
                                      size: 30,
                                    ),
                                  if (_answered &&
                                      index == _selectedAnswerIndex &&
                                      index !=
                                          _questions[_currentQuestionIndex]
                                              .correctAnswerIndex)
                                    const Icon(
                                      Icons.cancel,
                                      color: Colors.white,
                                      size: 30,
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // Next Button
                if (_answered)
                  SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 1),
                      end: Offset.zero,
                    ).animate(
                      CurvedAnimation(
                        parent: _optionController,
                        curve: Curves.easeOut,
                      ),
                    ),
                    child: ElevatedButton(
                      onPressed: _nextQuestion,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        backgroundColor: Colors.amber,
                        foregroundColor: Colors.black,
                      ),
                      child: Text(
                        _currentQuestionIndex < _questions.length - 1
                            ? 'Next Question'
                            : 'Finish Quiz',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
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