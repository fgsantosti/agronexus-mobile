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

class CadastroAreaScreen extends StatefulWidget {
  const CadastroAreaScreen({super.key});

  @override
  State<CadastroAreaScreen> createState() => _CadastroAreaScreenState();
}

class _CadastroAreaScreenState extends State<CadastroAreaScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomeCtrl = TextEditingController();
  final _tamanhoCtrl = TextEditingController();
  final _tipoForragemCtrl = TextEditingController();
  final _observacoesCtrl = TextEditingController();
  String _status = 'disponivel';
  String _tipo = 'piquete';
  PropriedadeEntity? _propriedadeSelecionada;

  @override
  void initState() {
    super.initState();
    context.read<PropriedadeBlocNew>().add(const LoadPropriedadesEvent());
  }

  @override
  void dispose() {
    _nomeCtrl.dispose();
    _tamanhoCtrl.dispose();
    _tipoForragemCtrl.dispose();
    _observacoesCtrl.dispose();
    super.dispose();
  }

  void _salvar() {
    if (!_formKey.currentState!.validate()) return;
    final tamanho = double.parse(_tamanhoCtrl.text.replaceAll(',', '.'));
    final area = AreaEntity(
      nome: _nomeCtrl.text.trim(),
      tipo: _tipo,
      tamanhoHa: tamanho,
      status: _status,
      propriedadeId: _propriedadeSelecionada?.id ?? '',
      propriedadeNome: _propriedadeSelecionada?.nome,
      tipoForragem: _tipoForragemCtrl.text.trim().isEmpty ? null : _tipoForragemCtrl.text.trim(),
      observacoes: _observacoesCtrl.text.trim().isEmpty ? null : _observacoesCtrl.text.trim(),
    );
    context.read<AreaBloc>().add(CreateAreaEvent(area));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nova Área'),
        actions: [
          TextButton(
            onPressed: _salvar,
            child: const Text('Salvar'),
          ),
        ],
      ),
      body: BlocListener<AreaBloc, AreaState>(
        listener: (context, state) {
          if (state is AreaCreated) {
            Navigator.pop(context, true);
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Área criada com sucesso')));
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
