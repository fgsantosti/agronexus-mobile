import 'package:equatable/equatable.dart';
import 'package:agronexus/domain/models/area_entity.dart';

abstract class AreaState extends Equatable {
  const AreaState();
  @override
  List<Object?> get props => [];
}

class AreaInitial extends AreaState {}

class AreaLoading extends AreaState {}

class AreasLoaded extends AreaState {
  final List<AreaEntity> areas;
  const AreasLoaded(this.areas);
  @override
  List<Object?> get props => [areas];
}

class AreaError extends AreaState {
  final String message;
  const AreaError(this.message);
  @override
  List<Object?> get props => [message];
}

class AreaCreated extends AreaState {
  final AreaEntity area;
  const AreaCreated(this.area);
  @override
  List<Object?> get props => [area];
}

class AreaUpdated extends AreaState {
  final AreaEntity area;
  const AreaUpdated(this.area);
  @override
  List<Object?> get props => [area];
}

class AreaDeleted extends AreaState {
  final String id;
  const AreaDeleted(this.id);
  @override
  List<Object?> get props => [id];
}
