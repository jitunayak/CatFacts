import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:my_flutter_app/bloc/theme_state.dart';

class ThemeCubit extends HydratedCubit<ThemeState> {
  ThemeCubit() : super(SystemThemeState());

  void toggleToDarkTheme() {
    emit(DarkThemeState());
  }

  void toggleToLightTheme() {
    emit(LightThemeState());
  }

  void toggleSystemTheme() {
    emit(SystemThemeState());
    // MediaQueryData mediaQuery = MediaQueryData.fromView(
    //   PlatformDispatcher.instance.views.first,
    // );
    // bool isDarkMode = mediaQuery.platformBrightness == Brightness.dark;

    // if (isDarkMode) {
    //   toggleToDarkTheme();
    // } else {
    //   toggleToLightTheme();
    // }
  }

  @override
  ThemeState? fromJson(Map<String, dynamic> json) {
    if (json['theme'] == 'dark') {
      return DarkThemeState();
    } else if (json['theme'] == 'light') {
      return LightThemeState();
    }
    return SystemThemeState();
  }

  @override
  Map<String, dynamic>? toJson(ThemeState state) {
    if (state is DarkThemeState) {
      return {'theme': 'dark'};
    } else if (state is LightThemeState) {
      return {'theme': 'light'};
    }
    return {'theme': 'system'};
  }
}
