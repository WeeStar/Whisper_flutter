import 'package:audio_service/audio_service.dart';
import 'package:whisper/service/new_play/queue_state.dart';

/// An [AudioHandler] for playing a list of podcast episodes.
///
/// This class exposes the interface and not the implementation.
abstract class AudioPlayerHandler implements AudioHandler {
  Stream<QueueState> get queueState;
}