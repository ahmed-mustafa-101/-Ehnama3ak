import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/message_repository.dart';
import 'unread_state.dart';

/// Lightweight global cubit for the unread message badge in AppBar/NavBar.
class UnreadCubit extends Cubit<UnreadState> {
  final MessageRepository _repo;

  UnreadCubit(this._repo) : super(const UnreadState());

  Future<void> refresh() async {
    try {
      final count = await _repo.getUnreadCount();
      emit(state.copyWith(count: count, status: UnreadStatus.loaded));
    } catch (_) {
      // Fail silently — badge is non-critical
    }
  }

  void decrement() {
    if (state.count > 0) emit(state.copyWith(count: state.count - 1));
  }

  void reset() => emit(state.copyWith(count: 0));
}
