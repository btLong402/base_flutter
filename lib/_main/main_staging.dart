import '../core/base/app/app_bootstrap.dart';
import '../core/base/config/environment.dart';

void main() async {
  await AppBootstrap.run(AppFlavor.staging);
}
