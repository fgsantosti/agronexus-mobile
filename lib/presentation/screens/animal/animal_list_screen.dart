import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:agronexus/presentation/bloc/animal/animal_bloc.dart';
import 'package:agronexus/presentation/bloc/animal/animal_event.dart';
import 'package:agronexus/presentation/bloc/animal/animal_state.dart';
import 'package:agronexus/domain/models/animal_entity.dart';
import 'package:agronexus/presentation/screens/animal/animal_form_screen.dart';
import 'package:agronexus/presentation/screens/animal/animal_detail_screen.dart';
import 'package:agronexus/config/inject_dependencies.dart';

class AnimalListScreen extends StatelessWidget {
  const AnimalListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AnimalBloc>(
      create: (context) => getIt<AnimalBloc>(),
      child: const _AnimalListContent(),
    );
  }
}

class _AnimalListContent extends StatefulWidget {
  const _AnimalListContent();

  @override
  State<_AnimalListContent> createState() => _AnimalListContentState();
}

class _AnimalListContentState extends State<_AnimalListContent> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();

    // Aguardar o próximo frame para garantir que o BLoC está pronto
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<AnimalBloc>().add(const LoadAnimaisEvent());
      }
    });

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent * 0.8) {
        if (mounted) {
          context.read<AnimalBloc>().add(const NextPageAnimaisEvent());
        }
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearch(String query) {
    context.read<AnimalBloc>().add(LoadAnimaisEvent(search: query));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Animais'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.of(context)
                  .push(
                MaterialPageRoute(
                  builder: (context) => const AnimalFormScreen(),
                ),
              )
                  .then((_) {
                // Recarregar lista após voltar do cadastro
                context.read<AnimalBloc>().add(const LoadAnimaisEvent());
              });
            },
          ),
        ],
      ),
      body: Column(
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
            child: BlocBuilder<AnimalBloc, AnimalState>(
              builder: (context, state) {
                if (state is AnimalLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is AnimalError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error, size: 64, color: Colors.red),
                        const SizedBox(height: 16),
                        Text(
                          state.message,
                          style: const TextStyle(fontSize: 16),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            context.read<AnimalBloc>().add(const LoadAnimaisEvent());
                          },
                          child: const Text('Tentar novamente'),
                        ),
                      ],
                    ),
                  );
                }

                if (state is AnimaisLoaded) {
                  if (state.animais.isEmpty) {
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
                    itemCount: state.animais.length + (state.hasMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == state.animais.length) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }

                      final animal = state.animais[index];
                      return _buildAnimalCard(animal);
                    },
                  );
                }

                return const SizedBox.shrink();
              },
            ),
          ),
        ],
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
            Text('Categoria: ${animal.categoria}'),
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
            const Icon(Icons.arrow_forward_ios),
          ],
        ),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => AnimalDetailScreen(animalId: animal.id!),
            ),
          );
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
}
