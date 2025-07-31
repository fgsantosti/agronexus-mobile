part of 'dashboard_bloc.dart';

abstract class DashboardEvent extends Equatable {
  const DashboardEvent();
}

class GetDashboardEvent extends DashboardEvent {
  const GetDashboardEvent();

  @override
  List<Object?> get props => [];
}
