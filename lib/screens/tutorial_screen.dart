import 'package:flutter/material.dart';

/// Tutorial screen explaining game rules and features
class TutorialScreen extends StatefulWidget {
  const TutorialScreen({super.key});

  @override
  State<TutorialScreen> createState() => _TutorialScreenState();
}

class _TutorialScreenState extends State<TutorialScreen> {
  int _currentPage = 0;
  final PageController _pageController = PageController();

  final List<TutorialPage> _pages = [
    TutorialPage(
      title: 'Welcome to XO Game!',
      description:
          'A modern, feature-rich Tic Tac Toe game with multiple board sizes, AI opponents, and comprehensive statistics tracking.',
      icon: Icons.videogame_asset,
      color: Colors.blue,
    ),
    TutorialPage(
      title: 'How to Play',
      description:
          'Take turns placing X or O on the board. The first player to get 3 (or 4) in a row wins! Rows can be horizontal, vertical, or diagonal.',
      icon: Icons.sports_esports,
      color: Colors.green,
    ),
    TutorialPage(
      title: 'Board Sizes',
      description:
          'Choose from 3x3, 4x4, or 5x5 boards. On 4x4 and 5x5 boards, you need 4 in a row to win!',
      icon: Icons.grid_3x3,
      color: Colors.purple,
    ),
    TutorialPage(
      title: 'Game Modes',
      description:
          'Play against a friend (PvP) or challenge our AI (PvC). Choose from Easy, Medium, Hard, or Adaptive difficulty levels.',
      icon: Icons.psychology,
      color: Colors.orange,
    ),
    TutorialPage(
      title: 'Undo & Redo',
      description:
          'Made a mistake? Use the undo button to take back your move. You can also redo moves you\'ve undone.',
      icon: Icons.undo,
      color: Colors.red,
    ),
    TutorialPage(
      title: 'Track Your Progress',
      description:
          'View detailed statistics, unlock achievements, and watch replays of your games in the menu.',
      icon: Icons.bar_chart,
      color: Colors.teal,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('How to Play'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              itemCount: _pages.length,
              itemBuilder: (context, index) {
                return _buildPage(_pages[index]);
              },
            ),
          ),
          _buildPageIndicator(),
          _buildNavigationButtons(),
        ],
      ),
    );
  }

  Widget _buildPage(TutorialPage page) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: page.color.withOpacity(0.2),
            ),
            child: Icon(
              page.icon,
              size: 64,
              color: page.color,
            ),
          ),
          const SizedBox(height: 32),
          Text(
            page.title,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            page.description,
            style: const TextStyle(
              fontSize: 16,
              height: 1.5,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPageIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        _pages.length,
        (index) => Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: _currentPage == index ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: _currentPage == index
                ? Theme.of(context).primaryColor
                : Colors.grey[300],
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }

  Widget _buildNavigationButtons() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (_currentPage > 0)
            TextButton(
              onPressed: () {
                _pageController.previousPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              },
              child: const Text('Previous'),
            )
          else
            const SizedBox(width: 80),
          if (_currentPage < _pages.length - 1)
            ElevatedButton(
              onPressed: () {
                _pageController.nextPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              },
              child: const Text('Next'),
            )
          else
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Get Started'),
            ),
        ],
      ),
    );
  }
}

class TutorialPage {
  final String title;
  final String description;
  final IconData icon;
  final Color color;

  TutorialPage({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });
}
