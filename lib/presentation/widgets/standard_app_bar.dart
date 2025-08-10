import 'package:flutter/material.dart';

/// AppBar padrão do projeto (fundo verde, ícones/branco, seta de voltar opcional).
AppBar buildStandardAppBar({
  required String title,
  List<Widget>? actions,
  bool showBack = true,
  PreferredSizeWidget? bottom,
}) {
  return AppBar(
    title: Text(title),
    backgroundColor: Colors.green.shade600,
    foregroundColor: Colors.white,
    iconTheme: const IconThemeData(color: Colors.white),
    titleTextStyle: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600),
    centerTitle: false,
    elevation: 0,
    leading: showBack
        ? Builder(
            builder: (ctx) => IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                final navigator = Navigator.of(ctx);
                if (navigator.canPop()) navigator.pop();
              },
            ),
          )
        : null,
    actions: actions,
    bottom: bottom,
  );
}
