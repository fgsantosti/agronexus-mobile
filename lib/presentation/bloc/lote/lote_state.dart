import 'package:equatable/equatable.dart';
import 'package:agronexus/domain/models/lote_entity.dart';

abstract class LoteState extends Equatable {
  const LoteState();

  @override
  List<Object?> get props => [];
}

class LoteInitial extends LoteState {}

class LoteLoading extends LoteState {}

class LotesLoaded extends LoteState {
  final List<LoteEntity> lotes;

  const LotesLoaded(this.lotes);

  @override
  List<Object> get props => [lotes];
}

class LoteCreated extends LoteState {}

class LoteUpdated extends LoteState {}

class LoteDeleted extends LoteState {}

class LoteError extends LoteState {
  final String message;

  const LoteError(this.message);

  @override
  List<Object> get props => [message];
}
