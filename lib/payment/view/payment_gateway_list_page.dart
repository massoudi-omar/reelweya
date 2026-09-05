// ignore_for_file: must_be_immutable
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_rx/src/rx_typedefs/rx_typedefs.dart';
import 'package:story_box/deep_link/share_manager/pure_flutter_share_service.dart';
import 'package:story_box/payment/comman_paymemt/comman_payment.dart';
import 'package:story_box/payment/razor_pay/razor_pay_service.dart';
import 'package:story_box/ui/refill/controller/refill_controller.dart';
import 'package:story_box/utils/asset.dart';
import 'package:story_box/utils/color.dart';
import 'package:story_box/utils/constant.dart';
import 'package:story_box/utils/enums.dart';
import 'package:story_box/utils/utils.dart';

import '../../utils/font_style.dart';
import '../controller/payment_controller.dart';

class PaymentGatewayListPage extends StatelessWidget {
  PaymentGatewayListPage({super.key});

  PaymentController paymentController = Get.put(PaymentController());
  final refillController = Get.find<RefillController>();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: Get.height * 0.65,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(24),
          topLeft: Radius.circular(24),
        ),
        border: Border.symmetric(vertical: BorderSide(color: AppColor.colorWhite.withValues(alpha: 0.10))),
        gradient: const LinearGradient(
          colors: [
            Color(0xff240F33),
            Color(0xff2D121B),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      width: Get.width,
      child: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: 58,
              width: Get.width,
              decoration: BoxDecoration(
                color: AppColor.colorWhite.withValues(alpha: 0.10),
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(24),
                  topLeft: Radius.circular(24),
                ),
              ),
              child: Center(
                child: Text(
                  EnumLocal.selectPaymentOption.name.tr,
                  style: AppFontStyle.styleW700(AppColor.colorWhite, 19),
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 18),
              child: Column(
                children: [
                  if (Constant.stripeSwitch)
                    PaymentItemBuilder(
                      EnumLocal.stripe.name.tr,
                      AppAsset.stripe,
                      () async {
                        Get.back(); // Close the payment selection dialog

                        await paymentController.makePaymentViaStripe();
                      },
                    ),
                  if (Constant.googlePlaySwitch)
                    Platform.isAndroid
                        ? PaymentItemBuilder(
                            EnumLocal.inAppPurchase.name.tr,
                            AppAsset.inAppPurchase,
                            () async {
                              Get.back(); // Close the payment selection dialog
                              await _handleInAppPurchase();
                            },
                          )
                        : PaymentItemBuilder(
                            EnumLocal.applePurchase.name.tr,
                            AppAsset.applePay,
                            () async {
                              Get.back(); // Close the payment selection dialog
                              await _handleInAppPurchase();
                            },
                          ),
                  if (Constant.razorPaySwitch)
                    PaymentItemBuilder(
                      EnumLocal.razorPay.name.tr,
                      AppAsset.razor,
                      () async {
                        Get.back(); // Close the payment selection dialog
                        await _handleRazorPayPayment();
                      },
                    ),
                  if (Constant.flutterWaveSwitch)
                    PaymentItemBuilder(
                      EnumLocal.flutterWave.name.tr,
                      AppAsset.flutterWave,
                      () async {
                        Get.back(); // Close the payment selection dialog
                        await paymentController.makePaymentViaFlutterWave();
                      },
                    ),
                  if (Constant.payPalSwitch)
                    PaymentItemBuilder(
                      EnumLocal.payPal.name.tr,
                      AppAsset.payPalImage,
                      () async {
                        Get.back(); // Close the payment selection dialog
                        await paymentController.makePaymentViaPaypal();
                      },
                    ),
                  if (Constant.payStackSwitch)
                    PaymentItemBuilder(
                      EnumLocal.payStack.name.tr,
                      AppAsset.payStackImage,
                      () async {
                        Get.back(); // Close the payment selection dialog
                        await paymentController.makePaymentViaPayStack();
                      },
                    ),
                  if (Constant.cashFreeSwitch)
                    PaymentItemBuilder(
                      EnumLocal.cashFree.name.tr,
                      AppAsset.cashFreeImage,
                      () async {
                        Get.back(); // Close the payment selection dialog
                        await paymentController.makePaymentViaCashFree();
                      },
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleInAppPurchase() async {
    try {
      log("Starting in-app purchase process");

      // Validate selected coin plan
      if (refillController.selectedCoinPlan == null) {
        log("No coin plan selected");
        Utils.showToast(Get.context!, EnumLocal.txtPleaseSelectACoinPlanFirst.name.tr);
        return;
      }

      // Get product key
      String productKey = refillController.selectedCoinPlan?.productKey ?? "";
      if (productKey.isEmpty) {
        log("Product key is empty for plan: ${refillController.selectedCoinPlan?.toJson()}");
        Utils.showToast(Get.context!, EnumLocal.txtProductKeyNotFoundForThisPlan.name.tr);
        return;
      }

      log("Initiating purchase for product: $productKey");
      log("Plan details: ${refillController.selectedCoinPlan?.toJson()}");

      // Start the purchase process
      await refillController.handleCoinPlanInAppPurchase();
    } catch (e) {
      log("Error in _handleInAppPurchase: $e");
      Utils.showToast(Get.context!, "${EnumLocal.txtFailedToStartPurchase.name.tr}: $e");
    }
  }

  Future<void> _handleRazorPayPayment() async {
    try {
      log("Starting Razorpay payment");

      if (refillController.selectedCoinPlan == null) {
        Utils.showToast(Get.context!, EnumLocal.txtPleaseSelectACoinPlanFirst.name.tr);
        return;
      }
      String amount = refillController.selectedCoinPlan?.offerPrice.toString() ?? '0';
      int amountInCents = ((double.tryParse(amount) ?? 0) * 100).toInt();
      razorPay(
        amount: amountInCents,
        onPaymentSuccess: () async {
          Utils.showLog("RazorPay Payment Successfully");

          Get.dialog(const LoadingWidget(), barrierDismissible: false); // Start Loading...

          final isSuccess = await refillController.recordCoinPlanHistoryApi("RazorPay");
          Get.back(); // Stop Loading...
          if (isSuccess) {
            Utils.showToast(Get.context!, EnumLocal.txtPaymentSuccessfully.name.tr);
            Get.close(2);
          } else {
            Utils.showToast(Get.context!, EnumLocal.txtSomeThingWentWrong.name.tr);
          }
        },
      );
      await 1.seconds.delay();
      RazorPayService().razorPayCheckout((amountInCents * 100).toInt());
    } catch (e) {
      log("Error in Razorpay payment: $e");
      Utils.showToast(Get.context!, "Razorpay payment failed: $e");
    }
  }

  // Future<void> _handleFlutterWavePayment() async {
  //   try {
  //     log("Starting FlutterWave payment");
  //
  //     if (refillController.selectedCoinPlan == null) {
  //       Utils.showToast(Get.context!, EnumLocal.txtPleaseSelectACoinPlanFirst.name.tr);
  //       return;
  //     }
  //
  //     String amount = refillController.selectedCoinPlan?.offerPrice.toString() ?? '0';
  //     int amountInCents = ((double.tryParse(amount) ?? 0) * 100).toInt();
  //     log("FlutterWave payment amount: $amount");
  //
  //     flutterWave(
  //       amount: amountInCents,
  //       onPaymentSuccess: () async {
  //         Utils.showLog("Flutter Wave Payment Successfully");
  //
  //         Get.dialog(const LoadingWidget(), barrierDismissible: false); // Start Loading...
  //
  //         final isSuccess = await refillController.recordCoinPlanHistoryApi("Flutter Wave");
  //
  //         Get.back(); // Stop Loading...
  //
  //         if (isSuccess) {
  //           Utils.showToast(Get.context!, EnumLocal.txtPaymentSuccessfully.name.tr);
  //           Get.close(2);
  //         } else {
  //           Utils.showToast(Get.context!, EnumLocal.txtSomeThingWentWrong.name.tr);
  //         }
  //       },
  //     );
  //   } catch (e) {
  //     log("Error in FlutterWave payment: $e");
  //     Utils.showToast(Get.context!, "${EnumLocal.txtFlutterWavePaymentFailed.name.tr}: $e");
  //   }
  // }
}

class PaymentItemBuilder extends StatelessWidget {
  String name, icon;
  Callback onTapItem;

  PaymentItemBuilder(
    this.name,
    this.icon,
    this.onTapItem, {
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTapItem,
      child: Container(
        margin: const EdgeInsets.only(top: 24),
        padding: const EdgeInsets.all(8),
        width: Get.width,
        decoration: BoxDecoration(
          border: Border.all(color: AppColor.colorWhite.withValues(alpha: 0.16)),
          color: AppColor.colorWhite.withValues(alpha: 0.06),
          borderRadius: const BorderRadius.all(
            Radius.circular(16),
          ),
        ),
        child: Row(
          children: [
            Container(
              height: 50,
              width: 50,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Image.asset(
                  icon,
                  height: 45,
                  width: 45,
                ),
              ),
            ),
            const SizedBox(
              width: 15,
            ),
            Text(
              name,
              style: AppFontStyle.styleW700(AppColor.colorWhite.withValues(alpha: 0.64), 16),
            ),
            const Spacer(),
            Image.asset(
              AppAsset.icRightArrow,
              width: 20,
              height: 20,
            ).paddingOnly(right: 12),
          ],
        ),
      ),
    );
  }
}
