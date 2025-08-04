import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        // Simular recarregamento
        await Future.delayed(Duration(seconds: 1));
      },
      child: ListView(
        padding: EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 20),
        children: [
          // Mensagem de boas-vindas
          Card(
            elevation: 2,
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.wb_sunny_outlined,
                        color: Colors.orange,
                        size: 28,
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Bem-vindo ao AgroNexus',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.green[800],
                              ),
                            ),
                            Text(
                              'Gerencie sua propriedade rural de forma inteligente',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 24),

          // Título para funcionalidades
          Text(
            'Funcionalidades',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),

          SizedBox(height: 16),

          // Dashboard com funcionalidades principais
          GridView.count(
            crossAxisCount: 2,
            childAspectRatio: 1.1,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            children: [
              _buildDashboardCard(
                title: 'Calendário',
                subtitle: 'Próximas atividades',
                icon: Icons.calendar_today,
                color: Colors.blue,
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Calendário em desenvolvimento')),
                  );
                },
              ),
              _buildDashboardCard(
                title: 'Finanças',
                subtitle: 'Controle financeiro',
                icon: Icons.monetization_on,
                color: Colors.amber,
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Finanças em desenvolvimento')),
                  );
                },
              ),
              _buildDashboardCard(
                title: 'Manejo Sanitário',
                subtitle: 'Controle veterinário',
                icon: Icons.medical_services,
                color: Colors.red,
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Manejo sanitário em desenvolvimento')),
                  );
                },
              ),
              _buildDashboardCard(
                title: 'Manejo Reprodutivo',
                subtitle: 'Controle reprodutivo',
                icon: Icons.favorite,
                color: Colors.pink,
                onTap: () {
                  context.go('/manejo-reprodutivo');
                },
              ),
              _buildDashboardCard(
                title: 'Propriedades',
                subtitle: 'Gerenciar propriedades',
                icon: Icons.home_work,
                color: Colors.green,
                onTap: () {
                  context.go('/propriedades');
                },
              ),
              _buildDashboardCard(
                title: 'Animais',
                subtitle: 'Controle do rebanho',
                icon: Icons.pets,
                color: Colors.brown,
                onTap: () {
                  context.go('/animais');
                },
              ),
            ],
          ),

          SizedBox(height: 24),

          // Card com informações úteis
          Card(
            elevation: 2,
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.lightbulb_outline,
                        color: Colors.orange,
                        size: 24,
                      ),
                      SizedBox(width: 12),
                      Text(
                        'Dica do Dia',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  Text(
                    'Mantenha sempre os dados dos seus animais atualizados para um melhor controle do rebanho.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardCard({
    required String title,
    String? subtitle,
    required IconData icon,
    required Color color,
    VoidCallback? onTap,
  }) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 32),
              SizedBox(height: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
                textAlign: TextAlign.center,
              ),
              if (subtitle != null) ...[
                SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
