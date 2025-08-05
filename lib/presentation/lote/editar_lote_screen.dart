import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:agronexus/presentation/bloc/lote/lote_bloc.dart';
import 'package:agronexus/presentation/bloc/lote/lote_events.dart';
import 'package:agronexus/presentation/bloc/lote/lote_state.dart';
import 'package:agronexus/domain/models/lote_entity.dart';

class EditarLoteScreen extends StatefulWidget {
  final LoteEntity lote;

  const EditarLoteScreen({
    super.key,
    required this.lote,
  });

  @override
  State<EditarLoteScreen> createState() => _EditarLoteScreenState();
}

class _EditarLoteScreenState extends State<EditarLoteScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers para campos de texto
  final _nomeController = TextEditingController();
  final _descricaoController = TextEditingController();
  final _criterioAgrupamentoController = TextEditingController();
  final _propriedadeIdController = TextEditingController();

  String? _aptidao;
  String? _finalidade;
  String? _sistemaCriacao;
  bool _ativo = true;
  bool _isLoading = false;

  // Opções dos dropdowns
  final List<Map<String, String>> _aptidaoOptions = [
    {'value': 'corte', 'label': 'Corte'},
    {'value': 'leite', 'label': 'Leite'},
    {'value': 'dupla_aptidao', 'label': 'Dupla Aptidão'},
  ];

  final List<Map<String, String>> _finalidadeOptions = [
    {'value': 'cria', 'label': 'Cria'},
    {'value': 'recria', 'label': 'Recria'},
    {'value': 'engorda', 'label': 'Engorda'},
  ];

  final List<Map<String, String>> _sistemaCriacaoOptions = [
    {'value': 'intensivo', 'label': 'Intensivo'},
    {'value': 'extensivo', 'label': 'Extensivo'},
    {'value': 'semi_extensivo', 'label': 'Semi-Extensivo'},
  ];

  @override
  void initState() {
    super.initState();
    _preencherCamposComDadosExistentes();
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _descricaoController.dispose();
    _criterioAgrupamentoController.dispose();
    _propriedadeIdController.dispose();
    super.dispose();
  }

  void _preencherCamposComDadosExistentes() {
    final lote = widget.lote;

    _nomeController.text = lote.nome;
    _descricaoController.text = lote.descricao;
    _criterioAgrupamentoController.text = lote.criterioAgrupamento;
    _propriedadeIdController.text = lote.propriedadeId;
    _aptidao = lote.aptidao;
    _finalidade = lote.finalidade;
    _sistemaCriacao = lote.sistemaCriacao;
    _ativo = lote.ativo;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Lote'),
        backgroundColor: Colors.green.shade600,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _atualizarLote,
            child: _isLoading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text(
                    'Salvar',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
          ),
        ],
      ),
      body: BlocListener<LoteBloc, LoteState>(
        listener: (context, state) {
          if (state is LoteUpdated) {
            Navigator.pop(context, true);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Lote atualizado com sucesso!')),
            );
          }

          if (state is LoteError) {
            setState(() => _isLoading = false);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }

          if (state is LoteLoading) {
            setState(() => _isLoading = true);
          }
        },
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Informações básicas
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Informações Básicas',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.green.shade700,
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _nomeController,
                          decoration: const InputDecoration(
                            labelText: 'Nome do Lote *',
                            hintText: 'Ex: Lote Bezerros 2024',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value?.isEmpty == true) {
                              return 'Nome é obrigatório';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _descricaoController,
                          decoration: const InputDecoration(
                            labelText: 'Descrição',
                            hintText: 'Descrição do lote',
                            border: OutlineInputBorder(),
                          ),
                          maxLines: 3,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _criterioAgrupamentoController,
                          decoration: const InputDecoration(
                            labelText: 'Critério de Agrupamento',
                            hintText: 'Ex: Bezerros desmamados em 2024',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _propriedadeIdController,
                          decoration: const InputDecoration(
                            labelText: 'ID da Propriedade *',
                            hintText: 'ID da propriedade',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value?.isEmpty == true) {
                              return 'ID da propriedade é obrigatório';
                            }
                            return null;
                          },
                          enabled: false, // Não permite editar o ID da propriedade
                        ),
                        const SizedBox(height: 16),
                        SwitchListTile(
                          title: const Text('Lote Ativo'),
                          subtitle: const Text('Define se o lote está em uso'),
                          value: _ativo,
                          onChanged: (value) {
                            setState(() {
                              _ativo = value;
                            });
                          },
                          activeColor: Colors.green.shade600,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Características do lote
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Características do Lote',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.green.shade700,
                          ),
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          value: _aptidao,
                          decoration: const InputDecoration(
                            labelText: 'Aptidão',
                            border: OutlineInputBorder(),
                          ),
                          items: _aptidaoOptions.map((option) {
                            return DropdownMenuItem<String>(
                              value: option['value'],
                              child: Text(option['label']!),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _aptidao = value;
                            });
                          },
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          value: _finalidade,
                          decoration: const InputDecoration(
                            labelText: 'Finalidade',
                            border: OutlineInputBorder(),
                          ),
                          items: _finalidadeOptions.map((option) {
                            return DropdownMenuItem<String>(
                              value: option['value'],
                              child: Text(option['label']!),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _finalidade = value;
                            });
                          },
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          value: _sistemaCriacao,
                          decoration: const InputDecoration(
                            labelText: 'Sistema de Criação',
                            border: OutlineInputBorder(),
                          ),
                          items: _sistemaCriacaoOptions.map((option) {
                            return DropdownMenuItem<String>(
                              value: option['value'],
                              child: Text(option['label']!),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _sistemaCriacao = value;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _atualizarLote() {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final loteAtualizado = widget.lote.copyWith(
      nome: () => _nomeController.text.trim(),
      descricao: () => _descricaoController.text.trim(),
      criterioAgrupamento: () => _criterioAgrupamentoController.text.trim(),
      propriedadeId: () => _propriedadeIdController.text.trim(),
      aptidao: () => _aptidao,
      finalidade: () => _finalidade,
      sistemaCriacao: () => _sistemaCriacao,
      ativo: () => _ativo,
    );

    context.read<LoteBloc>().add(UpdateLoteEvent(loteAtualizado));
  }
}
