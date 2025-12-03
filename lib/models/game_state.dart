import 'dart:math';

class GameState {
  final Random _random = Random();
  
  double light = 100.0;
  double maxLight = 100.0;
  double souls = 1000.0;
  int gems = 0; // Premium currency - purchased with real money
  double clickPower = 1.0;
  double autoGather = 0.0;
  double decayResistance = 0.0; // The Keeper - reduces decay
  double memoryResonance = 0.0; // Memory Resonance - passive memory generation
  int phaseStability = 0; // The Anchor - grace period before phase transition
  int phase = 4;
  List<String> memories = [];
  String? showMemory;
  int sacrifices = 0;
  double darkness = 0.0;
  List<String> whispers = [];
  int rebornCount = 0;
  bool isRebirthing = false;
  
  // Special Items
  bool hasMirror = false;
  bool hasCompass = false;
  bool hasLantern = false;
  DateTime? mirrorLastUsed;
  DateTime? compassLastUsed;
  DateTime? lanternLastUsed;
  
  // Memory resonance tracking
  double memoryResonanceProgress = 0.0; // Progress toward next memory
  
  // Persistent tracking across all cycles
  List<String> allSacrificedMemories = [];
  int totalMemoriesSacrificed = 0;
  int totalMemoriesPreserved = 0;
  
  // Sacrifice ritual state
  String? memoryToSacrifice;
  bool isShowingMemoryPreview = false;
  bool isShowingSacrificeConfirmation = false;
  bool isShowingSacrificeAftermath = false;

  static const List<String> memoryBank = [
    "A child's laughter echoes...",
    "The smell of rain on warm pavement...",
    "Your mother's voice singing...",
    "The first time someone said they loved you...",
    "A perfect summer afternoon...",
    "The taste of your favorite meal...",
    "A hug that made everything okay...",
    "The sound of waves at night...",
    "Dancing alone in your room...",
    "A sunset that took your breath away..."
  ];

  static const List<String> whisperBank = [
    "Let go...",
    "It's easier in the dark...",
    "Why keep fighting?",
    "The void is peaceful...",
    "Nothing matters...",
    "Give in...",
    "Stop trying...",
    "Embrace the end..."
  ];

  // Context-aware whisper pools
  static const List<String> manySacrificesWhispers = [
    "You've given up so much already... why keep going?",
    "How many memories is enough? When do you stop?",
    "You're burning yourself away. What's left?",
    "Was it worth it? Do you even remember what you lost?",
    "Another one gone. How many more?",
    "You've sacrificed everything that mattered. Why continue?",
  ];

  static const List<String> fewSacrificesWhispers = [
    "You're holding on too tight. Let go. It's easier.",
    "Those memories are weighing you down. Burn them.",
    "You could be stronger. You choose to be weak.",
    "Why suffer when you could just let go?",
    "Your memories are chains. Break them.",
  ];

  static const List<String> highCycleWhispers = [
    "How many times will you do this? When does it end?",
    "You've done this before. Nothing changes.",
    "The cycle repeats. Nothing matters.",
    "Again? Really? When will you learn?",
    "You're stuck. This is all there is.",
  ];

  static const List<String> lowLightWhispers = [
    "This is it. This time, just let it fade.",
    "You're tired. You've earned the rest.",
    "It's okay to stop. Really. It's okay.",
    "Just let go. It's easier.",
    "The darkness is calling. Answer it.",
  ];

  double get lightPercent => (light / maxLight) * 100;
  double get bgDarkness => (darkness + (100 - lightPercent) * 0.5).clamp(0, 95);

  bool updateLight(double delta) {
    final oldPhase = phase;
    // Slower decay: 0.3 + (phase * 0.15) instead of 0.5 + (phase * 0.2)
    // Apply decay resistance
    final baseDecay = 0.3 + (phase * 0.15);
    var decay = baseDecay * (1 - decayResistance.clamp(0.0, 0.5));
    
    // Lantern grace period: 50% decay reduction for 30 seconds after use
    if (isLanternGraceActive()) {
      decay *= 0.5;
    }
    
    // CRITICAL: Phase transitions must always be possible - the darkness must be able to consume
    // The Lantern provides temporary respite, not permanent protection
    light = (light - decay * delta * 10).clamp(0.0, maxLight);

    // Phase progression - extended to 6 phases, with stability grace period
    // IMPORTANT: Light must be able to hit 0 for phase progression - this is core to the game
    if (light <= 0 && phase < 6) {
      // Check for phase stability grace period (future implementation)
      // For now, proceed with phase transition
      phase++;
      darkness = (darkness + 20).clamp(0, 100);
      light = maxLight * 0.5;
    }

    // Auto-gather souls - but with diminishing returns to prevent pure idle play
    // Auto-gather is 50% less effective than active clicking
    if (autoGather > 0) {
      souls += autoGather * delta * 10 * 0.5; // 50% efficiency
    }
    
    // Memory Resonance - passive memory generation
    // BUT: Requires active engagement - only progresses when light is above 20%
    // This ensures players must actively maintain their light to receive passive memories
    if (memoryResonance > 0 && lightPercent > 20) {
      memoryResonanceProgress += memoryResonance * delta;
      // 1 memory per 5 minutes = 300 seconds (slower than active recall)
      if (memoryResonanceProgress >= 300.0) {
        memoryResonanceProgress = 0.0;
        _generateResonanceMemory();
      }
    }

    return phase > oldPhase;
  }
  
