import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:agronexus/presentation/bloc/reproducao/reproducao_bloc.dart';
import 'package:agronexus/presentation/bloc/reproducao/reproducao_event.dart';
import 'package:agronexus/presentation/bloc/reproducao/reproducao_state.dart';
import 'package:agronexus/presentation/widgets/standard_app_bar.dart';

class SelecionarLotesScreen extends StatefulWidget {
  final String estacaoMontaId;
  final List<dynamic> lotesJaAssociados;

  const SelecionarLotesScreen({
    super.key,
    required this.estacaoMontaId,
    required this.lotesJaAssociados,
  });

  @override
  State<SelecionarLotesScreen> createState() => _SelecionarLotesScreenState();
}

class _SelecionarLotesScreenState extends State<SelecionarLotesScreen> {
  List<dynamic> _lotesDisponiveis = [];
  Set<String> _lotesSelecionados = {};
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadLotesDisponiveis();

    // Pré-selecionar lotes já associados
    _lotesSelecionados = widget.lotesJaAssociados.map((lote) => lote['id']?.toString() ?? '').where((id) => id.isNotEmpty).toSet();
  }

  void _loadLotesDisponiveis() {
    context.read<ReproducaoBloc>().add(const LoadLotesDisponivelEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildStandardAppBar(
        title: 'Selecionar Lotes',
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _salvarAssociacoes,
            child: const Text(
              'SALVAR',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: BlocListener<ReproducaoBloc, ReproducaoState>(
        listener: (context, state) {
          if (state is LotesDisponivelLoaded) {
            setState(() {
              _lotesDisponiveis = state.lotes;
            });
          } else if (state is LotesAssociados) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
            Navigator.pop(context, true);
          } else if (state is ReproducaoError) {
            setState(() {
              _isLoading = false;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          } else if (state is ReproducaoLoading) {
            setState(() {
              _isLoading = true;
            });
          }
        },
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.green.shade50,
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.green.shade700),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Selecione os lotes que participarão desta estação de monta. '
                      'Apenas as fêmeas dos lotes selecionados poderão ser inseminadas.',
                      style: TextStyle(
                        color: Colors.green.shade700,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Text(
                    'Lotes Selecionados: ${_lotesSelecionados.length}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const Spacer(),
                  if (_lotesDisponiveis.isNotEmpty) ...[
                    TextButton(
                      onPressed: _selecionarTodos,
                      child: const Text('Selecionar Todos'),
                    ),
                    TextButton(
                      onPressed: _deselecionarTodos,
                      child: const Text('Limpar'),
                    ),
                  ],
                ],
              ),
            ),
            Expanded(
              child: BlocBuilder<ReproducaoBloc, ReproducaoState>(
                builder: (context, state) {
                  if (state is LotesDisponivelLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (_lotesDisponiveis.isEmpty) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.group_work, size: 64, color: Colors.grey),
                          SizedBox(height: 16),
                          Text(
                            'Nenhum lote disponível',
                            style: TextStyle(fontSize: 18),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Crie lotes em sua propriedade\npara associá-los à estação',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _lotesDisponiveis.length,
                    itemBuilder: (context, index) {
                      final lote = _lotesDisponiveis[index];
                      final loteId = lote['id']?.toString() ?? '';
                      final isSelected = _lotesSelecionados.contains(loteId);

                      return Card(
                        elevation: isSelected ? 4 : 1,
                        color: isSelected ? Colors.green.shade50 : null,
                        child: CheckboxListTile(
                          value: isSelected,
                          onChanged: (bool? value) {
                            setState(() {
                              if (value == true) {
                                _lotesSelecionados.add(loteId);
                              } else {
                                _lotesSelecionados.remove(loteId);
                              }
                            });
                          },
                          title: Text(
                            lote['nome'] ?? '',
                            style: TextStyle(
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (lote['descricao']?.isNotEmpty == true) Text(lote['descricao']),
                              Row(
                                children: [
                                  Icon(
                                    Icons.pets,
                                    size: 16,
                                    color: Colors.grey.shade600,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Total: ${lote['total_animais'] ?? 0} animais',
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: 12,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Icon(
                                    Icons.female,
                                    size: 16,
                                    color: Colors.pink.shade300,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Fêmeas: ${lote['total_femeas'] ?? 0}',
                                    style: TextStyle(
                                      color: Colors.pink.shade300,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                              if (lote['aptidao'] != null)
                                Row(
                                  children: [
                                    Icon(
                                      Icons.category,
                                      size: 16,
                                      color: Colors.grey.shade600,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Aptidão: ${lote['aptidao']}',
                                      style: TextStyle(
                                        color: Colors.grey.shade600,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                          isThreeLine: true,
                          activeColor: Colors.green,
                          checkColor: Colors.white,
                          secondary: CircleAvatar(
                            backgroundColor: isSelected ? Colors.green.shade700 : Colors.grey.shade300,
                            child: Icon(
                              Icons.group_work,
                              color: isSelected ? Colors.white : Colors.grey.shade600,
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            if (_isLoading)
              const Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(),
              ),
          ],
        ),
      ),
    );
  }

  void _selecionarTodos() {
    setState(() {
      _lotesSelecionados = _lotesDisponiveis.map((lote) => lote['id']?.toString() ?? '').where((id) => id.isNotEmpty).toSet();
    });
  }

  void _deselecionarTodos() {
    setState(() {
      _lotesSelecionados.clear();
    });
  }

  void _salvarAssociacoes() {
    if (_isLoading) return;

    // Verificar se houve mudanças
    final lotesAtuais = widget.lotesJaAssociados.map((lote) => lote['id']?.toString() ?? '').where((id) => id.isNotEmpty).toSet();

    if (_lotesSelecionados.difference(lotesAtuais).isEmpty && lotesAtuais.difference(_lotesSelecionados).isEmpty) {
      // Nenhuma mudança
      Navigator.pop(context);
      return;
    }

    // Confirmar ação se houver mudanças significativas
    if (_lotesSelecionados.isEmpty) {
      _showConfirmDialog(
        'Remover todos os lotes?',
        'Isso removerá todos os lotes associados a esta estação. '
            'Deseja continuar?',
        _executarAssociacao,
      );
    } else {
      _executarAssociacao();
    }
  }

  void _executarAssociacao() {
    context.read<ReproducaoBloc>().add(
          AssociarLotesEstacaoEvent(
            widget.estacaoMontaId,
            _lotesSelecionados.toList(),
          ),
        );
  }

  void _showConfirmDialog(String title, String content, VoidCallback onConfirm) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                onConfirm();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Confirmar'),
            ),
          ],
        );
      },
    );
  }
}
