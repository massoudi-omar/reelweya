import 'package:get/get.dart';
import 'package:incodes_payment/incodes_payment_services.dart';
import 'package:story_box/deep_link/share_manager/pure_flutter_share_service.dart';
import 'package:story_box/utils/color.dart';
import 'package:story_box/utils/constant.dart';
import 'package:story_box/utils/enums.dart';
import 'package:story_box/utils/preference.dart';
import 'package:story_box/utils/utils.dart';

/// razor pay payment
Future<void> razorPay({
  required num amount,
  required Function() onPaymentSuccess,
}) async {
  Utils.showLog("Razorpay Payment (Incodes) starting...");
  Utils.showLog("Razorpay Payment (Incodes) starting...$amount");

  try {
    final razorKey = Constant.razorPayId ?? '';
    final email = Preference.shared.getString(Preference.email) ?? '' ?? "email";
    ;
    // Utils.showLog("customerName>>>>>>>>>>>>>>>>>>>>>>$customerName");
    Utils.showLog("email>>>>>>>>>>>>>>>>>>>>>>$razorKey");
    Utils.showLog("Database.email>>>>>>>>>>>>>>>>>>>>>>${email}");
    final currency = Constant.currencyCode ?? "USD";

    String toHex6(int argb) {
      final hex8 = argb.toRadixString(16).padLeft(8, '0');
      return '#${hex8.substring(2)}';
    }

    Utils.showLog("amount.toDouble()${amount.toDouble()}");
    final appName = EnumLocal.txtAppName.name.tr;
    final hexColor = toHex6(AppColor.primaryColor.hashCode);

    await IncodesPaymentServices.razorPayPayment(
      currency: currency,
      razorpayKey: razorKey.isNotEmpty ? razorKey : "",
      contactNumber: "+91-0000000000",
      emailId: email.toString(),
      amount: amount.toDouble(),
      appName: appName,
      colorCode: hexColor,
      onPaymentSuccess: onPaymentSuccess,
      onPaymentFailure: () {
        Utils.showToast(Get.context!, EnumLocal.txtPaymentError.name.tr);
      },
      onExternalWallet: () {
        Utils.showLog("RazorPay External Wallet selected");
      },
    );
  } catch (e) {
    if (Get.isDialogOpen == true) Get.back();
    Utils.showLog("RazorPay Payment Failed => $e");
  }
}

/// stripe payment
Future<void> stripe({
  required num amount,
  required Function()? onPaymentSuccess,
}) async {
  try {
    Utils.showLog("Stripe Payment (Incodes) starting...");

    final publishableKey = Constant.stripeTestPublicKey ?? "";

    final secretKey = Constant.stripeTestSecretKey ?? "";

    final currency = Constant.currencyCode ?? "INR";

    final merchantDisplayName = EnumLocal.txtAppName.name.tr;

    final merchantCountryCode = "IN";
    final merchantCountryCode1 = Constant.stripeMerchantCountryCode ?? "IN";

    final int minorAmount = (amount * 100).toInt();

    await IncodesPaymentServices.stripePayment(
      amount: minorAmount,
      currency: currency,
      isTest: true,
      merchantCountryCode: merchantCountryCode,
      merchantDisplayName: merchantDisplayName,
      publishableKey: publishableKey,
      secretKey: secretKey,
      onPaymentSuccess: onPaymentSuccess,
      onPaymentFailure: () {
        Utils.showToast(Get.context!, EnumLocal.txtPaymentError.name.tr);
      },
    );

    Utils.showLog("Stripe payment flow finished (returned).");
  } catch (e) {
    if (Get.isDialogOpen == true) Get.back();
    Utils.showLog("Stripe Payment Failed !! => $e");
  }
}

/// flutter wave payment
Future<void> flutterWave({
  required num amount,
  required Function()? onPaymentSuccess,
}) async {
  Utils.showLog("Flutterwave Payment (Incodes) starting...");
  try {
    Get.dialog(LoadingWidget(), barrierDismissible: false);
    await 400.milliseconds.delay();
    if (Get.isDialogOpen == true) Get.back();

    final settingsKey = Constant.flutterWaveId;
    final publicKey = (settingsKey.isNotEmpty) ? settingsKey : "";

    // final currency =  "NGN";
    final currency = Constant.currencyCode ?? "NGN";
    final customerName = Preference.shared.getString(Preference.name) ?? '' ?? "User";
    final customerEmail = Preference.shared.getString(Preference.email) ?? '' ?? "email";

    Utils.showLog("customerName>>>>>>>>>>>>>>>>>>>>>>$customerName");
    Utils.showLog("customerEmail>>>>>>>>>>>>>>>>>>>>>>$customerEmail");
    Utils.showLog("currency>>>>>>>>>>>>>>>>>>>>>>$currency");
    Utils.showLog("publicKey>>>>>>>>>>>>>>>>>>>>>>$publicKey");

    await IncodesPaymentServices.flutterWavePayment(
      context: Get.context!,
      publicKey: publicKey,
      currency: currency,
      amount: amount.toString(),
      customerName: customerName,
      customerEmail: customerEmail.toString(),
      onPaymentSuccess: onPaymentSuccess,
      onPaymentFailure: () {
        Utils.showToast(Get.context!, EnumLocal.txtFlutterWavePaymentFailed.name.tr);
      },
    );

    Utils.showLog("Flutterwave payment flow finished.");
  } catch (e) {
    if (Get.isDialogOpen == true) Get.back();
    Utils.showLog("Flutterwave Payment Failed => $e");
  }
}

String getValidEmail(String? customerEmail) {
  final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]+$');

  if (customerEmail != null && emailRegex.hasMatch(customerEmail)) {
    return customerEmail;
  } else {
    return "test@gmail.com";
  }
}

