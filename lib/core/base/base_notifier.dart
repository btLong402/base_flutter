import 'package:base_flutter/core/base/base_usecase.dart';
import 'package:base_flutter/core/base/error/failures.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';


abstract class BaseNotifier<S> extends StateNotifier<S> {
  BaseNotifier(super._state);

  /// Standard failure to message mapper
  String mapFailureToMessage(Failure failure) {
    if (failure is ServerFailure) return failure.message;
    return 'Đã có lỗi xảy ra, vui lòng thử lại sau.';
  }

  /// Helper to execute a FutureResult and handle state updates.
  /// This is a generic version that doesn't force a specific state type.
  FutureResult<T> runTask<T>({
    required FutureResult<T> task,
    required void Function() onLoading,
    required void Function(T data) onSuccess,
    required void Function(String message) onError,
  }) async {
    onLoading();
    final result = await task;
    result.fold(
      (failure) => onError(mapFailureToMessage(failure)),
      onSuccess,
    );
    return result;
  }
}
