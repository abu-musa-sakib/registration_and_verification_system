// lib/common/utils/extensions/size_extension.dart

import 'package:registration_and_verification_system/common/utils/screen_size_util.dart';

extension SizeExtension on num {
  double get sw => ScreenSizeUtil.screenWidth * this;

  double get sh => ScreenSizeUtil.screenHeight * this;
}
