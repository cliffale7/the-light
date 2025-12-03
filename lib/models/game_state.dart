import 'dart:math';

class GameState {
  final Random _random = Random();
  
  double light = 100.0;
  double maxLight = 100.0;
  double souls = 1000.0;
  double clickPower = 1.0;
  double autoGather = 0.0;
  int phase = 4;
  List<String> memories = [];
  String? showMemory;
  int sacrifices = 0;
  double darkness = 0.0;
  List<String> whispers = [];
  int rebornCount = 0;
  bool isRebirthing = false;
  
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
    final decay = 0.5 + (phase * 0.2);
    light = (light - decay * delta * 10).clamp(0, maxLight);

    if (light <= 0 && phase < 4) {
      phase++;
      darkness = (darkness + 20).clamp(0, 100);
      light = maxLight * 0.5;
    }

    // Auto-gather souls
    if (autoGather > 0) {
      souls += autoGather * delta * 10;
    }

    return phase > oldPhase;
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

  void reborn() {
    if (phase >= 4 && souls >= 1000) {
      isRebirthing = true;
      rebornCount++;
      light = 100;
      maxLight = 100;
      souls = 0;
      clickPower = 1;
      autoGather = 0;
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

