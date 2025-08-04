import 'package:equatable/equatable.dart';
import 'package:agronexus/domain/models/propriedade_entity.dart';

abstract class PropriedadeState extends Equatable {
  const PropriedadeState();

  @override
  List<Object?> get props => [];
}

class PropriedadeInitial extends PropriedadeState {}

class PropriedadeLoading extends PropriedadeState {}

class PropriedadesLoaded extends PropriedadeState {
  final List<PropriedadeEntity> propriedades;

  const PropriedadesLoaded(this.propriedades);

  @override
  List<Object> get props => [propriedades];
}

class PropriedadeLoaded extends PropriedadeState {
  final PropriedadeEntity propriedade;

  const PropriedadeLoaded(this.propriedade);

  @override
  List<Object> get props => [propriedade];
}

class PropriedadeCreated extends PropriedadeState {
  final PropriedadeEntity propriedade;

  const PropriedadeCreated(this.propriedade);

  @override
  List<Object> get props => [propriedade];
}

class PropriedadeUpdated extends PropriedadeState {
  final PropriedadeEntity propriedade;

  const PropriedadeUpdated(this.propriedade);

  @override
  List<Object> get props => [propriedade];
}

class PropriedadeDeleted extends PropriedadeState {
  final String id;

  const PropriedadeDeleted(this.id);

  @override
  List<Object> get props => [id];
}

class PropriedadeError extends PropriedadeState {
  final String message;

  const PropriedadeError(this.message);

  @override
  List<Object> get props => [message];
}
