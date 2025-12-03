import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/game_state.dart';

class SaveService {
  static const String _keyGameState = 'game_state';
  static const String _keyVersion = 'save_version';
  static const int _currentVersion = 1;

  /// Save the game state to persistent storage
  static Future<bool> saveGameState(GameState gameState) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Create a map of all persistent data
      final saveData = {
        'version': _currentVersion,
        // Current cycle state
        'light': gameState.light,
        'maxLight': gameState.maxLight,
        'souls': gameState.souls,
        'clickPower': gameState.clickPower,
        'autoGather': gameState.autoGather,
        'phase': gameState.phase,
        'memories': gameState.memories,
        'sacrifices': gameState.sacrifices,
        'darkness': gameState.darkness,
        'rebornCount': gameState.rebornCount,
        
        // Persistent cross-cycle data
        'allSacrificedMemories': gameState.allSacrificedMemories,
        'totalMemoriesSacrificed': gameState.totalMemoriesSacrificed,
        'totalMemoriesPreserved': gameState.totalMemoriesPreserved,
      };
      
      // Convert to JSON string
      final jsonString = jsonEncode(saveData);
      
      // Save to preferences
      await prefs.setString(_keyGameState, jsonString);
      await prefs.setInt(_keyVersion, _currentVersion);
      
      return true;
    } catch (e) {
      // Error saving - silently fail (could add logging later)
      return false;
    }
  }

  /// Load the game state from persistent storage
  static Future<GameState?> loadGameState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Check if save data exists
      if (!prefs.containsKey(_keyGameState)) {
        return null; // No save data
      }
      
      // Get the JSON string
      final jsonString = prefs.getString(_keyGameState);
      if (jsonString == null) {
        return null;
      }
      
      // Parse JSON
      final saveData = jsonDecode(jsonString) as Map<String, dynamic>;
      
      // Check version for migration if needed
      final version = saveData['version'] as int? ?? 0;
      if (version != _currentVersion) {
        // Handle version migration here if needed in the future
        // Version mismatch - could add migration logic here
      }
      
      // Create new GameState and populate it
      final gameState = GameState();
      
      // Load current cycle state
      gameState.light = (saveData['light'] as num?)?.toDouble() ?? 100.0;
      gameState.maxLight = (saveData['maxLight'] as num?)?.toDouble() ?? 100.0;
      gameState.souls = (saveData['souls'] as num?)?.toDouble() ?? 1000.0;
      gameState.clickPower = (saveData['clickPower'] as num?)?.toDouble() ?? 1.0;
      gameState.autoGather = (saveData['autoGather'] as num?)?.toDouble() ?? 0.0;
      gameState.phase = saveData['phase'] as int? ?? 4;
      gameState.memories = List<String>.from(saveData['memories'] as List? ?? []);
      gameState.sacrifices = saveData['sacrifices'] as int? ?? 0;
      gameState.darkness = (saveData['darkness'] as num?)?.toDouble() ?? 0.0;
      gameState.rebornCount = saveData['rebornCount'] as int? ?? 0;
      
      // Load persistent cross-cycle data
      gameState.allSacrificedMemories = 
          List<String>.from(saveData['allSacrificedMemories'] as List? ?? []);
      gameState.totalMemoriesSacrificed = 
          saveData['totalMemoriesSacrificed'] as int? ?? 0;
      gameState.totalMemoriesPreserved = 
          saveData['totalMemoriesPreserved'] as int? ?? 0;
      
      return gameState;
    } catch (e) {
      // Error loading - return null to start fresh
      return null;
    }
  }

  /// Clear all save data (for testing or reset)
  static Future<bool> clearSaveData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_keyGameState);
      await prefs.remove(_keyVersion);
      return true;
    } catch (e) {
      // Error clearing - return false
      return false;
    }
  }

  /// Check if save data exists
  static Future<bool> hasSaveData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.containsKey(_keyGameState);
    } catch (e) {
      return false;
    }
  }
}

