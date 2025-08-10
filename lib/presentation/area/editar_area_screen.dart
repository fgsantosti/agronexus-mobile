import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:agronexus/presentation/bloc/area/area_bloc.dart';
import 'package:agronexus/presentation/bloc/area/area_event.dart';
import 'package:agronexus/presentation/bloc/area/area_state.dart';
import 'package:agronexus/presentation/bloc/propriedade/propriedade_bloc_new.dart';
import 'package:agronexus/presentation/bloc/propriedade/propriedade_event_new.dart';
import 'package:agronexus/presentation/bloc/propriedade/propriedade_state_new.dart';
import 'package:agronexus/domain/models/area_entity.dart';
import 'package:agronexus/domain/models/propriedade_entity.dart';

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
  late String _status;
  PropriedadeEntity? _propriedadeSelecionada;

  @override
  void initState() {
    super.initState();
    final a = widget.area;
    _nomeCtrl = TextEditingController(text: a.nome);
    _tipoCtrl = TextEditingController(text: a.tipo);
    _tamanhoCtrl = TextEditingController(text: a.tamanhoHa.toStringAsFixed(2));
    _tipoForragemCtrl = TextEditingController(text: a.tipoForragem ?? '');
    _observacoesCtrl = TextEditingController(text: a.observacoes ?? '');
    _status = a.status;
    context.read<PropriedadeBlocNew>().add(const LoadPropriedadesEvent());
  }

  @override
  void dispose() {
    _nomeCtrl.dispose();
    _tipoCtrl.dispose();
    _tamanhoCtrl.dispose();
    _tipoForragemCtrl.dispose();
    _observacoesCtrl.dispose();
    super.dispose();
  }

  void _atualizar() {
    if (!_formKey.currentState!.validate()) return;
    final tamanho = double.parse(_tamanhoCtrl.text.replaceAll(',', '.'));
    final updated = widget.area.copyWith(
      nome: () => _nomeCtrl.text.trim(),
      tipo: () => _tipoCtrl.text.trim(),
      tamanhoHa: () => tamanho,
      status: () => _status,
      propriedadeId: () => _propriedadeSelecionada?.id ?? widget.area.propriedadeId,
      propriedadeNome: () => _propriedadeSelecionada?.nome ?? widget.area.propriedadeNome,
      tipoForragem: () => _tipoForragemCtrl.text.trim().isEmpty ? null : _tipoForragemCtrl.text.trim(),
      observacoes: () => _observacoesCtrl.text.trim().isEmpty ? null : _observacoesCtrl.text.trim(),
    );
    context.read<AreaBloc>().add(UpdateAreaEvent(id: widget.area.id!, area: updated));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Área'),
        actions: [
          TextButton(onPressed: _atualizar, child: const Text('Salvar')),
        ],
      ),
      body: BlocListener<AreaBloc, AreaState>(
        listener: (context, state) {
          if (state is AreaUpdated) {
            Navigator.pop(context, true);
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Área atualizada com sucesso')));
          }
          if (state is AreaError) {
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
