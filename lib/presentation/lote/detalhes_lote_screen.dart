import 'package:flutter/material.dart';
import 'package:agronexus/domain/models/lote_entity.dart';
import 'package:agronexus/presentation/lote/editar_lote_screen.dart';

class DetalhesLoteScreen extends StatelessWidget {
  final LoteEntity lote;

  const DetalhesLoteScreen({
    super.key,
    required this.lote,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes do Lote'),
        backgroundColor: Colors.green.shade600,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => EditarLoteScreen(lote: lote),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header com informações principais
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.green.shade100,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.grid_view,
                            color: Colors.green.shade700,
                            size: 32,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                lote.nome,
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: lote.ativo ? Colors.green : Colors.red,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  lote.ativo ? 'ATIVO' : 'INATIVO',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            'Total Animais',
                            '${lote.totalAnimais}',
                            Icons.pets,
                            Colors.orange,
                          ),
                        ),
                        const SizedBox(width: 12),
                        if (lote.totalUa != null)
                          Expanded(
                            child: _buildStatCard(
                              'Total UA',
                              '${lote.totalUa!.toStringAsFixed(2)}',
                              Icons.scale,
                              Colors.blue,
                            ),
                          ),
                        if (lote.pesoMedio != null) ...[
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildStatCard(
                              'Peso Médio',
                              '${lote.pesoMedio!.toStringAsFixed(1)} kg',
                              Icons.monitor_weight,
                              Colors.purple,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Informações detalhadas
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Informações Básicas',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.green.shade700,
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (lote.descricao.isNotEmpty) _buildDetalheItem('Descrição', lote.descricao),
                    if (lote.criterioAgrupamento.isNotEmpty) _buildDetalheItem('Critério de Agrupamento', lote.criterioAgrupamento),
                    _buildDetalheItem('ID da Propriedade', lote.propriedadeId),
                  ],
                ),
              ),
            ),

            if (lote.aptidao != null || lote.finalidade != null || lote.sistemaCriacao != null) ...[
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Características do Lote',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade700,
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (lote.aptidao != null) _buildDetalheItem('Aptidão', _getAptidaoDisplay(lote.aptidao!)),
                      if (lote.finalidade != null) _buildDetalheItem('Finalidade', _getFinalidadeDisplay(lote.finalidade!)),
                      if (lote.sistemaCriacao != null) _buildDetalheItem('Sistema de Criação', _getSistemaCriacaoDisplay(lote.sistemaCriacao!)),
                    ],
                  ),
                ),
              ),
            ],

            if (lote.gmdMedio != null) ...[
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Indicadores de Performance',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade700,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildDetalheItem('GMD Médio', '${lote.gmdMedio!.toStringAsFixed(3)} kg/dia'),
                    ],
                  ),
                ),
              ),
            ],

            const SizedBox(height: 16),

            // Metadados
            if (lote.createdAt != null) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Informações do Sistema',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade700,
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (lote.id != null) _buildDetalheItem('ID', lote.id!),
                      _buildDetalheItem('Data de Criação', _formatarData(lote.createdAt!)),
                      if (lote.modifiedAt != null) _buildDetalheItem('Última Modificação', _formatarData(lote.modifiedAt!)),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
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
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              color: color,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildDetalheItem(String label, String valor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          Expanded(
            child: Text(
              valor,
              style: const TextStyle(color: Colors.black54),
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

  String _getSistemaCriacaoDisplay(String sistemaCriacao) {
    switch (sistemaCriacao) {
      case 'intensivo':
        return 'Intensivo';
      case 'extensivo':
        return 'Extensivo';
      case 'semi_extensivo':
        return 'Semi-Extensivo';
      default:
        return sistemaCriacao;
    }
  }

  String _formatarData(String dataIso) {
    try {
      final data = DateTime.parse(dataIso);
      return '${data.day.toString().padLeft(2, '0')}/${data.month.toString().padLeft(2, '0')}/${data.year} ${data.hour.toString().padLeft(2, '0')}:${data.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dataIso;
    }
  }
}
