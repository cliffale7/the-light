import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'dart:async';
import 'dart:math';
import 'game/last_light_game.dart';
import 'models/game_state.dart';
import 'components/rebirth_sequence.dart';
import 'components/sacrifice_ritual.dart';
import 'components/journey_reflection_screen.dart';
import 'services/save_service.dart';

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

class _LastLightScreenState extends State<LastLightScreen> with TickerProviderStateMixin {
  late LastLightGame game;
  GameState gameState =
      GameState(); // Initialize with default, will be replaced by load
  Timer? gameTimer;
  Timer? whisperTimer;
  bool showJourneyReflection = false;
  bool showSpecialItems = false;
  bool showShop = false;
  late TabController _shopTabController;

  @override
  void initState() {
    super.initState();
    game = LastLightGame();
    _shopTabController = TabController(length: 2, vsync: this);
    _loadGameState();
  }

  Future<void> _loadGameState() async {
    final loadedState = await SaveService.loadGameState();
    if (mounted) {
      setState(() {
        gameState = loadedState ?? GameState();
        game.updateLightPercent(gameState.lightPercent);
      });

      // Start game timer after loading
      _startGameTimer();
    }
  }

  void _startGameTimer() {
    // Game update loop
    gameTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (mounted && !gameState.isRebirthing) {
        setState(() {
          final phaseTransitioned = gameState.updateLight(0.1);
          game.updateLightPercent(gameState.lightPercent);

          // Check for phase transitions and whispers
          if (phaseTransitioned) {
            // Increased whisper frequency in later phases
            final whisperChance = 0.3 + (gameState.phase * 0.15);
            if (Random().nextDouble() < whisperChance) {
              gameState.addWhisper();
              Future.delayed(const Duration(seconds: 3), () {
                if (mounted) {
                  setState(() {
                    gameState.removeWhisper();
                  });
                }
              });
            }
          }

          // Add whispers during low light
          if (gameState.lightPercent < 20 &&
              gameState.whispers.isEmpty &&
              Random().nextDouble() < 0.1) {
            gameState.addWhisper();
            Future.delayed(const Duration(seconds: 4), () {
              if (mounted) {
                setState(() {
                  gameState.removeWhisper();
                });
              }
            });
          }

          // Add whisper after sacrifice
          if (gameState.isShowingSacrificeAftermath &&
              gameState.whispers.isEmpty) {
            Future.delayed(const Duration(milliseconds: 500), () {
              if (mounted) {
                setState(() {
                  gameState.addWhisper();
                });
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
    _shopTabController.dispose();
    _saveGameState(); // Save on dispose
    super.dispose();
  }

  void _handleClick() {
    setState(() {
      gameState.handleClick();
      game.updateLightPercent(gameState.lightPercent);
    });
    // Auto-save periodically (every 10 clicks or so)
    if (gameState.souls.floor() % 10 == 0) {
      _saveGameState();
    }
  }

  void _buyUpgrade(String type) {
    setState(() {
      if (gameState.buyUpgrade(type)) {
        game.updateLightPercent(gameState.lightPercent);
        _saveGameState(); // Save after upgrade
      }
    });
  }

  void _sacrifice() {
    if (gameState.memories.isEmpty) return;

    setState(() {
      gameState.startSacrificeRitual();
    });
  }

  void _continueFromMemoryPreview() {
    setState(() {
      gameState.isShowingMemoryPreview = false;
      gameState.isShowingSacrificeConfirmation = true;
    });
  }

  void _confirmSacrifice() {
    setState(() {
      gameState.confirmSacrifice();
      game.updateLightPercent(gameState.lightPercent);
      _saveGameState(); // Save after sacrifice
    });
  }

  void _cancelSacrifice() {
    setState(() {
      gameState.cancelSacrifice();
    });
  }

  void _completeSacrificeAftermath() {
    setState(() {
      gameState.completeSacrificeAftermath();
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

  Future<void> _saveGameState() async {
    await SaveService.saveGameState(gameState);
  }

  void _completeRebirth() {
    setState(() {
      gameState.reborn();
      game.updateLightPercent(gameState.lightPercent);
      gameState.isRebirthing = false;
      gameState.showMemory =
          "Cycle ${gameState.rebornCount} complete. You carry forward what you've learned.";
    });
    _saveGameState(); // Save after rebirth

    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) {
        setState(() {
          gameState.showMemory = null;
        });
      }
    });
  }

  void _toggleJourneyReflection() {
    setState(() {
      showJourneyReflection = !showJourneyReflection;
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
    return PopScope(
      canPop: !showShop && !showSpecialItems && !showJourneyReflection,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        // Handle back button - close overlays in order of priority
        if (showJourneyReflection) {
          setState(() => showJourneyReflection = false);
        } else if (showShop) {
          setState(() => showShop = false);
        } else if (showSpecialItems) {
          setState(() => showSpecialItems = false);
        }
      },
      child: Scaffold(
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
            Positioned.fill(child: GameWidget(game: game)),

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

            // Sacrifice Ritual Overlays
            if (gameState.isShowingMemoryPreview &&
                gameState.memoryToSacrifice != null)
              Positioned.fill(
                child: MemoryPreviewOverlay(
                  memory: gameState.memoryToSacrifice!,
                  onContinue: _continueFromMemoryPreview,
                  onCancel: _cancelSacrifice,
                ),
              ),

            if (gameState.isShowingSacrificeConfirmation &&
                gameState.memoryToSacrifice != null)
              Positioned.fill(
                child: SacrificeConfirmationDialog(
                  memory: gameState.memoryToSacrifice!,
                  onConfirm: _confirmSacrifice,
                  onCancel: _cancelSacrifice,
                ),
              ),

            if (gameState.isShowingSacrificeAftermath &&
                gameState.allSacrificedMemories.isNotEmpty)
              Positioned.fill(
                child: SacrificeAftermath(
                  memory: gameState.allSacrificedMemories.last,
                  onComplete: _completeSacrificeAftermath,
                ),
              ),

            // Whispers with enhanced visual effects
            ...gameState.whispers.asMap().entries.map((entry) {
              final index = entry.key;
              final whisper = entry.value;
              final phase = gameState.phase;
              final intensity = (phase / 4.0).clamp(0.0, 1.0);

              return Positioned(
                top: MediaQuery.of(context).padding.top + 60 + (index * 30),
                left: 16,
                right: 16,
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: 1.0),
                  duration: const Duration(milliseconds: 1000),
                  builder: (context, value, child) {
                    return Opacity(
                      opacity: value,
                      child: Text(
                        whisper,
                        style: TextStyle(
                          color: Color.lerp(
                            Colors.red.shade500,
                            Colors.red.shade900,
                            intensity,
                          ),
                          fontSize: 16 + (intensity * 2),
                          fontWeight: FontWeight.w400,
                          shadows: [
                            Shadow(
                              color: Colors.red.shade900.withValues(
                                alpha: 0.5 * intensity,
                              ),
                              blurRadius: 4 * intensity,
                            ),
                          ],
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  },
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

            // Journey Reflection Screen
            if (showJourneyReflection)
              Positioned.fill(
                child: JourneyReflectionScreen(
                  gameState: gameState,
                  onClose: _toggleJourneyReflection,
                ),
              ),

            // Main UI
            if (!showJourneyReflection && !showShop)
              Positioned.fill(
                child: SafeArea(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Stats (compact)
                        _buildStats(context),

                        const SizedBox(height: 4),

                        // Main click area (smaller)
                        _buildClickButton(context, compact: true),

                        const SizedBox(height: 4),

                      // Upgrades (compact grid)
                      _buildUpgrades(context, compact: true),

                      const SizedBox(height: 4),

                      // Action buttons row
                        Row(
                          children: [
                            // Sacrifice button
                            if (gameState.memories.isNotEmpty)
                              Expanded(
                                child: _buildSacrificeButton(context, compact: true),
                              ),
                            if (gameState.memories.isNotEmpty && gameState.phase >= 6)
                              const SizedBox(width: 8),
                            // Rebirth button
                            if (gameState.phase >= 6)
                              Expanded(
                                child: _buildRebirthButton(context, compact: true),
                              ),
                          ],
                        ),

                        // Story text (compact)
                        const SizedBox(height: 4),
                        _buildStoryText(context, compact: true),
                      ],
                    ),
                  ),
                ),
              ),
            
            // Shop overlay
            if (showShop)
              Positioned.fill(
                child: _buildShopScreen(context),
              ),
            
            // Special Items drawer overlay
            if (showSpecialItems)
              Positioned.fill(
                child: GestureDetector(
                  onTap: () => setState(() => showSpecialItems = false),
                  child: Container(
                    color: Colors.black.withValues(alpha: 0.5),
                    child: _buildSpecialItemsDrawer(context),
                  ),
                ),
              ),
          ],
        ),
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
                  size: 18,
                  color: HSLColor.fromAHSL(
                    1.0,
                    45,
                    1.0,
                    lightPercent / 100,
                  ).toColor(),
                ),
                const SizedBox(width: 6),
                Text(
                  '${gameState.light.floor()}/${gameState.maxLight.floor()}',
                  style: const TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            Row(
              children: [
                if (gameState.rebornCount > 0)
                  Row(
                    children: [
                      Icon(
                        Icons.wb_sunny,
                        size: 16,
                        color: Colors.yellow.shade400,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${gameState.rebornCount}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                  ),
                // Store button
                IconButton(
                  onPressed: () => setState(() => showShop = true),
                  icon: Icon(
                    Icons.store,
                    color: Colors.blue.shade300,
                    size: 20,
                  ),
                  tooltip: 'Store',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                const SizedBox(width: 4),
                // Special Items button
                IconButton(
                  onPressed: () => setState(() => showSpecialItems = true),
                  icon: Stack(
                    children: [
                      Icon(
                        Icons.inventory_2,
                        color: Colors.purple.shade300,
                        size: 20,
                      ),
                      if (gameState.hasMirror || gameState.hasCompass || gameState.hasLantern)
                        Positioned(
                          right: 0,
                          top: 0,
                          child: Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: Colors.orange,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                    ],
                  ),
                  tooltip: 'Special Items',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                const SizedBox(width: 4),
                // Your Journey button
                IconButton(
                  onPressed: _toggleJourneyReflection,
                  icon: Icon(
                    Icons.local_florist,
                    color: Colors.yellow.shade300,
                    size: 20,
                  ),
                  tooltip: 'Your Journey',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 4),
        Container(
          height: 12,
          decoration: BoxDecoration(
            color: Colors.grey.shade800,
            borderRadius: BorderRadius.circular(6),
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
                borderRadius: BorderRadius.circular(6),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Icon(Icons.favorite, size: 16, color: Colors.blue.shade400),
            const SizedBox(width: 6),
            Text(
              'Souls: ${gameState.souls.floor()}',
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
          ],
        ),
        if (gameState.phase > 0) ...[
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(Icons.warning, size: 16, color: Colors.red.shade400),
              const SizedBox(width: 6),
              Text(
                'Phase: ${gameState.phase}',
                style: TextStyle(color: Colors.red.shade400, fontSize: 14),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildClickButton(BuildContext context, {bool compact = false}) {
    final lightPercent = gameState.lightPercent;
    final size = compact ? 100.0 : 128.0;

    return Center(
      child: GestureDetector(
        onTap: _handleClick,
        child: Container(
          width: size,
          height: size,
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
                color: HSLColor.fromAHSL(
                  1.0,
                  45,
                  1.0,
                  0.7,
                ).toColor().withValues(alpha: 0.5),
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

  Widget _buildUpgrades(BuildContext context, {bool compact = false}) {
    final clickCost = (10 * pow(1.5, gameState.clickPower)).floor();
    final autoCost = (50 * pow(2, gameState.autoGather)).floor();
    final capacityCost = (100 * pow(2, gameState.maxLight / 100 - 1)).floor();
    final memoryCost = 200 + (gameState.memories.length * 100);
    final keeperCost = (200 * pow(2, gameState.decayResistance * 10)).floor();
    final resonanceCost = (500 * pow(3, gameState.memoryResonance)).floor();
    final canBuyMemory =
        gameState.memories.length < GameState.memoryBank.length;
    final currentClickPower =
        gameState.clickPower * (1 + gameState.rebornCount * 0.5);
    final canBuyKeeper = gameState.decayResistance < 0.5;
    final canBuyResonance = gameState.memoryResonance < 3.0;

    return Column(
      children: [
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: compact ? 6 : 8,
          mainAxisSpacing: compact ? 6 : 8,
          childAspectRatio: compact ? 1.8 : 1.5,
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
              indicator:
                  '${gameState.memories.length}/${GameState.memoryBank.length}',
              indicatorColor: Colors.cyan.shade700,
            ),
            _buildUpgradeButton(
              context,
              'The Keeper',
              '-10% decay rate',
              'Cost: $keeperCost souls',
              Icons.shield,
              Colors.green.shade900,
              gameState.souls >= keeperCost && canBuyKeeper,
              () => _buyUpgrade('keeper'),
              indicator: '${(gameState.decayResistance * 100).toInt()}%',
              indicatorColor: Colors.green.shade700,
            ),
            _buildUpgradeButton(
              context,
              'Memory Resonance',
              '1 memory per 5 min',
              'Cost: $resonanceCost souls',
              Icons.waves,
              Colors.pink.shade900,
              gameState.souls >= resonanceCost && canBuyResonance,
              () => _buyUpgrade('resonance'),
              indicator: 'Lvl ${gameState.memoryResonance.toInt()}',
              indicatorColor: Colors.pink.shade700,
            ),
          ],
        ),
      ],
    );
  }

  void _useMirror() {
    setState(() {
      gameState.useMirror();
    });
  }

  void _useCompass() {
    setState(() {
      gameState.useCompass();
    });
  }

  void _useLantern() {
    setState(() {
      gameState.useLantern();
      game.updateLightPercent(gameState.lightPercent);
    });
  }

  Widget _buildSpecialItemButton(
    BuildContext context,
    String title,
    String description,
    String cost,
    IconData icon,
    Color color,
    bool enabled,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: enabled ? onTap : null,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: enabled
              ? color.withValues(alpha: 0.5)
              : color.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: enabled ? color : Colors.grey.shade700,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, size: 24, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    description,
                    style: const TextStyle(fontSize: 12, color: Colors.white70),
                  ),
                  Text(
                    cost,
                    style: TextStyle(fontSize: 10, color: Colors.grey.shade400),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpecialItemUseButton(
    BuildContext context,
    String title,
    bool enabled,
    String cooldownText,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: enabled ? onTap : null,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: enabled
              ? color.withValues(alpha: 0.5)
              : Colors.grey.shade800.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: enabled ? color : Colors.grey.shade700,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, size: 24, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    cooldownText,
                    style: TextStyle(
                      fontSize: 12,
                      color: enabled ? Colors.white70 : Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
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
                Flexible(
                  child: Row(
                    children: [
                      Icon(icon, size: 20, color: Colors.white),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                if (indicator != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: (indicatorColor ?? color).withValues(alpha: 0.5),
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
              style: TextStyle(fontSize: 10, color: Colors.grey.shade400),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSacrificeButton(BuildContext context, {bool compact = false}) {
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
              style: TextStyle(fontSize: 10, color: Colors.grey.shade400),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRebirthButton(BuildContext context, {bool compact = false}) {
    final rebirthCost = 2000 + (gameState.rebornCount * 500);
    final canReborn = gameState.phase >= 6 && gameState.souls >= rebirthCost;
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
              style: TextStyle(fontSize: 10, color: Colors.grey.shade300),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStoryText(BuildContext context, {bool compact = false}) {
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
        storyText = "What are you even fighting for? Does it matter anymore?";
        break;
      case 4:
        storyText =
            "Does it matter anymore? The question echoes in the void.";
        break;
      case 5:
        storyText =
            "The void whispers your name. It knows you. It wants you.";
        break;
      case 6:
        storyText =
            "The end... or the beginning? The void beckons. Perhaps there's peace in letting go... or strength in beginning again.";
        break;
    }

    return Container(
      padding: EdgeInsets.all(compact ? 12 : 16),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        storyText,
        style: TextStyle(
          fontSize: compact ? 14 : 18,
          color: Colors.white,
          fontStyle: FontStyle.italic,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
  
  Widget _buildShopScreen(BuildContext context) {
    return Container(
      color: Colors.black.withValues(alpha: 0.95),
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Store',
                  style: TextStyle(
                    fontSize: 28,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: () => setState(() => showShop = false),
                  icon: const Icon(Icons.close, color: Colors.white),
                ),
              ],
            ),
          ),
          const Divider(color: Colors.grey),
          // Currency display
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Row(
                  children: [
                    Icon(Icons.favorite, color: Colors.blue.shade400, size: 24),
                    const SizedBox(width: 8),
                    Text(
                      '${gameState.souls.floor()}',
                      style: const TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Icon(Icons.diamond, color: Colors.cyan.shade400, size: 24),
                    const SizedBox(width: 8),
                    Text(
                      '${gameState.gems}',
                      style: const TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Content
          Expanded(
            child: Column(
              children: [
                TabBar(
                  controller: _shopTabController,
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.grey,
                  indicatorColor: Colors.blue,
                  tabs: const [
                    Tab(text: 'Soul Purchases'),
                    Tab(text: 'Premium Shop'),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    controller: _shopTabController,
                    children: [
                      // Soul Purchases Tab
                      ListView(
                        padding: const EdgeInsets.all(16),
                        children: [
                            const Text(
                              'Special Items can be purchased here or from the Special Items drawer.',
                              style: TextStyle(color: Colors.white70, fontSize: 14),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            if (!gameState.hasMirror)
                              _buildShopItem(
                                context,
                                'The Mirror',
                                'See your reflection, gain insight',
                                '1000 souls',
                                Icons.auto_awesome,
                                Colors.amber.shade900,
                                gameState.souls >= 1000,
                                () {
                                  _buyUpgrade('mirror');
                                },
                                isSoul: true,
                              ),
                            if (!gameState.hasCompass)
                              _buildShopItem(
                                context,
                                'The Compass',
                                'Find direction, quiet the voices',
                                '1500 souls',
                                Icons.explore,
                                Colors.indigo.shade900,
                                gameState.souls >= 1500,
                                () {
                                  _buyUpgrade('compass');
                                },
                                isSoul: true,
                              ),
                            if (!gameState.hasLantern)
                              _buildShopItem(
                                context,
                                'The Lantern',
                                'Hope that never fully dies',
                                '2000 souls',
                                Icons.light_mode,
                                Colors.orange.shade900,
                                gameState.souls >= 2000,
                                () {
                                  _buyUpgrade('lantern');
                                },
                                isSoul: true,
                              ),
                        ],
                      ),
                      // Premium Shop Tab
                      ListView(
                        padding: const EdgeInsets.all(16),
                        children: [
                            const Text(
                              'Support The Light',
                              style: TextStyle(
                                fontSize: 24,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Your support helps keep the light alive.',
                              style: TextStyle(color: Colors.white70, fontSize: 16),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 24),
                            _buildGemPack(
                              context,
                              'Small Light',
                              '100 Gems',
                              '\$0.99',
                              Icons.diamond,
                              Colors.cyan.shade400,
                              100,
                            ),
                            _buildGemPack(
                              context,
                              'Bright Light',
                              '550 Gems',
                              '\$4.99',
                              Icons.diamond,
                              Colors.cyan.shade300,
                              550,
                            ),
                            _buildGemPack(
                              context,
                              'Radiant Light',
                              '1200 Gems',
                              '\$9.99',
                              Icons.diamond,
                              Colors.cyan.shade200,
                              1200,
                            ),
                            const SizedBox(height: 24),
                            const Text(
                              'Premium Items',
                              style: TextStyle(
                                fontSize: 20,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'More premium items coming soon...',
                              style: TextStyle(color: Colors.white70, fontSize: 14),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
  
  Widget _buildSpecialItemsDrawer(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        height: screenHeight * 0.7,
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.95),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade600,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Special Items',
                    style: TextStyle(
                      fontSize: 24,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: () => setState(() => showSpecialItems = false),
                    icon: const Icon(Icons.close, color: Colors.white),
                  ),
                ],
              ),
            ),
            const Divider(color: Colors.grey),
            // Content
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Purchase section
                  if (!gameState.hasMirror ||
                      !gameState.hasCompass ||
                      !gameState.hasLantern) ...[
                    const Text(
                      'Available Items',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (!gameState.hasMirror)
                      _buildSpecialItemButton(
                        context,
                        'The Mirror',
                        'See your reflection, gain insight',
                        'Cost: 1000 souls',
                        Icons.auto_awesome,
                        Colors.amber.shade900,
                        gameState.souls >= 1000,
                        () {
                          _buyUpgrade('mirror');
                          setState(() {});
                        },
                      ),
                    if (!gameState.hasCompass)
                      _buildSpecialItemButton(
                        context,
                        'The Compass',
                        'Find direction, quiet the voices',
                        'Cost: 1500 souls',
                        Icons.explore,
                        Colors.indigo.shade900,
                        gameState.souls >= 1500,
                        () {
                          _buyUpgrade('compass');
                          setState(() {});
                        },
                      ),
                    if (!gameState.hasLantern)
                      _buildSpecialItemButton(
                        context,
                        'The Lantern',
                        'Hope that never fully dies',
                        'Cost: 2000 souls',
                        Icons.light_mode,
                        Colors.orange.shade900,
                        gameState.souls >= 2000,
                        () {
                          _buyUpgrade('lantern');
                          setState(() {});
                        },
                      ),
                    const SizedBox(height: 24),
                  ],
                  // Usage section
                  if (gameState.hasMirror || gameState.hasCompass || gameState.hasLantern) ...[
                    const Text(
                      'Use Items',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (gameState.hasMirror)
                      _buildSpecialItemUseButton(
                        context,
                        'The Mirror',
                        gameState.canUseMirror(),
                        gameState.mirrorLastUsed != null
                            ? 'Cooldown: ${5 - DateTime.now().difference(gameState.mirrorLastUsed!).inMinutes} min'
                            : 'Ready',
                        Icons.auto_awesome,
                        Colors.amber.shade700,
                        () => _useMirror(),
                      ),
                    if (gameState.hasCompass)
                      _buildSpecialItemUseButton(
                        context,
                        'The Compass',
                        gameState.canUseCompass(),
                        gameState.compassLastUsed != null
                            ? 'Cooldown: ${3 - DateTime.now().difference(gameState.compassLastUsed!).inMinutes} min'
                            : 'Ready',
                        Icons.explore,
                        Colors.indigo.shade700,
                        () => _useCompass(),
                      ),
                    if (gameState.hasLantern)
                      _buildSpecialItemUseButton(
                        context,
                        'The Lantern',
                        gameState.canUseLantern(),
                        gameState.lanternLastUsed != null
                            ? 'Cooldown: ${10 - DateTime.now().difference(gameState.lanternLastUsed!).inMinutes} min'
                            : 'Ready',
                        Icons.light_mode,
                        Colors.orange.shade700,
                        () => _useLantern(),
                      ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildShopItem(
    BuildContext context,
    String title,
    String description,
    String cost,
    IconData icon,
    Color color,
    bool enabled,
    VoidCallback onTap, {
    bool isSoul = false,
  }) {
    return InkWell(
      onTap: enabled ? onTap : null,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: enabled
              ? color.withValues(alpha: 0.3)
              : color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: enabled ? color : Colors.grey.shade700,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, size: 32, color: Colors.white),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: const TextStyle(fontSize: 14, color: Colors.white70),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        isSoul ? Icons.favorite : Icons.diamond,
                        size: 16,
                        color: isSoul ? Colors.blue.shade400 : Colors.cyan.shade400,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        cost,
                        style: TextStyle(
                          fontSize: 16,
                          color: enabled ? Colors.white : Colors.grey.shade500,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (enabled)
              Icon(Icons.arrow_forward_ios, color: Colors.white, size: 20),
          ],
        ),
      ),
    );
  }
  
  Widget _buildGemPack(
    BuildContext context,
    String title,
    String gems,
    String price,
    IconData icon,
    Color color,
    int gemAmount,
  ) {
    return InkWell(
      onTap: () {
        // TODO: Implement in-app purchase
        // For now, just add gems (testing/demo mode)
        setState(() {
          gameState.gems += gemAmount;
          _saveGameState();
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Purchased $gems! (Demo mode - IAP not yet implemented)'),
            backgroundColor: Colors.green,
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color, width: 2),
        ),
        child: Row(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    gems,
                    style: TextStyle(
                      fontSize: 16,
                      color: color,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              price,
              style: const TextStyle(
                fontSize: 20,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
