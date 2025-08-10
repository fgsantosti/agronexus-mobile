import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:agronexus/presentation/bloc/lote/lote_bloc.dart';
import 'package:agronexus/presentation/bloc/lote/lote_events.dart';
import 'package:agronexus/presentation/bloc/lote/lote_state.dart';
import 'package:agronexus/domain/models/lote_entity.dart';
import 'package:agronexus/presentation/lote/cadastro_lote_screen.dart';
import 'package:agronexus/presentation/lote/editar_lote_screen.dart';
import 'package:agronexus/presentation/lote/detalhes_lote_screen.dart';
import 'package:agronexus/presentation/bloc/propriedade/propriedade_bloc_new.dart';
import 'package:agronexus/presentation/bloc/propriedade/propriedade_event_new.dart';
import 'package:agronexus/presentation/bloc/area/area_bloc.dart';
import 'package:agronexus/config/inject_dependencies.dart';

class LoteScreen extends StatefulWidget {
  const LoteScreen({super.key});

  @override
  State<LoteScreen> createState() => _LoteScreenState();
}

class _LoteScreenState extends State<LoteScreen> {
  bool _isInitialized = false;
  List<LoteEntity>? _cachedLotes;

  @override
  void initState() {
    super.initState();
    _loadLotes();
  }

