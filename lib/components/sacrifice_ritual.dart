import 'package:flutter/material.dart';
import 'dart:async';

class MemoryPreviewOverlay extends StatefulWidget {
  final String memory;
  final VoidCallback onContinue;
  final VoidCallback onCancel;

  const MemoryPreviewOverlay({
    super.key,
    required this.memory,
    required this.onContinue,
    required this.onCancel,
  });

  @override
  State<MemoryPreviewOverlay> createState() => _MemoryPreviewOverlayState();
}

class _MemoryPreviewOverlayState extends State<MemoryPreviewOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeIn),
    );
    _fadeController.forward();

    // Auto-advance after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        widget.onContinue();
      }
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onContinue,
      child: Container(
        color: Colors.black.withValues(alpha: 0.95),
        child: Center(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Text(
                    widget.memory,
                    style: TextStyle(
                      fontSize: 32,
                      color: Colors.yellow.shade200,
                      fontWeight: FontWeight.w300,
                      letterSpacing: 1.5,
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 48),
                Text(
                  'Tap to continue...',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade400,
                    fontWeight: FontWeight.w300,
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

class SacrificeConfirmationDialog extends StatefulWidget {
  final String memory;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  const SacrificeConfirmationDialog({
    super.key,
    required this.memory,
    required this.onConfirm,
    required this.onCancel,
  });

  @override
  State<SacrificeConfirmationDialog> createState() =>
      _SacrificeConfirmationDialogState();
}

class _SacrificeConfirmationDialogState
    extends State<SacrificeConfirmationDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onCancel,
      child: Container(
        color: Colors.black.withValues(alpha: 0.9),
        child: Center(
          child: GestureDetector(
            onTap: () {}, // Prevent tap-through
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 32),
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade900,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.red.shade800,
                      width: 2,
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "You will forget this forever.",
                        style: TextStyle(
                          fontSize: 24,
                          color: Colors.yellow.shade200,
                          fontWeight: FontWeight.w300,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "But you will be stronger.",
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.orange.shade300,
                          fontWeight: FontWeight.w300,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      Text(
                        "Is this what you choose?",
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white70,
                          fontWeight: FontWeight.w300,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          // Keep It button (subtle)
                          TextButton(
                            onPressed: widget.onCancel,
                            child: Text(
                              'Keep It',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey.shade400,
                                fontWeight: FontWeight.w300,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          // Burn It button (prominent, weighty)
                          ElevatedButton(
                            onPressed: widget.onConfirm,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red.shade900,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 32,
                                vertical: 16,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text(
                              'Burn It',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class SacrificeAftermath extends StatefulWidget {
  final String memory;
  final VoidCallback onComplete;

  const SacrificeAftermath({
    super.key,
    required this.memory,
    required this.onComplete,
  });

  @override
  State<SacrificeAftermath> createState() => _SacrificeAftermathState();
}

class _SacrificeAftermathState extends State<SacrificeAftermath>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeOutAnimation;
  late Animation<double> _ashAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    );

    _fadeOutAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.7, curve: Curves.easeOut),
      ),
    );

    _ashAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.3, 1.0, curve: Curves.easeIn),
      ),
    );

    _controller.forward();

    // Complete after animation
    Future.delayed(const Duration(milliseconds: 3500), () {
      if (mounted) {
        widget.onComplete();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          color: Colors.black.withValues(alpha: 0.95),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Memory fading out
                Opacity(
                  opacity: _fadeOutAnimation.value,
                  child: Text(
                    widget.memory,
                    style: TextStyle(
                      fontSize: 28,
                      color: Colors.yellow.shade200,
                      fontWeight: FontWeight.w300,
                      letterSpacing: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 32),
                // Ash effect text
                Opacity(
                  opacity: _ashAnimation.value,
                  child: Text(
                    "The memory is gone.\nThe power remains.",
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.grey.shade500,
                      fontWeight: FontWeight.w300,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

