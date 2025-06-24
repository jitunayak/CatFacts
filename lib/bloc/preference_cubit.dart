import 'dart:convert';

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

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'shoudlAutoPlay': shoudlAutoPlay,
      'isSystemTTSEnabled': isSystemTTSEnabled,
      'isNotificationEnabled': isNotificationEnabled,
    };
  }

  factory Preferences.fromMap(Map<String, dynamic> map) {
    return Preferences(
      shoudlAutoPlay: map['shoudlAutoPlay'] as bool,
      isSystemTTSEnabled: map['isSystemTTSEnabled'] as bool,
      isNotificationEnabled: map['isNotificationEnabled'] as bool,
    );
  }

  String toJson() => json.encode(toMap());

  factory Preferences.fromJson(String source) =>
      Preferences.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() =>
      'Preferences(shoudlAutoPlay: $shoudlAutoPlay, isSystemTTSEnabled: $isSystemTTSEnabled, isNotificationEnabled: $isNotificationEnabled)';

  @override
  bool operator ==(covariant Preferences other) {
    if (identical(this, other)) return true;

    return other.shoudlAutoPlay == shoudlAutoPlay &&
        other.isSystemTTSEnabled == isSystemTTSEnabled &&
        other.isNotificationEnabled == isNotificationEnabled;
  }

  @override
  int get hashCode =>
      shoudlAutoPlay.hashCode ^
      isSystemTTSEnabled.hashCode ^
      isNotificationEnabled.hashCode;
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
    return Preferences.fromMap(json);
  }

  @override
  Map<String, dynamic>? toJson(Preferences state) {
    return state.toMap();
  }
}
