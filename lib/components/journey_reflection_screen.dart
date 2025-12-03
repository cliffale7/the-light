import 'package:flutter/material.dart';
import '../models/game_state.dart';

class JourneyReflectionScreen extends StatelessWidget {
  final GameState gameState;
  final VoidCallback onClose;

  const JourneyReflectionScreen({
    super.key,
    required this.gameState,
    required this.onClose,
  });

  String _getContextualText() {
    final totalSacrificed = gameState.totalMemoriesSacrificed;
    final totalPreserved = gameState.totalMemoriesPreserved;
    final currentMemories = gameState.memories.length;
    final totalHeld = totalPreserved + currentMemories;

    if (totalSacrificed == 0 && totalHeld == 0) {
      return "Your journey begins. Every choice matters.";
    } else if (totalSacrificed == 0) {
      return "You have held tight to what matters. The struggle is harder, but you carry more of yourself forward.";
    } else if (totalHeld == 0) {
      return "You have given everything. The power is great, but what remains?";
    } else if (totalSacrificed > totalHeld * 2) {
      return "You have given much to keep going. The cost is real. But you are still here.";
    } else if (totalHeld > totalSacrificed * 2) {
      return "You have held tight to what matters. The struggle is harder, but you carry more of yourself forward.";
    } else {
      return "You have walked the line between holding on and letting go. This is the eternal choice.";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Your Journey',
                    style: TextStyle(
                      fontSize: 32,
                      color: Colors.white,
                      fontWeight: FontWeight.w300,
                      letterSpacing: 2,
                    ),
                  ),
                  IconButton(
                    onPressed: onClose,
                    icon: const Icon(Icons.close, color: Colors.white70),
                  ),
                ],
              ),
            ),

            // Scrollable content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Statistics
                    _buildStatisticsSection(),

                    const SizedBox(height: 32),

                    // Memory Garden (Preserved Memories)
                    _buildMemoryGardenSection(),

                    const SizedBox(height: 32),

                    // Sacrificed Memories Archive
                    _buildSacrificedMemoriesSection(),

                    const SizedBox(height: 32),

                    // Balance Visualization
                    _buildBalanceSection(),

                    const SizedBox(height: 32),

                    // Contextual Philosophical Text
                    _buildPhilosophicalText(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatisticsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Statistics',
          style: TextStyle(
            fontSize: 24,
            color: Colors.white,
            fontWeight: FontWeight.w300,
          ),
        ),
        const SizedBox(height: 16),
        _buildStatCard(
          'Total Cycles',
          '${gameState.rebornCount}',
          Icons.refresh,
          Colors.yellow.shade400,
        ),
        const SizedBox(height: 8),
        _buildStatCard(
          'Memories Sacrificed',
          '${gameState.totalMemoriesSacrificed}',
          Icons.warning,
          Colors.red.shade400,
        ),
        const SizedBox(height: 8),
        _buildStatCard(
          'Memories Preserved',
          '${gameState.totalMemoriesPreserved + gameState.memories.length}',
          Icons.favorite,
          Colors.blue.shade400,
        ),
        const SizedBox(height: 8),
        _buildStatCard(
          'Darkness Faced',
          gameState.darkness.toStringAsFixed(1),
          Icons.dark_mode,
          Colors.grey.shade400,
        ),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade800),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.white70,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMemoryGardenSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.local_florist, color: Colors.yellow.shade300, size: 28),
            const SizedBox(width: 8),
            const Text(
              'The Memories You Kept',
              style: TextStyle(
                fontSize: 24,
                color: Colors.white,
                fontWeight: FontWeight.w300,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'These are the moments you chose to hold onto. They shaped you.',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade400,
            fontStyle: FontStyle.italic,
          ),
        ),
        const SizedBox(height: 16),
        if (gameState.memories.isEmpty)
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.grey.shade900.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade800),
            ),
            child: Center(
              child: Text(
                "No memories yet. They will grow here as you remember.",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade500,
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          )
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: gameState.memories.map((memory) {
              return _buildMemoryCard(memory, isPreserved: true);
            }).toList(),
          ),
      ],
    );
  }

  Widget _buildSacrificedMemoriesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.warning, color: Colors.red.shade400, size: 28),
            const SizedBox(width: 8),
            const Text(
              'The Memories You Burned',
              style: TextStyle(
                fontSize: 24,
                color: Colors.white,
                fontWeight: FontWeight.w300,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'These were the costs. They are gone, but they were real.',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade400,
            fontStyle: FontStyle.italic,
          ),
        ),
        const SizedBox(height: 16),
        if (gameState.allSacrificedMemories.isEmpty)
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.grey.shade900.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade800),
            ),
            child: Center(
              child: Text(
                "You have preserved all your memories. The garden is full.",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade500,
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          )
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: gameState.allSacrificedMemories.map((memory) {
              return _buildMemoryCard(memory, isPreserved: false);
            }).toList(),
          ),
      ],
    );
  }

  Widget _buildMemoryCard(String memory, {required bool isPreserved}) {
    return Container(
      padding: const EdgeInsets.all(12),
      constraints: const BoxConstraints(minWidth: 150, maxWidth: 200),
      decoration: BoxDecoration(
        color: isPreserved
            ? Colors.yellow.shade900.withValues(alpha: 0.3)
            : Colors.grey.shade800.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isPreserved
              ? Colors.yellow.shade700.withValues(alpha: 0.5)
              : Colors.grey.shade700,
          width: 1,
        ),
      ),
      child: Text(
        memory,
        style: TextStyle(
          fontSize: 12,
          color: isPreserved
              ? Colors.yellow.shade200
              : Colors.grey.shade500,
          fontWeight: FontWeight.w300,
          decoration: isPreserved ? null : TextDecoration.lineThrough,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildBalanceSection() {
    final totalSacrificed = gameState.totalMemoriesSacrificed;
    final totalPreserved = gameState.totalMemoriesPreserved + gameState.memories.length;
    final total = totalSacrificed + totalPreserved;

    if (total == 0) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'The Balance',
          style: TextStyle(
            fontSize: 24,
            color: Colors.white,
            fontWeight: FontWeight.w300,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.shade900,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade800),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Lost',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade400,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$totalSacrificed',
                      style: TextStyle(
                        fontSize: 24,
                        color: Colors.red.shade400,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 1,
                height: 40,
                color: Colors.grey.shade700,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Kept',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade400,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$totalPreserved',
                      style: TextStyle(
                        fontSize: 24,
                        color: Colors.yellow.shade300,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPhilosophicalText() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.grey.shade900.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade800),
      ),
      child: Text(
        _getContextualText(),
        style: TextStyle(
          fontSize: 18,
          color: Colors.yellow.shade200,
          fontWeight: FontWeight.w300,
          height: 1.6,
          fontStyle: FontStyle.italic,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}