  void _loadLotes() {
    context.read<LoteBloc>().add(const LoadLotesEvent());
    _isInitialized = true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lotes'),
        backgroundColor: Colors.green.shade600,
        foregroundColor: Colors.white,
      ),
      body: RefreshIndicator(
        onRefresh: () async => _loadLotes(),
        child: BlocListener<LoteBloc, LoteState>(
          listener: (context, state) {
            if (state is LotesLoaded) {
              _cachedLotes = state.lotes;
            } else if (state is LoteDeleted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Lote excluído com sucesso!'),
                  backgroundColor: Colors.green,
                ),
              );
              _loadLotes();
            } else if (state is LoteCreated || state is LoteUpdated) {
              _loadLotes();
            } else if (state is LoteError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Erro: ${state.message}'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          child: BlocBuilder<LoteBloc, LoteState>(
            builder: (context, state) {
              if (!_isInitialized && state is! LoteLoading) {
                _loadLotes();
                return const Center(child: CircularProgressIndicator());
              }

              if (state is LoteError && _cachedLotes == null) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 64, color: Colors.grey.shade400),
                      const SizedBox(height: 16),
                      Text(
                        'Erro ao carregar lotes',
                        style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        state.message,
                        style: TextStyle(color: Colors.grey.shade500),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadLotes,
                        child: const Text('Tentar Novamente'),
                      ),
                    ],
                  ),
                );
              }

              List<LoteEntity>? lotesToShow;
              if (state is LotesLoaded) {
                lotesToShow = state.lotes;
              } else if (_cachedLotes != null) {
                lotesToShow = _cachedLotes;
              }

              if (lotesToShow != null) {
                if (lotesToShow.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.grid_view_outlined, size: 64, color: Colors.grey.shade400),
                        const SizedBox(height: 16),
                        Text(
                          'Nenhum lote encontrado',
                          style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Cadastre o primeiro lote',
                          style: TextStyle(color: Colors.grey.shade500),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: lotesToShow.length,
                  itemBuilder: (context, index) {
                    final lote = lotesToShow![index];
                    return _buildLoteCard(lote);
                  },
                );
              }

              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Carregando lotes...'),
                  ],
                ),
              );
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green.shade600,
        onPressed: () => _navegarParaCadastro(),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildLoteCard(LoteEntity lote) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _mostrarDetalhes(lote),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.grid_view, color: Colors.green.shade600, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          lote.nome,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (lote.descricao.isNotEmpty)
                          Text(
                            lote.descricao,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        if (lote.areaAtual != null || lote.areaAtualId != null) ...[
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(Icons.map, size: 14, color: Colors.green.shade400),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  lote.areaAtual != null ? 'Área: ${lote.areaAtual!.nome}' : 'Área: ${lote.areaAtualId}',
                                  style: TextStyle(fontSize: 11, color: Colors.grey.shade700),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (value) => _executarAcao(value, lote),
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'detalhes',
                        child: Row(
                          children: [
                            Icon(Icons.visibility, size: 20),
                            SizedBox(width: 8),
                            Text('Ver Detalhes'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'editar',
                        child: Row(
                          children: [
                            Icon(Icons.edit, size: 20),
                            SizedBox(width: 8),
                            Text('Editar'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'excluir',
                        child: Row(
                          children: [
                            Icon(Icons.delete, size: 20, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Excluir', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildInfoChip(
                      'Animais',
                      '${lote.totalAnimais}',
                      Icons.pets,
                      Colors.orange,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildInfoChip(
                      'Status',
                      lote.ativo ? 'Ativo' : 'Inativo',
                      Icons.circle,
                      lote.ativo ? Colors.green : Colors.red,
                    ),
                  ),
                ],
              ),
              if (lote.aptidao != null || lote.finalidade != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    if (lote.aptidao != null)
                      Expanded(
                        child: _buildInfoChip(
                          'Aptidão',
                          _getAptidaoDisplay(lote.aptidao!),
                          Icons.star,
                          Colors.blue,
                        ),
                      ),
                    if (lote.aptidao != null && lote.finalidade != null) const SizedBox(width: 8),
                    if (lote.finalidade != null)
                      Expanded(
                        child: _buildInfoChip(
                          'Finalidade',
                          _getFinalidadeDisplay(lote.finalidade!),
                          Icons.flag,
                          Colors.purple,
                        ),
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 10,
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 11,
                    color: color,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getAptidaoDisplay(String aptidao) {
    switch (aptidao) {
      case 'corte':
        return 'Corte';
      case 'leite':
        return 'Leite';
      case 'dupla_aptidao':
        return 'Dupla Aptidão';
      default:
        return aptidao;
    }
  }

  String _getFinalidadeDisplay(String finalidade) {
    switch (finalidade) {
      case 'cria':
        return 'Cria';
      case 'recria':
        return 'Recria';
      case 'engorda':
        return 'Engorda';
      default:
        return finalidade;
    }
  }

  void _navegarParaCadastro() async {
    final loteBloc = context.read<LoteBloc>();
    final resultado = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => MultiBlocProvider(
          providers: [
            BlocProvider.value(value: loteBloc),
            BlocProvider(create: (context) => getIt<PropriedadeBlocNew>()..add(const LoadPropriedadesEvent())),
            BlocProvider(create: (context) => getIt<AreaBloc>()), // AreaBloc adicionado
          ],
          child: const CadastroLoteScreen(),
        ),
      ),
    );

    if (resultado == true || resultado == null) {
      _loadLotes();
    }
  }

  void _navegarParaEdicao(LoteEntity lote) async {
    final loteBloc = context.read<LoteBloc>();
    final resultado = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => MultiBlocProvider(
          providers: [
            BlocProvider.value(value: loteBloc),
            BlocProvider(create: (context) => getIt<PropriedadeBlocNew>()..add(const LoadPropriedadesEvent())),
            BlocProvider(create: (context) => getIt<AreaBloc>()), // AreaBloc adicionado
          ],
          child: EditarLoteScreen(lote: lote),
        ),
      ),
    );

    if (resultado == true) {
      _loadLotes();
    }
  }

  void _mostrarDetalhes(LoteEntity lote) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => DetalhesLoteScreen(lote: lote),
      ),
    );
  }

  void _executarAcao(String acao, LoteEntity lote) {
    switch (acao) {
      case 'detalhes':
        _mostrarDetalhes(lote);
        break;
      case 'editar':
        _navegarParaEdicao(lote);
        break;
      case 'excluir':
        _confirmarExclusao(lote);
        break;
    }
  }

  void _confirmarExclusao(LoteEntity lote) {
    final loteBloc = context.read<LoteBloc>();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Confirmar Exclusão'),
        content: Text(
          'Deseja realmente excluir o lote "${lote.nome}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              loteBloc.add(DeleteLoteEvent(lote.id!));
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }
}
