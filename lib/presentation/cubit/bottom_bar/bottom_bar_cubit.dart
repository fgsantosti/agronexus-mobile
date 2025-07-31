import 'package:agronexus/config/routers/router.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

part 'bottom_bar_state.dart';

class BottomBarCubit extends Cubit<BottomBarState> {
  BottomBarCubit() : super(const BottomBarState(item: BottomBarItems.home));

  void setItem({required BottomBarItems item}) {
    emit(BottomBarState(item: item));
  }
}
