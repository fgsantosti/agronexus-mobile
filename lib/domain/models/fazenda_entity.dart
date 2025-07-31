import 'package:agronexus/config/utils.dart';
import 'package:agronexus/domain/models/base_entity.dart';
import 'package:agronexus/domain/models/lote_entity.dart';
import 'package:flutter/material.dart';

enum TipoFazenda {
  bovinocultura(label: 'Bovinocultura', color: Colors.blue),
  agricultura(label: 'Agricultura', color: Colors.green),
  suinocultura(label: 'Suinocultura', color: Colors.red),
  avicultura(label: 'Avicultura', color: Colors.yellow),
  outros(label: 'Outros', color: Colors.grey);

  final String label;
  final Color color;
  const TipoFazenda({required this.label, required this.color});

  static TipoFazenda fromString(String value) {
    switch (value) {
      case 'bovinocultura':
        return TipoFazenda.bovinocultura;
      case 'agricultura':
        return TipoFazenda.agricultura;
      case 'suinocultura':
        return TipoFazenda.suinocultura;
      case 'avicultura':
        return TipoFazenda.avicultura;
      case 'outros':
        return TipoFazenda.outros;
      default:
        throw Exception('Invalid TipoFazenda value: $value');
    }
  }
}

class FazendaEntity extends BaseEntity {
  final String nome;
  final String localizacao;
  final String hectares;
  final TipoFazenda tipo;
  final bool ativa;
  final String usuario;
  final String usuarioNome;
  final int? totalAnimaisAtivos;
  final int? totalAnimaisInativos;
  final int? totalAnimaisAbate;
  final int? totalAnimaisVenda;
  final int? totalAnimaisLeilao;
  final List<LoteEntity>? lotes;
  final String? latitude;
  final String? longitude;

  const FazendaEntity({
    super.id,
    super.createdById,
    super.modifiedById,
    super.createdAt,
    super.modifiedAt,
    required this.nome,
    required this.localizacao,
    required this.hectares,
    required this.tipo,
    required this.ativa,
    required this.usuario,
    required this.usuarioNome,
    this.totalAnimaisAtivos,
    this.totalAnimaisInativos,
    this.totalAnimaisAbate,
    this.totalAnimaisVenda,
    this.totalAnimaisLeilao,
    this.lotes,
    this.latitude,
    this.longitude,
  });

  const FazendaEntity.empty()
      : nome = "",
        localizacao = '',
        hectares = '',
        tipo = TipoFazenda.bovinocultura,
        ativa = true,
        usuario = '',
        usuarioNome = '',
        totalAnimaisAtivos = null,
        totalAnimaisInativos = null,
        totalAnimaisAbate = null,
        totalAnimaisVenda = null,
        totalAnimaisLeilao = null,
        lotes = null,
        latitude = null,
        longitude = null;

  @override
  List<Object?> get props => [
        ...super.props,
        nome,
        localizacao,
        hectares,
        tipo,
        ativa,
        usuario,
        usuarioNome,
        totalAnimaisAtivos,
        totalAnimaisInativos,
        totalAnimaisAbate,
        totalAnimaisVenda,
        totalAnimaisLeilao,
        lotes,
        latitude,
        longitude,
      ];