  void _generateResonanceMemory() {
    final unusedMemories = memoryBank
        .where((m) => !memories.contains(m))
        .toList();
    if (unusedMemories.isNotEmpty) {
      final newMemory = unusedMemories[_random.nextInt(unusedMemories.length)];
      memories.add(newMemory);
      showMemory = "A memory resonates from the past: $newMemory";
    }
  }

  void handleClick() {
    final gain = clickPower * (1 + rebornCount * 0.5);
    light = (light + gain).clamp(0, maxLight);
    souls += 0.1 * (1 + rebornCount * 0.2);
  }

  bool buyUpgrade(String type) {
    final costs = {
      'click': (10 * pow(1.5, clickPower)).floorToDouble(),
      'auto': (50 * pow(2, autoGather)).floorToDouble(),
      'capacity': (100 * pow(2, maxLight / 100 - 1)).floorToDouble(),
      'memory': (200 + (memories.length * 100)).toDouble(),
      'keeper': (200 * pow(2, decayResistance * 10)).floorToDouble(),
      'resonance': (500 * pow(3, memoryResonance)).floorToDouble(),
      'anchor': (300 * pow(2.5, phaseStability)).floorToDouble(),
      'mirror': 1000.0,
      'compass': 1500.0,
      'lantern': 2000.0,
    };

    final cost = costs[type] ?? 0.0;
    if (souls < cost) return false;

    souls -= cost;

    switch (type) {
      case 'click':
        clickPower += 1;
        break;
      case 'auto':
        autoGather += 0.5;
        break;
      case 'capacity':
        maxLight += 50;
        break;
      case 'memory':
        final unusedMemories = memoryBank
            .where((m) => !memories.contains(m))
            .toList();
        if (unusedMemories.isNotEmpty) {
          final newMemory = unusedMemories[_random.nextInt(unusedMemories.length)];
          memories.add(newMemory);
          showMemory = newMemory;
        }
        break;
      case 'keeper':
        if (decayResistance < 0.5) {
          decayResistance = (decayResistance + 0.05).clamp(0.0, 0.5);
        }
        break;
      case 'resonance':
        if (memoryResonance < 3.0) {
          memoryResonance += 1.0;
        }
        break;
      case 'anchor':
        if (phaseStability < 5) {
          phaseStability += 1;
        }
        break;
      case 'mirror':
        hasMirror = true;
        break;
      case 'compass':
        hasCompass = true;
        break;
      case 'lantern':
        hasLantern = true;
        break;
    }

    return true;
  }

  String? getMemoryToSacrifice() {
    if (memories.isEmpty) return null;
    return memories.last;
  }

  void startSacrificeRitual() {
    if (memories.isEmpty) return;
    memoryToSacrifice = memories.last;
    isShowingMemoryPreview = true;
  }

  void confirmSacrifice() {
    if (memoryToSacrifice == null || memories.isEmpty) return;

    final sacrificedMemory = memoryToSacrifice!;
    memories.removeLast();
    sacrifices++;
    totalMemoriesSacrificed++;
    allSacrificedMemories.add(sacrificedMemory);
    
    maxLight += 100;
    clickPower += 5;
    darkness = (darkness + 10).clamp(0, 100);
    
    isShowingMemoryPreview = false;
    isShowingSacrificeConfirmation = false;
    isShowingSacrificeAftermath = true;
    memoryToSacrifice = null;
  }

  void cancelSacrifice() {
    memoryToSacrifice = null;
    isShowingMemoryPreview = false;
    isShowingSacrificeConfirmation = false;
  }

  void completeSacrificeAftermath() {
    isShowingSacrificeAftermath = false;
    showMemory = "The memory is gone. The power remains.";
  }

  // Special item activations
  bool canUseMirror() {
    if (!hasMirror) return false;
    if (mirrorLastUsed == null) return true;
    return DateTime.now().difference(mirrorLastUsed!).inMinutes >= 5;
  }

  void useMirror() {
    if (!canUseMirror()) return;
    mirrorLastUsed = DateTime.now();
    // Grant bonus based on journey
    final bonus = (totalMemoriesSacrificed > totalMemoriesPreserved + memories.length)
        ? 1.5  // If sacrificed more, get soul bonus
        : 1.3; // Otherwise smaller bonus
    souls += 100 * bonus;
    showMemory = _getMirrorReflection();
  }

