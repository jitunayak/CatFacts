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
}
