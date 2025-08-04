import 'package:equatable/equatable.dart';
import 'package:agronexus/domain/models/propriedade_entity.dart';

abstract class PropriedadeEvent extends Equatable {
  const PropriedadeEvent();

  @override
  List<Object?> get props => [];
}

class LoadPropriedadesEvent extends PropriedadeEvent {
  final int limit;
  final int offset;
  final String? search;

  const LoadPropriedadesEvent({
    this.limit = 20,
    this.offset = 0,
    this.search,
  });

  @override
  List<Object?> get props => [limit, offset, search];
}

class CreatePropriedadeEvent extends PropriedadeEvent {
  final PropriedadeEntity propriedade;

  const CreatePropriedadeEvent(this.propriedade);

  @override
  List<Object> get props => [propriedade];
}

class UpdatePropriedadeEvent extends PropriedadeEvent {
  final String id;
  final PropriedadeEntity propriedade;

  const UpdatePropriedadeEvent(this.id, this.propriedade);

  @override
  List<Object> get props => [id, propriedade];
}

class DeletePropriedadeEvent extends PropriedadeEvent {
  final String id;

  const DeletePropriedadeEvent(this.id);

  @override
  List<Object> get props => [id];
}

class GetPropriedadeEvent extends PropriedadeEvent {
  final String id;

  const GetPropriedadeEvent(this.id);

  @override
  List<Object> get props => [id];
}
