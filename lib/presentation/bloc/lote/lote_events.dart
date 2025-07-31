part of 'lote_bloc.dart';

abstract class LoteEvent extends Equatable {
  const LoteEvent();
}

class CreateLoteEvent extends LoteEvent {
  final LoteEntity entity;
  const CreateLoteEvent({required this.entity});

  @override
  List<Object?> get props => [entity];
}

class UpdateLoteEvent extends LoteEvent {
  final LoteEntity entity;
  const UpdateLoteEvent({required this.entity});

  @override
  List<Object?> get props => [entity];
}

class DeleteLoteEvent extends LoteEvent {
  final LoteEntity entity;
  const DeleteLoteEvent({required this.entity});

  @override
  List<Object?> get props => [entity];
}

class ListLoteEvent extends LoteEvent {
  final int limit;
  final int offset;
  final String? search;
  final bool isLoadingMore;

  const ListLoteEvent({
    this.limit = 20,
    this.offset = 0,
    this.search,
    this.isLoadingMore = false,
  });

  @override
  List<Object?> get props => [limit, offset, search, isLoadingMore];
}

class LoteDetailEvent extends LoteEvent {
  final String id;
  const LoteDetailEvent({required this.id});

  @override
  List<Object?> get props => [id];
}

class NextPageLoteEvent extends LoteEvent {
  const NextPageLoteEvent();

  @override
  List<Object?> get props => [];
}

class UpdateLoadedLoteEvent extends LoteEvent {
  final LoteEntity entity;
  const UpdateLoadedLoteEvent({required this.entity});

  @override
  List<Object?> get props => [entity];
}
