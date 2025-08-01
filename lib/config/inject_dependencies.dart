import 'package:agronexus/config/services/http.dart';
import 'package:agronexus/config/services/http_impl.dart';
import 'package:agronexus/domain/repositories/local/animal/animal_local_repository.dart';
import 'package:agronexus/domain/repositories/local/animal/animal_local_repository_impl.dart';
import 'package:agronexus/domain/repositories/local/auth/auth_local_repository.dart';
import 'package:agronexus/domain/repositories/local/auth/auth_local_repository_impl.dart';
import 'package:agronexus/domain/repositories/local/dashboard/dashboard_local_repository.dart';
import 'package:agronexus/domain/repositories/local/dashboard/dashboard_local_repository_impl.dart';
import 'package:agronexus/domain/repositories/local/fazenda/fazenda_local_repository.dart';
import 'package:agronexus/domain/repositories/local/fazenda/fazenda_local_repository_impl.dart';
import 'package:agronexus/domain/repositories/local/lote/lote_local_repository.dart';
import 'package:agronexus/domain/repositories/local/lote/lote_local_repository_impl.dart';
import 'package:agronexus/domain/repositories/local/user/user_local_repository.dart';
import 'package:agronexus/domain/repositories/local/user/user_local_repository_impl.dart';
import 'package:agronexus/domain/repositories/remote/animal/animal_remote_repository.dart';
import 'package:agronexus/domain/repositories/remote/animal/animal_remote_repository_impl.dart';
import 'package:agronexus/domain/repositories/remote/auth/auth_repository.dart';
import 'package:agronexus/domain/repositories/remote/auth/auth_repository_impl.dart';
import 'package:agronexus/domain/repositories/remote/dashboard/dashboard_remote_repository.dart';
import 'package:agronexus/domain/repositories/remote/dashboard/dashboard_remote_repository_impl.dart';
import 'package:agronexus/domain/repositories/remote/fazenda/fazenda_remote_repository.dart';
import 'package:agronexus/domain/repositories/remote/fazenda/fazenda_remote_repository_impl.dart';
import 'package:agronexus/domain/repositories/remote/lote/lote_remote_repository.dart';
import 'package:agronexus/domain/repositories/remote/lote/lote_remote_repository_impl.dart';
import 'package:agronexus/domain/repositories/remote/propriedade/propriedade_remote_repository.dart';
import 'package:agronexus/domain/repositories/remote/propriedade/propriedade_remote_repository_impl.dart';
import 'package:agronexus/domain/repositories/remote/user/user_remote_repository.dart';
import 'package:agronexus/domain/repositories/remote/user/user_remote_repository_impl.dart';
import 'package:agronexus/domain/services/animal_service.dart';
import 'package:agronexus/domain/services/auth_service.dart';
import 'package:agronexus/domain/services/dashboard_service.dart';
import 'package:agronexus/domain/services/fazenda_service.dart';
import 'package:agronexus/domain/services/lote_service.dart';
import 'package:agronexus/domain/services/propriedade_service.dart';
import 'package:agronexus/domain/services/user_service.dart';
import 'package:get_it/get_it.dart';

var getIt = GetIt.I;

void configureDependencies() {
  getIt.registerSingleton<HttpService>(HttpServiceImpl());
  getIt.registerSingleton<AuthLocalRepository>(AuthLocalRepositoryImpl());
  getIt.registerSingleton<AuthRemoteRepository>(
    AuthRemoteRepositoryImpl(httpService: getIt()),
  );
  getIt.registerSingleton<UserLocalRepository>(UserLocalRepositoryImpl());
  getIt.registerSingleton<UserRemoteRepository>(
    UserRemoteRepositoryImpl(httpService: getIt()),
  );
  getIt.registerSingleton<UserService>(
    UserService(
      authLocalRepository: getIt(),
      userLocalRepository: getIt(),
      userRemoteRepository: getIt(),
    ),
  );
  getIt.registerSingleton<AuthService>(
    AuthService(
        authLocalRepository: getIt(),
        authRepository: getIt(),
        userService: getIt()),
  );

  getIt.registerSingleton<AnimalLocalRepository>(AnimalLocalRepositoryImpl());
  getIt.registerSingleton<AnimalRemoteRepository>(
    AnimalRemoteRepositoryImpl(httpService: getIt()),
  );
  getIt.registerSingleton<AnimalService>(
    AnimalService(localRepository: getIt(), remoteRepository: getIt()),
  );

  getIt.registerSingleton<DashboardLocalRepository>(
      DashboardLocalRepositoryImpl());
  getIt.registerSingleton<DashboardRemoteRepository>(
    DashboardRemoteRepositoryImpl(httpService: getIt()),
  );
  getIt.registerSingleton<DashboardService>(
    DashboardService(localRepository: getIt(), remoteRepository: getIt()),
  );

  getIt.registerSingleton<FazendaLocalRepository>(FazendaLocalRepositoryImpl());
  getIt.registerSingleton<FazendaRemoteRepository>(
    FazendaRemoteRepositoryImpl(httpService: getIt()),
  );
  getIt.registerSingleton<FazendaService>(
    FazendaService(
      localRepository: getIt(),
      remoteRepository: getIt(),
    ),
  );

  getIt.registerSingleton<LoteLocalRepository>(LoteLocalRepositoryImpl());
  getIt.registerSingleton<LoteRemoteRepository>(
    LoteRemoteRepositoryImpl(httpService: getIt()),
  );
  getIt.registerSingleton<LoteService>(
    LoteService(localRepository: getIt(), remoteRepository: getIt()),
  );

  getIt.registerSingleton<PropriedadeRemoteRepository>(
    PropriedadeRemoteRepositoryImpl(httpService: getIt()),
  );
  getIt.registerSingleton<PropriedadeService>(
    PropriedadeService(remoteRepository: getIt()),
  );
}
