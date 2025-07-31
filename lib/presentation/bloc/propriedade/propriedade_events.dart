part of 'propriedade_bloc.dart';

abstract class PropriedadeEvent extends Equatable {
  const PropriedadeEvent();
  
  @override
  List<Object?> get props => [];
}

class ListPropriedadeEvent extends PropriedadeEvent {
  final int? limit;
  final int? offset;
  final String? search;

  const ListPropriedadeEvent({
    this.limit = 20,
    this.offset = 0,
    this.search,
  });

  @override
  List<Object?> get props => [limit, offset, search];
}

class CreatePropriedadeEvent extends PropriedadeEvent {
  final PropriedadeEntity entity;
  const CreatePropriedadeEvent({required this.entity});

  @override
  List<Object?> get props => [entity];
}

class UpdatePropriedadeEvent extends PropriedadeEvent {
  final PropriedadeEntity entity;
  const UpdatePropriedadeEvent({required this.entity});

  @override
  List<Object?> get props => [entity];
}

class DeletePropriedadeEvent extends PropriedadeEvent {
  final PropriedadeEntity entity;
  const DeletePropriedadeEvent({required this.entity});

  @override
  List<Object?> get props => [entity];
}

class GetPropriedadeEvent extends PropriedadeEvent {
  final String id;
  const GetPropriedadeEvent({required this.id});

  @override
  List<Object?> get props => [id];
}

class UpdateLoadedPropriedadeEvent extends PropriedadeEvent {
  final PropriedadeEntity? entity;
  const UpdateLoadedPropriedadeEvent({this.entity});

  @override
  List<Object?> get props => [entity];
}
