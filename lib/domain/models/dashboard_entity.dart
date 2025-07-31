import 'package:agronexus/config/utils.dart';
import 'package:equatable/equatable.dart';

class DashboardEntity extends Equatable {
  final int totalFazendas;
  final int totalLotes;
  final int totalAnimais;

  const DashboardEntity({
    required this.totalFazendas,
    required this.totalLotes,
    required this.totalAnimais,
  });

  @override
  List<Object?> get props => [totalFazendas, totalLotes, totalAnimais];

  DashboardEntity copyWith({
    AgroNexusGetter<int>? totalFazendas,
    AgroNexusGetter<int>? totalLotes,
    AgroNexusGetter<int>? totalAnimais,
  }) {
    return DashboardEntity(
      totalFazendas:
          totalFazendas != null ? totalFazendas() : this.totalFazendas,
      totalLotes: totalLotes != null ? totalLotes() : this.totalLotes,
      totalAnimais: totalAnimais != null ? totalAnimais() : this.totalAnimais,
    );
  }

  DashboardEntity.fromJson(Map<String?, dynamic> json)
      : totalFazendas = json['total_fazendas'] ?? 0,
        totalLotes = json['total_lotes'] ?? 0,
        totalAnimais = json['total_animais'] ?? 0;

  const DashboardEntity.empty()
      : totalFazendas = 0,
        totalLotes = 0,
        totalAnimais = 0;

  Map<String, dynamic> toJson() {
    Map<String, dynamic> data = {
      'total_fazendas': totalFazendas,
      'total_lotes': totalLotes,
      'total_animais': totalAnimais,
    };
    return data;
  }
}
