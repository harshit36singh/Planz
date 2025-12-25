import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:planz/pages/voice_command_parser.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

import 'package:planz/providers/task_notifier.dart';

class VoiceTask extends ConsumerStatefulWidget {
  final TaskPriority priority;

  const VoiceTask({super.key, required this.priority});

  @override
  ConsumerState<VoiceTask> createState() => _VoiceTaskState();
}

class _VoiceTaskState extends ConsumerState<VoiceTask>
    with TickerProviderStateMixin {
  late stt.SpeechToText _speech;
  bool _isListening = false;
  bool _isInitialized = false;
  String _text = '';
  String _status = 'Initializing...';
  VoiceCommand? _parsedCommand;
  late AnimationController _animationController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _setupAnimation();
    _initSpeech();
  }

  void _setupAnimation() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.15,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  void _initSpeech() async {
    try {
      bool available = await _speech.initialize(
        onStatus: _onSpeechStatus,
        onError: _onSpeechError,
        debugLogging: false,
      );
      
      if (mounted) {
        setState(() {
          _isInitialized = available;
          _status = available ? 'Tap to speak' : 'Speech recognition not available';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _status = 'Failed to initialize speech recognition';
        });
      }
    }
  }

  void _onSpeechStatus(String status) {
    if (!mounted) return;
    
    setState(() {
      switch (status) {
        case 'listening':
          _status = 'Listening...';
          if (!_animationController.isAnimating) {
            _animationController.repeat(reverse: true);
          }
          break;
        case 'notListening':
          _status = _text.isEmpty ? 'Tap to speak' : 'Processing...';
          _animationController.stop();
          _isListening = false;
          break;
        case 'done':
          _status = 'Processing...';
          _animationController.stop();
          _isListening = false;
          break;
        default:
          _status = status;
          break;
      }
    });
  }

  void _onSpeechError(dynamic error) {
    if (!mounted) return;
    
    setState(() {
      _status = 'Error occurred. Tap to try again.';
      _isListening = false;
      _animationController.stop();
    });
  }

  void _listen() async {
    if (!_isInitialized) {
      setState(() {
        _status = 'Speech recognition not ready';
      });
      return;
    }

    if (!_isListening) {
      setState(() {
        _isListening = true;
        _text = '';
        _parsedCommand = null;
        _status = 'Starting...';
      });

      try {
        await _speech.listen(
          onResult: (val) {
            if (mounted && val.recognizedWords != _text) {
              setState(() {
                _text = val.recognizedWords;
                if (val.finalResult) {
                  _parsedCommand = VoiceCommandParser.parseCommand(_text);
                }
              });
            }
          },
          listenFor: const Duration(seconds: 10),
          pauseFor: const Duration(seconds: 3),
          partialResults: false,
          localeId: 'en_US',
          cancelOnError: true,
        );
      } catch (e) {
        if (mounted) {
          setState(() {
            _status = 'Failed to start listening. Try again.';
            _isListening = false;
          });
        }
      }
    } else {
      _stop();
    }
  }

  void _stop() {
    _speech.stop();
    if (mounted) {
      setState(() {
        _isListening = false;
        _status = _text.isEmpty ? 'Tap to speak' : 'Processing...';
        _animationController.stop();
      });
    }
  }

  void _createTaskFromCommand() {
    if (_parsedCommand == null) return;

    Navigator.pop(context, {
      "task": _parsedCommand!.taskTitle,
      "desc": _parsedCommand!.description,
      "priority": widget.priority,
      "date": _parsedCommand!.scheduledDate,
      "time": _parsedCommand!.scheduledTime,
    });
  }

  void _clearCommand() {
    setState(() {
      _text = '';
      _parsedCommand = null;
      _status = 'Tap to speak';
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _speech.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
   
    return SingleChildScrollView(
      child: Container(
        color: Colors.white,
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Voice input button - Wrapped in RepaintBoundary for performance
            Center(
              child: RepaintBoundary(
                child: _VoiceMicButton(
                  isListening: _isListening,
                  isInitialized: _isInitialized,
                  animation: _pulseAnimation,
                  priorityColor: widget.priority.color,
                  onTap: _isInitialized ? _listen : null,
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Status text
            Text(
              _status,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
            
            // Conditional content wrapped in RepaintBoundary
            if (_text.isNotEmpty) 
              RepaintBoundary(
                child: _VoiceResultSection(
                  text: _text,
                  parsedCommand: _parsedCommand,
                  priorityColor: widget.priority.color,
                  onClear: _clearCommand,
                  onCreate: _createTaskFromCommand,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// Separate widget for microphone button to optimize repaints
class _VoiceMicButton extends StatelessWidget {
  final bool isListening;
  final bool isInitialized;
  final Animation<double> animation;
  final Color priorityColor;
  final VoidCallback? onTap;

  const _VoiceMicButton({
    required this.isListening,
    required this.isInitialized,
    required this.animation,
    required this.priorityColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Transform.scale(
          scale: isListening ? animation.value : 1.0,
          child: GestureDetector(
            onTap: onTap,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: !isInitialized
                    ? Colors.grey.shade400
                    : isListening
                        ? Colors.red.shade400
                        : priorityColor,
                shape: BoxShape.circle,
                boxShadow: isInitialized
                    ? [
                        BoxShadow(
                          color: (isListening
                                  ? Colors.red.shade400
                                  : priorityColor)
                              .withOpacity(0.3),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ]
                    : null,
              ),
              child: Icon(
                !isInitialized
                    ? Icons.mic_off
                    : isListening
                        ? Icons.mic
                        : Icons.mic_none,
                color: Colors.white,
                size: 40,
              ),
            ),
          ),
        );
      },
    );
  }
}

// Separate widget for voice results to optimize rebuilds
class _VoiceResultSection extends StatelessWidget {
  final String text;
  final VoiceCommand? parsedCommand;
  final Color priorityColor;
  final VoidCallback onClear;
  final VoidCallback onCreate;

  const _VoiceResultSection({
    required this.text,
    required this.parsedCommand,
    required this.priorityColor,
    required this.onClear,
    required this.onCreate,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 16),
        
        // Recognized text
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'You said:',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                text,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
        
        if (parsedCommand != null) ...[
          const SizedBox(height: 12),
          
          // Parsed command preview
          _CommandPreview(
            command: parsedCommand!,
            priorityColor: priorityColor,
          ),
          
          const SizedBox(height: 12),
          
          // Action buttons
          _ActionButtons(
            priorityColor: priorityColor,
            onClear: onClear,
            onCreate: onCreate,
          ),
        ],
      ],
    );
  }
}

// Separate widget for command preview
class _CommandPreview extends StatelessWidget {
  final VoiceCommand command;
  final Color priorityColor;

  const _CommandPreview({
    required this.command,
    required this.priorityColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: priorityColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: priorityColor.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                command.isScheduled ? Icons.schedule : Icons.task_alt,
                size: 16,
                color: priorityColor,
              ),
              const SizedBox(width: 6),
              Text(
                command.isScheduled ? 'Scheduled Task' : 'Quick Task',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: priorityColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            command.taskTitle,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          if (command.scheduledDate != null) ...[
            const SizedBox(height: 4),
            Text(
              'Date: ${command.scheduledDate!.day}/${command.scheduledDate!.month}/${command.scheduledDate!.year}',
              style: GoogleFonts.inter(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ],
          if (command.scheduledTime != null) ...[
            const SizedBox(height: 2),
            Text(
              'Time: ${command.scheduledTime!.format(context)}',
              style: GoogleFonts.inter(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// Separate widget for action buttons
class _ActionButtons extends StatelessWidget {
  final Color priorityColor;
  final VoidCallback onClear;
  final VoidCallback onCreate;

  const _ActionButtons({
    required this.priorityColor,
    required this.onClear,
    required this.onCreate,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: onClear,
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: Colors.grey.shade400),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'Try Again',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade600,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: onCreate,
            style: ElevatedButton.styleFrom(
              backgroundColor: priorityColor,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'Create Task',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ],
    );
  }
}