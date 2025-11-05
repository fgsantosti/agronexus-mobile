import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:agronexus/presentation/bloc/area/area_bloc.dart';
import 'package:agronexus/presentation/bloc/area/area_event.dart';
import 'package:agronexus/presentation/bloc/area/area_state.dart';
import 'package:agronexus/presentation/bloc/propriedade/propriedade_bloc_new.dart';
import 'package:agronexus/presentation/bloc/propriedade/propriedade_event_new.dart';
import 'package:agronexus/presentation/bloc/propriedade/propriedade_state_new.dart';
import 'package:agronexus/presentation/area/widgets/polygon_editor.dart';
import 'package:agronexus/domain/models/area_entity.dart';
import 'package:agronexus/domain/models/propriedade_entity.dart';
import 'package:agronexus/presentation/widgets/form_components.dart';
import 'package:agronexus/presentation/widgets/form_submit_protection_mixin.dart';

class CadastroAreaScreen extends StatefulWidget {
  const CadastroAreaScreen({super.key});

  @override
  State<CadastroAreaScreen> createState() => _CadastroAreaScreenState();
}

class _CadastroAreaScreenState extends State<CadastroAreaScreen> with FormSubmitProtectionMixin {
  final _formKey = GlobalKey<FormState>();
  final _nomeCtrl = TextEditingController();
  final _tamanhoCtrl = TextEditingController();
  final _tipoForragemCtrl = TextEditingController();
  final _observacoesCtrl = TextEditingController();
  final _coordenadasCtrl = TextEditingController();
  String _status = 'disponivel';
  String _tipo = 'piquete';
  PropriedadeEntity? _propriedadeSelecionada;
  List<List<double>>? _initialPolygon; // evita parse repetido em build

  @override
  void initState() {
    super.initState();
    context.read<PropriedadeBlocNew>().add(const LoadPropriedadesEvent());
    _parseInitialPolygon();
  }

  void _parseInitialPolygon() {
    if (_coordenadasCtrl.text.trim().isEmpty) {
      _initialPolygon = null;
      return;
    }
    try {
      final decoded = jsonDecode(_coordenadasCtrl.text.trim());
      if (decoded is List) {
        _initialPolygon = decoded
            .whereType<List>()
            .map<List<double>>((e) => [
                  double.tryParse(e[0].toString()) ?? 0,
                  double.tryParse(e[1].toString()) ?? 0,
                ])
            .toList();
      }
    } catch (_) {
      _initialPolygon = null;
    }
  }

  @override
  void dispose() {
    _nomeCtrl.dispose();
    _tamanhoCtrl.dispose();
    _tipoForragemCtrl.dispose();
    _observacoesCtrl.dispose();
    _coordenadasCtrl.dispose();
    super.dispose();
  }

