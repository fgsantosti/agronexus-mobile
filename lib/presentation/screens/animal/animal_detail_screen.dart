import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:agronexus/presentation/bloc/animal/animal_bloc.dart';
import 'package:agronexus/presentation/bloc/animal/animal_event.dart';
import 'package:agronexus/presentation/bloc/animal/animal_state.dart';
import 'package:agronexus/domain/models/animal_entity.dart';

class AnimalDetailScreen extends StatefulWidget {
  final String animalId;

  const AnimalDetailScreen({
    Key? key,
    required this.animalId,
  }) : super(key: key);

  @override
  State<AnimalDetailScreen> createState() => _AnimalDetailScreenState();
}

class _AnimalDetailScreenState extends State<AnimalDetailScreen> {
  @override
  void initState() {
    super.initState();
    context.read<AnimalBloc>().add(LoadAnimalDetailEvent(widget.animalId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes do Animal'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        actions: [
          BlocBuilder<AnimalBloc, AnimalState>(
            builder: (context, state) {
              if (state is AnimalDetailLoaded) {
                return PopupMenuButton<String>(
                  onSelected: (value) {
                    switch (value) {
                      case 'edit':
                        _editAnimal(state.animal);
                        break;
                      case 'delete':
                        _deleteAnimal(state.animal);
                        break;
                    }
                  },
                  itemBuilder: (BuildContext context) => [
                    const PopupMenuItem<String>(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit),
                          SizedBox(width: 8),
                          Text('Editar'),
                        ],
                      ),
                    ),
                    const PopupMenuItem<String>(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Excluir', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: BlocListener<AnimalBloc, AnimalState>(
        listener: (context, state) {
          if (state is AnimalDeleted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Animal excluído com sucesso'),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.of(context).pop();
          } else if (state is AnimalError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
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
                        context.read<AnimalBloc>().add(LoadAnimalDetailEvent(widget.animalId));
                      },
                      child: const Text('Tentar novamente'),
                    ),
                  ],
                ),
              );
            }

            if (state is AnimalDetailLoaded) {
              return _buildAnimalDetails(state.animal);
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildAnimalDetails(AnimalEntity animal) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cabeçalho principal
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: animal.sexo == Sexo.macho ? Colors.blue : Colors.pink,
                    child: Icon(
                      animal.sexo == Sexo.macho ? Icons.male : Icons.female,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          animal.identificacaoUnica,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (animal.nomeRegistro != null && animal.nomeRegistro!.isNotEmpty)
                          Text(
                            animal.nomeRegistro!,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                          ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: _getStatusColor(animal.status),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            animal.status.label,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Informações básicas
          _buildInfoSection(
            'Informações Básicas',
            [
              _buildInfoRow('Sexo', animal.sexo.label),
              _buildInfoRow('Data de Nascimento', animal.dataNascimento),
              _buildInfoRow('Categoria', animal.categoria),
              if (animal.especie != null) _buildInfoRow('Espécie', animal.especie!.nomeDisplay),
              if (animal.raca != null) _buildInfoRow('Raça', animal.raca!.nome),
            ],
          ),

          // Propriedade e Lote
          if (animal.propriedade != null || animal.loteAtual != null)
            _buildInfoSection(
              'Localização',
              [
                if (animal.propriedade != null) _buildInfoRow('Propriedade', animal.propriedade!.nome),
                if (animal.loteAtual != null) _buildInfoRow('Lote Atual', animal.loteAtual!.nome),
              ],
            ),

          // Genealogia
          if (animal.pai != null || animal.mae != null)
            _buildInfoSection(
              'Genealogia',
              [
                if (animal.pai != null) _buildInfoRow('Pai', animal.pai!.identificacaoUnica),
                if (animal.mae != null) _buildInfoRow('Mãe', animal.mae!.identificacaoUnica),
              ],
            ),

          // Dados comerciais
          if (animal.dataCompra != null || animal.dataVenda != null)
            _buildInfoSection(
              'Dados Comerciais',
              [
                if (animal.dataCompra != null) _buildInfoRow('Data de Compra', animal.dataCompra!),
                if (animal.valorCompra != null) _buildInfoRow('Valor de Compra', 'R\$ ${animal.valorCompra!.toStringAsFixed(2)}'),
                if (animal.origem != null && animal.origem!.isNotEmpty) _buildInfoRow('Origem', animal.origem!),
                if (animal.dataVenda != null) _buildInfoRow('Data de Venda', animal.dataVenda!),
                if (animal.valorVenda != null) _buildInfoRow('Valor de Venda', 'R\$ ${animal.valorVenda!.toStringAsFixed(2)}'),
                if (animal.destino != null && animal.destino!.isNotEmpty) _buildInfoRow('Destino', animal.destino!),
              ],
            ),

          // Dados de morte (se aplicável)
          if (animal.dataMorte != null)
            _buildInfoSection(
              'Dados de Morte',
              [
                _buildInfoRow('Data da Morte', animal.dataMorte!),
                if (animal.causaMorte != null && animal.causaMorte!.isNotEmpty) _buildInfoRow('Causa da Morte', animal.causaMorte!),
              ],
            ),

          // Observações
          if (animal.observacoes != null && animal.observacoes!.isNotEmpty)
            _buildInfoSection(
              'Observações',
              [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    animal.observacoes!,
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(String title, List<Widget> children) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
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

  void _editAnimal(AnimalEntity animal) {
    // TODO: Implementar navegação para tela de edição
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Funcionalidade de edição será implementada'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _deleteAnimal(AnimalEntity animal) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar Exclusão'),
          content: Text('Tem certeza que deseja excluir o animal ${animal.identificacaoUnica}?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () {
                Navigator.of(context).pop();
                context.read<AnimalBloc>().add(DeleteAnimalEvent(animal.id!));
              },
              child: const Text('Excluir', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }
}
