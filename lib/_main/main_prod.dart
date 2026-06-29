import 'package:base_flutter/core/base/app/app_bootstrap.dart';
import 'package:base_flutter/core/base/config/environment.dart';

void main() async {
  await AppBootstrap.run(AppFlavor.production);
}
