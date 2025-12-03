import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'dart:async';
import 'dart:math';
import 'game/last_light_game.dart';
import 'models/game_state.dart';
import 'components/rebirth_sequence.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'The Light',
      theme: ThemeData.dark(),
      home: const LastLightScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class LastLightScreen extends StatefulWidget {
  const LastLightScreen({super.key});

  @override
  State<LastLightScreen> createState() => _LastLightScreenState();
}

class _LastLightScreenState extends State<LastLightScreen> {
  late LastLightGame game;
  late GameState gameState;
  Timer? gameTimer;
  Timer? whisperTimer;

  @override
  void initState() {
    super.initState();
    game = LastLightGame();
    gameState = GameState();

    // Game update loop
    gameTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (mounted && !gameState.isRebirthing) {
        setState(() {
          final phaseTransitioned = gameState.updateLight(0.1);
          game.updateLightPercent(gameState.lightPercent);

          // Check for phase transitions and whispers
          if (phaseTransitioned && Random().nextDouble() < 0.3) {
            gameState.addWhisper();
            Future.delayed(const Duration(seconds: 3), () {
              if (mounted) {
                setState(() {
                  gameState.removeWhisper();
                });
              }
            });
          }
        });
      }
    });

    // Memory display timer
    Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (mounted && gameState.showMemory != null) {
        Future.delayed(const Duration(seconds: 4), () {
          if (mounted) {
            setState(() {
              gameState.showMemory = null;
            });
          }
        });
      }
    });
  }

  @override
  void dispose() {
    gameTimer?.cancel();
    whisperTimer?.cancel();
    super.dispose();
  }

  void _handleClick() {
    setState(() {
      gameState.handleClick();
      game.updateLightPercent(gameState.lightPercent);
    });
  }

  void _buyUpgrade(String type) {
    setState(() {
      if (gameState.buyUpgrade(type)) {
        game.updateLightPercent(gameState.lightPercent);
      }
    });
  }

  void _sacrifice() {
    setState(() {
      gameState.sacrifice();
      game.updateLightPercent(gameState.lightPercent);
    });
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          gameState.showMemory = null;
        });
      }
    });
  }

  void _reborn() {
    setState(() {
      gameState.isRebirthing = true;
    });
  }

  void _completeRebirth() {
    setState(() {
      gameState.reborn();
      game.updateLightPercent(gameState.lightPercent);
      gameState.isRebirthing = false;
      gameState.showMemory =
          "Cycle ${gameState.rebornCount} complete. You carry forward what you've learned.";
    });

    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) {
        setState(() {
          gameState.showMemory = null;
        });
      }
    });
  }

  Color _getBackgroundColor() {
    final bgDarkness = gameState.bgDarkness;
    final saturation = (60 - bgDarkness).clamp(10, 60);
    final lightness = (30 - bgDarkness / 2).clamp(5, 30);

    return HSLColor.fromAHSL(
      1.0,
      220,
      saturation / 100,
      lightness / 100,
    ).toColor();
  }

  Color _getBottomColor() {
    final bgDarkness = gameState.bgDarkness;
    return HSLColor.fromAHSL(
      1.0,
      0,
      0,
      ((10 - bgDarkness / 3).clamp(2, 10) / 100),
    ).toColor();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [_getBackgroundColor(), _getBottomColor()],
          ),
        ),
        child: Stack(
          children: [
            // Flame game background
            Positioned.fill(
              child: GameWidget(game: game),
            ),

            // Rebirth animation overlay
            if (gameState.isRebirthing)
              Positioned.fill(
                child: RebirthSequence(
                  rebornCount: gameState.rebornCount + 1,
                  sacrifices: gameState.sacrifices,
                  darkness: gameState.darkness,
                  onComplete: _completeRebirth,
                ),
              ),

            // Whispers
            ...gameState.whispers.asMap().entries.map((entry) {
              final index = entry.key;
              final whisper = entry.value;
              return Positioned(
                top: 20 + (index * 10) * 4.0,
                left: 10 + (Random().nextDouble() * 80) * 4.0,
                child: Text(
                  whisper,
                  style: TextStyle(
                    color: Colors.red.shade500,
                    fontSize: 14,
                    fontWeight: FontWeight.w300,
                  ),
                ),
              );
            }),

            // Memory display
            if (gameState.showMemory != null)
              Positioned(
                top: MediaQuery.of(context).size.height * 0.33,
                left: 0,
                right: 0,
                child: Center(
                  child: Text(
                    gameState.showMemory!,
                    style: TextStyle(
                      color: Colors.yellow.shade200,
                      fontSize: 24,
                      fontWeight: FontWeight.w300,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),

            // Main UI
            Positioned.fill(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Stats
                    _buildStats(context),

                    const SizedBox(height: 16),

                    // Main click area
                    _buildClickButton(context),

                    const SizedBox(height: 16),

                    // Upgrades
                    _buildUpgrades(context),

                    // Dark choices
                    if (gameState.memories.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      _buildSacrificeButton(context),
                    ],

                    // Rebirth button
                    if (gameState.phase >= 4) ...[
                      const SizedBox(height: 16),
                      _buildRebirthButton(context),
                    ],

                    // Story text
                    const SizedBox(height: 16),
                    _buildStoryText(context),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStats(BuildContext context) {
    final lightPercent = gameState.lightPercent;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(
                  Icons.local_fire_department,
                  size: 24,
                  color: HSLColor.fromAHSL(
                    1.0,
                    45,
                    1.0,
                    lightPercent / 100,
                  ).toColor(),
                ),
                const SizedBox(width: 8),
                Text(
                  'The Light: ${gameState.light.floor()}/${gameState.maxLight.floor()}',
                  style: const TextStyle(
                    fontSize: 20,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            if (gameState.rebornCount > 0)
              Row(
                children: [
                  Icon(Icons.wb_sunny, size: 20, color: Colors.yellow.shade400),
                  const SizedBox(width: 8),
                  Text(
                    'Rebirths: ${gameState.rebornCount}',
                    style: const TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ],
              ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          height: 16,
          decoration: BoxDecoration(
            color: Colors.grey.shade800,
            borderRadius: BorderRadius.circular(8),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: lightPercent / 100,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    HSLColor.fromAHSL(1.0, 45, 1.0, 0.7).toColor(),
                    HSLColor.fromAHSL(1.0, 30, 1.0, 0.5).toColor(),
                  ],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Icon(Icons.favorite, size: 20, color: Colors.blue.shade400),
            const SizedBox(width: 8),
            Text(
              'Souls: ${gameState.souls.floor()}',
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
        if (gameState.phase > 0) ...[
          const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.warning, size: 20, color: Colors.red.shade400),
                const SizedBox(width: 8),
                Text(
                  'Darkness Phase: ${gameState.phase}',
                  style: TextStyle(color: Colors.red.shade400),
                ),
              ],
            ),
        ],
      ],
    );
  }

  Widget _buildClickButton(BuildContext context) {
    final lightPercent = gameState.lightPercent;

    return Center(
      child: GestureDetector(
        onTap: _handleClick,
        child: Container(
          width: 128,
          height: 128,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                HSLColor.fromAHSL(
                  1.0,
                  45,
                  1.0,
                  (lightPercent / 100).clamp(0.3, 1.0),
                ).toColor(),
                HSLColor.fromAHSL(
                  1.0,
                  30,
                  1.0,
                  (lightPercent / 200).clamp(0.2, 1.0),
                ).toColor(),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: HSLColor.fromAHSL(1.0, 45, 1.0, 0.7)
                    .toColor()
                    .withValues(alpha: 0.5),
                blurRadius: lightPercent / 5,
              ),
            ],
          ),
          child: Icon(
            Icons.local_fire_department,
            size: 64,
            color: lightPercent > 50 ? Colors.white : Colors.amber,
          ),
        ),
      ),
    );
  }

  Widget _buildUpgrades(BuildContext context) {
    final clickCost = (10 * pow(1.5, gameState.clickPower)).floor();
    final autoCost = (50 * pow(2, gameState.autoGather)).floor();
    final capacityCost = (100 * pow(2, gameState.maxLight / 100 - 1)).floor();
    final memoryCost = 200 + (gameState.memories.length * 100);
    final canBuyMemory = gameState.memories.length < GameState.memoryBank.length;
    final currentClickPower = gameState.clickPower * (1 + gameState.rebornCount * 0.5);

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 8,
      mainAxisSpacing: 8,
      childAspectRatio: 1.5,
      children: [
        _buildUpgradeButton(
          context,
          'Brighter Click',
          '+1 per click (Current: +${currentClickPower.toStringAsFixed(1)})',
          'Cost: $clickCost souls',
          Icons.bolt,
          Colors.yellow.shade900,
          gameState.souls >= clickCost,
          () => _buyUpgrade('click'),
          indicator: 'Lvl ${gameState.clickPower.toInt()}',
          indicatorColor: Colors.yellow.shade700,
        ),
        _buildUpgradeButton(
          context,
          'Soul Gatherer',
          '+0.5 souls/sec',
          'Cost: $autoCost souls',
          Icons.favorite,
          Colors.blue.shade900,
          gameState.souls >= autoCost,
          () => _buyUpgrade('auto'),
          indicator: '+${gameState.autoGather.toStringAsFixed(1)}/s',
          indicatorColor: Colors.blue.shade700,
        ),
        _buildUpgradeButton(
          context,
          'Expand Light',
          '+50 max light',
          'Cost: $capacityCost souls',
          Icons.local_fire_department,
          Colors.purple.shade900,
          gameState.souls >= capacityCost,
          () => _buyUpgrade('capacity'),
          indicator: 'Max: ${gameState.maxLight.toInt()}',
          indicatorColor: Colors.purple.shade700,
        ),
        _buildUpgradeButton(
          context,
          'Recall Memory',
          'Remember what matters',
          'Cost: $memoryCost souls',
          Icons.favorite,
          Colors.cyan.shade900,
          gameState.souls >= memoryCost && canBuyMemory,
          () => _buyUpgrade('memory'),
          indicator: '${gameState.memories.length}/${GameState.memoryBank.length}',
          indicatorColor: Colors.cyan.shade700,
        ),
      ],
    );
  }

  Widget _buildUpgradeButton(
    BuildContext context,
    String title,
    String description,
    String cost,
    IconData icon,
    Color color,
    bool enabled,
    VoidCallback onTap, {
    String? indicator,
    Color? indicatorColor,
  }) {
    return InkWell(
      onTap: enabled ? onTap : null,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: enabled
              ? color.withValues(alpha: 0.5)
              : color.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(icon, size: 20, color: Colors.white),
                    const SizedBox(width: 8),
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                if (indicator != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: (indicatorColor ?? color)
                          .withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      indicator,
                      style: const TextStyle(
                        fontSize: 10,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              description,
              style: const TextStyle(fontSize: 12, color: Colors.white70),
            ),
            const SizedBox(height: 4),
            Text(
              cost,
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey.shade400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSacrificeButton(BuildContext context) {
    return InkWell(
      onTap: _sacrifice,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.red.shade900.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.red.shade600, width: 2),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.warning, size: 20, color: Colors.white),
                const SizedBox(width: 8),
                const Text(
                  'Sacrifice a Memory',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            const Text(
              'Burn what you love for power',
              style: TextStyle(fontSize: 12, color: Colors.white70),
            ),
            const SizedBox(height: 4),
            Text(
              '+100 max light, +5 click power, +darkness',
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey.shade400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRebirthButton(BuildContext context) {
    final canReborn = gameState.souls >= 1000;
    return InkWell(
      onTap: canReborn ? _reborn : null,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: canReborn
                ? [Colors.yellow.shade600, Colors.orange.shade600]
                : [Colors.grey.shade700, Colors.grey.shade800],
          ),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: canReborn ? Colors.yellow.shade400 : Colors.grey,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.wb_sunny, size: 24, color: Colors.white),
                const SizedBox(width: 8),
                const Text(
                  'Be Reborn',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Start over, but carry the strength of your journey',
              style: TextStyle(fontSize: 12, color: Colors.white70),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              'Cost: 1000 souls | Rebirths grant permanent bonuses',
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey.shade300,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStoryText(BuildContext context) {
    String storyText = '';
    switch (gameState.phase) {
      case 0:
        storyText = "The light flickers. It always does. Keep it alive.";
        break;
      case 1:
        storyText = "The darkness grows hungry. It wants everything you have.";
        break;
      case 2:
        storyText = "You're tired. So tired. But you can't stop. Not yet.";
        break;
      case 3:
        storyText =
            "What are you even fighting for? Does it matter anymore?";
        break;
      case 4:
        storyText =
            "The void beckons. Perhaps there's peace in letting go... or strength in beginning again.";
        break;
    }

    return Text(
      storyText,
      style: TextStyle(
        fontSize: 14,
        color: Colors.grey.shade400,
      ),
      textAlign: TextAlign.center,
    );
  }
}
