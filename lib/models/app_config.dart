import 'package:my_flutter_app/models/env_keys.dart';
import 'package:my_flutter_app/models/router_path.dart';

class Config {
  Config._();
  static final EnvKeys env = EnvKeys();
  static final RouterPath path = RouterPath();
}
