import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';

void main() {
  runApp(SuperTicTacToe());
}

class SuperTicTacToe extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Super Tic-Tac-Toe',
      home: NameInputScreen(),
    );
  }
}

class NameInputScreen extends StatefulWidget {
  @override
  _NameInputScreenState createState() => _NameInputScreenState();
}

class _NameInputScreenState extends State<NameInputScreen> {
  final TextEditingController player1Controller = TextEditingController();
  final TextEditingController player2Controller = TextEditingController();

  void startGame() {
    if (player1Controller.text.isNotEmpty &&
        player2Controller.text.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => GameScreen(
            player1: player1Controller.text,
            player2: player2Controller.text,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter names for both players')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Enter Player Names")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: player1Controller,
              decoration: InputDecoration(
                labelText: "Player 1 (X)",
              ),
            ),
            TextField(
              controller: player2Controller,
              decoration: InputDecoration(
                labelText: "Player 2 (O)",
              ),
            ),
            ElevatedButton(
              onPressed: startGame,
              child: Text("Start Game"),
            ),
          ],
        ),
      ),
    );
  }
}

class GameScreen extends StatefulWidget {
  final String player1;
  final String player2;

  GameScreen({required this.player1, required this.player2});

  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late ConfettiController _confettiController;
  List<List<String>> board =
      List.generate(9, (_) => List.generate(9, (_) => ''));
  List<String> smallBoardWinners = List.generate(9, (_) => '');
  String currentPlayer = 'X';
  String winner = '';
  int activeBoard = -1;
  List<List<int>> winningLine = [];

  @override
  void initState() {
    super.initState();
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 10));
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  void makeMove(int boardIndex, int cellIndex) {
    if (winner.isNotEmpty ||
        board[boardIndex][cellIndex] != '' ||
        smallBoardWinners[boardIndex].isNotEmpty) return;

    setState(() {
      board[boardIndex][cellIndex] = currentPlayer;

      // Check for a winner in the small board
      if (checkWin(board[boardIndex])) {
        smallBoardWinners[boardIndex] = currentPlayer;
        winningLine = getWinningLine(board[boardIndex]);
      }

      // Check for a winner on the super board
      if (checkWin(smallBoardWinners)) {
        winner = currentPlayer;
        _confettiController.play();
      } else {
        // Switch turns
        currentPlayer = currentPlayer == 'X' ? 'O' : 'X';
        activeBoard = smallBoardWinners[cellIndex].isEmpty ? cellIndex : -1;
      }
    });
  }

  bool checkWin(List<String> board) {
    const winPatterns = [
      [0, 1, 2],
      [3, 4, 5],
      [6, 7, 8],
      [0, 3, 6],
      [1, 4, 7],
      [2, 5, 8],
      [0, 4, 8],
      [2, 4, 6],
    ];

    for (var pattern in winPatterns) {
      if (board[pattern[0]] == board[pattern[1]] &&
          board[pattern[1]] == board[pattern[2]] &&
          board[pattern[0]] != '') {
        return true;
      }
    }
    return false;
  }

  List<List<int>> getWinningLine(List<String> board) {
    const winPatterns = [
      [0, 1, 2],
      [3, 4, 5],
      [6, 7, 8],
      [0, 3, 6],
      [1, 4, 7],
      [2, 5, 8],
      [0, 4, 8],
      [2, 4, 6],
    ];

    for (var pattern in winPatterns) {
      if (board[pattern[0]] == board[pattern[1]] &&
          board[pattern[1]] == board[pattern[2]] &&
          board[pattern[0]] != '') {
        return [pattern];
      }
    }
    return [];
  }

  Widget buildSmallBoard(int boardIndex) {
    return Stack(
      children: [
        GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 4,
            crossAxisSpacing: 4,
          ),
          itemCount: 9,
          itemBuilder: (context, cellIndex) {
            return GestureDetector(
              onTap: () => makeMove(boardIndex, cellIndex),
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black),
                  color: (activeBoard == -1 || activeBoard == boardIndex) &&
                          board[boardIndex][cellIndex] == ''
                      ? Colors.yellow[100]
                      : Colors.grey[300],
                ),
                child: Center(
                  child: Text(
                    board[boardIndex][cellIndex],
                    style: TextStyle(
                      fontSize: MediaQuery.of(context).size.width /
                          10, // Adjust font size
                      color: board[boardIndex][cellIndex] == 'X'
                          ? Colors.red
                          : board[boardIndex][cellIndex] == 'O'
                              ? Colors.blue
                              : Colors.black,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
        if (smallBoardWinners[boardIndex].isNotEmpty)
          Center(
            child: Text(
              smallBoardWinners[boardIndex],
              style: TextStyle(
                fontSize: MediaQuery.of(context).size.width /
                    5, // Increase the font size to cover most of the small board
                fontWeight: FontWeight.bold,
                color: smallBoardWinners[boardIndex] == 'X'
                    ? Colors.red
                    : Colors.blue,
              ),
            ),
          ),
        if (winningLine.isNotEmpty && winningLine[0].contains(boardIndex))
          CustomPaint(
            painter: WinningLinePainter(winningLine[0], boardIndex),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Super Tic-Tac-Toe")),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 4,
                    crossAxisSpacing: 4,
                  ),
                  itemCount: 9,
                  itemBuilder: (context, boardIndex) {
                    return buildSmallBoard(boardIndex);
                  },
                ),
              ),
            ],
          ),
          if (winner.isNotEmpty)
            Align(
              alignment: Alignment.center,
              child: Text(
                "$winner Wins!",
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ),
          Positioned(
            bottom: 20,
            right: 20,
            child: ElevatedButton(
              onPressed: resetGame,
              child: Text("Reset Game"),
            ),
          ),
          ConfettiWidget(
            confettiController: _confettiController,
            blastDirectionality: BlastDirectionality.explosive,
            shouldLoop: false,
            colors: [Colors.blue, Colors.red, Colors.green, Colors.orange],
          ),
        ],
      ),
    );
  }

  void resetGame() {
    setState(() {
      board = List.generate(9, (_) => List.generate(9, (_) => ''));
      smallBoardWinners = List.generate(9, (_) => '');
      currentPlayer = 'X';
      winner = '';
      activeBoard = -1;
      winningLine = [];
    });
  }
}

class WinningLinePainter extends CustomPainter {
  final List<int> winningCells;
  final int boardIndex;

  WinningLinePainter(this.winningCells, this.boardIndex);

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = Colors.green
      ..strokeWidth = 8
      ..style = PaintingStyle.stroke;

    double cellSize = size.width / 3;

    // Calculate line coordinates based on the winning pattern
    Offset start = Offset(
      (winningCells[0] % 3) * cellSize + cellSize / 2,
      (winningCells[0] ~/ 3) * cellSize + cellSize / 2,
    );
    Offset end = Offset(
      (winningCells[2] % 3) * cellSize + cellSize / 2,
      (winningCells[2] ~/ 3) * cellSize + cellSize / 2,
    );

    canvas.drawLine(start, end, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
