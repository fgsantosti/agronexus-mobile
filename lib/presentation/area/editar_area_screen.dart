import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:agronexus/config/routers/router.dart';
import 'package:agronexus/presentation/bloc/area/area_bloc.dart';
import 'package:agronexus/presentation/bloc/area/area_event.dart';
import 'package:agronexus/presentation/bloc/area/area_state.dart';
import 'package:agronexus/presentation/bloc/propriedade/propriedade_bloc_new.dart';
import 'package:agronexus/presentation/bloc/propriedade/propriedade_event_new.dart';
import 'package:agronexus/presentation/bloc/propriedade/propriedade_state_new.dart';
import 'package:agronexus/domain/models/area_entity.dart';
import 'package:agronexus/domain/models/propriedade_entity.dart';
import 'package:agronexus/presentation/area/widgets/polygon_editor.dart';
import 'package:agronexus/presentation/widgets/standard_app_bar.dart';

class EditarAreaScreen extends StatefulWidget {
  final AreaEntity area;
  const EditarAreaScreen({super.key, required this.area});

  @override
  State<EditarAreaScreen> createState() => _EditarAreaScreenState();
}

class _EditarAreaScreenState extends State<EditarAreaScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nomeCtrl;
  late TextEditingController _tipoCtrl;
  late TextEditingController _tamanhoCtrl;
  late TextEditingController _tipoForragemCtrl;
  late TextEditingController _observacoesCtrl;
  late TextEditingController _coordenadasCtrl;
  late String _status;
  PropriedadeEntity? _propriedadeSelecionada;
  List<List<double>>? _initialPolygon;

  @override
  void initState() {
    super.initState();
    final a = widget.area;
    _nomeCtrl = TextEditingController(text: a.nome);
    _tipoCtrl = TextEditingController(text: a.tipo);
    _tamanhoCtrl = TextEditingController(text: a.tamanhoHa.toStringAsFixed(2));
    _tipoForragemCtrl = TextEditingController(text: a.tipoForragem ?? '');
    _observacoesCtrl = TextEditingController(text: a.observacoes ?? '');
    _coordenadasCtrl = TextEditingController(
      text: a.coordenadasPoligono == null ? '' : const JsonEncoder.withIndent('  ').convert(a.coordenadasPoligono),
    );
    _status = a.status;
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
    _tipoCtrl.dispose();
    _tamanhoCtrl.dispose();
    _tipoForragemCtrl.dispose();
    _observacoesCtrl.dispose();
    _coordenadasCtrl.dispose();
    super.dispose();
  }

  void _atualizar() {
    debugPrint('🔄 Iniciando atualização da área...');
    if (!_formKey.currentState!.validate()) {
      debugPrint('❌ Formulário não passou na validação');
      return;
    }
    debugPrint('✅ Formulário validado com sucesso');
    final tamanho = double.parse(_tamanhoCtrl.text.replaceAll(',', '.'));
    debugPrint('📏 Tamanho parseado: $tamanho');
    final updated = widget.area.copyWith(
      nome: () => _nomeCtrl.text.trim(),
      tipo: () => _tipoCtrl.text.trim(),
      tamanhoHa: () => tamanho,
      status: () => _status,
      propriedadeId: () => _propriedadeSelecionada?.id ?? widget.area.propriedadeId,
      propriedadeNome: () => _propriedadeSelecionada?.nome ?? widget.area.propriedadeNome,
      tipoForragem: () => _tipoForragemCtrl.text.trim().isEmpty ? null : _tipoForragemCtrl.text.trim(),
      observacoes: () => _observacoesCtrl.text.trim().isEmpty ? null : _observacoesCtrl.text.trim(),
      coordenadasPoligono: () {
        if (_coordenadasCtrl.text.trim().isEmpty) return null;
        try {
          final decoded = jsonDecode(_coordenadasCtrl.text.trim());
          if (decoded is! List) throw const FormatException('Lista esperada');
          return decoded;
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Coordenadas inválidas: ${e.toString()}')),
          );
          return widget.area.coordenadasPoligono; // mantém antigo se inválido
        }
      },
    );
    debugPrint('📤 Enviando evento UpdateAreaEvent para o BLoC...');
    debugPrint('🆔 ID da área: ${widget.area.id}');
    context.read<AreaBloc>().add(UpdateAreaEvent(id: widget.area.id!, area: updated));
    debugPrint('✅ Evento enviado!');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildStandardAppBar(
        title: 'Editar Área',
        actions: [
          TextButton(onPressed: _atualizar, child: const Text('Salvar', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
        ],
      ),
      body: BlocListener<AreaBloc, AreaState>(
        listener: (context, state) {
          debugPrint('🔔 Estado recebido no BlocListener: ${state.runtimeType}');
          if (state is AreaUpdated) {
            debugPrint('✅ Área atualizada com sucesso!');
            Navigator.pop(context, true);
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Área atualizada com sucesso')));
            // Navegar para a tela de detalhes da área editada
            context.go(AgroNexusRouter.areas.detailPath.replaceFirst(':id', state.area.id!), extra: state.area);
          }
          if (state is AreaError) {
            debugPrint('❌ Erro ao atualizar área: ${state.message}');
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
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

                    // Enquanto carregando, mostra progress / evita setar valor inválido
                    if (propriedades.isEmpty) {
                      return const Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: SizedBox(height: 24, width: 24, child: CircularProgressIndicator(strokeWidth: 2)),
                        ),
                      );
                    }

                    // Define seleção apenas quando lista disponível
                    if (_propriedadeSelecionada == null || !propriedades.contains(_propriedadeSelecionada)) {
                      _propriedadeSelecionada = propriedades.firstWhere(
                        (p) => p.id == widget.area.propriedadeId,
                        orElse: () => propriedades.first,
                      );
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
                  value: _tipoCtrl.text,
                  decoration: const InputDecoration(labelText: 'Tipo *'),
                  items: const [
                    DropdownMenuItem(value: 'piquete', child: Text('Piquete')),
                    DropdownMenuItem(value: 'baia', child: Text('Baia')),
                    DropdownMenuItem(value: 'curral', child: Text('Curral')),
                    DropdownMenuItem(value: 'apartacao', child: Text('Apartação')),
                    DropdownMenuItem(value: 'enfermaria', child: Text('Enfermaria')),
                  ],
                  onChanged: (v) => setState(() => _tipoCtrl.text = v ?? _tipoCtrl.text),
                  validator: (v) => v == null || v.isEmpty ? 'Selecione o tipo' : null,
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
                  child: Text('Polígono / Geolocalização', style: Theme.of(context).textTheme.titleMedium),
                ),
                const SizedBox(height: 8),
                PolygonEditor(
                  initial: _initialPolygon,
                  onChanged: (points) {
                    if (points.isEmpty) {
                      _coordenadasCtrl.text = '';
                      _initialPolygon = null;
                    } else {
                      _coordenadasCtrl.text = const JsonEncoder.withIndent('  ').convert(points);
                      _initialPolygon = points;
                    }
                  },
                  onAreaChanged: (ha) {
                    // Sempre usa 2 casas decimais conforme exigido pela API
                    final txt = ha.toStringAsFixed(2);
                    if (_tamanhoCtrl.text != txt) {
                      _tamanhoCtrl.text = txt;
                    }
                  },
                  onClear: () {
                    _coordenadasCtrl.clear();
                    _initialPolygon = null;
                    // Mantém tamanho existente
                    setState(() {});
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _coordenadasCtrl,
                  decoration: const InputDecoration(labelText: 'Coordenadas (JSON)', alignLabelWithHint: true, hintText: '[[ -21.000000, -47.000000 ]]'),
                  maxLines: 6,
                  onChanged: (_) => _parseInitialPolygon(),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return null;
                    try {
                      final decoded = jsonDecode(v.trim());
                      if (decoded is! List) return 'Deve ser uma lista de coordenadas';
                      final list = decoded;
                      if (list.isNotEmpty) {
                        // Validar que cada item da lista tem 2 elementos (lat, lng)
                        for (var item in list) {
                          if (item is! List || item.length != 2) {
                            return 'Cada coordenada deve ter latitude e longitude';
                          }
                        }
                      }
                      _parseInitialPolygon();
                    } catch (e) {
                      return 'JSON inválido: ${e.toString()}';
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
                  onChanged: (v) => setState(() => _status = v ?? _status),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
