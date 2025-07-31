import 'dart:convert';

import 'package:agronexus/domain/models/animal_entity.dart';
import 'package:agronexus/domain/repositories/local/animal/animal_local_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AnimalLocalRepositoryImpl extends AnimalLocalRepository {
  static const String _synkedEntitiesKey = "synkedAnimals";
  static const String _notSynkedEntitiesKey = "notSynkedAnimals";
  SharedPreferences? _sharedPreferences;

  AnimalLocalRepositoryImpl() {
    _initSharedPreferences();
  }

  Future<void> _initSharedPreferences() async {
    _sharedPreferences = await SharedPreferences.getInstance();
  }

  Future<void> _validateSharedInstance() async {
    if (_sharedPreferences == null) {
      await _initSharedPreferences();
    }
  }

  String _toJsonString(AnimalEntity entity) {
    return jsonEncode(entity.toJson());
  }

  List<String> _toStringList(List<AnimalEntity> entities) {
    return entities.map((e) => _toJsonString(e)).toList();
  }

  List<AnimalEntity> _fromStringList(List<String> jsonList) {
    return jsonList
        .map<AnimalEntity>((e) => AnimalEntity.fromJson(jsonDecode(e)))
        .toList();
  }

  @override
  Future<List<AnimalEntity>> getAllEntities() async {
    await _validateSharedInstance();
    List<AnimalEntity> synkedEntities = await getSynkedEntities();
    List<AnimalEntity> notSynkedEntities = await getNotSynkedEntities();
    return [...synkedEntities, ...notSynkedEntities];
  }

  @override
  Future<List<AnimalEntity>> getNotSynkedEntities() async {
    await _validateSharedInstance();
    List<String> entities =
        _sharedPreferences!.getStringList(_notSynkedEntitiesKey) ?? [];
    return _fromStringList(entities);
  }

  @override
  Future<List<AnimalEntity>> getSynkedEntities() async {
    await _validateSharedInstance();
    List<String> entities =
        _sharedPreferences!.getStringList(_synkedEntitiesKey) ?? [];
    return _fromStringList(entities);
  }

  @override
  Future<void> saveEntity({
    required AnimalEntity entity,
    required bool isSynked,
  }) async {
    await _validateSharedInstance();
    if (isSynked) {
      List<String> synkedEntities =
          _sharedPreferences!.getStringList(_synkedEntitiesKey) ?? [];
      synkedEntities.add(_toJsonString(entity));
      await _sharedPreferences!
          .setStringList(_synkedEntitiesKey, synkedEntities);
    } else {
      List<String> notSynkedEntities =
          _sharedPreferences!.getStringList(_notSynkedEntitiesKey) ?? [];
      notSynkedEntities.add(_toJsonString(entity));
      await _sharedPreferences!
          .setStringList(_notSynkedEntitiesKey, notSynkedEntities);
    }
  }

  @override
  Future<void> saveEntities({
    required List<AnimalEntity> entities,
    required bool isSynked,
  }) async {
    await _validateSharedInstance();
    List<String> synkedEntities = _toStringList(entities);
    if (isSynked) {
      await deleteSynkedEntities();
      await _sharedPreferences!
          .setStringList(_synkedEntitiesKey, synkedEntities);
    } else {
      await deleteNotSynkedEntities();
      await _sharedPreferences!
          .setStringList(_notSynkedEntitiesKey, synkedEntities);
    }
  }

  @override
  Future<void> deleteSynkedEntities() async {
    await _validateSharedInstance();
    await _sharedPreferences!.remove(_synkedEntitiesKey);
  }

  @override
  Future<void> deleteNotSynkedEntities() async {
    await _validateSharedInstance();
    await _sharedPreferences!.remove(_notSynkedEntitiesKey);
  }

  @override
  Future<void> deleteAllEntities() async {
    await _validateSharedInstance();
    await deleteNotSynkedEntities();
    await deleteSynkedEntities();
  }
}