///pay stack payment
Future<void> payStack({
  required num amount,
  required Function()? onPaymentSuccess,
}) async {
  Utils.showLog("Paystack Payment (Incodes) starting...");

  try {
    Get.dialog(const LoadingWidget(), barrierDismissible: false);
    await 400.milliseconds.delay();
    if (Get.isDialogOpen == true) Get.back();

    // final settingsSecret =
    //     GetSettingApi.getSettingModel?.data?.flutterwaveId;
    // final secretKey = (settingsSecret != null && settingsSecret.isNotEmpty)
    //     ? settingsSecret
    //     : "";
    final settingsSecret = Constant.paystackSecretKey;

    final customerEmail = Constant.contactEmail ?? "test@gmail.com";

    final currency = Constant.currencyCode ?? "NGN";

    final int majorAmount = amount.toInt();
    String email = getValidEmail(customerEmail);
    await IncodesPaymentServices.payStackPayment(
      context: Get.context!,
      secretKey: settingsSecret.toString(),
      customerEmail: email.toString(),
      amount: majorAmount,
      currency: currency,
      onPaymentSuccess: onPaymentSuccess,
      onPaymentFailure: () {
        Utils.showToast(Get.context!, EnumLocal.txtPaymentError.name.tr);
      },
    );

    Utils.showLog("Paystack payment flow finished.");
  } catch (e) {
    if (Get.isDialogOpen == true) Get.back();
    Utils.showLog("Paystack Payment Failed => $e");
  }
}

///pay pal payment
Future<void> payPal({
  required num amount,
  required Function()? onPaymentSuccess,
}) async {
  Utils.showLog("PayPal Payment (Incodes) starting...");
  try {
    Get.dialog(const LoadingWidget(), barrierDismissible: false);
    await 400.milliseconds.delay();
    if (Get.isDialogOpen == true) Get.back();

    final currency = Constant.currencyCode ?? "USD";
    // final currency = "USD";

    final paypalClientId = Constant.paypalClientId;
    final secretKey = Constant.paypalSecretKey;

    await IncodesPaymentServices.paypalPayment(
      context: Get.context!,
      clientId: paypalClientId.toString(),
      secretKey: secretKey.toString(),
      transactions: [
        {
          "amount": {
            "total": amount.toString(),
            "currency": currency,
            "details": {"subtotal": amount.toString(), "shipping": '0', "shipping_discount": 0},
          },
          "description": "Subscription purchase via PayPal",
          "item_list": {
            "items": [
              {
                "name": "Subscription Plan",
                "quantity": 1,
                "price": amount.toString(),
                "currency": currency,
              },
            ],
          },
        },
      ],
      onPaymentSuccess: onPaymentSuccess,
      onPaymentFailure: () {
        Utils.showToast(Get.context!, EnumLocal.txtPaymentError.name.tr);
      },
    );

    Utils.showLog("PayPal payment flow finished.");
  } catch (e) {
    Get.back();
    Utils.showLog("PayPal Payment Failed => $e");
  }
}

///in app purchase payment
Future<void> inAppPurchase({
  required num amount,
  required Function()? onPaymentSuccess,
}) async {
  Utils.showLog("InAppPurchase Payment (Incodes) starting...");
  try {
    Get.dialog(const LoadingWidget(), barrierDismissible: false);
    await 400.milliseconds.delay();
    if (Get.isDialogOpen == true) Get.back();

    final productId = "com.android.coin100";
    final userId = Preference.userId ?? "123456";

    await IncodesPaymentServices.inAppPurchasePayment(
      userId: userId,
      productIds: [productId],
      amount: amount.toDouble(),
      onPaymentSuccess: onPaymentSuccess,
      onPaymentFailure: () {
        Utils.showToast(Get.context!, EnumLocal.txtPaymentError.name.tr);
      },
    );

    Utils.showLog("InAppPurchase payment flow finished.");
  } catch (e) {
    if (Get.isDialogOpen == true) Get.back();
    Utils.showLog("InAppPurchase Payment Failed => $e");
  }
}

///cash free payment
Future<void> cashFree({
  required num amount,
  required Function()? onPaymentSuccess,
}) async {
  Utils.showLog("CashFree Payment (Incodes) starting...");
  try {
    Get.dialog(const LoadingWidget(), barrierDismissible: false);
    await 400.milliseconds.delay();
    if (Get.isDialogOpen == true) Get.back();

    final customerName = Preference.name ?? "John";
    final customerEmail = Preference.email ?? "test@gmail.com";

    Utils.showLog("Database.getUserProfileResponseModel?.user?.phoneNumber${9876543210}");

    final cashfreeClientId = Constant.cashfreeClientId;
    final cashfreeSecretKey = Constant.cashfreeClientSecret;

// final currency ="INR";
    final currency = Constant.currencyCode ?? "INR";

    await IncodesPaymentServices.cashFreePayment(
      context: Get.context!,
      clientId: cashfreeClientId.toString(),
      clientSecret: cashfreeSecretKey.toString(),
      amount: amount.toDouble(),
      currency: currency,
      customerName: customerName,
      customerEmail: customerEmail.toString(),
      customerPhone: "9876543210",
      paymentGatewayName: "CashFree",
      onPaymentSuccess: onPaymentSuccess,
      onPaymentFailure: () {
        Utils.showToast(Get.context!, EnumLocal.txtPaymentError.name.tr);
      },
    );

    Utils.showLog("CashFree payment flow finished.");
  } catch (e) {
    if (Get.isDialogOpen == true) Get.back();
    Utils.showLog("CashFree Payment Failed => $e");
  }
}
