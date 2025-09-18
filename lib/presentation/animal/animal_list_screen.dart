import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../domain/models/animal_entity.dart';
import '../bloc/animal/animal_bloc.dart';
import '../bloc/animal/animal_event.dart';
import '../bloc/animal/animal_state.dart';
import 'package:agronexus/presentation/widgets/entity_action_menu.dart';
import 'package:agronexus/presentation/widgets/standard_app_bar.dart';

class AnimalListScreen extends StatelessWidget {
  const AnimalListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _AnimalListContent();
  }
}

class _AnimalListContent extends StatefulWidget {
  const _AnimalListContent();

  @override
  State<_AnimalListContent> createState() => _AnimalListContentState();
}

class _AnimalListContentState extends State<_AnimalListContent> with WidgetsBindingObserver {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  // Cache local dos dados conforme padrão das instruções
  List<AnimalEntity>? _cachedAnimais;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _scrollController.addListener(_scrollListener);
    _loadAnimais();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Recarregar quando app volta para foreground
    if (state == AppLifecycleState.resumed) {
      _loadAnimais();
    }
  }

  void _loadAnimais() {
    context.read<AnimalBloc>().add(const LoadAnimaisEvent());
  }

  void _scrollListener() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent * 0.8) {
      if (mounted) {
        context.read<AnimalBloc>().add(const NextPageAnimaisEvent());
      }
    }
  }

  void _onSearch(String query) {
    context.read<AnimalBloc>().add(LoadAnimaisEvent(search: query));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildStandardAppBar(
        title: 'Animais',
        showBack: false,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onSelected: (value) {
              switch (value) {
                case 'import':
                  context.go('/animais/importar');
                  break;
                case 'export':
                  context.go('/animais/exportar');
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'import',
                child: Row(
                  children: [
                    Icon(Icons.file_upload),
                    SizedBox(width: 8),
                    Text('Importar Excel'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'export',
                child: Row(
                  children: [
                    Icon(Icons.file_download),
                    SizedBox(width: 8),
                    Text('Exportar Excel'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => _loadAnimais(),
        child: Column(
          children: [
            // Barra de pesquisa
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Pesquisar animais...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            _onSearch('');
                          },
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onChanged: _onSearch,
              ),
            ),

            // Lista de animais
            Expanded(
              child: BlocListener<AnimalBloc, AnimalState>(
                listener: (context, state) {
                  // Atualizar cache quando dados são carregados
                  if (state is AnimaisLoaded) {
                    _cachedAnimais = state.animais;
                  }

                  if (state is AnimalCreated) {
                    // Adiciona novo animal no topo (se não existir) sem refetch
                    _cachedAnimais ??= [];
                    final exists = _cachedAnimais!.any((a) => a.id == state.animal.id);
                    if (!exists) {
                      _cachedAnimais = [state.animal, ..._cachedAnimais!];
                    }
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Animal cadastrado com sucesso!')),
                    );
                    setState(() {});
                  }

                  if (state is AnimalUpdated) {
                    if (_cachedAnimais != null) {
                      final idx = _cachedAnimais!.indexWhere((a) => a.id == state.animal.id);
                      if (idx != -1) {
                        _cachedAnimais![idx] = state.animal;
                      }
                    }
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Animal atualizado com sucesso!')),
                    );
                    setState(() {});
                  }

                  if (state is AnimalDeleted) {
                    _cachedAnimais?.removeWhere((a) => a.id == state.id);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Animal excluído com sucesso!')),
                    );
                    setState(() {});
                  }

                  if (state is AnimalError) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(state.message)),
                    );
                  }
                },
                child: BlocBuilder<AnimalBloc, AnimalState>(
                  builder: (context, state) {
                    // Mostrar loading apenas se não há cache
                    if (state is AnimalLoading && _cachedAnimais == null) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    // Usar dados do cache ou lista vazia
                    final animais = _cachedAnimais ?? [];

                    if (state is AnimalError && _cachedAnimais == null) {
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
                              onPressed: _loadAnimais,
                              child: const Text('Tentar novamente'),
                            ),
                          ],
                        ),
                      );
                    }

                    if (animais.isEmpty) {
                      return const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.pets, size: 64, color: Colors.grey),
                            SizedBox(height: 16),
                            Text(
                              'Nenhum animal encontrado',
                              style: TextStyle(fontSize: 16, color: Colors.grey),
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.builder(
                      controller: _scrollController,
                      itemCount: animais.length + ((state is AnimaisLoaded && state.hasMore) ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == animais.length) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(16.0),
                              child: CircularProgressIndicator(),
                            ),
                          );
                        }

                        final animal = animais[index];
                        return _buildAnimalCard(animal);
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'fabAnimais',
        onPressed: () {
          // Navega para cadastro e aguarda retorno do animal criado para atualização imediata
          context.push('/animais/cadastro').then((value) {
            if (value is AnimalEntity) {
              setState(() {
                _cachedAnimais ??= [];
                final exists = _cachedAnimais!.any((a) => a.id == value.id);
                if (!exists) {
                  _cachedAnimais = [value, ..._cachedAnimais!];
                }
              });
            }
          });
        },
        backgroundColor: Colors.green,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildAnimalCard(AnimalEntity animal) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: animal.sexo == Sexo.macho ? Colors.blue : Colors.pink,
          child: Icon(
            animal.sexo == Sexo.macho ? Icons.male : Icons.female,
            color: Colors.white,
          ),
        ),
        title: Text(
          animal.identificacaoUnica,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (animal.nomeRegistro != null && animal.nomeRegistro!.isNotEmpty) Text('Nome: ${animal.nomeRegistro}'),
            Text('Categoria: ${animal.categoria.label}'),
            Text('Status: ${animal.status.label}'),
            if (animal.especie != null) Text('Espécie: ${animal.especie!.nomeDisplay}'),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _getStatusColor(animal.status),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                animal.status.label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 8),
            EntityActionMenu(
              onEdit: () => context.push('/animais/editar/${animal.id}').then((value) {
                if (value is AnimalEntity && _cachedAnimais != null) {
                  final idx = _cachedAnimais!.indexWhere((a) => a.id == value.id);
                  if (idx != -1) {
                    setState(() => _cachedAnimais![idx] = value);
                  }
                }
              }),
              onDelete: () => _showDeleteConfirmDialog(animal),
            ),
          ],
        ),
        onTap: () {
          context.go('/animais/detalhes/${animal.id}');
        },
      ),
    );
  }

  Color _getStatusColor(StatusAnimal status) {
    switch (status) {
      case StatusAnimal.ativo:
        return Colors.green;
      case StatusAnimal.vendido:
        return Colors.blue;
      case StatusAnimal.morto:
        return Colors.red;
      case StatusAnimal.descartado:
        return Colors.orange;
    }
  }

  void _showDeleteConfirmDialog(AnimalEntity animal) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Excluir Animal'),
        content: Text('Confirma excluir o animal ${animal.identificacaoUnica}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      // Dispara evento real de exclusão
      context.read<AnimalBloc>().add(DeleteAnimalEvent(animal.id!));
    }
  }
}
