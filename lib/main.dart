import 'dart:async';
import 'dart:developer';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_branch_sdk/flutter_branch_sdk.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:mobile_device_identifier/mobile_device_identifier.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:story_box/connectivity_manager/connectivity_manager.dart';
import 'package:story_box/deep_link/services/deep_link_services.dart';
import 'package:story_box/localization/localization_service.dart';
import 'package:story_box/localization/localizations_delegate.dart';
import 'package:story_box/notification/notification_service.dart';
import 'package:story_box/payment/subscription/subscription_manager.dart';
import 'package:story_box/routes/app_pages.dart';
import 'package:story_box/routes/app_routes.dart';
import 'package:story_box/ui/setting_view_page/api/setting_api.dart';
import 'package:story_box/ui/startup/binding/startup_binding.dart';
import 'package:story_box/utils/color.dart';
import 'package:story_box/utils/constant.dart';
import 'package:story_box/utils/preference.dart';
import 'localization/locale_constant.dart';
import 'utils/utils.dart';
// import 'package:no_screenshot/no_screenshot.dart';

Future<void> main() async {
  /// Initialize  Widgets binding use in the firebase core or etc...
  WidgetsFlutterBinding.ensureInitialized();

  /// Initialize Shared Preference
  await Preference().instance();

  ///settingApiCall
  await SettingApi.callApi();

  /// initialize Firebase
  await Firebase.initializeApp();
  await Purchases.setLogLevel(LogLevel.debug);

  /// initialize branch io
  await onInitializeBranchIo();

  /// initialize RevenueCat
  await onInitializeRevenueCat();

  /// FCM Token
  ///
  ///
  String? fcmToken;
  try {
    fcmToken = await getFcmTokenWithRetry();
  } catch (e) {
    print("FCM Token error: $e");
  }

  /// Initialize Mobile Ads testing
  MobileAds.instance.updateRequestConfiguration(
    RequestConfiguration(
      testDeviceIds: ["27725C0BA50B789AA8A8833105F99920"],
    ),
  );

  FirebaseMessaging.onBackgroundMessage(NotificationServices.backgroundNotification);

  /// Device Id
  final identity = await MobileDeviceIdentifier().getDeviceId();
  Utils.showLog("Device Id => $identity");
  Utils.showLog("FCM Token => $fcmToken");
  log("FCM Token => $fcmToken");
  log("identity => $identity");

  if (identity != null && fcmToken != null) {
    Preference.onSetFcmToken(fcmToken);
    Preference.onSetIdentity(identity);
  }
  Stripe.publishableKey = Constant.stripeTestPublicKey;

  /// 2.  start listening to renewals / cancellations / billing issues

  // final _noScreenshot = NoScreenshot.instance;
  // bool result = await _noScreenshot.screenshotOff();
  // debugPrint('Screenshot Off: $result');

  /// Initialize Internet connectivity manger
  await InternetConnectivity().instance();
  Get.put(LocalizationService());
  await Get.find<LocalizationService>().init();
  runApp(const MyApp());
}

Future<String?> getFcmTokenWithRetry() async {
  try {
    return await FirebaseMessaging.instance.getToken();
  } catch (e) {
    await Future.delayed(const Duration(seconds: 2));

    try {
      return await FirebaseMessaging.instance.getToken();
    } catch (e) {
      return null;
    }
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  static final StreamController purchaseStreamController = StreamController<PurchaseDetails>.broadcast();

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void didChangeDependencies() {
    getLocale().then((locale) {
      setState(() {
        log("didChangeDependencies Preference Revoked ${locale.languageCode}");
        log("didChangeDependencies GET LOCALE Revoked ${Get.locale!.languageCode}");
        Get.updateLocale(locale);
      });
    });
    super.didChangeDependencies();
  }

  @override
  void initState() {
    DeepLinkServices.onInitDeepLinks();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      left: false,
      right: false,
      top: false,
      bottom: true,
      child: GetMaterialApp(
        color: AppColor.colorBlack,
        debugShowCheckedModeBanner: false,
        title: 'ReelWay',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        getPages: AppPages.list,
        defaultTransition: Transition.fadeIn,
        locale: Get.locale ?? Locale(Constant.languageEn, Constant.countryCodeEn),
        translations: AppLanguages(),
        fallbackLocale: Locale(Constant.languageEn, Constant.countryCodeEn),
        initialRoute: AppRoutes.splash,
        // initialBinding: StartupBinding(),
      ),
    );
  }
}
// >>>>>> >>>>>> Sized Box Extension <<<<<< <<<<<<

extension HeightExtension on num {
  SizedBox get height => SizedBox(height: toDouble());
}

extension WidthExtension on num {
  SizedBox get width => SizedBox(width: toDouble());
}

Future<void> onInitializeBranchIo() async {
  try {
    await FlutterBranchSdk.init().then((value) {
      // FlutterBranchSdk.validateSDKIntegration();
    });
  } catch (e) {
    Utils.showLog("Initialize Branch Io Failed !! => $e");
  }
}

Future<void> onInitializeRevenueCat() async {
  // Init RevenueCat (handle errors gracefully)
  try {
    await PremiumManager.instance.setupRevenueCatSDK();
  } catch (e, st) {
    log('SubscriptionManager init error: $e\n$st');
  }
}
