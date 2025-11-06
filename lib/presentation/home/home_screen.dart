import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:agronexus/config/api.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:agronexus/presentation/cubit/bottom_bar/bottom_bar_cubit.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:agronexus/config/services/showcase_service.dart';
import 'package:agronexus/config/inject_dependencies.dart';

class FunctionalityData {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final Color backgroundColor;
  final Future<void> Function()? onTap;
  final GlobalKey? showcaseKey;

  FunctionalityData({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.backgroundColor,
    this.onTap,
    this.showcaseKey,
  });
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ShowcaseService _showcaseService = getIt<ShowcaseService>();
  bool _showcaseChecked = false; // Flag para evitar verificação múltipla

  // Keys para o showcase
  final GlobalKey _welcomeKey = GlobalKey();
  final GlobalKey _propriedadesKey = GlobalKey();
  final GlobalKey _animaisKey = GlobalKey();
  final GlobalKey _manejoKey = GlobalKey();

  @override
  void initState() {
    super.initState();

    // Verificar e iniciar showcase após o build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_showcaseChecked) {
        _checkAndStartShowcase();
      }
    });
  }

  Future<void> _checkAndStartShowcase() async {
    _showcaseChecked = true;
    final showcaseCompleted = await _showcaseService.isHomeShowcaseCompleted();

    if (!showcaseCompleted && mounted) {
      // Pequeno delay para garantir que tudo foi renderizado
      await Future.delayed(const Duration(milliseconds: 500));

      if (mounted) {
        ShowCaseWidget.of(context).startShowCase([
          _welcomeKey,
          _propriedadesKey,
          _animaisKey,
          _manejoKey,
        ]);
      }
    }
  }

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
    return Showcase(
      key: _welcomeKey,
      title: 'Bem-vindo ao AgroNexus!',
      description: 'Este é seu painel principal. Aqui você pode acessar todas as funcionalidades do sistema de gestão rural.',
      targetShapeBorder: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
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
          childAspectRatio = 1.1; // Aumentado de 1.0 para 1.1 para dar mais altura
          crossAxisSpacing = 12;
          mainAxisSpacing = 12;
        } else {
          // Phone muito pequeno
          crossAxisCount = 1;
          childAspectRatio = 2.2; // Aumentado de 2.8 para 2.2 para dar mais altura aos cards
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
          itemCount: 3, // Reduzido de 6 para 3 (removidos cards em desenvolvimento)
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
        final titleFontSize = (cardWidth * 0.045).clamp(16.0, 20.0); // Aumentado o mínimo de 14 para 16
        final subtitleFontSize = (cardWidth * 0.035).clamp(13.0, 16.0); // Aumentado o mínimo de 11 para 13
        final padding = (cardWidth * 0.08).clamp(12.0, 20.0);

        Widget cardWidget = Container(
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
                    SizedBox(height: cardHeight * 0.06), // Reduzido de 0.08 para 0.06
                    Expanded(
                      // Mudado de Flexible para Expanded para garantir espaço
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
                    SizedBox(height: cardHeight * 0.01), // Reduzido de 0.02 para 0.01
                    Expanded(
                      // Mudado de Flexible para Expanded para garantir espaço
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

        // Se houver uma key de showcase, envolver o card com Showcase
        if (item.showcaseKey != null) {
          String description = '';
          String title = item.title;

          if (item.title == 'Propriedades') {
            title = '⚠️ Comece por aqui!';
            description = 'IMPORTANTE: Antes de utilizar o sistema, você precisa cadastrar uma propriedade. '
                'Toque aqui para acessar o cadastro de propriedades e criar sua primeira propriedade rural.';
          } else if (item.title == 'Animais') {
            description = 'Após cadastrar uma propriedade, você pode começar a cadastrar os animais do seu rebanho. '
                'Aqui você gerencia todas as informações dos animais.';
          } else if (item.title == 'Manejo Reprodutivo') {
            description = 'Controle todas as atividades reprodutivas do seu rebanho: inseminações, gestações, '
                'partos e diagnósticos de prenhez.';
          }

          return Showcase(
            key: item.showcaseKey!,
            title: title,
            description: description,
            targetShapeBorder: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            onTargetClick: () async {
              // Marcar como completo ANTES de qualquer navegação
              await _showcaseService.setHomeShowcaseCompleted();

              // Fechar o showcase
              if (mounted) {
                ShowCaseWidget.of(context).dismiss();
              }

              // Executar a ação do card
              if (item.onTap != null && mounted) {
                item.onTap!();
              }
            },
            disposeOnTap: true,
            onToolTipClick: () async {
              // Marcar como completo quando clicar no tooltip
              await _showcaseService.setHomeShowcaseCompleted();
            },
            child: cardWidget,
          );
        }

        return cardWidget;
      },
    );
  }

  FunctionalityData _getFunctionalityData(int index) {
    final functionalities = [
      // Cards em desenvolvimento - temporariamente desativados
      /*
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
      */
      FunctionalityData(
        title: 'Manejo Reprodutivo',
        subtitle: 'Controle reprodutivo',
        icon: Icons.favorite,
        color: Colors.pink,
        backgroundColor: Colors.pink[50]!,
        showcaseKey: _manejoKey,
        onTap: () async {
          // Marcar showcase como completo antes de navegar
          await _showcaseService.setHomeShowcaseCompleted();
          if (mounted) {
            context.push(API.manejoReprodutivoRoute);
          }
        },
      ),
      FunctionalityData(
        title: 'Propriedades',
        subtitle: 'Gerenciar propriedades',
        icon: Icons.home_work,
        color: Colors.green,
        backgroundColor: Colors.green[50]!,
        showcaseKey: _propriedadesKey,
        onTap: () async {
          // Marcar showcase como completo antes de navegar
          await _showcaseService.setHomeShowcaseCompleted();
          if (mounted) {
            // Atualizar o estado da bottom bar para propriedades
            context.read<BottomBarCubit>().setItem(item: BottomBarItems.propriedades);
            context.go(API.propriedadesRoute);
          }
        },
      ),
      FunctionalityData(
        title: 'Animais',
        subtitle: 'Controle do rebanho',
        icon: Icons.pets,
        color: Colors.brown,
        backgroundColor: Colors.brown[50]!,
        showcaseKey: _animaisKey,
        onTap: () async {
          // Marcar showcase como completo antes de navegar
          await _showcaseService.setHomeShowcaseCompleted();
          if (mounted) {
            // Atualizar o estado da bottom bar para animais
            context.read<BottomBarCubit>().setItem(item: BottomBarItems.animais);
            context.go(API.animaisRoute);
          }
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
