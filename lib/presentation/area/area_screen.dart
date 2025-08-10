import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:agronexus/presentation/bloc/area/area_bloc.dart';
import 'package:agronexus/presentation/bloc/area/area_event.dart';
import 'package:agronexus/presentation/bloc/area/area_state.dart';
import 'package:agronexus/domain/models/area_entity.dart';
import 'package:go_router/go_router.dart';
import 'package:agronexus/config/routers/router.dart';

/// Tela de listagem de Áreas seguindo o padrão visual de [AnimalListScreen]
class AreaScreen extends StatelessWidget {
  const AreaScreen({super.key});

  @override
  Widget build(BuildContext context) => const _AreaListContent();
}

class _AreaListContent extends StatefulWidget {
  const _AreaListContent();
  @override
  State<_AreaListContent> createState() => _AreaListContentState();
}

class _AreaListContentState extends State<_AreaListContent> with WidgetsBindingObserver {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<AreaEntity>? _cachedAreas; // cache conforme instruções
  String _search = '';
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadAreas();
  }

  void _loadAreas() {
    context.read<AreaBloc>().add(const LoadAreasEvent());
    _initialized = true;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _initialized) {
      _loadAreas();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    setState(() => _search = value.trim().toLowerCase());
  }

  List<AreaEntity> _applyFilter(List<AreaEntity> areas) {
    if (_search.isEmpty) return areas;
    return areas.where((a) => a.nome.toLowerCase().contains(_search) || a.tipo.toLowerCase().contains(_search)).toList();
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'em_uso':
        return Colors.teal;
      case 'descanso':
        return Colors.orangeAccent;
      case 'degradada':
        return Colors.redAccent;
      case 'reforma':
        return Colors.indigo;
      case 'disponivel':
        return Colors.green;
      default:
        return Colors.blueGrey;
    }
  }

  String _statusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'em_uso':
        return 'Em Uso';
      case 'descanso':
        return 'Em Descanso';
      case 'degradada':
        return 'Degradada';
      case 'reforma':
        return 'Em Reforma';
      case 'disponivel':
        return 'Disponível';
      default:
        return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Áreas'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: RefreshIndicator(
        onRefresh: () async => _loadAreas(),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Pesquisar áreas...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            _onSearchChanged('');
                          },
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onChanged: _onSearchChanged,
              ),
            ),
            Expanded(
              child: BlocListener<AreaBloc, AreaState>(
                listener: (context, state) {
                  if (state is AreasLoaded) {
                    _cachedAreas = state.areas;
                  }
                  if (state is AreaCreated || state is AreaUpdated || state is AreaDeleted) {
                    // Recarrega lista mantendo cache até novos dados
                    _loadAreas();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Operação realizada com sucesso!')),
                    );
                  }
                  if (state is AreaError) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(state.message)),
                    );
                  }
                },
                child: BlocBuilder<AreaBloc, AreaState>(
                  builder: (context, state) {
                    if (state is AreaLoading && _cachedAreas == null) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final areas = _applyFilter(_cachedAreas ?? []);

                    if (state is AreaError && _cachedAreas == null) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.error, size: 64, color: Colors.red),
                            const SizedBox(height: 16),
                            Text(
                              state.message,
                              style: const TextStyle(fontSize: 16),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _loadAreas,
                              child: const Text('Tentar novamente'),
                            ),
                          ],
                        ),
                      );
                    }

                    if (areas.isEmpty) {
                      return const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.map, size: 64, color: Colors.grey),
                            SizedBox(height: 16),
                            Text(
                              'Nenhuma área encontrada',
                              style: TextStyle(fontSize: 16, color: Colors.grey),
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.builder(
                      controller: _scrollController,
                      itemCount: areas.length,
                      itemBuilder: (context, index) => _buildAreaCard(areas[index]),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final created = await context.push(AgroNexusRouter.areas.addPath);
          if (created == true) {
            _loadAreas();
          }
        },
        backgroundColor: Colors.green,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildAreaCard(AreaEntity area) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.green.shade700,
          child: const Icon(Icons.map, color: Colors.white),
        ),
        title: Text(area.nome, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Tipo: ${area.tipo}'),
            Text('Tamanho: ${area.tamanhoHa.toStringAsFixed(2)} ha'),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _statusColor(area.status),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(_statusLabel(area.status), style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(width: 4),
            PopupMenuButton<String>(
              onSelected: (value) {
                switch (value) {
                  case 'editar':
                    context.push(AgroNexusRouter.areas.editPath, extra: area).then((updated) {
                      if (updated == true) {
                        _loadAreas();
                      }
                    });
                    break;
                  case 'excluir':
                    _confirmDelete(area);
                    break;
                }
              },
              itemBuilder: (context) => const [
                PopupMenuItem(value: 'editar', child: Text('Editar')),
                PopupMenuItem(value: 'excluir', child: Text('Excluir')),
              ],
              child: const Icon(Icons.more_vert),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(AreaEntity area) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(children: [Icon(Icons.warning, color: Colors.orange), SizedBox(width: 8), Text('Confirmar Exclusão')]),
        content: Text('Excluir área ${area.nome}? Esta ação não pode ser desfeita.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<AreaBloc>().add(DeleteAreaEvent(area.id!));
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }
}
