import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:agronexus/presentation/bloc/reproducao/reproducao_bloc.dart';
import 'package:agronexus/presentation/bloc/reproducao/reproducao_event.dart';
import 'package:agronexus/presentation/bloc/reproducao/reproducao_state.dart';
import 'package:agronexus/presentation/bloc/animal/animal_bloc.dart';
import 'package:agronexus/domain/models/reproducao_entity.dart';
import 'package:agronexus/domain/models/animal_entity.dart';
import 'package:agronexus/presentation/reproducao/selecionar_lotes_screen.dart';
import 'package:agronexus/presentation/reproducao/cadastro_inseminacao_screen.dart';
import 'package:agronexus/presentation/reproducao/cadastro_diagnostico_gestacao_screen.dart';
import 'package:agronexus/presentation/reproducao/cadastro_parto_screen.dart';
import 'package:agronexus/presentation/reproducao/configurar_padroes_estacao_screen.dart';
import 'package:agronexus/presentation/widgets/standard_app_bar.dart';
import 'package:agronexus/config/inject_dependencies.dart';
import 'package:intl/intl.dart';

class EstacaoMontaDetalheScreen extends StatefulWidget {
  final String estacaoMontaId;
  final EstacaoMontaEntity? estacao;

  const EstacaoMontaDetalheScreen({
    super.key,
    required this.estacaoMontaId,
    this.estacao,
  });

  @override
  State<EstacaoMontaDetalheScreen> createState() => _EstacaoMontaDetalheScreenState();
}

