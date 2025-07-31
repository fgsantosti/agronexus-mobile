import 'dart:convert';

import 'package:agronexus/domain/models/user_entity.dart';
import 'package:agronexus/domain/repositories/local/user/user_local_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserLocalRepositoryImpl implements UserLocalRepository {
  static const _selfUserKey = "selfUser";
  static const _allUsersKey = "allUsers";
  late SharedPreferences _sharedPreferences;

  UserLocalRepositoryImpl() {
    _initSharedPreferences();
  }

  Future<void> _initSharedPreferences() async {
    _sharedPreferences = await SharedPreferences.getInstance();
  }

  @override
  Future<void> deleteAllEntities() async {
    await _initSharedPreferences();
    await _sharedPreferences.remove(_allUsersKey);
  }

  @override
  Future<void> deleteSelfEntity() async {
    await _initSharedPreferences();
    await _sharedPreferences.remove(_selfUserKey);
  }

  @override
  Future<List<UserEntity>> getAllEntities() async {
    await _initSharedPreferences();
    List usersString = _sharedPreferences.getStringList(_allUsersKey) ?? [];
    return usersString.map((e) => UserEntity.fromJson(json.decode(e))).toList();
  }

  @override
  Future<UserEntity> getSelfEntity() async {
    await _initSharedPreferences();
    return UserEntity.fromJson(
      json.decode(_sharedPreferences.getString(_selfUserKey) ?? "{}"),
    );
  }

  @override
  Future<void> saveAllEntities(List<UserEntity> user) async {
    await _initSharedPreferences();
    List<String> usersString = user
        .map(
          (e) => json.encode(e.toJson()),
        )
        .toList();
    await _sharedPreferences.setStringList(_allUsersKey, usersString);
  }

  @override
  Future<void> saveSelfEntity(UserEntity user) async {
    await _initSharedPreferences();
    await _sharedPreferences.setString(
      _selfUserKey,
      json.encode(user.toJson()),
    );
  }
}
