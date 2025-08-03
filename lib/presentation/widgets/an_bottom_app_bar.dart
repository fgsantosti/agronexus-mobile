import 'package:agronexus/presentation/cubit/bottom_bar/bottom_bar_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class AnBottomAppBar extends StatefulWidget {
  const AnBottomAppBar({super.key});

  @override
  State<AnBottomAppBar> createState() => _AnBottomAppBarState();
}

class _AnBottomAppBarState extends State<AnBottomAppBar> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BottomBarCubit, BottomBarState>(
        builder: (context, state) {
      return Container(
        height: 60,
        padding: const EdgeInsets.symmetric(horizontal: 30),
        decoration: BoxDecoration(
          color: Colors.green[800],
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: BottomBarItems.values
              .map(
                (e) => InkWell(
                  onTap: () {
                    context.read<BottomBarCubit>().setItem(item: e);
                    GoRouter.of(context).pushReplacement(e.route);
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        e.icon,
                        color: state.item == e ? Colors.white : Colors.white54,
                        size: state.item == e ? 30 : 24,
                      ),
                      const SizedBox(height: 5),
                      if (state.item != e)
                        Text(
                          e.label,
                          style: TextStyle(
                            color:
                                state.item == e ? Colors.white : Colors.white54,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                    ],
                  ),
                ),
              )
              .toList(),
        ),
      );
    });
  }
}
