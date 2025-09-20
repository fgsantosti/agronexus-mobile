import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:agronexus/config/api.dart';

class FunctionalityData {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final Color backgroundColor;
  final VoidCallback? onTap;

  FunctionalityData({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.backgroundColor,
    this.onTap,
  });
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            // Simular recarregamento
            await Future.delayed(Duration(seconds: 1));
          },
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Mensagem de boas-vindas
                  _buildWelcomeCard(),

                  const SizedBox(height: 32),

                  // Título para funcionalidades
                  Text(
                    'Funcionalidades',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Dashboard com funcionalidades principais - Responsivo
                  _buildResponsiveFunctionalitiesGrid(screenWidth),

                  const SizedBox(height: 32),

                  // Card com informações úteis
                  _buildTipCard(),

                  const SizedBox(height: 120), // Espaço maior para bottom navigation
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(
            Icons.wb_sunny_outlined,
            color: Colors.orange,
            size: 32,
          ),
          const SizedBox(width: 16),
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
                const SizedBox(height: 4),
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
    );
  }

  Widget _buildResponsiveFunctionalitiesGrid(double screenWidth) {
    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount;
        double childAspectRatio;
        double crossAxisSpacing = 16;
        double mainAxisSpacing = 16;

        if (constraints.maxWidth > 900) {
          // Desktop/Tablet muito grande
          crossAxisCount = 4;
          childAspectRatio = 1.15;
        } else if (constraints.maxWidth > 600) {
          // Tablet
          crossAxisCount = 3;
          childAspectRatio = 1.1;
        } else if (constraints.maxWidth > 450) {
          // Phone muito grande
          crossAxisCount = 2;
          childAspectRatio = 1.15;
        } else if (constraints.maxWidth > 350) {
          // Phone médio
          crossAxisCount = 2;
          childAspectRatio = 1.0;
          crossAxisSpacing = 12;
          mainAxisSpacing = 12;
        } else {
          // Phone muito pequeno
          crossAxisCount = 1;
          childAspectRatio = 2.8;
          crossAxisSpacing = 8;
          mainAxisSpacing = 12;
        }

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: crossAxisSpacing,
            mainAxisSpacing: mainAxisSpacing,
            childAspectRatio: childAspectRatio,
          ),
          itemCount: 6,
          itemBuilder: (context, index) {
            return _buildFunctionalityCard(_getFunctionalityData(index));
          },
        );
      },
    );
  }

  Widget _buildFunctionalityCard(FunctionalityData item) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cardWidth = constraints.maxWidth;
        final cardHeight = constraints.maxHeight;

        // Ajustar tamanhos baseado na dimensão do card
        final iconSize = (cardWidth * 0.2).clamp(24.0, 36.0);
        final titleFontSize = (cardWidth * 0.04).clamp(14.0, 18.0);
        final subtitleFontSize = (cardWidth * 0.03).clamp(11.0, 14.0);
        final padding = (cardWidth * 0.08).clamp(12.0, 20.0);

        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: item.onTap,
              child: Padding(
                padding: EdgeInsets.all(padding),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: EdgeInsets.all(iconSize * 0.35),
                      decoration: BoxDecoration(
                        color: item.backgroundColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        item.icon,
                        color: item.color,
                        size: iconSize,
                      ),
                    ),
                    SizedBox(height: cardHeight * 0.08),
                    Flexible(
                      child: Text(
                        item.title,
                        style: TextStyle(
                          fontSize: titleFontSize,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                      ),
                    ),
                    SizedBox(height: cardHeight * 0.02),
                    Flexible(
                      child: Text(
                        item.subtitle,
                        style: TextStyle(
                          fontSize: subtitleFontSize,
                          color: Colors.grey[600],
                        ),
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  FunctionalityData _getFunctionalityData(int index) {
    final functionalities = [
      FunctionalityData(
        title: 'Calendário',
        subtitle: 'Próximas atividades',
        icon: Icons.calendar_today,
        color: Colors.blue,
        backgroundColor: Colors.blue[50]!,
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Calendário em desenvolvimento')),
          );
        },
      ),
      FunctionalityData(
        title: 'Finanças',
        subtitle: 'Controle financeiro',
        icon: Icons.monetization_on,
        color: Colors.amber,
        backgroundColor: Colors.amber[50]!,
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Finanças em desenvolvimento')),
          );
        },
      ),
      FunctionalityData(
        title: 'Manejo Sanitário',
        subtitle: 'Controle veterinário',
        icon: Icons.medical_services,
        color: Colors.red,
        backgroundColor: Colors.red[50]!,
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Manejo sanitário em desenvolvimento')),
          );
        },
      ),
      FunctionalityData(
        title: 'Manejo Reprodutivo',
        subtitle: 'Controle reprodutivo',
        icon: Icons.favorite,
        color: Colors.pink,
        backgroundColor: Colors.pink[50]!,
        onTap: () {
          context.go(API.manejoReprodutivoRoute);
        },
      ),
      FunctionalityData(
        title: 'Propriedades',
        subtitle: 'Gerenciar propriedades',
        icon: Icons.home_work,
        color: Colors.green,
        backgroundColor: Colors.green[50]!,
        onTap: () {
          context.go(API.propriedadesRoute);
        },
      ),
      FunctionalityData(
        title: 'Animais',
        subtitle: 'Controle do rebanho',
        icon: Icons.pets,
        color: Colors.brown,
        backgroundColor: Colors.brown[50]!,
        onTap: () {
          context.go(API.animaisRoute);
        },
      ),
    ];
    return functionalities[index];
  }

  Widget _buildTipCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.lightbulb_outline,
                color: Colors.orange,
                size: 24,
              ),
              const SizedBox(width: 12),
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
          const SizedBox(height: 12),
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
    );
  }
}
