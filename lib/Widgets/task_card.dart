import 'package:flutter/material.dart';

class TaskCard extends StatefulWidget {
  final String title;
  final String description;
  final VoidCallback onDone;
  final Color color;
  const TaskCard({
    super.key,
    required this.title,
    required this.description,
    required this.onDone,
    this.color = Colors.white,
  });

  @override
  State<TaskCard> createState() => _TaskCardState();
}

class _TaskCardState extends State<TaskCard> {
  double drag_pos = 0;
  @override
  Widget build(BuildContext context) {
    double card_width = MediaQuery.of(context).size.width * 0.85;
    return Container(
      width: card_width,
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: widget.color,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          SizedBox(height: 2),
          Text(widget.description, style: const TextStyle(color: Colors.grey)),
          SizedBox(height: 4),
          Stack(
            children: [
              // 1️⃣ Background track
              Container(
                height: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  gradient: LinearGradient(
                    colors: [Colors.blue.shade400, Colors.blue.shade900],
                  ),
                ),
                alignment: Alignment.center,
                child: const Text(
                  "Drag to mark done",
                  style: TextStyle(
                    color: Colors.white70,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              // 2️⃣ Progress indicator
              Positioned(
                left: 0,
                child: Container(
                  width: drag_pos + 50, // progress based on drag
                  height: 60,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(35),
                    color: Colors.blue.withOpacity(0.3),
                  ),
                ),
              ),

              // 3️⃣ Draggable thumb
              Positioned(
                left: drag_pos,
                child: GestureDetector(
                  onHorizontalDragUpdate: (details) {
                    setState(() {
                      drag_pos += details.delta.dx;
                      drag_pos = drag_pos.clamp(0.0, card_width - 50);
                    });
                  },
                  onHorizontalDragEnd: (details) {
                    if (drag_pos > card_width - 70) {
                      widget.onDone();
                    }
                    setState(() {
                      drag_pos = 0;
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 100),
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 0, 94, 216),
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 6,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.arrow_forward,
                      color: Color.fromARGB(255, 255, 255, 255),
                      size: 28,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
