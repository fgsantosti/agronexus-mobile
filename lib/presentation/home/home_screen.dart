import 'package:agronexus/presentation/bloc/propriedade/propriedade_bloc.dart';
import 'package:agronexus/presentation/home/widgets/propriedade_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Carregar propriedades ao inicializar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PropriedadeBloC>().add(ListPropriedadeEvent());
    });
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<PropriedadeBloC>().add(ListPropriedadeEvent());
      },
      child: ListView(
        padding: EdgeInsets.only(left: 10, right: 10, top: 10, bottom: 20),
        children: [
          // Dashboard com dados reais
          BlocBuilder<PropriedadeBloC, PropriedadeState>(
            builder: (context, state) {
              return GridView.count(
                crossAxisCount: 2,
                childAspectRatio: 1.2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                children: [
                  _buildDashboardCard(
                    title: 'Inteligente',
                    value: 'Calendário',
                    subtitle: 'Próximas atividades',
                    icon: Icons.calendar_today,
                    color: Colors.green,
                    onTap: () {
                      // TODO: Navegar para tela de calendário
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Calendário em desenvolvimento')),
                      );
                    },
                  ),
                  _buildDashboardCard(
                    title: 'Receitas/Despesas',
                    value: 'Finanças',
                    subtitle: 'Controle financeiro',
                    icon: Icons.monetization_on,
                    color: Colors.amber,
                    onTap: () {
                      // TODO: Navegar para tela de finanças
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Finanças em desenvolvimento')),
                      );
                    },
                  ),
                  _buildDashboardCard(
                    title: 'Manejo Sanitário',
                    value: 'Saúde',
                    subtitle: 'Controle veterinário',
                    icon: Icons.medical_services,
                    color: Colors.red,
                    onTap: () {
                      // TODO: Navegar para tela de manejo sanitário
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Manejo sanitário em desenvolvimento')),
                      );
                    },
                  ),
                  _buildDashboardCard(
                    title: 'Manejo Reprodutivo',
                    value: 'Reprodução',
                    subtitle: 'Controle reprodutivo',
                    icon: Icons.favorite,
                    color: Colors.pink,
                    onTap: () {
                      context.go('/manejo-reprodutivo');
                    },
                  ),
                ],
              );
            },
          ),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Minhas Propriedades',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                ),
                onPressed: () {
                  // TODO: Implementar navegação para nova propriedade
                },
                label: Text("Nova Propriedade"),
                icon: Icon(FontAwesomeIcons.plus),
              ),
            ],
          ),
          SizedBox(height: 15),
          BlocBuilder<PropriedadeBloC, PropriedadeState>(
            builder: (context, state) {
              if (state is PropriedadeLoading) {
                return Center(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: CircularProgressIndicator(),
                  ),
                );
              }
              if (state is PropriedadeError) {
                return Card(
                  color: Colors.red[50],
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Icon(Icons.error, color: Colors.red, size: 48),
                        SizedBox(height: 8),
                        Text(
                          'Erro ao carregar propriedades',
                          style: TextStyle(
                            color: Colors.red[700],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          state.message,
                          style: TextStyle(color: Colors.red[600]),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: () {
                            context.read<PropriedadeBloC>().add(ListPropriedadeEvent());
                          },
                          child: Text('Tentar Novamente'),
                        ),
                      ],
                    ),
                  ),
                );
              }
              if (state is PropriedadeListLoaded) {
                final propriedades = state.entities;
                return propriedades.isEmpty
                    ? Card(
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Column(
                            children: [
                              Icon(Icons.home_outlined, size: 48, color: Colors.grey),
                              SizedBox(height: 8),
                              Text(
                                'Nenhuma propriedade cadastrada',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[600],
                                ),
                              ),
                              SizedBox(height: 8),
                              ElevatedButton(
                                onPressed: () {
                                  // TODO: Implementar navegação para nova propriedade
                                },
                                child: Text('Cadastrar Primeira Propriedade'),
                              ),
                            ],
                          ),
                        ),
                      )
                    : Column(
                        children: propriedades.map((e) => PropriedadeCard(propriedade: e)).toList(),
                      );
              }
              return Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('Carregue as propriedades'),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardCard({
    required String title,
    required String value,
    String? subtitle,
    required IconData icon,
    required Color color,
    VoidCallback? onTap,
  }) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
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
            children: [
              Icon(icon, color: color, size: 32),
              SizedBox(height: 8),
              Text(
                value,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[700],
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
