import 'package:equatable/equatable.dart';

enum UnreadStatus { initial, loaded }

class UnreadState extends Equatable {
  final int count;
  final UnreadStatus status;

  const UnreadState({this.count = 0, this.status = UnreadStatus.initial});

  UnreadState copyWith({int? count, UnreadStatus? status}) =>
      UnreadState(count: count ?? this.count, status: status ?? this.status);

  @override
  List<Object?> get props => [count, status];
}
