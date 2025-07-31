part of 'dashboard_bloc.dart';

enum DashboardStatus { loading, success, failure }

class DashboardState extends Equatable {
  final DashboardStatus status;
  final DashboardEntity? entity;
  final String? errorMessage;

  const DashboardState({
    this.status = DashboardStatus.loading,
    this.entity,
    this.errorMessage,
  });

  DashboardState copyWith({
    AgroNexusGetter<DashboardStatus>? status,
    AgroNexusGetter<DashboardEntity?>? entity,
    AgroNexusGetter<String?>? errorMessage,
  }) {
    return DashboardState(
      status: status != null ? status() : this.status,
      entity: entity != null ? entity() : this.entity,
      errorMessage: errorMessage != null ? errorMessage() : this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, entity, errorMessage];
}
