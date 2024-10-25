import 'package:get/get.dart';

import '../modules/home/bindings/register_binding.dart';
import '../modules/home/views/register_view.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.HOME;

  static final routes = [
    GetPage(
      name: _Paths.HOME,
      page: () => RegisterScreen(),
      binding: HomeBinding(),
    ),
  ];
}
