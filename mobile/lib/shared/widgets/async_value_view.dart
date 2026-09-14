import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/string_constants.dart';
import '../theme/app_colors.dart';

/// Consistent loading/error/data rendering for an `AsyncValue<T>` - avoids
/// every screen re-implementing the same three branches.
class AsyncValueView<T> extends StatelessWidget {
  const AsyncValueView({
    super.key,
    required this.value,
    required this.data,
    this.loading,
    this.error,
  });

  final AsyncValue<T> value;
  final Widget Function(T data) data;
  final Widget Function()? loading;
  final Widget Function(Object error)? error;

  @override
  Widget build(BuildContext context) {
    return value.when(
      data: data,
      loading: () => loading?.call() ?? const _DefaultLoading(),
      error: (err, _) => error?.call(err) ?? _DefaultError(err),
    );
  }
}

class _DefaultLoading extends StatelessWidget {
  const _DefaultLoading();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 32),
      child: Center(
        child: SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.4)),
      ),
    );
  }
}

class _DefaultError extends StatelessWidget {
  const _DefaultError(this.err);

  final Object err;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Center(
        child: Text(
          StringConstants.genericErrorMessage,
          style: const TextStyle(color: AppColors.ink500, fontSize: 12.5),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
