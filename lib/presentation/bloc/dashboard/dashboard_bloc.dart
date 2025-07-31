import 'package:agronexus/config/utils.dart';
import 'package:agronexus/domain/models/dashboard_entity.dart';
import 'package:agronexus/domain/services/dashboard_service.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'dashboard_events.dart';
part 'dashboard_state.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final DashboardService service;

  DashboardBloc({required this.service}) : super(const DashboardState()) {
    on<GetDashboardEvent>(_onDashboardDetailEvent);
  }

  void _onDashboardDetailEvent(
    GetDashboardEvent event,
    Emitter<DashboardState> emit,
  ) async {
    emit(state.copyWith(status: () => DashboardStatus.loading));
    try {
      final DashboardEntity result = await service.getEntity();
      emit(
        state.copyWith(
          status: () => DashboardStatus.success,
          entity: () => result,
        ),
      );
    } catch (e) {
      emit(state.copyWith(status: () => DashboardStatus.failure));
    }
  }
}
