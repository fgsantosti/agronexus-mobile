import 'package:equatable/equatable.dart';
import 'package:agronexus/domain/models/lote_entity.dart';

abstract class LoteEvent extends Equatable {
  const LoteEvent();

  @override
  List<Object?> get props => [];
}

class LoadLotesEvent extends LoteEvent {
  final int limit;
  final int offset;
  final String? search;

  const LoadLotesEvent({
    this.limit = 20,
    this.offset = 0,
    this.search,
  });

  @override
  List<Object?> get props => [limit, offset, search];
}

class CreateLoteEvent extends LoteEvent {
  final LoteEntity lote;

  const CreateLoteEvent(this.lote);

  @override
  List<Object> get props => [lote];
}

class UpdateLoteEvent extends LoteEvent {
  final LoteEntity lote;

  const UpdateLoteEvent(this.lote);

  @override
  List<Object> get props => [lote];
}

class DeleteLoteEvent extends LoteEvent {
  final String loteId;

  const DeleteLoteEvent(this.loteId);

  @override
  List<Object> get props => [loteId];
}
