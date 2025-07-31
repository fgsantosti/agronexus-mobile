import 'package:agronexus/domain/models/propriedade_entity.dart';
import 'package:flutter/material.dart';

class PropriedadeCard extends StatelessWidget {
  final PropriedadeEntity propriedade;

  const PropriedadeCard({super.key, required this.propriedade});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8.0),
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    propriedade.nome,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.green[700],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: propriedade.ativa ? Colors.green[100] : Colors.red[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    propriedade.ativa ? 'Ativa' : 'Inativa',
                    style: TextStyle(
                      fontSize: 12,
                      color: propriedade.ativa ? Colors.green[700] : Colors.red[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            if (propriedade.proprietario != null) ...[
              Row(
                children: [
                  Icon(Icons.person, color: Colors.grey[600], size: 16),
                  SizedBox(width: 4),
                  Text(
                    'Proprietário: ${propriedade.proprietario!.nomeCompleto}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
            ],
            if (propriedade.localizacao.isNotEmpty) ...[
              Row(
                children: [
                  Icon(Icons.location_on, color: Colors.grey[600], size: 16),
                  SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      propriedade.localizacao,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
            ],
            Row(
              children: [
                Icon(Icons.landscape, color: Colors.grey[600], size: 16),
                SizedBox(width: 4),
                Text(
                  'Área Total: ${propriedade.areaTotalHa} ha',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
            if (propriedade.areaOcupada != null) ...[
              SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.straighten, color: Colors.grey[600], size: 16),
                  SizedBox(width: 4),
                  Text(
                    'Área Ocupada: ${propriedade.areaOcupada} m²',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
            ],
            SizedBox(height: 12),
            // Estatísticas em cards menores
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatCard(
                  'Lotes',
                  propriedade.totalLotes.toString(),
                  Colors.blue,
                  Icons.grid_view,
                ),
                _buildStatCard(
                  'Áreas',
                  propriedade.totalAreas.toString(),
                  Colors.orange,
                  Icons.crop_landscape,
                ),
                _buildStatCard(
                  'Animais',
                  propriedade.totalAnimais.toString(),
                  Colors.brown,
                  Icons.pets,
                ),
              ],
            ),
            SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () {
                    // TODO: Implementar navegação para detalhes
                  },
                  icon: Icon(Icons.visibility, size: 16),
                  label: Text('Ver Detalhes'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.green[700],
                  ),
                ),
                SizedBox(width: 8),
                TextButton.icon(
                  onPressed: () {
                    // TODO: Implementar edição
                  },
                  icon: Icon(Icons.edit, size: 16),
                  label: Text('Editar'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.blue[700],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, Color color, IconData icon) {
    return Expanded(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 4),
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
