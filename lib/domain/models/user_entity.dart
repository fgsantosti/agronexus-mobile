import 'package:agronexus/config/utils.dart';
import 'package:agronexus/domain/models/base_entity.dart';

class UserEntity extends BaseEntity {
  final String username;
  final String firstName;
  final String lastName;
  final String email;
  final String cpf;

  final bool? isStaff;
  final bool? isActive;
  final String? password;
  final String? password2;

  final String? accessToken;
  final String? refreshToken;

  const UserEntity({
    super.id,
    super.createdById,
    super.modifiedById,
    super.createdAt,
    super.modifiedAt,
    required this.username,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.cpf,
    this.isStaff,
    this.isActive,
    this.password,
    this.password2,
    this.accessToken,
    this.refreshToken,
  });

  @override
  List<Object?> get props => [
        ...super.props,
        username,
        firstName,
        lastName,
        email,
        cpf,
        isStaff,
        isActive,
        password,
        password2,
        accessToken,
        refreshToken,
      ];

  const UserEntity.empty()
      : username = '',
        firstName = '',
        lastName = '',
        email = '',
        cpf = '',
        isStaff = null,
        isActive = null,
        password = null,
        password2 = null,
        accessToken = null,
        refreshToken = null;

  @override
  UserEntity copyWith({
    AgroNexusGetter<String?>? id,
    AgroNexusGetter<String?>? createdById,
    AgroNexusGetter<String?>? modifiedById,
    AgroNexusGetter<String?>? createdAt,
    AgroNexusGetter<String?>? modifiedAt,
    AgroNexusGetter<String>? username,
    AgroNexusGetter<String>? firstName,
    AgroNexusGetter<String>? lastName,
    AgroNexusGetter<String>? email,
    AgroNexusGetter<String>? cpf,
    AgroNexusGetter<bool?>? isStaff,
    AgroNexusGetter<bool?>? isActive,
    AgroNexusGetter<String?>? password,
    AgroNexusGetter<String?>? password2,
    AgroNexusGetter<String?>? accessToken,
    AgroNexusGetter<String?>? refreshToken,
  }) {
    return UserEntity(
      id: id != null ? id() : this.id,
      createdById: createdById != null ? createdById() : this.createdById,
      modifiedById: modifiedById != null ? modifiedById() : this.modifiedById,
      createdAt: createdAt != null ? createdAt() : this.createdAt,
      modifiedAt: modifiedAt != null ? modifiedAt() : this.modifiedAt,
      username: username != null ? username() : this.username,
      firstName: firstName != null ? firstName() : this.firstName,
      lastName: lastName != null ? lastName() : this.lastName,
      email: email != null ? email() : this.email,
      cpf: cpf != null ? cpf() : this.cpf,
      isStaff: isStaff != null ? isStaff() : this.isStaff,
      isActive: isActive != null ? isActive() : this.isActive,
      password: password != null ? password() : this.password,
      password2: password2 != null ? password2() : this.password2,
      accessToken: accessToken != null ? accessToken() : this.accessToken,
      refreshToken: refreshToken != null ? refreshToken() : this.refreshToken,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    Map<String, dynamic> data = super.toJson();
    data['first_name'] = firstName;
    data['email'] = email;
    data['cpf'] = cpf;
    data['is_staff'] = isStaff;
    data['is_active'] = isActive;
    data["password"] = password;
    data['password2'] = password2;
    data['access'] = accessToken;
    data['refresh'] = refreshToken;
    return data;
  }

  Map<String, dynamic> toJsonSend() {
    Map<String, dynamic> data = super.toJson();
    data['username'] = username;
    data['first_name'] = firstName;
    data['last_name'] = lastName;
    data['email'] = email;
    data['cpf'] = cpf;
    data['is_staff'] = isStaff;
    data['is_active'] = isActive;
    data['password'] = password;
    data['password2'] = password2;

    return data;
  }

  UserEntity.fromJson(Map<String, dynamic> json)
      : username = json['username'] ?? '',
        firstName = json['first_name'] ?? '',
        lastName = json['last_name'] ?? '',
        email = json['email'] ?? '',
        cpf = json['cpf'] ?? '',
        isStaff = json['is_staff'] ?? false,
        isActive = json['is_active'] ?? json['ativo'] ?? true,
        password = json['password'],
        password2 = json['password2'],
        accessToken = json['access'],
        refreshToken = json['refresh'],
        super.fromJson(_convertMapForBaseEntity(json));

  static Map<String?, dynamic> _convertMapForBaseEntity(Map<String, dynamic> json) {
    return {
      'id': json['id']?.toString(),
      'created_by': json['created_by']?.toString(),
      'modified_by': json['modified_by']?.toString(), 
      'created_at': json['created_at']?.toString(),
      'modified_at': json['modified_at']?.toString(),
    };
  }
}
