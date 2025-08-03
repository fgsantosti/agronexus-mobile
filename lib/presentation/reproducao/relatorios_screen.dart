import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:agronexus/presentation/bloc/reproducao/reproducao_bloc.dart';
import 'package:agronexus/presentation/bloc/reproducao/reproducao_event.dart';
import 'package:agronexus/presentation/bloc/reproducao/reproducao_state.dart';

class RelatoriosScreen extends StatefulWidget {
  const RelatoriosScreen({super.key});

  @override
  State<RelatoriosScreen> createState() => _RelatoriosScreenState();
}

class _RelatoriosScreenState extends State<RelatoriosScreen> {
  @override
  void initState() {
    super.initState();
    _loadDados();
  }

  void _loadDados() {
    context.read<ReproducaoBloc>().add(LoadResumoReproducaoEvent());
    context.read<ReproducaoBloc>().add(LoadInseminacoesPendenteDiagnosticoEvent());
    context.read<ReproducaoBloc>().add(LoadGestacoesPendentePartoEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async => _loadDados(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildResumoCard(),
              const SizedBox(height: 16),
              _buildInseminacoesPendentesCard(),
              const SizedBox(height: 16),
              _buildGestacoesPendentesCard(),
              const SizedBox(height: 16),
              _buildRelatoriosDisponiveis(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResumoCard() {
    return BlocBuilder<ReproducaoBloc, ReproducaoState>(
      builder: (context, state) {
        if (state is ResumoReproducaoLoaded) {
          return Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.analytics, color: Colors.blue.shade400),
                      const SizedBox(width: 8),
                      const Text(
                        'Resumo Geral',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  GridView.count(
                    crossAxisCount: 2,
                    childAspectRatio: 2.5,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      _buildStatTile(
                        'Inseminações',
                        state.resumo['inseminacoes']?.toString() ?? '0',
                        Icons.favorite,
                        Colors.red,
                      ),
                      _buildStatTile(
                        'Prenhes',
                        state.resumo['diagnosticos_positivos']?.toString() ?? '0',
                        Icons.check_circle,
                        Colors.green,
                      ),
                      _buildStatTile(
                        'Partos',
                        state.resumo['partos_vivos']?.toString() ?? '0',
                        Icons.child_care,
                        Colors.blue,
                      ),
                      _buildStatTile(
                        'Taxa Prenhez',
                        '${state.resumo['taxa_prenhez'] ?? 0}%',
                        Icons.trending_up,
                        Colors.orange,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const Text('Carregando resumo...'),
                const SizedBox(height: 8),
                LinearProgressIndicator(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInseminacoesPendentesCard() {
    return BlocBuilder<ReproducaoBloc, ReproducaoState>(
      builder: (context, state) {
        if (state is InseminacoesPendenteDiagnosticoLoaded) {
          return Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.schedule, color: Colors.orange.shade400),
                      const SizedBox(width: 8),
                      const Text(
                        'Pendentes de Diagnóstico',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      CircleAvatar(
                        radius: 12,
                        backgroundColor: Colors.orange.shade400,
                        child: Text(
                          state.inseminacoes.length.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (state.inseminacoes.isEmpty)
                    const Text(
                      'Nenhuma inseminação pendente de diagnóstico',
                      style: TextStyle(color: Colors.grey),
                    )
                  else
                    Text(
                      '${state.inseminacoes.length} inseminação(ões) aguardando diagnóstico de gestação',
                      style: TextStyle(color: Colors.grey.shade700),
                    ),
                ],
              ),
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildGestacoesPendentesCard() {
    return BlocBuilder<ReproducaoBloc, ReproducaoState>(
      builder: (context, state) {
        if (state is GestacoesPendentePartoLoaded) {
          return Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.event, color: Colors.green.shade400),
                      const SizedBox(width: 8),
                      const Text(
                        'Próximas ao Parto',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      CircleAvatar(
                        radius: 12,
                        backgroundColor: Colors.green.shade400,
                        child: Text(
                          state.gestacoes.length.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (state.gestacoes.isEmpty)
                    const Text(
                      'Nenhuma gestação próxima ao parto',
                      style: TextStyle(color: Colors.grey),
                    )
                  else
                    Text(
                      '${state.gestacoes.length} gestação(ões) com parto previsto nos próximos dias',
                      style: TextStyle(color: Colors.grey.shade700),
                    ),
                ],
              ),
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildRelatoriosDisponiveis() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.assessment, color: Colors.purple.shade400),
                const SizedBox(width: 8),
                const Text(
                  'Relatórios Disponíveis',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildRelatorioItem(
              'Relatório de Prenhez',
              'Taxa de sucesso por período',
              Icons.trending_up,
              Colors.green,
              () => _showRelatorioDialog('Relatório de Prenhez'),
            ),
            const Divider(),
            _buildRelatorioItem(
              'Estatísticas Reprodutivas',
              'Dados detalhados de reprodução',
              Icons.bar_chart,
              Colors.blue,
              () => _showRelatorioDialog('Estatísticas Reprodutivas'),
            ),
            const Divider(),
            _buildRelatorioItem(
              'Eficiência por Estação',
              'Performance das estações de monta',
              Icons.calendar_today,
              Colors.orange,
              () => _showRelatorioDialog('Eficiência por Estação'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatTile(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildRelatorioItem(
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: color.withOpacity(0.1),
        child: Icon(icon, color: color),
      ),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }

  void _showRelatorioDialog(String relatorio) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(relatorio),
        content: const Text('Esta funcionalidade estará disponível em breve com gráficos detalhados e exportação de dados.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }
}
