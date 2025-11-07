import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/game_bloc.dart';
import '../blocs/game_event.dart';
import 'home_screen.dart';

class PickSideScreen extends StatefulWidget {
  const PickSideScreen({Key? key}) : super(key: key);
  @override
  _PickSideScreenState createState() => _PickSideScreenState();
}

class _PickSideScreenState extends State<PickSideScreen>
    with SingleTickerProviderStateMixin {
  String? selectedSide;
  late AnimationController _buttonController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _buttonController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _scaleAnimation = CurvedAnimation(
      parent: _buttonController,
      curve: Curves.elasticOut,
    );
  }

  @override
  void dispose() {
    _buttonController.dispose();
    super.dispose();
  }

  Widget _buildSideButton(String side) {
    bool isSelected = selectedSide == side;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedSide = side;
          _buttonController.forward(from: 0.0);
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
        decoration: BoxDecoration(
          color: side == "X" ? Colors.green : Colors.blue,
          border: Border.all(
            color: isSelected ? Colors.white : Colors.transparent,
            width: 4,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: ScaleTransition(
          scale:
              isSelected ? _scaleAnimation : const AlwaysStoppedAnimation(1.0),
          child: Text(
            side,
            style: const TextStyle(
                fontSize: 48, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
        title: const Text(
          'Pick Your Side',
        ),
        leading: Padding(
          padding: const EdgeInsets.only(left: 25.0),
          child: Image.asset(
            'assets/icon/icon.png', // Replace with your image path
            width: 40,
            height: 40,
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.deepPurple, Colors.indigo],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Choose your side',
                style: TextStyle(
                  fontSize: 36,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'assets/fonts/Poppins-Bold.ttf',
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildSideButton("X"),
                  const SizedBox(width: 40),
                  _buildSideButton("O"),
                ],
              ),
              const SizedBox(height: 20),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: selectedSide != null
                    ? ElevatedButton(
                        key: const ValueKey('confirm'),
                        onPressed: () {
                          context
                              .read<GameBloc>()
                              .add(SetPlayerSide(selectedSide!));
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                                builder: (_) => const HomeScreen()),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 30, vertical: 15),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20)),
                        ),
                        child: const Text(
                          'Confirm',
                          style: TextStyle(
                              fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                      )
                    : const SizedBox.shrink(key: ValueKey('empty')),
              ),
              const SizedBox(height: 10),
              const Text(
                'Choose wisely!',
                style: TextStyle(fontSize: 20, color: Colors.white70),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
