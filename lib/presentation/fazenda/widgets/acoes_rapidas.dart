import 'package:agronexus/domain/models/fazenda_entity.dart';
import 'package:agronexus/presentation/fazenda/widgets/fazenda_detalhe_item.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class AcoesRapidas extends StatelessWidget {
  final FazendaEntity fazenda;
  const AcoesRapidas({super.key, required this.fazenda});

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
        crossAxisAlignment: CrossAxisAlignment.start,
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
              icon: FontAwesomeIcons.bolt,
              label: "Ações Rápidas",
              value: "",
              isTitle: true,
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.blue,
                    side: BorderSide(color: Colors.blue),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    iconColor: Colors.blue,
                    padding: EdgeInsets.symmetric(vertical: 5, horizontal: 18),
                    minimumSize: Size(double.infinity, 40),
                  ),
                  onPressed: () {},
                  label: Text("Novo Lote"),
                  icon: Icon(FontAwesomeIcons.plus),
                ),
                SizedBox(height: 16),
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.green,
                    side: BorderSide(color: Colors.green),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    iconColor: Colors.green,
                    padding: EdgeInsets.symmetric(vertical: 5, horizontal: 18),
                    minimumSize: Size(double.infinity, 40),
                  ),
                  onPressed: () {},
                  label: Text("Adicionar Animal"),
                  icon: Icon(FontAwesomeIcons.plus),
                ),
                SizedBox(height: 16),
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.lightBlue,
                    side: BorderSide(color: Colors.lightBlue),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    iconColor: Colors.lightBlue,
                    padding: EdgeInsets.symmetric(vertical: 5, horizontal: 18),
                    minimumSize: Size(double.infinity, 40),
                  ),
                  onPressed: () {},
                  label: Text("Gerar Relatório"),
                  icon: Icon(FontAwesomeIcons.fileLines),
                ),
                SizedBox(height: 16),
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.red,
                    side: BorderSide(color: Colors.red),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    iconColor: Colors.red,
                    padding: EdgeInsets.symmetric(vertical: 5, horizontal: 18),
                    minimumSize: Size(double.infinity, 40),
                  ),
                  onPressed: () {},
                  label: Text("Imprimir Dados"),
                  icon: Icon(FontAwesomeIcons.print),
                ),
                SizedBox(height: 16),
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.green[800],
                    side: BorderSide(color: Colors.green[800]!),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    iconColor: Colors.green[800],
                    padding: EdgeInsets.symmetric(vertical: 5, horizontal: 18),
                    minimumSize: Size(double.infinity, 40),
                  ),
                  onPressed: () {
                    if (fazenda.latitude != null && fazenda.longitude != null) {
                      launchUrl(
                        Uri.parse(
                          "https://www.google.com/maps/search/?api=1&query=${fazenda.latitude},${fazenda.longitude}",
                        ),
                        mode: LaunchMode.externalApplication,
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("Localização não disponível"),
                        ),
                      );
                    }
                  },
                  label: Text("Ver no mapa"),
                  icon: Icon(FontAwesomeIcons.solidMap),
                ),
                SizedBox(height: 8),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
