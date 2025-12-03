import 'package:flame/game.dart';
import '../components/particle_component.dart';

class LastLightGame extends FlameGame {
  final ParticleComponent particleComponent = ParticleComponent();

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    add(particleComponent);
  }

  void updateLightPercent(double percent) {
    particleComponent.updateLightPercent(percent);
  }
}

