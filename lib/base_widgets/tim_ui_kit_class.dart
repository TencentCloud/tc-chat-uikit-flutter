import 'package:tencent_im_base/base_widgets/tim_callback.dart';
import 'package:zhaopin/im/data_services/core/core_services_implements.dart';
import 'package:zhaopin/im/data_services/services_locatar.dart';

class TIMUIKitClass {
  static final CoreServicesImpl _coreServices =
      serviceLocator<CoreServicesImpl>();

  static void onTIMCallback(TIMCallback callbackValue) {
    _coreServices.callOnCallback(callbackValue);
  }
}
