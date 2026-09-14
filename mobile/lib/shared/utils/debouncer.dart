import 'dart:async';

/// Trailing-edge debounce - used for search-as-you-type
/// (docs/06_MOBILE_RULES.md §5, "≥300ms"). Mirrors web/src/utils/debounce.ts.
class Debouncer {
  Debouncer(this.delay);

  final Duration delay;
  Timer? _timer;

  void run(void Function() action) {
    _timer?.cancel();
    _timer = Timer(delay, action);
  }

  void dispose() {
    _timer?.cancel();
  }
}
