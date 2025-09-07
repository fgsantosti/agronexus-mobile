import 'package:agronexus/config/utils.dart';
import 'package:agronexus/domain/models/base_entity.dart';

enum ImportStatus {
  pendente(label: 'Pendente', value: 'pendente'),
  sucesso(label: 'Sucesso', value: 'sucesso'),
  erro(label: 'Erro', value: 'erro'),
  processando(label: 'Processando', value: 'processando');

  final String label;
  final String value;
  const ImportStatus({required this.label, required this.value});

  static ImportStatus fromString(String value) {
    switch (value) {
      case 'pendente':
        return ImportStatus.pendente;
      case 'sucesso':
        return ImportStatus.sucesso;
      case 'erro':
        return ImportStatus.erro;
      case 'processando':
        return ImportStatus.processando;
      default:
        throw Exception('Invalid ImportStatus value: $value');
    }
  }
}

class ImportResultEntity extends BaseEntity {
  final int totalRegistros;
  final int sucessos;
  final int erros;
  final List<String> mensagensErro;
  final ImportStatus status;
  final String? arquivoPath;

  const ImportResultEntity({
    super.id,
    super.createdById,
    super.modifiedById,
    super.createdAt,
    super.modifiedAt,
    required this.totalRegistros,
    required this.sucessos,
    required this.erros,
    required this.mensagensErro,
    required this.status,
    this.arquivoPath,
  });

  @override
  List<Object?> get props => [
        ...super.props,
        totalRegistros,
        sucessos,
        erros,
        mensagensErro,
        status,
        arquivoPath,
      ];

  ImportResultEntity copyWith({
    AgroNexusGetter<String?>? id,
    AgroNexusGetter<String?>? createdById,
    AgroNexusGetter<String?>? modifiedById,
    AgroNexusGetter<String?>? createdAt,
    AgroNexusGetter<String?>? modifiedAt,
    AgroNexusGetter<int>? totalRegistros,
    AgroNexusGetter<int>? sucessos,
    AgroNexusGetter<int>? erros,
    AgroNexusGetter<List<String>>? mensagensErro,
    AgroNexusGetter<ImportStatus>? status,
    AgroNexusGetter<String?>? arquivoPath,
  }) {
    return ImportResultEntity(
      id: id != null ? id() : this.id,
      createdById: createdById != null ? createdById() : this.createdById,
      modifiedById: modifiedById != null ? modifiedById() : this.modifiedById,
      createdAt: createdAt != null ? createdAt() : this.createdAt,
      modifiedAt: modifiedAt != null ? modifiedAt() : this.modifiedAt,
      totalRegistros: totalRegistros != null ? totalRegistros() : this.totalRegistros,
      sucessos: sucessos != null ? sucessos() : this.sucessos,
      erros: erros != null ? erros() : this.erros,
      mensagensErro: mensagensErro != null ? mensagensErro() : this.mensagensErro,
      status: status != null ? status() : this.status,
      arquivoPath: arquivoPath != null ? arquivoPath() : this.arquivoPath,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final data = super.toJson();
    data.addAll({
      'total_registros': totalRegistros,
      'sucessos': sucessos,
      'erros': erros,
      'mensagens_erro': mensagensErro,
      'status': status.value,
      'arquivo_path': arquivoPath,
    });
    return data;
  }

  ImportResultEntity.fromJson(Map<String, dynamic> json)
      : totalRegistros = json['total_registros'] ?? 0,
        sucessos = json['sucessos'] ?? 0,
        erros = json['erros'] ?? 0,
        mensagensErro = List<String>.from(json['mensagens_erro'] ?? []),
        status = ImportStatus.fromString(json['status'] ?? 'pendente'),
        arquivoPath = json['arquivo_path'],
        super.fromJson(json);
}
