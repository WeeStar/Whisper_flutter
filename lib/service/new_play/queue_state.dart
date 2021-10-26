import 'package:audio_service/audio_service.dart';

class QueueState {
  static final QueueState empty =
      const QueueState([], 0, [], AudioServiceRepeatMode.none);

  final List<MediaItem> queue;
  final int? queueIndex;
  final List<int>? shuffleIndices;
  final AudioServiceRepeatMode repeatMode;

  const QueueState(
      this.queue, this.queueIndex, this.shuffleIndices, this.repeatMode);

  List<int> get indices =>
      shuffleIndices ?? List.generate(queue.length, (i) => i);
}
