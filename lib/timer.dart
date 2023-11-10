import 'dart:async';

class GlobalTimerManager {
  static final GlobalTimerManager _instance = GlobalTimerManager._internal();
  Timer? _timer;
  int _remainingSeconds = 60;
  bool _isTimerRunning = false;
  Function? onTickCb;

  factory GlobalTimerManager() {
    return _instance;
  }

  GlobalTimerManager._internal();

  void startTimer({required Function onTick}) {
    onTickCb = onTick;
    if (!_isTimerRunning) {
      _isTimerRunning = true;
      _timer = Timer.periodic(Duration(seconds: 1), (timer) {
        if (_remainingSeconds > 1) {
          _remainingSeconds--;
        } else {
          stopTimer();
        }
        onTickCb?.call(); // Callback for updating UI
      });
    }
  }

  void updateTickCb({Function? onTick}) {
    onTickCb = onTick;
  }

  void stopTimer() {
    if (_timer?.isActive ?? false) {
      _timer?.cancel();
    }
    _remainingSeconds = 60;
    _isTimerRunning = false;
  }

  bool get isTimerRunning => _isTimerRunning;
  int get remainingSeconds => _remainingSeconds;
}
