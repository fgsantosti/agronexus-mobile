import 'package:agronexus/config/routers/router.dart';
import 'package:agronexus/presentation/bloc/login/login_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[50],
      body: BlocListener<LoginBloc, LoginState>(
        listener: (context, state) async {
          GoRouter router = GoRouter.of(context);
          if (state.status == LoginStatus.success) {
            await Future.delayed(Duration(seconds: 3));
            router.go(AgroNexusRouter.home.path);
          }
          if (state.status == LoginStatus.initial) {
            await Future.delayed(Duration(seconds: 3));
            router.go(AgroNexusRouter.login.path);
          }
        },
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/logo.png', width: 150)
                  .animate()
                  .scale(duration: Duration(milliseconds: 500))
                  .then(delay: Duration(milliseconds: 300))
                  .shake(),
              SizedBox(height: 20),
              Text(
                'AgroNexus',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.green[800],
                ),
              ).animate().fadeIn().slideY(),
              SizedBox(height: 10),
              CircularProgressIndicator(color: Colors.green)
                  .animate()
                  .rotate(duration: Duration(seconds: 1))
                  .then(delay: Duration(milliseconds: 300))
                  .fadeIn(),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
