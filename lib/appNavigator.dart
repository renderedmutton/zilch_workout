import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zilch_workout/auth/authCubit.dart';
import 'package:zilch_workout/auth/authNavigator.dart';
import 'package:zilch_workout/dataRepository.dart';
import 'package:zilch_workout/loadingView.dart';
import 'package:zilch_workout/presession/presessionBloc.dart';
import 'package:zilch_workout/presession/presessionEvent.dart';
import 'package:zilch_workout/presession/presessionView.dart';
import 'package:zilch_workout/session/sessionCubit.dart';
import 'package:zilch_workout/session/sessionState.dart';
import 'package:zilch_workout/session/sessionView.dart';
import 'package:rate_my_app/rate_my_app.dart';

class AppNavigator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return RateMyAppBuilder(
        rateMyApp: RateMyApp(
          minDays: 0,
          minLaunches: 3,
          googlePlayIdentifier: 'com.zilchWorkout.zilchWorkout',
          appStoreIdentifier: '1579800590',
        ),
        onInitialized: (context, rateMyApp) {
          if (rateMyApp.shouldOpenDialog) rateMyApp.showRateDialog(context);
        },
        builder: (context) {
          return BlocBuilder<SessionCubit, SessionState>(
              builder: (context, state) {
            return Navigator(
              pages: [
                //show loading screen
                if (state is UnknownSessionState)
                  MaterialPage(child: LoadingView()),

                //show auth flow
                if (state is Unauthenticated)
                  MaterialPage(
                    child: BlocProvider(
                      create: (context) =>
                          AuthCubit(context.read<SessionCubit>()),
                      child: AuthNavigator(),
                    ),
                  ),
                if (state is AuthenticatedWithoutUser)
                  MaterialPage(
                    child: BlocProvider(
                      create: (context) => PresessionBloc(
                          userId: state.userId,
                          username: state.username,
                          nickname: state.nickname,
                          dataRepo: context.read<DataRepository>(),
                          sessionCubit: context.read<SessionCubit>())
                        ..add(ReadyPresession()),
                      child: PresessionView(),
                    ),
                  ),

                //show main page
                if (state is Authenticated)
                  MaterialPage(child: SessionView(state.user)),
              ],
              onPopPage: (route, result) => route.didPop(result),
            );
          });
        });
  }
}
