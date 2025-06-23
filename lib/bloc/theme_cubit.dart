import 'package:bloc/bloc.dart';
import 'package:my_flutter_app/bloc/theme_state.dart';

class ThemeCubit extends Cubit<ThemeState> {
  ThemeCubit() : super(LightThemeState());

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
}
