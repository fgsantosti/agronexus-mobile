import 'package:agronexus/presentation/bloc/propriedade/propriedade_bloc.dart';
import 'package:agronexus/presentation/home/widgets/propriedade_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

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
              int totalPropriedades = 0;
              int totalAnimais = 0;
              int totalLotes = 0;
              int totalAreas = 0;
              double totalAreaHa = 0;

              if (state is PropriedadeListLoaded) {
                totalPropriedades = state.entities.length;
                totalAnimais = state.entities.fold(0, (sum, prop) => sum + prop.totalAnimais);
                totalLotes = state.entities.fold(0, (sum, prop) => sum + prop.totalLotes);
                totalAreas = state.entities.fold(0, (sum, prop) => sum + prop.totalAreas);
                totalAreaHa = state.entities.fold(0.0, (sum, prop) {
                  // Converte string para double
                  double area = double.tryParse(prop.areaTotalHa) ?? 0.0;
                  return sum + area;
                });
              }

              return GridView.count(
                crossAxisCount: 2,
                childAspectRatio: 1.2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                children: [
                  _buildDashboardCard(
                    title: 'Propriedades',
                    value: totalPropriedades.toString(),
                    subtitle: '${totalAreaHa.toStringAsFixed(0)} ha total',
                    icon: Icons.home,
                    color: Colors.green,
                  ),
                  _buildDashboardCard(
                    title: 'Animais',
                    value: totalAnimais.toString(),
                    subtitle: 'Total cadastrado',
                    icon: Icons.pets,
                    color: Colors.brown,
                  ),
                  _buildDashboardCard(
                    title: 'Lotes',
                    value: totalLotes.toString(),
                    subtitle: 'Em todas propriedades',
                    icon: Icons.grid_view,
                    color: Colors.blue,
                  ),
                  _buildDashboardCard(
                    title: 'Áreas',
                    value: totalAreas.toString(),
                    subtitle: 'Total de áreas',
                    icon: Icons.crop_landscape,
                    color: Colors.orange,
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
                        children: propriedades
                            .map((e) => PropriedadeCard(propriedade: e))
                            .toList(),
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
    );
  }
}
