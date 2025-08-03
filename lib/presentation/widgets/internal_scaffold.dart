import 'package:agronexus/config/routers/router.dart';
import 'package:agronexus/presentation/bloc/login/login_bloc.dart';
import 'package:agronexus/presentation/widgets/an_bottom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class InternalScaffold extends StatelessWidget {
  final Widget child;
  const InternalScaffold({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return BlocListener<LoginBloc, LoginState>(
      listener: (context, state) {
        // Quando o estado for initial (após logout), redireciona para login
        if (state.status == LoginStatus.initial && state.user == null) {
          GoRouter.of(context).go(AgroNexusRouter.login.path);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          // Logo no canto esquerdo
          leading: GoRouter.of(context).canPop()
              ? IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () {
                    GoRouter.of(context).pop();
                  },
                )
              : Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Image.asset(
                    'assets/logo.png',
                    height: 40,
                    width: 40,
                    fit: BoxFit.contain,
                  ),
                ),
          title: null,
          centerTitle: false,
          backgroundColor: Colors.green[800],
          toolbarHeight: 80,
          iconTheme: const IconThemeData(
            color: Colors.white,
            size: 30,
          ),
          // shape: const RoundedRectangleBorder(
          //   borderRadius: BorderRadius.only(
          //     bottomLeft: Radius.circular(20),
          //     bottomRight: Radius.circular(20),
          //   ),
          // ),
          actions: [
            BlocBuilder<LoginBloc, LoginState>(
              builder: (context, state) {
                return IconButton(
                  onPressed: state.status == LoginStatus.loading
                      ? null // Desabilita o botão durante o logout
                      : () {
                          context.read<LoginBloc>().add(LogoutLoginEvent());
                        },
                  icon: state.status == LoginStatus.loading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Icon(Icons.exit_to_app),
                );
              },
            ),
            SizedBox(width: 10),
          ],
        ),
        body: child,
        bottomNavigationBar: AnBottomAppBar(),
      ),
    );
  }
}
