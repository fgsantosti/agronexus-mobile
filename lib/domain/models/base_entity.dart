import 'package:agronexus/config/utils.dart';
import 'package:equatable/equatable.dart';

class BaseEntity extends Equatable {
  final String? id;
  final String? createdById;
  final String? modifiedById;
  final String? createdAt;
  final String? modifiedAt;

  const BaseEntity({
    this.id,
    this.createdById,
    this.modifiedById,
    this.createdAt,
    this.modifiedAt,
  });

  @override
  List<Object?> get props =>
      [id, createdById, modifiedById, createdAt, modifiedAt];

  BaseEntity copyWith({
    AgroNexusGetter<String?>? id,
    AgroNexusGetter<String?>? createdById,
    AgroNexusGetter<String?>? modifiedById,
    AgroNexusGetter<String?>? createdAt,
    AgroNexusGetter<String?>? modifiedAt,
  }) {
    return BaseEntity(
      id: id != null ? id() : this.id,
      createdById: createdById != null ? createdById() : this.createdById,
      modifiedById: modifiedById != null ? modifiedById() : this.modifiedById,
      createdAt: createdAt != null ? createdAt() : this.createdAt,
      modifiedAt: modifiedAt != null ? modifiedAt() : this.modifiedAt,
    );
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> data = {
      'id': id,
      'created_by': createdById,
      'modified_by': modifiedById,
      'created_at': createdAt,
      'modified_at': modifiedAt,
    };
    return data;
  }

  BaseEntity.fromJson(Map<String?, dynamic> json)
      : id = json['id']?.toString(),
        createdById = json['created_by']?.toString(),
        modifiedById = json['modified_by']?.toString(),
        createdAt = json['created_at']?.toString(),
        modifiedAt = json['modified_at']?.toString();
}
