import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as math;

class ColorWheelPicker extends StatefulWidget {
  final Color initialColor;
  final Function(Color) onColorChanged;
  final Function(Color)? onColorSelected;

  const ColorWheelPicker({
    super.key,
    required this.initialColor,
    required this.onColorChanged,
    this.onColorSelected,
  });

  @override
  State<ColorWheelPicker> createState() => _ColorWheelPickerState();
}

class _ColorWheelPickerState extends State<ColorWheelPicker> {
  late Color selectedColor;
  HSVColor? currentHSV;
  
  // Predefined popular colors for quick selection
  final List<Color> predefinedColors = [
    Colors.blue.shade600,
    Colors.red.shade600,
    Colors.green.shade600,
    Colors.orange.shade600,
    Colors.purple.shade600,
    Colors.teal.shade600,
    Colors.pink.shade600,
    Colors.indigo.shade600,
    Colors.amber.shade600,
    Colors.cyan.shade600,
    Colors.deepOrange.shade600,
    Colors.lightGreen.shade600,
  ];

  @override
  void initState() {
    super.initState();
    selectedColor = widget.initialColor;
    currentHSV = HSVColor.fromColor(selectedColor);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Title
          Text(
            'Choose Theme Color',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Color Wheel
          Center(
            child: Container(
              width: 200,
              height: 200,
              child: CustomPaint(
                painter: ColorWheelPainter(
                  currentHSV: currentHSV,
                  onColorChanged: (HSVColor hsv) {
                    setState(() {
                      currentHSV = hsv;
                      selectedColor = hsv.toColor();
                    });
                    widget.onColorChanged(selectedColor);
                  },
                ),
                child: GestureDetector(
                  onPanUpdate: (details) {
                    _updateColorFromPosition(details.localPosition);
                  },
                  onTapDown: (details) {
                    _updateColorFromPosition(details.localPosition);
                  },
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Selected color preview
          Container(
            width: double.infinity,
            height: 60,
            decoration: BoxDecoration(
              color: selectedColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.grey.shade300,
                width: 1,
              ),
            ),
            child: Center(
              child: Text(
                'Selected Color',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: _getContrastingTextColor(selectedColor),
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Quick color presets
          Text(
            'Quick Presets',
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
          
          const SizedBox(height: 12),
          
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: predefinedColors.map((color) {
              final isSelected = color.value == selectedColor.value;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    selectedColor = color;
                    currentHSV = HSVColor.fromColor(color);
                  });
                  widget.onColorChanged(selectedColor);
                },
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? Colors.black87 : Colors.grey.shade300,
                      width: isSelected ? 3 : 1,
                    ),
                    boxShadow: isSelected ? [
                      BoxShadow(
                        color: color.withOpacity(0.3),
                        blurRadius: 8,
                        spreadRadius: 2,
                      ),
                    ] : null,
                  ),
                  child: isSelected
                      ? const Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 16,
                        )
                      : null,
                ),
              );
            }).toList(),
          ),
          
          const SizedBox(height: 32),
          
          // Action buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.grey.shade400),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text(
                    'Cancel',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    widget.onColorSelected?.call(selectedColor);
                    Navigator.pop(context, selectedColor);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: selectedColor,
                    foregroundColor: _getContrastingTextColor(selectedColor),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text(
                    'Apply',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
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

  void _updateColorFromPosition(Offset position) {
    final center = const Offset(100, 100); // Center of 200x200 wheel
    final offset = position - center;
    final distance = offset.distance;
    
    if (distance <= 100) { // Within the wheel
      final angle = (math.atan2(offset.dy, offset.dx) + math.pi) / (2 * math.pi);
      final saturation = math.min(distance / 100, 1.0);
      
      setState(() {
        currentHSV = HSVColor.fromAHSV(
          1.0,
          angle * 360,
          saturation,
          1.0, // Keep brightness at maximum for vibrant colors
        );
        selectedColor = currentHSV!.toColor();
      });
      widget.onColorChanged(selectedColor);
    }
  }

  Color _getContrastingTextColor(Color backgroundColor) {
    // Calculate luminance to determine if we should use white or black text
    final luminance = backgroundColor.computeLuminance();
    return luminance > 0.5 ? Colors.black87 : Colors.white;
  }
}

class ColorWheelPainter extends CustomPainter {
  final HSVColor? currentHSV;
  final Function(HSVColor) onColorChanged;

  ColorWheelPainter({
    required this.currentHSV,
    required this.onColorChanged,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Draw color wheel
    final rect = Rect.fromCircle(center: center, radius: radius);
    final gradient = SweepGradient(
      colors: [
        const HSVColor.fromAHSV(1.0, 0, 1, 1).toColor(),
        const HSVColor.fromAHSV(1.0, 60, 1, 1).toColor(),
        const HSVColor.fromAHSV(1.0, 120, 1, 1).toColor(),
        const HSVColor.fromAHSV(1.0, 180, 1, 1).toColor(),
        const HSVColor.fromAHSV(1.0, 240, 1, 1).toColor(),
        const HSVColor.fromAHSV(1.0, 300, 1, 1).toColor(),
        const HSVColor.fromAHSV(1.0, 360, 1, 1).toColor(),
      ],
    );

    final paint = Paint()..shader = gradient.createShader(rect);
    canvas.drawCircle(center, radius, paint);

    // Draw saturation gradient (transparent to opaque from center to edge)
    final saturationGradient = RadialGradient(
      colors: [
        Colors.white,
        Colors.white.withOpacity(0.0),
      ],
      stops: const [0.0, 1.0],
    );
    
    final saturationPaint = Paint()
      ..shader = saturationGradient.createShader(rect);
    canvas.drawCircle(center, radius, saturationPaint);

    // Draw selection indicator
    if (currentHSV != null) {
      final angle = (currentHSV!.hue * math.pi / 180) - math.pi;
      final distance = currentHSV!.saturation * radius;
      final indicatorPosition = Offset(
        center.dx + math.cos(angle) * distance,
        center.dy + math.sin(angle) * distance,
      );

      // Draw outer ring
      canvas.drawCircle(
        indicatorPosition,
        12,
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3,
      );

      // Draw inner dot
      canvas.drawCircle(
        indicatorPosition,
        8,
        Paint()
          ..color = currentHSV!.toColor()
          ..style = PaintingStyle.fill,
      );
    }
  }

  @override
  bool shouldRepaint(ColorWheelPainter oldDelegate) {
    return currentHSV != oldDelegate.currentHSV;
  }
}

// Helper function to show the color picker
Future<Color?> showColorWheelPicker({
  required BuildContext context,
  required Color initialColor,
  Function(Color)? onColorChanged,
}) {
  return showModalBottomSheet<Color>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => ColorWheelPicker(
      initialColor: initialColor,
      onColorChanged: onColorChanged ?? (color) {},
      onColorSelected: (color) {
        // Handle the selected color here
        // You can save it to preferences or state management
      },
    ),
  );
}