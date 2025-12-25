import 'package:flutter/material.dart';

class DailyTasksWidget extends StatelessWidget {
  final int completedTasks;
  final int totalTasks;
  final VoidCallback? onAddTask;
  final VoidCallback? onBackPressed;
  final VoidCallback? onMenuPressed;

  const DailyTasksWidget({
    Key? key,
    this.completedTasks = 2,
    this.totalTasks = 4,
    this.onAddTask,
    this.onBackPressed,
    this.onMenuPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      height: 400,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFE6B800), // Golden yellow
            Color(0xFFFF6B9D), // Pink
            Color(0xFF8B5CF6), // Purple
            Color(0xFF3B82F6), // Blue
          ],
          stops: [0.0, 0.3, 0.7, 1.0],
        ),
      ),
      child: Stack(
        children: [
          // Vertical line pattern overlay
          CustomPaint(
            size: Size(300, 400),
            painter: VerticalLinesPainter(),
          ),
          
          // Main content
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top navigation bar
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: onBackPressed,
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.arrow_back_ios_new,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: onMenuPressed,
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.more_horiz,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ),
                  ],
                ),
                
                const Spacer(),
                
                // Title
                const Text(
                  'Daily\nTasks',
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    height: 1.1,
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // Progress section
                Row(
                  children: [
                    // Progress pill
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.25),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            '$completedTasks/$totalTasks',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 8),
                
                // "tasks" label
                const Text(
                  'tasks',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // Add button
                Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: onAddTask,
                    child: Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.25),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.add,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class VerticalLinesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..strokeWidth = 1.5;

    // Draw vertical lines with varying heights and positions
    final lineSpacing = size.width / 20;
    
    for (int i = 0; i < 20; i++) {
      final x = i * lineSpacing;
      final startY = size.height * 0.2 + (i % 3) * 20;
      final endY = size.height * 0.8 - (i % 4) * 30;
      
      canvas.drawLine(
        Offset(x, startY),
        Offset(x, endY),
        paint,
      );
    }
    
    // Draw some accent lines with different opacity
    paint.color = Colors.white.withOpacity(0.05);
    paint.strokeWidth = 2.0;
    
    for (int i = 0; i < 15; i++) {
      final x = (i + 0.5) * (size.width / 15);
      final startY = size.height * 0.1;
      final endY = size.height * 0.9;
      
      canvas.drawLine(
        Offset(x, startY),
        Offset(x, endY),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

// Example usage widget
class TaskCardExample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Center(
        child: DailyTasksWidget(
          completedTasks: 2,
          totalTasks: 4,
          onAddTask: () {
            print('Add task pressed');
          },
          onBackPressed: () {
            print('Back pressed');
          },
          onMenuPressed: () {
            print('Menu pressed');
          },
        ),
      ),
    );
  }
}