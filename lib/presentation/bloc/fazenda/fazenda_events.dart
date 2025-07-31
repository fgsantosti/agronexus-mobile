part of 'fazenda_bloc.dart';

abstract class FazendaEvent extends Equatable {
  const FazendaEvent();
}

class CreateFazendaEvent extends FazendaEvent {
  final FazendaEntity entity;
  const CreateFazendaEvent({required this.entity});

  @override
  List<Object?> get props => [entity];
}

class UpdateFazendaEvent extends FazendaEvent {
  final FazendaEntity entity;
  const UpdateFazendaEvent({required this.entity});

  @override
  List<Object?> get props => [entity];
}

class DeleteFazendaEvent extends FazendaEvent {
  final FazendaEntity entity;
  const DeleteFazendaEvent({required this.entity});

  @override
  List<Object?> get props => [entity];
}

class ListFazendaEvent extends FazendaEvent {
  final int limit;
  final int offset;
  final String? search;
  final bool isLoadingMore;

  const ListFazendaEvent({
    this.limit = 20,
    this.offset = 0,
    this.search,
    this.isLoadingMore = false,
  });

  @override
  List<Object?> get props => [limit, offset, search, isLoadingMore];
}

class FazendaDetailEvent extends FazendaEvent {
  final String id;
  const FazendaDetailEvent({required this.id});

  @override
  List<Object?> get props => [id];
}

class NextPageFazendaEvent extends FazendaEvent {
  const NextPageFazendaEvent();

  @override
  List<Object?> get props => [];
}

class UpdateLoadedFazendaEvent extends FazendaEvent {
  final FazendaEntity entity;
  const UpdateLoadedFazendaEvent({required this.entity});

  @override
  List<Object?> get props => [entity];
}
