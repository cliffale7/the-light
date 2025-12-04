import 'package:flame/game.dart';
import '../components/particle_component.dart';
import '../components/header_flame_component.dart';

class LastLightGame extends FlameGame {
  final ParticleComponent particleComponent = ParticleComponent();
  final HeaderFlameComponent headerFlameComponent = HeaderFlameComponent();

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    add(particleComponent);
    add(headerFlameComponent);
  }

  void updateLightPercent(double percent) {
    particleComponent.updateLightPercent(percent);
    headerFlameComponent.updateLightPercent(percent);
  }
}

