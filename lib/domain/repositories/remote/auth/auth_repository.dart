import 'package:agronexus/config/exceptions.dart';
import 'package:agronexus/domain/models/user_entity.dart';
import 'package:dartz/dartz.dart';

abstract class AuthRemoteRepository {
  Future<Either<AgroNexusException, UserEntity>> login({
    required String email,
    required String password,
  });
  Future<Either<AgroNexusException, Map<String, dynamic>>> refresh();
  Future<Either<AgroNexusException, Map<String, dynamic>>> revoke();
}
