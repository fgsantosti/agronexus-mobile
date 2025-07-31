import 'package:agronexus/domain/models/fazenda_entity.dart';
import 'package:agronexus/presentation/fazenda/widgets/estatistica_detalhes.dart';
import 'package:agronexus/presentation/fazenda/widgets/fazenda_detalhe_item.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class Estatisticas extends StatelessWidget {
  final FazendaEntity fazenda;
  const Estatisticas({super.key, required this.fazenda});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.2),
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
            child: FazendaDetalheItem(
              icon: FontAwesomeIcons.chartSimple,
              label: "Estatísticas",
              value: "",
              isTitle: true,
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text(
                    fazenda.lotes?.length.toString() ?? "0",
                    style: TextStyle(
                      fontSize: 35,
                      color: Colors.black,
                    ),
                  ),
                ),
                Center(
                  child: Text(
                    "Lotes Ativos",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                    ),
                  ),
                ),
                SizedBox(height: 16),
                EstatisticaDetalhe(
                  color: Colors.green,
                  label: "Animais Ativos",
                  value: fazenda.totalAnimaisAtivos?.toString() ?? '0',
                ),
                SizedBox(height: 8),
                EstatisticaDetalhe(
                  color: Colors.red,
                  label: "Para Abate",
                  value: fazenda.totalAnimaisAbate?.toString() ?? '0',
                ),
                SizedBox(height: 8),
                EstatisticaDetalhe(
                  color: Colors.amber[700]!,
                  label: "Para Venda",
                  value: fazenda.totalAnimaisAbate?.toString() ?? '0',
                ),
                SizedBox(height: 8),
                EstatisticaDetalhe(
                  color: Colors.blue,
                  label: "Para Leilão",
                  value: fazenda.totalAnimaisLeilao?.toString() ?? '0',
                ),
                SizedBox(height: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
