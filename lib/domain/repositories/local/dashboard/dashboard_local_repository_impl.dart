import 'dart:convert';

import 'package:agronexus/domain/models/dashboard_entity.dart';
import 'package:agronexus/domain/repositories/local/dashboard/dashboard_local_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DashboardLocalRepositoryImpl extends DashboardLocalRepository {
  static const String _synkedEntitiesKey = "synkedDashboards";
  static const String _notSynkedEntitiesKey = "notSynkedDashboards";
  SharedPreferences? _sharedPreferences;

  DashboardLocalRepositoryImpl() {
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

  String _toJsonString(DashboardEntity entity) {
    return jsonEncode(entity.toJson());
  }

  List<String> _toStringList(List<DashboardEntity> entities) {
    return entities.map((e) => _toJsonString(e)).toList();
  }

  List<DashboardEntity> _fromStringList(List<String> jsonList) {
    return jsonList
        .map<DashboardEntity>((e) => DashboardEntity.fromJson(jsonDecode(e)))
        .toList();
  }

  @override
  Future<List<DashboardEntity>> getAllEntities() async {
    await _validateSharedInstance();
    List<DashboardEntity> synkedEntities = await getSynkedEntities();
    List<DashboardEntity> notSynkedEntities = await getNotSynkedEntities();
    return [...synkedEntities, ...notSynkedEntities];
  }

  @override
  Future<List<DashboardEntity>> getNotSynkedEntities() async {
    await _validateSharedInstance();
    List<String> entities =
        _sharedPreferences!.getStringList(_notSynkedEntitiesKey) ?? [];
    return _fromStringList(entities);
  }

  @override
  Future<List<DashboardEntity>> getSynkedEntities() async {
    await _validateSharedInstance();
    List<String> entities =
        _sharedPreferences!.getStringList(_synkedEntitiesKey) ?? [];
    return _fromStringList(entities);
  }

  @override
  Future<void> saveEntity({
    required DashboardEntity entity,
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
    required List<DashboardEntity> entities,
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