  String _getMirrorReflection() {
    if (totalMemoriesSacrificed > totalMemoriesPreserved + memories.length) {
      return "The mirror shows strength, but at a cost. You see what you've given up.";
    } else if (memories.isNotEmpty) {
      return "The mirror shows what you've held onto. These moments define you.";
    } else {
      return "The mirror shows a journey just beginning. The path is yours to choose.";
    }
  }

  bool canUseCompass() {
    if (!hasCompass) return false;
    if (compassLastUsed == null) return true;
    return DateTime.now().difference(compassLastUsed!).inMinutes >= 3;
  }

  void useCompass() {
    if (!canUseCompass()) return;
    compassLastUsed = DateTime.now();
    // Clear all whispers
    whispers.clear();
    showMemory = "The compass points inward. The voices quiet. You know your path.";
  }

  bool canUseLantern() {
    if (!hasLantern) return false;
    if (lanternLastUsed == null) return true;
    return DateTime.now().difference(lanternLastUsed!).inMinutes >= 10;
  }

  void useLantern() {
    if (!canUseLantern()) return;
    lanternLastUsed = DateTime.now();
    // Restore light to 50% - a moment of respite, not permanent protection
    light = maxLight * 0.5;
    showMemory = "The lantern's light fills you. Hope returns. The darkness recedes.";
  }
  
  // The Lantern provides a temporary grace period after use
  // For 30 seconds after use, decay is reduced by 50%
  bool isLanternGraceActive() {
    if (!hasLantern || lanternLastUsed == null) return false;
    final secondsSinceUse = DateTime.now().difference(lanternLastUsed!).inSeconds;
    return secondsSinceUse < 30; // 30 second grace period
  }

  double getWhisperReduction() {
    return hasCompass ? 0.25 : 0.0;
  }

  void reborn() {
    // Increased rebirth cost: 2000 souls (or scale with rebornCount)
    final rebirthCost = 2000 + (rebornCount * 500);
    if (phase >= 6 && souls >= rebirthCost) {
      isRebirthing = true;
      rebornCount++;
      light = 100;
      maxLight = 100;
      souls = 0;
      clickPower = 1;
      autoGather = 0;
      // Generators reset
      decayResistance = 0.0;
      memoryResonance = 0.0;
      phaseStability = 0;
      memoryResonanceProgress = 0.0;
      phase = 0;
      
      // Track preserved memories before clearing
      totalMemoriesPreserved += memories.length;
      
      memories.clear();
      sacrifices = 0;
      darkness = (darkness - 50).clamp(0, 100);
      
      // Reset sacrifice ritual state
      memoryToSacrifice = null;
      isShowingMemoryPreview = false;
      isShowingSacrificeConfirmation = false;
      isShowingSacrificeAftermath = false;
    }
  }

  void addWhisper() {
    // Compass reduces whisper frequency
    if (hasCompass && _random.nextDouble() < getWhisperReduction()) {
      return; // Skip this whisper
    }
    
    String? whisper;
    
    // Context-aware whisper selection
    final totalSacrificed = totalMemoriesSacrificed;
    final currentMemories = memories.length;
    
    // Determine context
    final hasManySacrifices = totalSacrificed >= 3;
    final hasFewSacrifices = totalSacrificed == 0 && currentMemories > 0;
    final hasHighCycles = rebornCount >= 3;
    final hasLowLight = lightPercent < 20;
    final justSacrificed = isShowingSacrificeAftermath;
    
    // Priority order: recent sacrifice > low light > many sacrifices > high cycles > few sacrifices > default
    if (justSacrificed && manySacrificesWhispers.isNotEmpty) {
      whisper = manySacrificesWhispers[_random.nextInt(manySacrificesWhispers.length)];
    } else if (hasLowLight && lowLightWhispers.isNotEmpty) {
      whisper = lowLightWhispers[_random.nextInt(lowLightWhispers.length)];
    } else if (hasManySacrifices && manySacrificesWhispers.isNotEmpty) {
      whisper = manySacrificesWhispers[_random.nextInt(manySacrificesWhispers.length)];
    } else if (hasHighCycles && highCycleWhispers.isNotEmpty) {
      whisper = highCycleWhispers[_random.nextInt(highCycleWhispers.length)];
    } else if (hasFewSacrifices && fewSacrificesWhispers.isNotEmpty) {
      whisper = fewSacrificesWhispers[_random.nextInt(fewSacrificesWhispers.length)];
    } else if (whisperBank.isNotEmpty) {
      whisper = whisperBank[_random.nextInt(whisperBank.length)];
    }
    
    if (whisper != null) {
      whispers.add(whisper);
    }
  }

  void removeWhisper() {
    if (whispers.isNotEmpty) {
      whispers.removeAt(0);
    }
  }
}

