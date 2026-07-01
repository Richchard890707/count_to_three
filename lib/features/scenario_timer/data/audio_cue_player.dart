import 'package:audio_session/audio_session.dart';
import 'package:just_audio/just_audio.dart';
import 'package:count_to_three/features/scenario_timer/domain/models/workout_timer_state.dart';

/// Track A (foreground): plays the rest cue through the active output (earbuds),
/// ducking the user's music for the length of the ding then restoring volume.
/// This is the confirmed-doable core — see SPEC.md "提示輸出/輸入".
class AudioCuePlayer {
  final AudioPlayer _soft = AudioPlayer();
  final AudioPlayer _spine = AudioPlayer();
  AudioSession? _session;
  bool _ready = false;

  Future<void> init() async {
    if (_ready) return;
    _session = await AudioSession.instance;
    await _session!.configure(
      const AudioSessionConfiguration(
        avAudioSessionCategory: AVAudioSessionCategory.playback,
        avAudioSessionCategoryOptions: AVAudioSessionCategoryOptions.duckOthers,
        // usage.media (not sonification): plays through earbuds even in
        // silent mode, exactly like Spotify; silent mode only mutes the
        // ringer/notification streams, never media. duck via transient focus.
        androidAudioAttributes: AndroidAudioAttributes(
          contentType: AndroidAudioContentType.music,
          usage: AndroidAudioUsage.media,
        ),
        androidAudioFocusGainType:
            AndroidAudioFocusGainType.gainTransientMayDuck,
      ),
    );
    await _soft.setAsset('assets/sounds/cue_soft.wav');
    await _spine.setAsset('assets/sounds/cue_spine.wav');
    _ready = true;
  }

  /// Plays the cue and un-ducks (restores music volume) once it finishes.
  Future<void> play(RestCue cue) async {
    if (!_ready) await init();
    final player = cue == RestCue.soft ? _soft : _spine;
    await _session?.setActive(true);
    await player.seek(Duration.zero);
    await player.play(); // completes when the ding finishes
    await _session?.setActive(false); // iOS: must deactivate to restore volume
  }

  Future<void> dispose() async {
    await _soft.dispose();
    await _spine.dispose();
  }
}