class _EstacaoMontaDetalheScreenState extends State<EstacaoMontaDetalheScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');

  EstacaoMontaEntity? _estacao;
  List<dynamic> _lotes = [];
  Map<String, dynamic>? _dashboard;

  // Cache local para as abas
  List<InseminacaoEntity>? _cachedInseminacoes;
  List<DiagnosticoGestacaoEntity>? _cachedDiagnosticos;
  List<PartoEntity>? _cachedPartos;

  // Configurações padrão da estação
  TipoInseminacao? _tipoInseminacaoPadrao;
  ProtocoloIATFEntity? _protocoloPadrao;
  AnimalEntity? _reprodutorPadrao;
  String? _semenUtilizadoPadrao;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _estacao = widget.estacao;

    // Inicializar configurações padrão demonstrativas
    _tipoInseminacaoPadrao = TipoInseminacao.iatf;
    _semenUtilizadoPadrao = "Sêmen Premium IATF";

    print('DEBUG INIT: Configurações iniciais:');
    print('- Tipo: ${_tipoInseminacaoPadrao?.label ?? "Nenhum"}');
    print('- Reprodutor: ${_reprodutorPadrao?.identificacaoUnica ?? "Nenhum"}');
    print('- Protocolo: ${_protocoloPadrao?.nome ?? "Nenhum"}');
    print('- Sêmen: ${_semenUtilizadoPadrao ?? "Nenhum"}');

    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadData() {
    context.read<ReproducaoBloc>().add(LoadEstacaoMontaDetalheEvent(widget.estacaoMontaId));
    context.read<ReproducaoBloc>().add(LoadDashboardEstacaoEvent(widget.estacaoMontaId));
    // Carregar dados das abas
    _loadInseminacoes();
    _loadDiagnosticos();
    _loadPartos();
  }

  void _loadInseminacoes() {
    context.read<ReproducaoBloc>().add(LoadInseminacoesPorEstacaoEvent(widget.estacaoMontaId));
  }

  void _loadDiagnosticos() {
    context.read<ReproducaoBloc>().add(LoadDiagnosticosPorEstacaoEvent(widget.estacaoMontaId));
  }

  void _loadPartos() {
    context.read<ReproducaoBloc>().add(LoadPartosPorEstacaoEvent(widget.estacaoMontaId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildStandardAppBar(
        title: _estacao?.nome ?? 'Estação de Monta',
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          isScrollable: true,
          tabs: const [
            Tab(text: 'Dashboard', icon: Icon(Icons.analytics)),
            Tab(text: 'Lotes', icon: Icon(Icons.group_work)),
            Tab(text: 'Inseminação', icon: Icon(Icons.favorite)),
            Tab(text: 'Diagnóstico', icon: Icon(Icons.medical_services)),
            Tab(text: 'Partos', icon: Icon(Icons.child_care)),
          ],
        ),
      ),
      body: BlocListener<ReproducaoBloc, ReproducaoState>(
        listener: (context, state) {
          if (state is EstacaoMontaDetalheLoaded) {
            setState(() {
              _estacao = state.estacao;
              _lotes = state.lotes;
            });
          } else if (state is DashboardEstacaoLoaded) {
            setState(() {
              _dashboard = state.dashboard;
            });
          } else if (state is LotesAssociados) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
            _loadData(); // Recarregar dados após associar lotes
          } else if (state is InseminacoesLoaded) {
            setState(() {
              _cachedInseminacoes = state.inseminacoes;
            });
          } else if (state is InseminacaoCreated) {
            // Recarregar dados quando uma nova inseminação for criada
            _loadInseminacoes();
            _loadData(); // Recarregar dashboard também
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Inseminação cadastrada com sucesso!')),
            );
          } else if (state is InseminacaoUpdated) {
            // Recarregar dados quando uma inseminação for atualizada
            _loadInseminacoes();
            _loadData(); // Recarregar dashboard também
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Inseminação atualizada com sucesso!')),
            );
          } else if (state is InseminacaoDeleted) {
            // Recarregar dados quando uma inseminação for deletada
            _loadInseminacoes();
            _loadData(); // Recarregar dashboard também
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Inseminação excluída com sucesso!')),
            );
          } else if (state is DiagnosticosGestacaoLoaded) {
            setState(() {
              _cachedDiagnosticos = state.diagnosticos;
            });
          } else if (state is DiagnosticoGestacaoCreated) {
            // Recarregar dados quando um novo diagnóstico for criado
            _loadDiagnosticos();
            _loadData(); // Recarregar dashboard também
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Diagnóstico cadastrado com sucesso!')),
            );
          } else if (state is DiagnosticoGestacaoUpdated) {
            // Recarregar dados quando um diagnóstico for atualizado
            _loadDiagnosticos();
            _loadData(); // Recarregar dashboard também
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Diagnóstico atualizado com sucesso!')),
            );
          } else if (state is DiagnosticoGestacaoDeleted) {
            // Recarregar dados quando um diagnóstico for deletado
            _loadDiagnosticos();
            _loadData(); // Recarregar dashboard também
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Diagnóstico excluído com sucesso!')),
            );
          } else if (state is PartosLoaded) {
            setState(() {
              _cachedPartos = state.partos;
            });
          } else if (state is PartoCreated) {
            // Recarregar dados quando um novo parto for criado
            _loadPartos();
            _loadData(); // Recarregar dashboard também
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Parto cadastrado com sucesso!')),
            );
          } else if (state is PartoUpdated) {
            // Recarregar dados quando um parto for atualizado
            _loadPartos();
            _loadData(); // Recarregar dashboard também
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Parto atualizado com sucesso!')),
            );
          } else if (state is PartoDeleted) {
            // Recarregar dados quando um parto for deletado
            _loadPartos();
            _loadData(); // Recarregar dashboard também
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Parto excluído com sucesso!')),
            );
            // Recarregar dados quando um novo parto for criado
            _loadPartos();
            _loadData(); // Recarregar dashboard também
          } else if (state is PartoUpdated) {
            // Recarregar dados quando um parto for atualizado
            _loadPartos();
            _loadData(); // Recarregar dashboard também
          } else if (state is PartoDeleted) {
            // Recarregar dados quando um parto for deletado
            _loadPartos();
            _loadData(); // Recarregar dashboard também
          } else if (state is ReproducaoError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildDashboardTab(),
            _buildLotesTab(),
            _buildInseminacaoTab(),
            _buildDiagnosticoTab(),
            _buildPartosTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardTab() {
    if (_dashboard == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoCard(),
          const SizedBox(height: 16),
          _buildConfiguracoesPadraoCard(),
          const SizedBox(height: 16),
          _buildResumoCard(),
          const SizedBox(height: 16),
          _buildProgressoCard(),
          const SizedBox(height: 16),
          _buildTaxasCard(),
        ],
      ),
    );
  }

  Widget _buildConfiguracoesPadraoCard() {
    final temConfiguracoes = _tipoInseminacaoPadrao != null || _protocoloPadrao != null || _reprodutorPadrao != null || (_semenUtilizadoPadrao != null && _semenUtilizadoPadrao!.isNotEmpty);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Configurações Padrão para Inseminações',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (temConfiguracoes) ...[
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.green.shade100,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            'Ativo',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.green.shade700,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildCampoConfiguracaoPadrao(
              'Protocolo IATF',
              _protocoloPadrao?.nome ?? 'Não configurado',
              Icons.description,
            ),
            const SizedBox(height: 8),
            _buildCampoConfiguracaoPadrao(
              'Tipo de Inseminação',
              _tipoInseminacaoPadrao?.label ?? 'Não configurado',
              Icons.category,
            ),
            const SizedBox(height: 8),
            _buildCampoConfiguracaoPadrao(
              'Reprodutor',
              _reprodutorPadrao?.identificacaoUnica ?? 'Não configurado',
              Icons.pets,
            ),
            const SizedBox(height: 8),
            _buildCampoConfiguracaoPadrao(
              'Sêmen Utilizado',
              _semenUtilizadoPadrao ?? 'Não configurado',
              Icons.science,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _configurarPadroes,
                icon: const Icon(Icons.edit),
                label: Text(
                  temConfiguracoes ? 'Editar Configurações Padrão' : 'Configurar Padrões para Inseminação',
                  overflow: TextOverflow.ellipsis,
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  backgroundColor: temConfiguracoes ? Colors.green.shade600 : Colors.blue.shade600,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildCampoConfiguracaoPadrao(String label, String? valor, IconData icon) {
    final isConfigured = valor != null && valor != 'Não configurado';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: isConfigured ? Colors.green.shade600 : Colors.grey[600]),
          const SizedBox(width: 8),
          Expanded(
            flex: 2,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 3,
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    valor ?? 'Não configurado',
                    style: TextStyle(
                      color: isConfigured ? Colors.green.shade700 : Colors.grey[600],
                      fontStyle: isConfigured ? FontStyle.normal : FontStyle.italic,
                      fontWeight: isConfigured ? FontWeight.w500 : FontWeight.normal,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
                if (isConfigured) ...[
                  const SizedBox(width: 4),
                  Icon(
                    Icons.check_circle,
                    size: 16,
                    color: Colors.green.shade600,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _configurarPadroes() {
    if (_estacao == null) return;

    final reproductionBloc = context.read<ReproducaoBloc>();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BlocProvider.value(
          value: reproductionBloc,
          child: ConfigurarPadroesEstacaoScreen(
            estacao: _estacao!,
            tipoInseminacaoPadrao: _tipoInseminacaoPadrao,
            protocoloPadrao: _protocoloPadrao,
            reprodutorPadrao: _reprodutorPadrao,
            semenUtilizadoPadrao: _semenUtilizadoPadrao,
          ),
        ),
      ),
    ).then((configuracoes) {
      if (configuracoes != null) {
        // Atualizar as configurações locais
        setState(() {
          // Atualizar tipo de inseminação
          _tipoInseminacaoPadrao = configuracoes['tipo_inseminacao_obj'];

          // Atualizar sêmen utilizado
          _semenUtilizadoPadrao = configuracoes['semen_utilizado'];

          // Atualizar reprodutor
          _reprodutorPadrao = configuracoes['reprodutor_obj'];

          // Atualizar protocolo IATF
          _protocoloPadrao = configuracoes['protocolo_iatf_obj'];

          print('DEBUG: Configurações atualizadas:');
          print('- Tipo: ${_tipoInseminacaoPadrao?.label ?? "Nenhum"}');
          print('- Reprodutor: ${_reprodutorPadrao?.identificacaoUnica ?? "Nenhum"}');
          print('- Protocolo: ${_protocoloPadrao?.nome ?? "Nenhum"}');
          print('- Sêmen: ${_semenUtilizadoPadrao ?? "Nenhum"}');
        });
      }
    });
  }

  Widget _buildInfoCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Informações da Estação',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            if (_estacao != null) ...[
              Text('Nome: ${_estacao!.nome}'),
              Text('Período: ${_dateFormat.format(_estacao!.dataInicio)} - ${_dateFormat.format(_estacao!.dataFim)}'),
              Text('Status: ${_estacao!.ativa ? "Ativa" : "Inativa"}'),
              if (_estacao!.observacoes?.isNotEmpty == true) Text('Observações: ${_estacao!.observacoes}'),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildResumoCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Resumo Geral',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    'Total de Fêmeas',
                    _dashboard?['total_femeas']?.toString() ?? '0',
                    Icons.pets,
                    Colors.blue,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    'Lotes Associados',
                    _lotes.length.toString(),
                    Icons.group_work,
                    Colors.orange,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressoCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Progresso das Atividades',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    'Inseminações',
                    _dashboard?['inseminacoes_realizadas']?.toString() ?? '0',
                    Icons.favorite,
                    Colors.red,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    'Diagnósticos',
                    _dashboard?['diagnosticos_realizados']?.toString() ?? '0',
                    Icons.medical_services,
                    Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    'Partos',
                    _dashboard?['partos_realizados']?.toString() ?? '0',
                    Icons.child_care,
                    Colors.purple,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    'Pendências',
                    (_dashboard?['diagnosticos_pendentes']?.toString() ?? '0'),
                    Icons.pending_actions,
                    Colors.amber,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTaxasCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Índices de Performance',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildPercentageItem(
                    'Taxa de Prenhez',
                    _dashboard?['taxa_prenhez']?.toDouble() ?? 0.0,
                    Colors.green,
                  ),
                ),
                Expanded(
                  child: _buildPercentageItem(
                    'Taxa de Parto',
                    _dashboard?['taxa_parto']?.toDouble() ?? 0.0,
                    Colors.blue,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: color.withOpacity(0.1),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: const TextStyle(fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPercentageItem(String label, double percentage, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: color.withOpacity(0.1),
      ),
      child: Column(
        children: [
          Text(
            '${percentage.toStringAsFixed(1)}%',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 12),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: percentage / 100,
            backgroundColor: color.withOpacity(0.2),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ],
      ),
    );
  }

  Widget _buildLotesTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Lotes Associados (${_lotes.length})',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => _navegarParaSelecionarLotes(),
                icon: const Icon(Icons.add),
                label: const Text('Gerenciar Lotes'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: _lotes.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.group_work, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text('Nenhum lote associado'),
                      SizedBox(height: 8),
                      Text(
                        'Clique em "Gerenciar Lotes" para\nassociar lotes a esta estação',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _lotes.length,
                  itemBuilder: (context, index) {
                    final lote = _lotes[index];
                    return Card(
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.green.shade100,
                          child: Icon(
                            Icons.group_work,
                            color: Colors.green.shade700,
                          ),
                        ),
                        title: Text(lote['nome'] ?? ''),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (lote['descricao']?.isNotEmpty == true) Text(lote['descricao']),
                            Text('Fêmeas: ${lote['total_femeas'] ?? 0}'),
                            if (lote['aptidao'] != null) Text('Aptidão: ${lote['aptidao']}'),
                          ],
                        ),
                        isThreeLine: true,
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildInseminacaoTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Inseminações da Estação',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => _navegarParaCadastroInseminacao(),
                icon: const Icon(Icons.add),
                label: const Text('Nova'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: BlocBuilder<ReproducaoBloc, ReproducaoState>(
            builder: (context, state) {
              if (state is InseminacoesLoading && _cachedInseminacoes == null) {
                return const Center(child: CircularProgressIndicator());
              }

              final inseminacoes = _cachedInseminacoes ?? [];

              if (inseminacoes.isEmpty) {
                return const Center(
                  child: Text('Nenhuma inseminação encontrada para esta estação'),
                );
              }

              return RefreshIndicator(
                onRefresh: () async => _loadInseminacoes(),
                child: ListView.builder(
                  itemCount: inseminacoes.length,
                  itemBuilder: (context, index) {
                    final inseminacao = inseminacoes[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      child: ListTile(
                        title: Text(inseminacao.animal.identificacaoUnica),
                        subtitle: Text('Data: ${DateFormat('dd/MM/yyyy').format(inseminacao.dataInseminacao)}'),
                        trailing: Text(inseminacao.tipo.label),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDiagnosticoTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Diagnósticos da Estação',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => _navegarParaCadastroDiagnostico(),
                icon: const Icon(Icons.add),
                label: const Text('Novo'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: BlocBuilder<ReproducaoBloc, ReproducaoState>(
            builder: (context, state) {
              if (state is DiagnosticosGestacaoLoading && _cachedDiagnosticos == null) {
                return const Center(child: CircularProgressIndicator());
              }

              final diagnosticos = _cachedDiagnosticos ?? [];

              if (diagnosticos.isEmpty) {
                return const Center(
                  child: Text('Nenhum diagnóstico encontrado para esta estação'),
                );
              }

              return RefreshIndicator(
                onRefresh: () async => _loadDiagnosticos(),
                child: ListView.builder(
                  itemCount: diagnosticos.length,
                  itemBuilder: (context, index) {
                    final diagnostico = diagnosticos[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      child: ListTile(
                        title: Text('${diagnostico.inseminacao.animal.identificacaoUnica} - ${diagnostico.resultado.label}'),
                        subtitle: Text('Data: ${DateFormat('dd/MM/yyyy').format(diagnostico.dataDiagnostico)}'),
                        trailing: Text(diagnostico.metodo),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPartosTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Partos da Estação',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => _navegarParaCadastroParto(),
                icon: const Icon(Icons.add),
                label: const Text('Novo'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: BlocBuilder<ReproducaoBloc, ReproducaoState>(
            builder: (context, state) {
              if (state is PartosLoading && _cachedPartos == null) {
                return const Center(child: CircularProgressIndicator());
              }

              final partos = _cachedPartos ?? [];

              if (partos.isEmpty) {
                return const Center(
                  child: Text('Nenhum parto encontrado para esta estação'),
                );
              }

              return RefreshIndicator(
                onRefresh: () async => _loadPartos(),
                child: ListView.builder(
                  itemCount: partos.length,
                  itemBuilder: (context, index) {
                    final parto = partos[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      child: ListTile(
                        title: Text(parto.mae.identificacaoUnica),
                        subtitle: Text('Data: ${DateFormat('dd/MM/yyyy').format(parto.dataParto)}'),
                        trailing: Text(parto.resultado.label),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _navegarParaSelecionarLotes() {
    final reproductionBloc = context.read<ReproducaoBloc>();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BlocProvider.value(
          value: reproductionBloc,
          child: SelecionarLotesScreen(
            estacaoMontaId: widget.estacaoMontaId,
            lotesJaAssociados: _lotes,
          ),
        ),
      ),
    ).then((_) => _loadData()); // Recarregar ao voltar
  }

  void _navegarParaCadastroInseminacao() {
    final reproductionBloc = context.read<ReproducaoBloc>();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BlocProvider.value(
          value: reproductionBloc,
          child: CadastroInseminacaoScreen(
            estacaoMontaPadrao: _estacao,
            // Usar configurações padrão definidas pelo usuário
            tipoInseminacaoPadrao: _tipoInseminacaoPadrao ?? TipoInseminacao.iatf,
            protocoloPadrao: _protocoloPadrao,
            reprodutorPadrao: _reprodutorPadrao,
            semenUtilizadoPadrao: _semenUtilizadoPadrao ?? "Sêmen Premium IATF - ${_estacao?.nome ?? 'Estação'}",
          ),
        ),
      ),
    ).then((_) => _loadData()); // Recarregar ao voltar
  }

  void _navegarParaCadastroDiagnostico() {
    final reproductionBloc = context.read<ReproducaoBloc>();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BlocProvider.value(
          value: reproductionBloc,
          child: const CadastroDiagnosticoGestacaoScreen(),
        ),
      ),
    ).then((_) => _loadData()); // Recarregar ao voltar
  }

  void _navegarParaCadastroParto() {
    final reproductionBloc = context.read<ReproducaoBloc>();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MultiBlocProvider(
          providers: [
            BlocProvider.value(value: reproductionBloc),
            BlocProvider(create: (context) => getIt<AnimalBloc>()),
          ],
          child: const CadastroPartoScreen(),
        ),
      ),
    ).then((_) => _loadData()); // Recarregar ao voltar
  }
}
