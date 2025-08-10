import 'package:agronexus/domain/models/base_entity.dart';
import 'package:agronexus/config/utils.dart';

class AreaEntity extends BaseEntity {
  final String nome;
  final String tipo; // piquete, baia, curral, apartacao, enfermaria
  final double tamanhoHa;
  final String status; // em_uso, descanso, degradada, reforma, disponivel
  final String propriedadeId;
  final String? propriedadeNome;
  final String? tipoForragem;
  final String? observacoes;
  final dynamic coordenadasPoligono; // manter dinâmico (lista/map) conforme API

  const AreaEntity({
    super.id,
    super.createdById,
    super.modifiedById,
    super.createdAt,
    super.modifiedAt,
    required this.nome,
    required this.tipo,
    required this.tamanhoHa,
    required this.status,
    required this.propriedadeId,
    this.propriedadeNome,
    this.tipoForragem,
    this.observacoes,
    this.coordenadasPoligono,
  });

  @override
  List<Object?> get props => [
        ...super.props,
        nome,
        tipo,
        tamanhoHa,
        status,
        propriedadeId,
        propriedadeNome,
        tipoForragem,
        observacoes,
        coordenadasPoligono,
      ];

  factory AreaEntity.fromJson(Map<String, dynamic> json) {
    return AreaEntity(
      id: json['id']?.toString(),
      createdById: json['created_by']?.toString(),
      modifiedById: json['modified_by']?.toString(),
      createdAt: (json['created_at'] ?? json['data_criacao'])?.toString(),
      modifiedAt: json['modified_at']?.toString(),
      nome: json['nome'] ?? '',
      tipo: json['tipo'] ?? '',
      tamanhoHa: (json['tamanho_ha'] is num) ? (json['tamanho_ha'] as num).toDouble() : double.tryParse(json['tamanho_ha']?.toString() ?? '0') ?? 0,
      status: json['status'] ?? '',
      propriedadeId: json['propriedade']?['id']?.toString() ?? json['propriedade_id']?.toString() ?? '',
      propriedadeNome: json['propriedade']?['nome']?.toString(),
      tipoForragem: json['tipo_forragem']?.toString(),
      observacoes: json['observacoes']?.toString(),
      coordenadasPoligono: json['coordenadas_poligono'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'tipo': tipo,
      'tamanho_ha': tamanhoHa,
      'status': status,
      'propriedade_id': propriedadeId,
      if (tipoForragem != null) 'tipo_forragem': tipoForragem,
      if (observacoes != null) 'observacoes': observacoes,
      if (coordenadasPoligono != null) 'coordenadas_poligono': coordenadasPoligono,
    };
  }

  AreaEntity copyWith({
    AgroNexusGetter<String?>? id,
    AgroNexusGetter<String?>? createdById,
    AgroNexusGetter<String?>? modifiedById,
    AgroNexusGetter<String?>? createdAt,
    AgroNexusGetter<String?>? modifiedAt,
    AgroNexusGetter<String>? nome,
    AgroNexusGetter<String>? tipo,
    AgroNexusGetter<double>? tamanhoHa,
    AgroNexusGetter<String>? status,
    AgroNexusGetter<String>? propriedadeId,
    AgroNexusGetter<String?>? propriedadeNome,
    AgroNexusGetter<String?>? tipoForragem,
    AgroNexusGetter<String?>? observacoes,
    AgroNexusGetter<dynamic>? coordenadasPoligono,
  }) {
    return AreaEntity(
      id: id != null ? id() : this.id,
      createdById: createdById != null ? createdById() : this.createdById,
      modifiedById: modifiedById != null ? modifiedById() : this.modifiedById,
      createdAt: createdAt != null ? createdAt() : this.createdAt,
      modifiedAt: modifiedAt != null ? modifiedAt() : this.modifiedAt,
      nome: nome != null ? nome() : this.nome,
      tipo: tipo != null ? tipo() : this.tipo,
      tamanhoHa: tamanhoHa != null ? tamanhoHa() : this.tamanhoHa,
      status: status != null ? status() : this.status,
      propriedadeId: propriedadeId != null ? propriedadeId() : this.propriedadeId,
      propriedadeNome: propriedadeNome != null ? propriedadeNome() : this.propriedadeNome,
      tipoForragem: tipoForragem != null ? tipoForragem() : this.tipoForragem,
      observacoes: observacoes != null ? observacoes() : this.observacoes,
      coordenadasPoligono: coordenadasPoligono != null ? coordenadasPoligono() : this.coordenadasPoligono,
    );
  }
}