  @override
  FazendaEntity copyWith({
    AgroNexusGetter<String?>? id,
    AgroNexusGetter<String?>? createdById,
    AgroNexusGetter<String?>? modifiedById,
    AgroNexusGetter<String?>? createdAt,
    AgroNexusGetter<String?>? modifiedAt,
    AgroNexusGetter<String>? nome,
    AgroNexusGetter<String>? localizacao,
    AgroNexusGetter<String>? hectares,
    AgroNexusGetter<TipoFazenda>? tipo,
    AgroNexusGetter<bool>? ativa,
    AgroNexusGetter<String>? usuario,
    AgroNexusGetter<String>? usuarioNome,
    AgroNexusGetter<int?>? totalAnimaisAtivos,
    AgroNexusGetter<int?>? totalAnimaisInativos,
    AgroNexusGetter<int?>? totalAnimaisAbate,
    AgroNexusGetter<int?>? totalAnimaisVenda,
    AgroNexusGetter<int?>? totalAnimaisLeilao,
    AgroNexusGetter<List<LoteEntity>?>? lotes,
    AgroNexusGetter<String?>? latitude,
    AgroNexusGetter<String?>? longitude,
  }) {
    return FazendaEntity(
      id: id != null ? id() : this.id,
      createdById: createdById != null ? createdById() : this.createdById,
      modifiedById: modifiedById != null ? modifiedById() : this.modifiedById,
      createdAt: createdAt != null ? createdAt() : this.createdAt,
      modifiedAt: modifiedAt != null ? modifiedAt() : this.modifiedAt,
      nome: nome != null ? nome() : this.nome,
      localizacao: localizacao != null ? localizacao() : this.localizacao,
      hectares: hectares != null ? hectares() : this.hectares,
      tipo: tipo != null ? tipo() : this.tipo,
      ativa: ativa != null ? ativa() : this.ativa,
      usuario: usuario != null ? usuario() : this.usuario,
      usuarioNome: usuarioNome != null ? usuarioNome() : this.usuarioNome,
      totalAnimaisAtivos: totalAnimaisAtivos != null
          ? totalAnimaisAtivos()
          : this.totalAnimaisAtivos,
      totalAnimaisInativos: totalAnimaisInativos != null
          ? totalAnimaisInativos()
          : this.totalAnimaisInativos,
      totalAnimaisAbate: totalAnimaisAbate != null
          ? totalAnimaisAbate()
          : this.totalAnimaisAbate,
      totalAnimaisVenda: totalAnimaisVenda != null
          ? totalAnimaisVenda()
          : this.totalAnimaisVenda,
      totalAnimaisLeilao: totalAnimaisLeilao != null
          ? totalAnimaisLeilao()
          : this.totalAnimaisLeilao,
      lotes: lotes != null ? lotes() : this.lotes,
      latitude: latitude != null ? latitude() : this.latitude,
      longitude: longitude != null ? longitude() : this.longitude,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    Map<String, dynamic> data = super.toJson();
    data['nome'] = nome;
    data['localizacao'] = localizacao;
    data['hectares'] = hectares;
    data['tipo'] = tipo.name;
    data['ativa'] = ativa;
    if (usuario.isNotEmpty) {
      data['usuario'] = usuario;
    }
    data['total_animais_ativos'] = totalAnimaisAtivos;
    data['total_animais_inativos'] = totalAnimaisInativos;
    data['total_animais_abate'] = totalAnimaisAbate;
    data['total_animais_venda'] = totalAnimaisVenda;
    data['total_animais_leilao'] = totalAnimaisLeilao;
    if (lotes != null) {
      data['lotes'] = lotes!.map((v) => v.toJson()).toList();
    }
    data['latitude'] = latitude;
    data['longitude'] = longitude;
    return data;
  }

  FazendaEntity.fromJson(super.json)
      : nome = json['nome'] ?? "",
        localizacao = json['localizacao'] ?? "",
        hectares = json['hectares'] ?? "",
        tipo = TipoFazenda.fromString(json['tipo'] ?? ""),
        ativa = json['ativa'] ?? true,
        usuario = json['usuario'] ?? "",
        usuarioNome = json['usuario_nome'] ?? "",
        totalAnimaisAtivos = json['total_animais_ativos'],
        totalAnimaisInativos = json['total_animais_inativos'],
        totalAnimaisAbate = json['total_animais_abate'],
        totalAnimaisVenda = json['total_animais_venda'],
        totalAnimaisLeilao = json['total_animais_leilao'],
        lotes = (json['lotes'] as List<dynamic>?)
            ?.map((e) => LoteEntity.fromJson(e))
            .toList(),
        latitude = json['latitude'],
        longitude = json['longitude'],
        super.fromJson();
}
