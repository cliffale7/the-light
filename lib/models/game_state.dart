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

  void sacrifice() {
    if (memories.isEmpty) return;

    final sacrificedMemory = memories.removeLast();
    sacrifices++;
    maxLight += 100;
    clickPower += 5;
    darkness = (darkness + 10).clamp(0, 100);
    showMemory = "You sacrificed: $sacrificedMemory";
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
      memories.clear();
      sacrifices = 0;
      darkness = (darkness - 50).clamp(0, 100);
    }
  }

  void addWhisper() {
    if (whisperBank.isNotEmpty) {
      whispers.add(whisperBank[_random.nextInt(whisperBank.length)]);
    }
  }

  void removeWhisper() {
    if (whispers.isNotEmpty) {
      whispers.removeAt(0);
    }
  }
}

