import 'package:hydrated_bloc/hydrated_bloc.dart';

enum Themes { light, dark, system }

class ThemeCubit extends HydratedCubit<Themes> {
  ThemeCubit() : super(Themes.system);

  void toggleToDarkTheme() {
    emit(Themes.dark);
  }

  void toggleToLightTheme() {
    emit(Themes.light);
  }

  void toggleSystemTheme() {
    emit(Themes.system);
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
  Themes? fromJson(Map<String, dynamic> json) {
    if (json['theme'] == 'dark') {
      return Themes.dark;
    } else if (json['theme'] == 'light') {
      return Themes.light;
    }
    return Themes.system;
  }

  @override
  Map<String, dynamic>? toJson(Themes state) {
    if (state == Themes.dark) {
      return {'theme': 'dark'};
    } else if (state == Themes.light) {
      return {'theme': 'light'};
    }
    return {'theme': 'system'};
  }
}
