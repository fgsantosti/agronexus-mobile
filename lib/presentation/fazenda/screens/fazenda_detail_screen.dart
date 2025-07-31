import 'package:agronexus/presentation/bloc/fazenda/fazenda_bloc.dart';
import 'package:agronexus/presentation/fazenda/widgets/acoes_rapidas.dart';
import 'package:agronexus/presentation/fazenda/widgets/estatisticas.dart';
import 'package:agronexus/presentation/fazenda/widgets/informacoes_basicas.dart';
import 'package:agronexus/presentation/fazenda/widgets/lista_lotes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class FazendaDetailScreen extends StatelessWidget {
  const FazendaDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FazendaBloc, FazendaState>(
      builder: (context, state) {
        if (state.status == FazendaStatus.loading) {
          return Center(child: CircularProgressIndicator());
        }
        if (state.status == FazendaStatus.failure) {
          return Center(child: Text('Erro ao carregar detalhes da fazenda'));
        }
        if (state.entity.id == null) {
          return Center(child: Text('Nenhum dado disponível'));
        }
        return ListView(
          padding: EdgeInsets.all(16),
          children: [
            Text(
              state.entity.nome,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            InformacoesBasicas(fazenda: state.entity),
            SizedBox(height: 20),
            Estatisticas(fazenda: state.entity),
            SizedBox(height: 20),
            AcoesRapidas(fazenda: state.entity),
            SizedBox(height: 20),
            if (state.entity.lotes == null || state.entity.lotes!.isEmpty)
              Center(child: Text('Nenhum lote disponível'))
            else ...[
              ListaLotes(lotes: state.entity.lotes!),
              SizedBox(height: 20),
            ],
          ],
        );
      },
    );
  }
}