  void _salvar() {
    if (!canSubmit()) return;
    if (!_formKey.currentState!.validate()) {
      resetProtection();
      return;
    }
    markAsSubmitting();

    final tamanho = double.parse(_tamanhoCtrl.text.replaceAll(',', '.'));
    dynamic coordenadas;
    if (_coordenadasCtrl.text.trim().isNotEmpty) {
      try {
        final decoded = jsonDecode(_coordenadasCtrl.text.trim());
        // Aceita lista de listas [[lat,lng],...] ou lista de objetos [{"lat":..,"lng":..}]
        if (decoded is List) {
          coordenadas = decoded;
        } else {
          throw const FormatException('Estrutura deve ser lista');
        }
      } catch (e) {
        if (mounted) {
          FormSnackBar.showError(context, 'Formato de coordenadas inválido: ${e.toString()}');
        }
        resetProtection();
        return; // impede envio se inválido
      }
    }
    final area = AreaEntity(
      nome: _nomeCtrl.text.trim(),
      tipo: _tipo,
      tamanhoHa: tamanho,
      status: _status,
      propriedadeId: _propriedadeSelecionada?.id ?? '',
      propriedadeNome: _propriedadeSelecionada?.nome,
      tipoForragem: _tipoForragemCtrl.text.trim().isEmpty ? null : _tipoForragemCtrl.text.trim(),
      observacoes: _observacoesCtrl.text.trim().isEmpty ? null : _observacoesCtrl.text.trim(),
      coordenadasPoligono: coordenadas,
    );
    context.read<AreaBloc>().add(CreateAreaEvent(area));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: FormAppBar(
        title: 'Nova Área',
        showSaveButton: false,
      ),
      body: BlocListener<AreaBloc, AreaState>(
        listener: (context, state) {
          if (state is AreaCreated) {
            FormSnackBar.showSuccess(context, 'Área criada com sucesso');
            safeNavigateBack();
          }
          if (state is AreaError) {
            FormSnackBar.showError(context, state.message);
            resetProtection();
          }
        },
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                BlocBuilder<PropriedadeBlocNew, PropriedadeState>(
                  builder: (context, propState) {
                    final propriedades = propState is PropriedadesLoaded ? propState.propriedades : <PropriedadeEntity>[];
                    if (propriedades.isEmpty) {
                      return const Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: SizedBox(height: 24, width: 24, child: CircularProgressIndicator(strokeWidth: 2)),
                        ),
                      );
                    }
                    if (_propriedadeSelecionada == null || !propriedades.contains(_propriedadeSelecionada)) {
                      _propriedadeSelecionada = propriedades.first;
                    }
                    return DropdownButtonFormField<PropriedadeEntity>(
                      key: ValueKey(_propriedadeSelecionada?.id),
                      decoration: const InputDecoration(labelText: 'Propriedade *'),
                      value: _propriedadeSelecionada,
                      items: propriedades.map((p) => DropdownMenuItem(value: p, child: Text(p.nome))).toList(),
                      onChanged: (v) => setState(() => _propriedadeSelecionada = v),
                      validator: (v) => v == null ? 'Selecione a propriedade' : null,
                    );
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _nomeCtrl,
                  decoration: const InputDecoration(labelText: 'Nome *'),
                  validator: (v) => v == null || v.trim().isEmpty ? 'Informe o nome' : null,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _tipo,
                  decoration: const InputDecoration(labelText: 'Tipo *'),
                  items: const [
                    DropdownMenuItem(value: 'piquete', child: Text('Piquete')),
                    DropdownMenuItem(value: 'baia', child: Text('Baia')),
                    DropdownMenuItem(value: 'curral', child: Text('Curral')),
                    DropdownMenuItem(value: 'apartacao', child: Text('Apartação')),
                    DropdownMenuItem(value: 'enfermaria', child: Text('Enfermaria')),
                  ],
                  onChanged: (v) => setState(() => _tipo = v ?? 'piquete'),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _tamanhoCtrl,
                  decoration: const InputDecoration(labelText: 'Tamanho (ha) *'),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Informe o tamanho';
                    return double.tryParse(v.replaceAll(',', '.')) == null ? 'Valor inválido' : null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _tipoForragemCtrl,
                  decoration: const InputDecoration(labelText: 'Tipo de Forragem'),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _observacoesCtrl,
                  decoration: const InputDecoration(labelText: 'Observações'),
                  maxLines: 3,
                ),
                const SizedBox(height: 12),
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Polígono / Geolocalização (opcional)',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                const SizedBox(height: 8),
                PolygonEditor(
                  initial: _initialPolygon,
                  onChanged: (points) {
                    _coordenadasCtrl.text = const JsonEncoder.withIndent('  ').convert(points);
                    _initialPolygon = points;
                  },
                  onAreaChanged: (ha) {
                    // Atualiza campo tamanho se usuário ainda não digitou manualmente
                    // ou sempre mantemos sincronizado (decisão: sobrescrever enquanto polígono aberto)
                    if (_tamanhoCtrl.text.trim().isEmpty || true) {
                      // formata com até 4 decimais
                      final txt = ha < 10 ? ha.toStringAsFixed(4) : ha.toStringAsFixed(2);
                      if (_tamanhoCtrl.text != txt) {
                        _tamanhoCtrl.text = txt;
                      }
                    }
                  },
                  onClear: () {
                    _coordenadasCtrl.clear();
                    _initialPolygon = null;
                    // Não limpar tamanho para evitar perda de dado manual
                    setState(() {});
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _coordenadasCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Coordenadas (JSON)',
                    alignLabelWithHint: true,
                    hintText: '[[ -21.000000, -47.000000 ]]',
                  ),
                  maxLines: 6,
                  onChanged: (_) => _parseInitialPolygon(),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return null;
                    try {
                      final decoded = jsonDecode(v.trim());
                      if (decoded is! List) return 'Deve ser lista';
                      _parseInitialPolygon();
                    } catch (_) {
                      return 'JSON inválido';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 8),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _status,
                  decoration: const InputDecoration(labelText: 'Status'),
                  items: const [
                    DropdownMenuItem(value: 'disponivel', child: Text('Disponível')),
                    DropdownMenuItem(value: 'em_uso', child: Text('Em Uso')),
                    DropdownMenuItem(value: 'descanso', child: Text('Em Descanso')),
                    DropdownMenuItem(value: 'degradada', child: Text('Degradada')),
                    DropdownMenuItem(value: 'reforma', child: Text('Em Reforma')),
                  ],
                  onChanged: (v) => setState(() => _status = v ?? 'disponivel'),
                ),
                const SizedBox(height: 24),
                FormPrimaryButton(
                  text: 'Salvar Área',
                  onPressed: _salvar,
                  isLoading: isSaving,
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
