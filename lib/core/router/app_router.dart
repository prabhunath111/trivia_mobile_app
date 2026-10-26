import 'package:go_router/go_router.dart';

import '../../data/models/game_mode.dart';
import '../../presentation/game/state/quiz_state.dart';
import '../../presentation/game/view/quiz_screen.dart';
import '../../presentation/home/home_screen.dart';
import '../../presentation/result/result_screen.dart';

GoRouter buildAppRouter() {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/game/:mode',
        name: 'game',
        builder: (context, state) {
          final modeParam = state.pathParameters['mode'];
          final mode = GameMode.values.firstWhere(
            (m) => m.name == modeParam,
            orElse: () => GameMode.classicQuiz,
          );
          return QuizScreen(mode: mode);
        },
      ),
      GoRoute(
        path: '/result',
        name: 'result',
        builder: (context, state) {
          final result = state.extra as QuizState;
          return ResultScreen(result: result);
        },
      ),
    ],
  );
}
