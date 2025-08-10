import 'package:flutter/material.dart';

/// Menu de ações padronizado exibindo Editar e Excluir.
/// Uso:
/// EntityActionMenu(
///   onDetails: () {},
/// )
class EntityActionMenu extends StatelessWidget {
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final IconData icon;
  final double iconSize;
  final EdgeInsetsGeometry? padding;

  const EntityActionMenu({
    super.key,
    this.onEdit,
    this.onDelete,
    this.icon = Icons.more_vert,
    this.iconSize = 24,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<_ActionKey>(
      padding: padding ?? EdgeInsets.zero,
      icon: Icon(icon, size: iconSize),
      onSelected: (value) {
        switch (value) {
          case _ActionKey.edit:
            onEdit?.call();
            break;
          case _ActionKey.delete:
            onDelete?.call();
            break;
        }
      },
      itemBuilder: (context) {
        return [
          if (onEdit != null)
            const PopupMenuItem(
              value: _ActionKey.edit,
              child: Row(
                children: [
                  Icon(Icons.edit, size: 20),
                  SizedBox(width: 8),
                  Text('Editar'),
                ],
              ),
            ),
          if (onDelete != null)
            const PopupMenuItem(
              value: _ActionKey.delete,
              child: Row(
                children: [
                  Icon(Icons.delete, size: 20, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Excluir', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
        ];
      },
    );
  }
}

enum _ActionKey { edit, delete }

/// Helper para AppBars de telas de detalhes com padrão verde e ícones brancos.
PreferredSizeWidget buildDetailAppBar(String titulo) {
  return AppBar(
    backgroundColor: Colors.green.shade600,
    centerTitle: true,
    iconTheme: const IconThemeData(color: Colors.white),
    titleTextStyle: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600),
    title: Text(titulo),
  );
}
