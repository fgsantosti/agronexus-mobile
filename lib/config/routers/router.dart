import 'package:agronexus/config/inject_dependencies.dart';
import 'package:agronexus/config/routers/utils.dart';
import 'package:agronexus/domain/models/fazenda_entity.dart';
import 'package:agronexus/presentation/bloc/fazenda/fazenda_bloc.dart';
import 'package:agronexus/presentation/bloc/login/login_bloc.dart';
import 'package:agronexus/presentation/bloc/propriedade/propriedade_bloc.dart';
import 'package:agronexus/presentation/bloc/reproducao/reproducao_bloc.dart';
import 'package:agronexus/presentation/cubit/bottom_bar/bottom_bar_cubit.dart';
import 'package:agronexus/presentation/fazenda/screens/fazenda_add_screen.dart';
import 'package:agronexus/presentation/fazenda/screens/fazenda_detail_screen.dart';
import 'package:agronexus/presentation/home/home_screen.dart';
import 'package:agronexus/presentation/login/login_screen.dart';
import 'package:agronexus/presentation/reproducao/manejo_reprodutivo_screen.dart';
import 'package:agronexus/presentation/splash/splash_screen.dart';
import 'package:agronexus/presentation/widgets/internal_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

enum AgroNexusRouter {
  login(path: loginPath),
  home(path: homePath),
  splash(path: splashPath),
  fazenda(path: fazendaPath),
  lotes(path: lotesPath),
  animais(path: animaisPath),
  perfil(path: perfilPath),
  manejoReprodutivo(path: manejoReprodutivoPath),
  ;

  static const String add = "/add";
  static const String listing = "/listing";
  static const String edit = "/edit:id";
  static const String detail = "/detail:id";

  String get addPath => '$path$add';
  String get listingPath => '$path$listing';
  String get editPath => '$path$edit';
  String get detailPath => '$path$detail';

  static const String loginPath = '/login';
  static const String splashPath = '/splash';
  static const String homePath = '/home';
  static const String fazendaPath = '/fazenda';
  static const String lotesPath = "/lotes";
  static const String animaisPath = "/animais";
  static const String perfilPath = "/perfil";
  static const String manejoReprodutivoPath = "/manejo-reprodutivo";

  final String path;
  const AgroNexusRouter({required this.path});

