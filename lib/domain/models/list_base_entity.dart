import 'package:agronexus/config/utils.dart';
import 'package:equatable/equatable.dart';

class ListBaseEntity<T> extends Equatable {
  final int count;
  final String next;
  final String previous;
  final List<T> results;

  const ListBaseEntity({
    required this.count,
    required this.next,
    required this.previous,
    required this.results,
  });

  @override
  List<Object?> get props => [count, next, previous, ...results];

  ListBaseEntity<T> copyWith({
    AgroNexusGetter<int>? count,
    AgroNexusGetter<String>? next,
    AgroNexusGetter<String>? previous,
    AgroNexusGetter<List<T>>? results,
  }) {
    return ListBaseEntity<T>(
      count: count != null ? count() : this.count,
      next: next != null ? next() : this.next,
      previous: previous != null ? previous() : this.previous,
      results: results != null ? results() : this.results,
    );
  }

  ListBaseEntity.fromJson({
    required Map<String?, dynamic> json,
    required T Function(Map<String?, dynamic>) fromJson,
  })  : count = json['count'] ?? 0,
        next = json['next'] ?? "",
        previous = json['previous'] ?? "",
        results = json['results'] != null
            ? (json['results'] as List)
                .map((e) => fromJson(e as Map<String?, dynamic>))
                .toList()
            : <T>[];

  const ListBaseEntity.empty()
      : count = 0,
        next = "",
        previous = "",
        results = const [];
}
