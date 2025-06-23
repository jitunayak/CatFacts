import 'package:hydrated_bloc/hydrated_bloc.dart';

class Preferences {
  final bool shoudlAutoPlay;
  final bool isSystemTTSEnabled;
  final bool isNotificationEnabled;

  const Preferences({
    this.shoudlAutoPlay = false,
    this.isSystemTTSEnabled = false,
    this.isNotificationEnabled = false,
  });

  Preferences copyWith({
    bool? shoudlAutoPlay,
    bool? isSystemTTSEnabled,
    bool? isNotificationEnabled,
  }) {
    return Preferences(
      shoudlAutoPlay: shoudlAutoPlay ?? this.shoudlAutoPlay,
      isSystemTTSEnabled: isSystemTTSEnabled ?? this.isSystemTTSEnabled,
      isNotificationEnabled:
          isNotificationEnabled ?? this.isNotificationEnabled,
    );
  }
}

class PreferenceCubit extends HydratedCubit<Preferences> {
  PreferenceCubit() : super(const Preferences());

  void saveShouldAutoPlay(bool value) {
    emit(state.copyWith(shoudlAutoPlay: value));
  }

  void saveIsSystemTTSEnabled(bool value) {
    emit(state.copyWith(isSystemTTSEnabled: value));
  }

  void saveIsNotificationEnabled(bool value) {
    emit(state.copyWith(isNotificationEnabled: value));
  }

  @override
  Preferences? fromJson(Map<String, dynamic> json) {
    return Preferences(
      shoudlAutoPlay: json['shoudlAutoPlay'] as bool? ?? false,
      isSystemTTSEnabled: json['isSystemTTSEnabled'] as bool? ?? false,
      isNotificationEnabled: json['isNotificationEnabled'] as bool? ?? false,
    );
  }

  @override
  Map<String, dynamic>? toJson(Preferences state) {
    return {
      'shoudlAutoPlay': state.shoudlAutoPlay,
      'isSystemTTSEnabled': state.isSystemTTSEnabled,
      'isNotificationEnabled': state.isNotificationEnabled,
    };
  }
}
