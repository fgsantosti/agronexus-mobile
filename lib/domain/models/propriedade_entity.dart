import 'package:agronexus/config/utils.dart';
import 'package:agronexus/domain/models/base_entity.dart';

class PropriedadeProprietario {
  final int id;
  final String username;
  final String nomeCompleto;
  final String perfil;
  final bool ativo;

  const PropriedadeProprietario({
    required this.id,
    required this.username,
    required this.nomeCompleto,
    required this.perfil,
    required this.ativo,
  });

  factory PropriedadeProprietario.fromJson(Map<String, dynamic> json) {
    return PropriedadeProprietario(
      id: json['id'] ?? 0,
      username: json['username'] ?? '',
      nomeCompleto: json['nome_completo'] ?? '',
      perfil: json['perfil'] ?? '',
      ativo: json['ativo'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'nome_completo': nomeCompleto,
      'perfil': perfil,
      'ativo': ativo,
    };
  }
}

class PropriedadeCoordenadas {
  final double latitude;
  final double longitude;

  const PropriedadeCoordenadas({
    required this.latitude,
    required this.longitude,
  });

  factory PropriedadeCoordenadas.fromJson(Map<String, dynamic> json) {
    return PropriedadeCoordenadas(
      latitude: (json['latitude'] ?? 0.0).toDouble(),
      longitude: (json['longitude'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}

class PropriedadeEntity extends BaseEntity {
  final String nome;
  final PropriedadeProprietario? proprietario;
  final String localizacao;
  final String areaTotalHa;
  final PropriedadeCoordenadas? coordenadasGps;
  final String? inscricaoEstadual;
  final String? cnpjCpf;
  final bool ativa;
  final String? dataCriacao;
  final String? areaOcupada;
  final int totalAnimais;
  final int totalLotes;
  final int totalAreas;

  const PropriedadeEntity({
    super.id,
    super.createdById,
    super.modifiedById,
    super.createdAt,
    super.modifiedAt,
    required this.nome,
    this.proprietario,
    required this.localizacao,
    required this.areaTotalHa,
    this.coordenadasGps,
    this.inscricaoEstadual,
    this.cnpjCpf,
    this.ativa = true,
    this.dataCriacao,
    this.areaOcupada,
    this.totalAnimais = 0,
    this.totalLotes = 0,
    this.totalAreas = 0,
  });

  @override
  List<Object?> get props => [
        ...super.props,
        nome,
        proprietario,
        localizacao,
        areaTotalHa,
        coordenadasGps,
        inscricaoEstadual,
        cnpjCpf,
        ativa,
        dataCriacao,
        areaOcupada,
        totalAnimais,
        totalLotes,
        totalAreas,
      ];

  const PropriedadeEntity.empty()
      : nome = '',
        proprietario = null,
        localizacao = '',
        areaTotalHa = '',
        coordenadasGps = null,
        inscricaoEstadual = null,
        cnpjCpf = null,
        ativa = true,
        dataCriacao = null,
        areaOcupada = null,
        totalAnimais = 0,
        totalLotes = 0,
        totalAreas = 0;

  @override
  PropriedadeEntity copyWith({
    AgroNexusGetter<String?>? id,
    AgroNexusGetter<String?>? createdById,
    AgroNexusGetter<String?>? modifiedById,
    AgroNexusGetter<String?>? createdAt,
    AgroNexusGetter<String?>? modifiedAt,
    AgroNexusGetter<String>? nome,
    AgroNexusGetter<PropriedadeProprietario?>? proprietario,
    AgroNexusGetter<String>? localizacao,
    AgroNexusGetter<String>? areaTotalHa,
    AgroNexusGetter<PropriedadeCoordenadas?>? coordenadasGps,
    AgroNexusGetter<String?>? inscricaoEstadual,
    AgroNexusGetter<String?>? cnpjCpf,
    AgroNexusGetter<bool>? ativa,
    AgroNexusGetter<String?>? dataCriacao,
    AgroNexusGetter<String?>? areaOcupada,
    AgroNexusGetter<int>? totalAnimais,
    AgroNexusGetter<int>? totalLotes,
    AgroNexusGetter<int>? totalAreas,
  }) {
    return PropriedadeEntity(
      id: id != null ? id() : this.id,
      createdById: createdById != null ? createdById() : this.createdById,
      modifiedById: modifiedById != null ? modifiedById() : this.modifiedById,
      createdAt: createdAt != null ? createdAt() : this.createdAt,
      modifiedAt: modifiedAt != null ? modifiedAt() : this.modifiedAt,
      nome: nome != null ? nome() : this.nome,
      proprietario: proprietario != null ? proprietario() : this.proprietario,
      localizacao: localizacao != null ? localizacao() : this.localizacao,
      areaTotalHa: areaTotalHa != null ? areaTotalHa() : this.areaTotalHa,
      coordenadasGps: coordenadasGps != null ? coordenadasGps() : this.coordenadasGps,
      inscricaoEstadual: inscricaoEstadual != null ? inscricaoEstadual() : this.inscricaoEstadual,
      cnpjCpf: cnpjCpf != null ? cnpjCpf() : this.cnpjCpf,
      ativa: ativa != null ? ativa() : this.ativa,
      dataCriacao: dataCriacao != null ? dataCriacao() : this.dataCriacao,
      areaOcupada: areaOcupada != null ? areaOcupada() : this.areaOcupada,
      totalAnimais: totalAnimais != null ? totalAnimais() : this.totalAnimais,
      totalLotes: totalLotes != null ? totalLotes() : this.totalLotes,
      totalAreas: totalAreas != null ? totalAreas() : this.totalAreas,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    Map<String, dynamic> data = super.toJson();
    data['nome'] = nome;
    if (proprietario != null) {
      data['proprietario'] = proprietario!.toJson();
    }
    data['localizacao'] = localizacao;
    data['area_total_ha'] = areaTotalHa;
    if (coordenadasGps != null) {
      data['coordenadas_gps'] = coordenadasGps!.toJson();
    }
    data['inscricao_estadual'] = inscricaoEstadual;
    data['cnpj_cpf'] = cnpjCpf;
    data['ativa'] = ativa;
    data['data_criacao'] = dataCriacao;
    data['area_ocupada'] = areaOcupada;
    data['total_animais'] = totalAnimais;
    data['total_lotes'] = totalLotes;
    data['total_areas'] = totalAreas;
    return data;
  }

  PropriedadeEntity.fromJson(Map<String, dynamic> json)
      : nome = json['nome'] ?? '',
        proprietario = json['proprietario'] != null 
            ? PropriedadeProprietario.fromJson(json['proprietario']) 
            : null,
        localizacao = json['localizacao'] ?? '',
        areaTotalHa = json['area_total_ha']?.toString() ?? '',
        coordenadasGps = json['coordenadas_gps'] != null 
            ? PropriedadeCoordenadas.fromJson(json['coordenadas_gps']) 
            : null,
        inscricaoEstadual = json['inscricao_estadual'],
        cnpjCpf = json['cnpj_cpf'],
        ativa = json['ativa'] ?? true,
        dataCriacao = json['data_criacao'],
        areaOcupada = json['area_ocupada'],
        totalAnimais = json['total_animais'] ?? 0,
        totalLotes = json['total_lotes'] ?? 0,
        totalAreas = json['total_areas'] ?? 0,
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
