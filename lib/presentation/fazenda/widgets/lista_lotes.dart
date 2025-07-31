import 'package:agronexus/config/utils.dart';
import 'package:agronexus/domain/models/lote_entity.dart';
import 'package:agronexus/presentation/fazenda/widgets/fazenda_detalhe_item.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ListaLotes extends StatelessWidget {
  final List<LoteEntity> lotes;
  const ListaLotes({super.key, required this.lotes});

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
              icon: FontAwesomeIcons.solidClone,
              label: "Lotes da Fazenda",
              value: "${lotes.length} lotes",
              isTitle: true,
            ),
          ),
          Padding(
            padding: EdgeInsets.only(left: 16, right: 16, bottom: 16, top: 8),
            child: Column(
              children: lotes
                  .map(
                    (lote) => Container(
                      margin: EdgeInsets.only(bottom: 8),
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: lote.ativa ? Colors.green : Colors.red,
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withValues(alpha: 0.2),
                            spreadRadius: 1,
                            blurRadius: 3,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                lote.nomeLote,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(formatDateToUser(date: lote.dataEntrada)),
                            ],
                          ),
                          SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Animais: ${lote.totalAnimais}",
                              ),
                              Text(
                                "Status: ${lote.ativa ? "Ativo" : "Inativo"}",
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              IconButton(
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(color: Colors.blue),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  iconColor: Colors.blue,
                                  padding: EdgeInsets.only(left: 8, right: 8),
                                ),
                                onPressed: () {},
                                icon: FaIcon(FontAwesomeIcons.pen),
                              ),
                              SizedBox(width: 8),
                              IconButton(
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(color: Colors.red),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  iconColor: Colors.red,
                                  padding: EdgeInsets.only(left: 8, right: 8),
                                ),
                                onPressed: () {},
                                icon: FaIcon(FontAwesomeIcons.trash),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}
