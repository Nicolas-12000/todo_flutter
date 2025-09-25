import 'dart:async';
import 'package:get/get.dart';

class StopWatchController extends GetxController {
  final Stopwatch _stopwatch = Stopwatch();
  Timer? _timer;

  // Human readable elapsed time
  final RxString elapsed = '00:00:00'.obs;

  // Running state exposed as Rx so UI can observe it
  final RxBool isRunningRx = false.obs;

  bool get isRunning => _stopwatch.isRunning;

  void _updateElapsed() {
    final ms = _stopwatch.elapsedMilliseconds;
    final duration = Duration(milliseconds: ms);
    final hours = duration.inHours.toString().padLeft(2, '0');
    final minutes = (duration.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    elapsed.value = '$hours:$minutes:$seconds';
  }

  void start() {
    if (!_stopwatch.isRunning) {
      _stopwatch.start();
      isRunningRx.value = true;
      _timer?.cancel();
      _timer = Timer.periodic(const Duration(milliseconds: 200), (_) {
        _updateElapsed();
      });
    }
  }

  void stop() {
    if (_stopwatch.isRunning) {
      _stopwatch.stop();
      isRunningRx.value = false;
      _timer?.cancel();
      _updateElapsed();
    }
  }

  void reset() {
    _stopwatch.reset();
    isRunningRx.value = false;
    _updateElapsed();
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }
}
