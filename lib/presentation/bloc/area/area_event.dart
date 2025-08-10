import 'package:equatable/equatable.dart';
import 'package:agronexus/domain/models/area_entity.dart';

abstract class AreaEvent extends Equatable {
  const AreaEvent();
  @override
  List<Object?> get props => [];
}

class LoadAreasEvent extends AreaEvent {
  final String? propriedadeId;
  const LoadAreasEvent({this.propriedadeId});
  @override
  List<Object?> get props => [propriedadeId];
}

class CreateAreaEvent extends AreaEvent {
  final AreaEntity area;
  const CreateAreaEvent(this.area);
  @override
  List<Object?> get props => [area];
}

class UpdateAreaEvent extends AreaEvent {
  final String id;
  final AreaEntity area;
  const UpdateAreaEvent({required this.id, required this.area});
  @override
  List<Object?> get props => [id, area];
}

class DeleteAreaEvent extends AreaEvent {
  final String id;
  const DeleteAreaEvent(this.id);
  @override
  List<Object?> get props => [id];
}
