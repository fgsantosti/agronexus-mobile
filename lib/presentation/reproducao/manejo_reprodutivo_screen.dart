import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:agronexus/presentation/bloc/reproducao/reproducao_bloc.dart';
import 'package:agronexus/presentation/bloc/reproducao/reproducao_event.dart';
import 'package:agronexus/presentation/bloc/reproducao/reproducao_state.dart';
import 'package:agronexus/presentation/reproducao/inseminacao_screen.dart';
import 'package:agronexus/presentation/reproducao/diagnostico_gestacao_screen.dart';
import 'package:agronexus/presentation/reproducao/parto_screen.dart';
import 'package:agronexus/presentation/reproducao/estacao_monta_screen.dart';
import 'package:agronexus/presentation/reproducao/protocolo_iatf_screen.dart';
import 'package:agronexus/presentation/reproducao/relatorios_screen.dart';
import 'package:agronexus/presentation/widgets/standard_app_bar.dart';

class ManejoReprodutivoScreen extends StatefulWidget {
  const ManejoReprodutivoScreen({super.key});

  @override
  State<ManejoReprodutivoScreen> createState() => _ManejoReprodutivoScreenState();
}

class _ManejoReprodutivoScreenState extends State<ManejoReprodutivoScreen> with TickerProviderStateMixin, WidgetsBindingObserver {
  late TabController _tabController;
  Map<String, dynamic>? _resumoData; // Armazenar o resumo localmente

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
    WidgetsBinding.instance.addObserver(this);

    // Carregar resumo ao inicializar apenas se não existe ainda
    if (_resumoData == null) {
      context.read<ReproducaoBloc>().add(LoadResumoReproducaoEvent());
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _tabController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    // Recarregar dados quando o app volta para o foreground
    if (state == AppLifecycleState.resumed) {
      _recarregarDadosSeNecessario();
    }
  }

  void _recarregarDadosSeNecessario() {
    // Recarregar resumo apenas se os dados estão muito antigos ou se não existem
    if (_resumoData == null) {
      context.read<ReproducaoBloc>().add(LoadResumoReproducaoEvent());
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true, // Permite que a tela seja fechada normalmente
      onPopInvokedWithResult: (didPop, result) {
        // Log para debug
        print('DEBUG NAVEGAÇÃO - PopScope no ManejoReprodutivoScreen invocado: didPop=$didPop');

        // Se o pop foi bem sucedido, não precisamos fazer nada adicional
        if (didPop) {
          print('DEBUG NAVEGAÇÃO - Pop foi bem sucedido, voltando para tela anterior');
        }
      },
      child: Scaffold(
        appBar: buildStandardAppBar(
          title: 'Manejo Reprodutivo',
          showBack: true,
          bottom: TabBar(
            controller: _tabController,
            isScrollable: true,
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            labelStyle: const TextStyle(fontWeight: FontWeight.bold),
            tabs: const [
              Tab(icon: Icon(Icons.favorite), text: 'Inseminações'),
              Tab(icon: Icon(Icons.medical_services), text: 'Diagnósticos'),
              Tab(icon: Icon(Icons.child_care), text: 'Partos'),
              Tab(icon: Icon(Icons.calendar_today), text: 'Est. Monta'),
              Tab(icon: Icon(Icons.science), text: 'IATF'),
              Tab(icon: Icon(Icons.assessment), text: 'Relatórios'),
            ],
          ),
        ),
        body: Column(
          children: [
            // Card com resumo geral
            _buildResumoCard(),
            // Conteúdo das abas
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  InseminacaoScreen(),
                  DiagnosticoGestacaoScreen(),
                  PartoScreen(),
                  EstacaoMontaScreen(),
                  ProtocoloIATFScreen(),
                  RelatoriosScreen(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResumoCard() {
    return BlocListener<ReproducaoBloc, ReproducaoState>(
      listener: (context, state) {
        // Quando o resumo for carregado, armazenar localmente
        if (state is ResumoReproducaoLoaded) {
          setState(() {
            _resumoData = state.resumo;
          });
        }
        // Quando uma operação de inseminação for concluída, atualizar o resumo
        else if (state is InseminacaoCreated || state is InseminacaoUpdated || state is InseminacaoDeleted) {
          // Aguardar um pouco e recarregar o resumo
          Future.delayed(const Duration(milliseconds: 1000), () {
            if (mounted) {
              context.read<ReproducaoBloc>().add(LoadResumoReproducaoEvent());
            }
          });
        }
      },
      child: BlocBuilder<ReproducaoBloc, ReproducaoState>(
        builder: (context, state) {
          // Mostrar loading apenas se não temos dados salvos E é loading do resumo
          if (state is ResumoReproducaoLoading && _resumoData == null) {
            return Container(
              margin: const EdgeInsets.all(16),
              child: const Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
              ),
            );
          }

          // Usar dados salvos ou do estado atual
          Map<String, dynamic>? resumoToShow;
          if (state is ResumoReproducaoLoaded) {
            resumoToShow = state.resumo;
          } else if (_resumoData != null) {
            resumoToShow = _resumoData;
          }

          if (resumoToShow != null) {
            return Container(
              margin: const EdgeInsets.all(16),
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.analytics, color: Colors.pink.shade400),
                          const SizedBox(width: 8),
                          const Text(
                            'Resumo do Ano',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildStatCard(
                              'Inseminações',
                              resumoToShow['inseminacoes']?.toString() ?? '0',
                              Icons.favorite,
                              Colors.red,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildStatCard(
                              'Prenhes',
                              resumoToShow['diagnosticos_positivos']?.toString() ?? '0',
                              Icons.medical_services,
                              Colors.orange,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildStatCard(
                              'Partos',
                              resumoToShow['partos_vivos']?.toString() ?? '0',
                              Icons.child_care,
                              Colors.green,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildStatCard(
                              'Taxa Prenhez',
                              '${resumoToShow['taxa_prenhez'] ?? 0}%',
                              Icons.trending_up,
                              Colors.blue,
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

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 10,
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
