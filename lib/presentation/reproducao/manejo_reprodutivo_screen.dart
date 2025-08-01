import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:agronexus/presentation/reproducao/nova_inseminacao_screen.dart';
import 'package:agronexus/presentation/reproducao/novo_diagnostico_screen.dart';
import 'package:agronexus/domain/entities/reproducao.dart';

class ManejoReprodutivoScreen extends StatefulWidget {
  final String? propriedadeId;

  const ManejoReprodutivoScreen({
    super.key,
    this.propriedadeId,
  });

  @override
  State<ManejoReprodutivoScreen> createState() => _ManejoReprodutivoScreenState();
}

class _ManejoReprodutivoScreenState extends State<ManejoReprodutivoScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Dados mockados para demonstração
  List<EstacaoMonta> estacoesAtivas = [];
  List<Inseminacao> inseminacoesRecentes = [];
  List<DiagnosticoGestacao> diagnosticos = [];
  List<Parto> partosRecentes = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _carregarDadosMockados();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _carregarDadosMockados() {
    // Simulando dados para demonstração
    estacoesAtivas = [
      EstacaoMonta(
        id: '1',
        propriedadeId: widget.propriedadeId ?? '1',
        nome: 'Estação 2025',
        dataInicio: DateTime.now().subtract(Duration(days: 30)),
        dataFim: DateTime.now().add(Duration(days: 60)),
        lotesParticipantes: ['lote1', 'lote2'],
        observacoes: 'Estação de monta principal',
        ativa: true,
      ),
    ];

    inseminacoesRecentes = [
      Inseminacao(
        id: '1',
        animalId: 'animal1',
        manejoId: 'manejo1',
        dataInseminacao: DateTime.now().subtract(Duration(days: 15)),
        tipo: TipoInseminacao.iatf,
        semenUtilizado: 'Sêmen Premium XYZ',
        observacoes: 'IATF realizada com sucesso',
      ),
      Inseminacao(
        id: '2',
        animalId: 'animal2',
        manejoId: 'manejo2',
        dataInseminacao: DateTime.now().subtract(Duration(days: 45)),
        tipo: TipoInseminacao.ia,
        semenUtilizado: 'Sêmen ABC123',
        observacoes: 'IA convencional',
      ),
    ];

    diagnosticos = [
      DiagnosticoGestacao(
        id: '1',
        inseminacaoId: '2',
        manejoId: 'manejo3',
        dataDiagnostico: DateTime.now().subtract(Duration(days: 10)),
        resultado: ResultadoDiagnostico.positivo,
        metodo: 'Ultrassom',
        observacoes: 'Prenha confirmada',
      ),
    ];

    partosRecentes = [
      Parto(
        id: '1',
        maeId: 'animal3',
        manejoId: 'manejo4',
        dataParto: DateTime.now().subtract(Duration(days: 5)),
        resultado: ResultadoParto.nascido_vivo,
        dificuldade: DificuldadeParto.normal,
        numeroFilhotes: 1,
        filhotesIds: ['bezerro1'],
        pesoNascimento: 32.5,
        observacoes: 'Parto normal, bezerro saudável',
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Manejo Reprodutivo'),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: Column(
        children: [
          // Dashboard Cards
          Container(
            padding: EdgeInsets.all(16),
            child: GridView.count(
              crossAxisCount: 2,
              childAspectRatio: 1.1,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              children: [
                _buildDashboardCard(
                  title: 'Estações Ativas',
                  value: estacoesAtivas.length.toString(),
                  icon: FontAwesomeIcons.calendar,
                  color: Colors.green,
                ),
                _buildDashboardCard(
                  title: 'IAs Recentes',
                  value: inseminacoesRecentes.length.toString(),
                  icon: FontAwesomeIcons.syringe,
                  color: Colors.blue,
                ),
                _buildDashboardCard(
                  title: 'Prenhas Confirmadas',
                  value: diagnosticos.where((d) => d.resultado == ResultadoDiagnostico.positivo).length.toString(),
                  icon: FontAwesomeIcons.heartbeat,
                  color: Colors.pink,
                ),
                _buildDashboardCard(
                  title: 'Partos Recentes',
                  value: partosRecentes.length.toString(),
                  icon: FontAwesomeIcons.baby,
                  color: Colors.orange,
                ),
              ],
            ),
          ),

          // Tab Bar
          Container(
            color: Colors.grey[100],
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              labelColor: Theme.of(context).primaryColor,
              unselectedLabelColor: Colors.grey,
              indicatorColor: Theme.of(context).primaryColor,
              tabs: [
                Tab(text: 'Estações', icon: Icon(FontAwesomeIcons.calendar, size: 16)),
                Tab(text: 'Inseminações', icon: Icon(FontAwesomeIcons.syringe, size: 16)),
                Tab(text: 'Diagnósticos', icon: Icon(FontAwesomeIcons.search, size: 16)),
                Tab(text: 'Partos', icon: Icon(FontAwesomeIcons.baby, size: 16)),
              ],
            ),
          ),

          // Tab Views
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildEstacoesTab(),
                _buildInseminacoesTab(),
                _buildDiagnosticosTab(),
                _buildPartosTab(),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _mostrarMenuAdicionar(),
        child: Icon(Icons.add),
      ),
    );
  }

  Widget _buildDashboardCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 4,
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          gradient: LinearGradient(
            colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 28),
            SizedBox(height: 8),
            Flexible(
              child: Text(
                value,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Flexible(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[700],
                ),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEstacoesTab() {
    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: estacoesAtivas.length,
      itemBuilder: (context, index) {
        final estacao = estacoesAtivas[index];
        return Card(
          margin: EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.green.withOpacity(0.2),
              child: Icon(FontAwesomeIcons.calendar, color: Colors.green, size: 20),
            ),
            title: Text(estacao.nome),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${_formatarData(estacao.dataInicio)} - ${_formatarData(estacao.dataFim)}'),
                Text('${estacao.lotesParticipantes.length} lotes participantes'),
              ],
            ),
            trailing: PopupMenuButton(
              itemBuilder: (context) => [
                PopupMenuItem(value: 'editar', child: Text('Editar')),
                PopupMenuItem(value: 'relatorio', child: Text('Relatório')),
              ],
              onSelected: (value) {
                if (value == 'editar') {
                  _editarEstacao(estacao);
                } else if (value == 'relatorio') {
                  _gerarRelatorioEstacao(estacao);
                }
              },
            ),
            onTap: () => _verDetalhesEstacao(estacao),
          ),
        );
      },
    );
  }

  Widget _buildInseminacoesTab() {
    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: inseminacoesRecentes.length,
      itemBuilder: (context, index) {
        final inseminacao = inseminacoesRecentes[index];
        return Card(
          margin: EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.blue.withOpacity(0.2),
              child: Icon(FontAwesomeIcons.syringe, color: Colors.blue, size: 20),
            ),
            title: Text('${inseminacao.tipoDisplay} - Animal ${inseminacao.animalId}'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_formatarData(inseminacao.dataInseminacao)),
                if (inseminacao.semenUtilizado != null) Text('Sêmen: ${inseminacao.semenUtilizado}'),
                Text('Diagnóstico previsto: ${_formatarData(inseminacao.dataDiagnosticoPrevista)}'),
              ],
            ),
            trailing: PopupMenuButton(
              itemBuilder: (context) => [
                PopupMenuItem(value: 'diagnostico', child: Text('Fazer Diagnóstico')),
                PopupMenuItem(value: 'editar', child: Text('Editar')),
              ],
              onSelected: (value) {
                if (value == 'diagnostico') {
                  _fazerDiagnostico(inseminacao);
                } else if (value == 'editar') {
                  _editarInseminacao(inseminacao);
                }
              },
            ),
            onTap: () => _verDetalhesInseminacao(inseminacao),
          ),
        );
      },
    );
  }

  Widget _buildDiagnosticosTab() {
    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: diagnosticos.length,
      itemBuilder: (context, index) {
        final diagnostico = diagnosticos[index];
        Color statusColor = diagnostico.resultado == ResultadoDiagnostico.positivo
            ? Colors.green
            : diagnostico.resultado == ResultadoDiagnostico.negativo
                ? Colors.red
                : Colors.orange;

        return Card(
          margin: EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: statusColor.withOpacity(0.2),
              child: Icon(
                diagnostico.resultado == ResultadoDiagnostico.positivo ? FontAwesomeIcons.heartbeat : FontAwesomeIcons.times,
                color: statusColor,
                size: 20,
              ),
            ),
            title: Text('${diagnostico.resultadoDisplay} - ${_formatarData(diagnostico.dataDiagnostico)}'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (diagnostico.metodo != null) Text('Método: ${diagnostico.metodo}'),
                if (diagnostico.dataPartoPrevista != null) Text('Parto previsto: ${_formatarData(diagnostico.dataPartoPrevista!)}'),
              ],
            ),
            trailing: PopupMenuButton(
              itemBuilder: (context) => [
                if (diagnostico.resultado == ResultadoDiagnostico.positivo) PopupMenuItem(value: 'agendar_parto', child: Text('Agendar Parto')),
                PopupMenuItem(value: 'editar', child: Text('Editar')),
              ],
              onSelected: (value) {
                if (value == 'agendar_parto') {
                  _agendarParto(diagnostico);
                } else if (value == 'editar') {
                  _editarDiagnostico(diagnostico);
                }
              },
            ),
            onTap: () => _verDetalhesDiagnostico(diagnostico),
          ),
        );
      },
    );
  }

  Widget _buildPartosTab() {
    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: partosRecentes.length,
      itemBuilder: (context, index) {
        final parto = partosRecentes[index];
        Color statusColor = parto.resultado == ResultadoParto.nascido_vivo ? Colors.green : Colors.red;

        return Card(
          margin: EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: statusColor.withOpacity(0.2),
              child: Icon(FontAwesomeIcons.baby, color: statusColor, size: 20),
            ),
            title: Text('${parto.resultadoDisplay} - ${_formatarData(parto.dataParto)}'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Mãe: Animal ${parto.maeId}'),
                Text('Dificuldade: ${parto.dificuldadeDisplay}'),
                if (parto.pesoNascimento != null) Text('Peso nascimento: ${parto.pesoNascimento}kg'),
                Text('${parto.numeroFilhotes} filhote(s)'),
              ],
            ),
            trailing: PopupMenuButton(
              itemBuilder: (context) => [
                PopupMenuItem(value: 'cadastrar_filhote', child: Text('Cadastrar Filhote')),
                PopupMenuItem(value: 'editar', child: Text('Editar')),
              ],
              onSelected: (value) {
                if (value == 'cadastrar_filhote') {
                  _cadastrarFilhote(parto);
                } else if (value == 'editar') {
                  _editarParto(parto);
                }
              },
            ),
            onTap: () => _verDetalhesParto(parto),
          ),
        );
      },
    );
  }

  void _mostrarMenuAdicionar() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Adicionar',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            ListTile(
              leading: Icon(FontAwesomeIcons.calendar, color: Colors.green),
              title: Text('Nova Estação de Monta'),
              onTap: () {
                Navigator.pop(context);
                _novaEstacao();
              },
            ),
            ListTile(
              leading: Icon(FontAwesomeIcons.syringe, color: Colors.blue),
              title: Text('Nova Inseminação'),
              onTap: () {
                Navigator.pop(context);
                _novaInseminacao();
              },
            ),
            ListTile(
              leading: Icon(FontAwesomeIcons.search, color: Colors.orange),
              title: Text('Novo Diagnóstico'),
              onTap: () {
                Navigator.pop(context);
                _novoDiagnostico();
              },
            ),
            ListTile(
              leading: Icon(FontAwesomeIcons.baby, color: Colors.pink),
              title: Text('Registrar Parto'),
              onTap: () {
                Navigator.pop(context);
                _registrarParto();
              },
            ),
          ],
        ),
      ),
    );
  }

  String _formatarData(DateTime data) {
    return '${data.day.toString().padLeft(2, '0')}/${data.month.toString().padLeft(2, '0')}/${data.year}';
  }

  // Métodos para navegação e ações (implementar conforme necessário)
  void _novaEstacao() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Nova Estação de Monta - Em desenvolvimento')),
    );
  }

  void _novaInseminacao() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NovaInseminacaoScreen(
          propriedadeId: widget.propriedadeId,
        ),
      ),
    );
  }

  void _novoDiagnostico() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NovoDiagnosticoScreen(
          propriedadeId: widget.propriedadeId,
        ),
      ),
    );
  }

  void _registrarParto() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Registrar Parto - Em desenvolvimento')),
    );
  }

  void _verDetalhesEstacao(EstacaoMonta estacao) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Detalhes da Estação: ${estacao.nome}')),
    );
  }

  void _editarEstacao(EstacaoMonta estacao) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Editar Estação: ${estacao.nome}')),
    );
  }

  void _gerarRelatorioEstacao(EstacaoMonta estacao) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Relatório da Estação: ${estacao.nome}')),
    );
  }

  void _verDetalhesInseminacao(Inseminacao inseminacao) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Detalhes da Inseminação: ${inseminacao.id}')),
    );
  }

  void _editarInseminacao(Inseminacao inseminacao) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Editar Inseminação: ${inseminacao.id}')),
    );
  }

  void _fazerDiagnostico(Inseminacao inseminacao) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NovoDiagnosticoScreen(
          propriedadeId: widget.propriedadeId,
          inseminacao: inseminacao,
        ),
      ),
    );
  }

  void _verDetalhesDiagnostico(DiagnosticoGestacao diagnostico) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Detalhes do Diagnóstico: ${diagnostico.id}')),
    );
  }

  void _editarDiagnostico(DiagnosticoGestacao diagnostico) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Editar Diagnóstico: ${diagnostico.id}')),
    );
  }

  void _agendarParto(DiagnosticoGestacao diagnostico) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Agendar Parto para: ${diagnostico.dataPartoPrevista}')),
    );
  }

  void _verDetalhesParto(Parto parto) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Detalhes do Parto: ${parto.id}')),
    );
  }

  void _editarParto(Parto parto) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Editar Parto: ${parto.id}')),
    );
  }

  void _cadastrarFilhote(Parto parto) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Cadastrar Filhote do Parto: ${parto.id}')),
    );
  }
}
