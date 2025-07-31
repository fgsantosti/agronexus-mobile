import 'package:agronexus/domain/models/list_base_entity.dart';
import 'package:agronexus/domain/models/user_entity.dart';
import 'package:agronexus/domain/repositories/local/auth/auth_local_repository.dart';
import 'package:agronexus/domain/repositories/local/user/user_local_repository.dart';
import 'package:agronexus/domain/repositories/remote/user/user_remote_repository.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

class UserService {
  final UserRemoteRepository userRemoteRepository;
  final UserLocalRepository userLocalRepository;
  final AuthLocalRepository authLocalRepository;

  UserService({
    required this.userRemoteRepository,
    required this.userLocalRepository,
    required this.authLocalRepository,
  });

  Future<void> setSelfUser({String? password}) async {
    bool result = await InternetConnection().hasInternetAccess;
    if (result == true) {
      final userData = await userRemoteRepository.getSelfUser();
      userData.fold(
        (l) => throw l,
        (r) => userLocalRepository.saveSelfEntity(
          r.copyWith(password: password != null ? () => password : null),
        ),
      );
    }
  }

  Future<UserEntity> getSelfUser() async {
    try {
      return (await userRemoteRepository.getSelfUser())
          .fold((l) => throw l, (r) => r);
    } catch (e) {
      null;
    }
    return await userLocalRepository.getSelfEntity();
  }

  Future<UserEntity> getSelfLocalUser() async {
    return await userLocalRepository.getSelfEntity();
  }

  Future<void> logout() async {
    await authLocalRepository.logout();
  }

  Future<UserEntity> createUser({
    required UserEntity user,
    required String password,
    required String password2,
  }) async {
    bool result = await InternetConnection().hasInternetAccess;
    if (result == true) {
      final userData = await userRemoteRepository.create(
        entity: user,
        password: password,
        password2: password2,
      );
      return userData.fold(
        (l) => throw l,
        (r) => r,
      );
    }
    await userLocalRepository.saveAllEntities(
      [user.copyWith(password: () => password, password2: () => password2)],
    );
    return user;
  }

  Future<UserEntity> updateUser({
    required UserEntity user,
  }) async {
    bool result = await InternetConnection().hasInternetAccess;
    if (result == true) {
      final userData = await userRemoteRepository.update(entity: user);
      return userData.fold(
        (l) => throw l,
        (r) => r,
      );
    }
    await userLocalRepository.saveSelfEntity(user);
    return user;
  }

  Future<void> deleteUser(String id) async {
    bool result = await InternetConnection().hasInternetAccess;
    if (result == true) {
      final userData = await userRemoteRepository.delete(id: id);
      return userData.fold(
        (l) => throw l,
        (r) => r,
      );
    }
    await userLocalRepository.deleteSelfEntity();
  }

  Future<UserEntity> getUserById(String id) async {
    bool result = await InternetConnection().hasInternetAccess;
    if (result == true) {
      final userData = await userRemoteRepository.getById(id);
      return userData.fold(
        (l) => throw l,
        (r) => r,
      );
    }
    return await userLocalRepository.getSelfEntity();
  }

  Future<ListBaseEntity<UserEntity>> listAllUsers({
    int limit = 20,
    int offset = 0,
    String? profile,
    String? search,
  }) async {
    bool result = await InternetConnection().hasInternetAccess;
    if (result == true) {
      final userData = await userRemoteRepository.list(
        limit: limit,
        offset: offset,
        profile: profile,
        search: search,
      );
      return userData.fold(
        (l) => throw l,
        (r) => r,
      );
    }
    final List<UserEntity> data = await userLocalRepository.getAllEntities();
    return ListBaseEntity<UserEntity>.empty().copyWith(results: () => data);
  }

  Future<Map<String, dynamic>> updatePassword({
    required String lastPassword,
    required String password,
    required String password2,
  }) async {
    bool result = await InternetConnection().hasInternetAccess;
    if (result == true) {
      final userData = await userRemoteRepository.updatePassword(
        lastPassword: lastPassword,
        password: password,
        password2: password2,
      );
      return userData.fold(
        (l) => throw l,
        (r) async {
          await setSelfUser(password: password);
          return r;
        },
      );
    }
    return {};
  }
}
