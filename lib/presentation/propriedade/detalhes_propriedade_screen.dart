import 'package:flutter/material.dart';
import 'package:agronexus/domain/models/propriedade_entity.dart';
import 'package:agronexus/presentation/widgets/standard_app_bar.dart';

class DetalhesPropriedadeScreen extends StatelessWidget {
  final PropriedadeEntity propriedade;

  const DetalhesPropriedadeScreen({
    super.key,
    required this.propriedade,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildStandardAppBar(title: 'Detalhes da Propriedade'),
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
                            Icons.home_work,
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
                                propriedade.nome,
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
                                  color: propriedade.ativa ? Colors.green : Colors.red,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  propriedade.ativa ? 'ATIVA' : 'INATIVA',
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
                            'Área Total',
                            '${propriedade.areaTotalHa} ha',
                            Icons.landscape,
                            Colors.blue,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildStatCard(
                            'Animais',
                            '${propriedade.totalAnimais}',
                            Icons.pets,
                            Colors.orange,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildStatCard(
                            'Lotes',
                            '${propriedade.totalLotes}',
                            Icons.grid_view,
                            Colors.purple,
                          ),
                        ),
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
                      'Informações Detalhadas',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.green.shade700,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildDetalheItem('Localização', propriedade.localizacao),
                    if (propriedade.areaOcupada != null) _buildDetalheItem('Área Ocupada', '${propriedade.areaOcupada} ha'),
                    if (propriedade.totalAreas > 0) _buildDetalheItem('Total de Áreas', '${propriedade.totalAreas}'),
                  ],
                ),
              ),
            ),

            if (propriedade.inscricaoEstadual != null || propriedade.cnpjCpf != null) ...[
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Documentação',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade700,
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (propriedade.inscricaoEstadual != null) _buildDetalheItem('Inscrição Estadual', propriedade.inscricaoEstadual!),
                      if (propriedade.cnpjCpf != null) _buildDetalheItem('CNPJ/CPF', propriedade.cnpjCpf!),
                    ],
                  ),
                ),
              ),
            ],

            if (propriedade.coordenadasGps != null) ...[
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Coordenadas GPS',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade700,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildCoordenadaCard(
                              'Latitude',
                              propriedade.coordenadasGps!.latitude.toString(),
                              Icons.north,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildCoordenadaCard(
                              'Longitude',
                              propriedade.coordenadasGps!.longitude.toString(),
                              Icons.east,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],

            if (propriedade.proprietario != null) ...[
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Proprietário',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade700,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildDetalheItem('Nome', propriedade.proprietario!.nomeCompleto),
                      _buildDetalheItem('Username', propriedade.proprietario!.username),
                      _buildDetalheItem('Perfil', propriedade.proprietario!.perfil),
                      _buildDetalheItem(
                        'Status',
                        propriedade.proprietario!.ativo ? 'Ativo' : 'Inativo',
                      ),
                    ],
                  ),
                ),
              ),
            ],

            if (propriedade.dataCriacao != null) ...[
              const SizedBox(height: 16),
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
                      _buildDetalheItem('Data de Criação', propriedade.dataCriacao!),
                      if (propriedade.id != null) _buildDetalheItem('ID', propriedade.id!),
                    ],
                  ),
                ),
              ),
            ],

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
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
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
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

  Widget _buildDetalheItem(String titulo, String valor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            titulo,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            valor,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Divider(color: Colors.grey.shade200, height: 1),
        ],
      ),
    );
  }

  Widget _buildCoordenadaCard(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.blue, size: 20),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.blue,
            ),
          ),
        ],
      ),
    );
  }

  // _navegarParaEdicao removido (edição não disponível)
}
