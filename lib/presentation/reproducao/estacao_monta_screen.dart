import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:agronexus/presentation/bloc/reproducao/reproducao_bloc.dart';
import 'package:agronexus/presentation/bloc/reproducao/reproducao_event.dart';
import 'package:agronexus/presentation/bloc/reproducao/reproducao_state.dart';
import 'package:agronexus/presentation/bloc/propriedade/propriedade_bloc_new.dart';
import 'package:agronexus/presentation/bloc/propriedade/propriedade_event_new.dart';
import 'package:agronexus/domain/models/reproducao_entity.dart';
import 'package:agronexus/presentation/reproducao/cadastro_estacao_monta_screen.dart';
import 'package:agronexus/presentation/reproducao/estacao_monta_detalhe_screen.dart';
import 'package:agronexus/config/inject_dependencies.dart';
import 'package:intl/intl.dart';

class EstacaoMontaScreen extends StatefulWidget {
  const EstacaoMontaScreen({super.key});

  @override
  State<EstacaoMontaScreen> createState() => _EstacaoMontaScreenState();
}

class _EstacaoMontaScreenState extends State<EstacaoMontaScreen> {
  final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');
  bool _mostrarApenasAtivas = true;

  @override
  void initState() {
    super.initState();
    _loadEstacoes();
  }

  void _loadEstacoes() {
    context.read<ReproducaoBloc>().add(LoadEstacoesMotaEvent(
          ativa: _mostrarApenasAtivas ? true : null,
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<ReproducaoBloc, ReproducaoState>(
        listener: (context, state) {
          if (state is EstacaoMontaCreated || state is EstacaoMontaUpdated || state is EstacaoMontaDeleted) {
            _loadEstacoes();
          }
        },
        child: RefreshIndicator(
          onRefresh: () async => _loadEstacoes(),
          child: BlocBuilder<ReproducaoBloc, ReproducaoState>(
            builder: (context, state) {
              if (state is EstacoesMotaLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state is ReproducaoError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 64, color: Colors.red.shade400),
                      const SizedBox(height: 16),
                      Text(
                        'Erro ao carregar estações',
                        style: TextStyle(fontSize: 18, color: Colors.red.shade400),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        state.message,
                        style: TextStyle(color: Colors.grey.shade600),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadEstacoes,
                        child: const Text('Tentar Novamente'),
                      ),
                    ],
                  ),
                );
              }

              if (state is EstacoesMotaLoaded) {
                if (state.estacoes.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.calendar_today_outlined, size: 64, color: Colors.grey.shade400),
                        const SizedBox(height: 16),
                        Text(
                          'Nenhuma estação de monta encontrada',
                          style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Crie a primeira estação de monta',
                          style: TextStyle(color: Colors.grey.shade500),
                        ),
                      ],
                    ),
                  );
                }

                return Column(
                  children: [
                    _buildFilterHeader(),
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: state.estacoes.length,
                        itemBuilder: (context, index) {
                          final estacao = state.estacoes[index];
                          return _buildEstacaoCard(estacao);
                        },
                      ),
                    ),
                  ],
                );
              }

              return const Center(child: Text('Carregando...'));
            },
          ),
        ),
      ),
      floatingActionButton: BlocBuilder<ReproducaoBloc, ReproducaoState>(
        builder: (context, state) {
          return FloatingActionButton(
            heroTag: 'fabEstacaoMonta',
            backgroundColor: Colors.blue.shade400,
            onPressed: () {
              _showAddEstacaoDialog(context);
            },
            child: const Icon(Icons.add, color: Colors.white),
          );
        },
      ),
    );
  }

  Widget _buildFilterHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        children: [
          const Icon(Icons.filter_list, color: Colors.grey),
          const SizedBox(width: 8),
          const Text(
            'Filtros:',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Row(
              children: [
                FilterChip(
                  label: const Text('Apenas Ativas'),
                  selected: _mostrarApenasAtivas,
                  onSelected: (selected) {
                    setState(() {
                      _mostrarApenasAtivas = selected;
                    });
                    _loadEstacoes();
                  },
                  selectedColor: Colors.blue.shade100,
                  checkmarkColor: Colors.blue.shade600,
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text('Todas'),
                  selected: !_mostrarApenasAtivas,
                  onSelected: (selected) {
                    setState(() {
                      _mostrarApenasAtivas = !selected;
                    });
                    _loadEstacoes();
                  },
                  selectedColor: Colors.grey.shade200,
                  checkmarkColor: Colors.grey.shade600,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEstacaoCard(EstacaoMontaEntity estacao) {
    final isAtiva = estacao.ativa;
    final agora = DateTime.now();
    final estaEmAndamento = agora.isAfter(estacao.dataInicio) && agora.isBefore(estacao.dataFim);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          _showEstacaoDetails(estacao);
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: estaEmAndamento ? Colors.green : (isAtiva ? Colors.blue : Colors.grey),
                    child: Icon(
                      estaEmAndamento ? Icons.play_arrow : Icons.calendar_today,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          estacao.nome,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          estaEmAndamento ? 'Em andamento' : (isAtiva ? 'Ativa' : 'Inativa'),
                          style: TextStyle(
                            color: estaEmAndamento ? Colors.green : (isAtiva ? Colors.blue : Colors.grey),
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${_dateFormat.format(estacao.dataInicio)} -',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        _dateFormat.format(estacao.dataFim),
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.female, size: 16, color: Colors.grey.shade600),
                  const SizedBox(width: 4),
                  Text(
                    'Fêmeas: ${estacao.totalFemeas}',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Icon(Icons.trending_up, size: 16, color: Colors.grey.shade600),
                  const SizedBox(width: 4),
                  Text(
                    'Taxa Prenhez: ${estacao.taxaPrenhez.toStringAsFixed(1)}%',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showEstacaoDetails(EstacaoMontaEntity estacao) {
    final reproductionBloc = context.read<ReproducaoBloc>();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BlocProvider.value(
          value: reproductionBloc,
          child: EstacaoMontaDetalheScreen(
            estacaoMontaId: estacao.id,
            estacao: estacao,
          ),
        ),
      ),
    ).then((_) => _loadEstacoes()); // Recarregar ao voltar
  }

  void _showAddEstacaoDialog(BuildContext context) async {
    final reproductionBloc = context.read<ReproducaoBloc>();

    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => MultiBlocProvider(
          providers: [
            BlocProvider.value(value: reproductionBloc),
            BlocProvider(create: (context) => getIt<PropriedadeBlocNew>()..add(const LoadPropriedadesEvent())),
          ],
          child: const CadastroEstacaoMontaScreen(),
        ),
      ),
    );

    if (result == true) {
      _loadEstacoes();
    }
  }
}