  static GoRouter router = GoRouter(
    initialLocation: splash.path,
    routes: [
      // SPLASH SCREEN
      GoRoute(
        path: splash.path,
        builder: (context, state) => MultiBlocProvider(
          providers: [
            BlocProvider(
              create: (context) => LoginBloc(
                authService: getIt(),
                userService: getIt(),
              )..add(AutoLoginEvent()),
            )
          ],
          child: SplashScreen(),
        ),
      ),
      // LOGIN SCREEN
      GoRoute(
        path: login.path,
        builder: (context, state) => MultiBlocProvider(
          providers: [
            BlocProvider(
              create: (context) => LoginBloc(
                authService: getIt(),
                userService: getIt(),
              ),
            )
          ],
          child: LoginScreen(),
        ),
      ),
      ShellRoute(
        builder: (context, state, child) => MultiBlocProvider(providers: [
          BlocProvider(
            create: (context) => LoginBloc(
              authService: getIt(),
              userService: getIt(),
            )..add(GetUserLoginEvent()),
          ),
          BlocProvider(create: (context) => BottomBarCubit()),
        ], child: InternalScaffold(child: child)),
        routes: [
          // HOME SCREEN
          GoRoute(
            path: home.path,
            pageBuilder: (context, state) {
              return CustomTransitionPage(
                key: state.pageKey,
                transitionDuration: RoutesUtils.duration,
                transitionsBuilder: RoutesUtils.transitionBuilder,
                child: MultiBlocProvider(
                  providers: [
                    // Dashboard temporariamente comentado - endpoint não existe
                    // BlocProvider(
                    //   create: (context) => DashboardBloc(service: getIt())
                    //     ..add(GetDashboardEvent()),
                    // ),
                    // Fazenda temporariamente comentado - endpoint não existe
                    // BlocProvider(
                    //   create: (context) => FazendaBloc(service: getIt())
                    //     ..add(ListFazendaEvent()),
                    // ),
                    BlocProvider(
                      create: (context) => PropriedadeBloC(service: getIt()),
                    ),
                  ],
                  child: HomeScreen(),
                ),
              );
            },
          ),
          // FAZENDA SCREEN
          GoRoute(
            path: fazenda.path,
            pageBuilder: (context, state) {
              return CustomTransitionPage(
                key: state.pageKey,
                transitionDuration: RoutesUtils.duration,
                transitionsBuilder: RoutesUtils.transitionBuilder,
                child: MultiBlocProvider(
                  providers: [
                    BlocProvider(
                      create: (context) => FazendaBloc(service: getIt())..add(ListFazendaEvent()),
                    ),
                  ],
                  child: Center(child: Text("Fazenda")),
                ),
              );
            },
            routes: [
              // ADD
              GoRoute(
                path: add,
                pageBuilder: (context, state) {
                  return CustomTransitionPage(
                    key: state.pageKey,
                    transitionDuration: RoutesUtils.duration,
                    transitionsBuilder: RoutesUtils.transitionBuilder,
                    child: MultiBlocProvider(
                      providers: [
                        BlocProvider(
                          create: (context) => FazendaBloc(service: getIt())
                            ..add(
                              UpdateLoadedFazendaEvent(
                                entity: FazendaEntity.empty(),
                              ),
                            ),
                        ),
                      ],
                      child: FazendaAddScreen(),
                    ),
                  );
                },
              ),
              // EDIT
              GoRoute(
                path: edit,
                pageBuilder: (context, state) {
                  final String entityId = state.extra as String? ?? "";
                  return CustomTransitionPage(
                    key: state.pageKey,
                    transitionDuration: RoutesUtils.duration,
                    transitionsBuilder: RoutesUtils.transitionBuilder,
                    child: MultiBlocProvider(
                      providers: [
                        BlocProvider(
                          create: (context) => FazendaBloc(service: getIt())..add(FazendaDetailEvent(id: entityId)),
                        ),
                      ],
                      child: FazendaAddScreen(),
                    ),
                  );
                },
              ),
              // DETAIL
              GoRoute(
                path: detail,
                pageBuilder: (context, state) {
                  final String entityId = state.extra as String? ?? "";
                  return CustomTransitionPage(
                    key: state.pageKey,
                    transitionDuration: RoutesUtils.duration,
                    transitionsBuilder: RoutesUtils.transitionBuilder,
                    child: MultiBlocProvider(
                      providers: [
                        BlocProvider(
                          create: (context) => FazendaBloc(service: getIt())..add(FazendaDetailEvent(id: entityId)),
                        ),
                      ],
                      child: FazendaDetailScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
          // LOTES SCREEN
          GoRoute(
            path: lotes.path,
            pageBuilder: (context, state) {
              return CustomTransitionPage(
                key: state.pageKey,
                transitionDuration: RoutesUtils.duration,
                transitionsBuilder: RoutesUtils.transitionBuilder,
                child: Center(child: Text("Lotes")),
              );
            },
          ),
          // ANIMAIS SCREEN
          GoRoute(
            path: animais.path,
            pageBuilder: (context, state) {
              return CustomTransitionPage(
                key: state.pageKey,
                transitionDuration: RoutesUtils.duration,
                transitionsBuilder: RoutesUtils.transitionBuilder,
                child: Center(child: Text("Animais")),
              );
            },
          ),
          // Perfil SCREEN
          GoRoute(
            path: perfil.path,
            pageBuilder: (context, state) {
              return CustomTransitionPage(
                key: state.pageKey,
                transitionDuration: RoutesUtils.duration,
                transitionsBuilder: RoutesUtils.transitionBuilder,
                child: Center(child: Text("Perfil")),
              );
            },
          ),
          // Manejo Reprodutivo SCREEN
          GoRoute(
            path: manejoReprodutivo.path,
            pageBuilder: (context, state) {
              return CustomTransitionPage(
                key: state.pageKey,
                transitionDuration: RoutesUtils.duration,
                transitionsBuilder: RoutesUtils.transitionBuilder,
                child: MultiBlocProvider(
                  providers: [
                    BlocProvider(
                      create: (context) => ReproducaoBloc(getIt()),
                    ),
                  ],
                  child: ManejoReprodutivoScreen(),
                ),
              );
            },
          ),
        ],
      ),
    ],
  );
}
