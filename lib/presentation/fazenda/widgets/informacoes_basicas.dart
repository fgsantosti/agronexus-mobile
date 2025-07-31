import 'package:agronexus/domain/models/fazenda_entity.dart';
import 'package:agronexus/presentation/fazenda/widgets/fazenda_detalhe_item.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class InformacoesBasicas extends StatelessWidget {
  final FazendaEntity fazenda;
  const InformacoesBasicas({super.key, required this.fazenda});

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
              icon: FontAwesomeIcons.circleInfo,
              label: "Informações Básicas",
              value: "",
              isTitle: true,
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FazendaDetalheItem(
                  icon: FontAwesomeIcons.locationDot,
                  label: "Localização",
                  value: fazenda.localizacao,
                ),
                SizedBox(height: 8),
                FazendaDetalheItem(
                  icon: FontAwesomeIcons.rulerCombined,
                  label: "Tamanho",
                  value: "${fazenda.hectares} hectares",
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    Icon(FontAwesomeIcons.tags, color: Colors.black, size: 20),
                    SizedBox(width: 8),
                    Text(
                      "Tipo",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.black,
                      ),
                    ),
                    Spacer(),
                    Container(
                      padding: EdgeInsets.symmetric(
                        vertical: 4,
                        horizontal: 8,
                      ),
                      decoration: BoxDecoration(
                        color: fazenda.tipo.color.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: fazenda.tipo.color,
                          width: 2,
                        ),
                      ),
                      child: Text(
                        fazenda.tipo.label,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                FazendaDetalheItem(
                  icon: fazenda.ativa
                      ? FontAwesomeIcons.check
                      : FontAwesomeIcons.xmark,
                  label: "Ativa",
                  value: fazenda.ativa ? "Sim" : "Não",
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
