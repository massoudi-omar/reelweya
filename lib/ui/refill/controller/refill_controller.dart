import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:story_box/payment/subscription/subscription_manager.dart';
import 'package:story_box/ui/refill/api/store_api.dart';
import 'package:story_box/ui/refill/model/coin_plan.dart';
import 'package:story_box/ui/refill/model/vip_plan.dart';
import 'package:story_box/ui/setting_view_page/api/setting_api.dart';
import 'package:story_box/ui/setting_view_page/model/setting.dart';
import 'package:story_box/utils/constant.dart';
import 'package:story_box/utils/enums.dart';
import 'package:story_box/utils/preference.dart';
import 'package:story_box/payment/in_app_purchase/in_app_purchase_helper.dart';
import 'package:story_box/payment/in_app_purchase/iap_callback.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:story_box/utils/utils.dart';

class RefillController extends GetxController {
  List<CoinPlan> coinPlan = [];
  List<VipPlan> vipPlan = [];
  bool isLoadingVipPlan = false;
  bool isLoadingCoinPlan = false;
  CoinPlan? selectedCoinPlan;
  VipPlan? selectedVipPlan;

  Setting? setting;
  List<Package> packages = [];
  List<Package> offerings = [];
  bool isActive = false;
  @override
  void onInit() async {
    packages = PremiumManager.instance.availablePackages;
    List<Package> items = PremiumManager.instance.currentOffering;
    offerings.addAll(items);

    getCoinPlanApi();
    getVipPlanApi();
    SettingApi.callApi();
    isActive = await PremiumManager.onCheckSubscriptionIsActive() ?? false;
    super.onInit();

    log("Constant.stripeSwitch${Constant.stripeSwitch}");
    log("Constant.googlePlaySwitch${Constant.googlePlaySwitch}");
    log("Constant.googlePlaySwitch${SettingApi.setting?.flutterWaveSwitch}");
    log("Constant.googlePlaySwitch${SettingApi.setting?.razorPaySwitch}");
  }

  getCoinPlanApi() async {
    isLoadingCoinPlan = true;
    coinPlan = await StoreApi.fetchCoinPlanApi();
    isLoadingCoinPlan = false;
    update(['coinPlan']);
  }

  getVipPlanApi() async {
    isLoadingVipPlan = true;
    vipPlan = await StoreApi.fetchVipPlanApi();
    isLoadingVipPlan = false;
    update(['vipPlan']);
  }

  void selectCoinPlan(int index) {
    selectedCoinPlan = coinPlan[index];
    update(['coinPlan']);
  }

  void selectVipPlan(int index) {
    selectedVipPlan = vipPlan[index];
    update(['coinPlan']);
  }

  // Method to handle in-app purchase for coin plans
  // Future<void> handleCoinPlanInAppPurchase() async {
  //   try {
  //     if (selectedCoinPlan == null) {
  //       log("No coin plan selected");
  //       return;
  //     }
  //
  //     String productKey = selectedCoinPlan!.productKey ?? "";
  //     if (productKey.isEmpty) {
  //       log("Product key is empty for coin plan");
  //       return;
  //     }
  //
  //     List<String> kProductIds = <String>[productKey];
  //
  //     // Initialize with custom callback
  //     InAppPurchaseHelper().init(
  //       paymentType: "In App Purchase",
  //       userId: Preference.userId,
  //       productKey: kProductIds,
  //       rupee: selectedCoinPlan!.offerPrice?.toDouble() ?? 0.0,
  //     );
  //
  //     // Setup purchase listener with callback for coin plan
  //     InAppPurchaseHelper().setupPurchaseListener(CoinPlanIAPCallback(
  //       coinPlanId: selectedCoinPlan!.sId ?? '',
  //       refillController: this,
  //     ));
  //
  //     log("Coin plan initialization completed");
  //
  //     // Wait for store info to load
  //     bool storeInitialized = await InAppPurchaseHelper().initStoreInfo();
  //
  //     if (!storeInitialized) {
  //       log("Store initialization failed");
  //       return;
  //     }
  //
  //     log("selectedCoinPlan.productKey :: $productKey");
  //
  //     ProductDetails? product = InAppPurchaseHelper().getProductDetail(productKey);
  //     if (product != null) {
  //       log("Product details retrieved successfully for :: ${product.id}");
  //       await InAppPurchaseHelper().buyProduct(product);
  //     } else {
  //       log("Product is null for :: $productKey");
  //     }
  //   } catch (e) {
  //     log("Error in handleCoinPlanInAppPurchase: $e");
  //     Utils.showToast(Get.context!, "Error initiating purchase");
  //   }
  // }

  Future<void> handleCoinPlanInAppPurchase() async {
    try {
      if (selectedCoinPlan == null) {
        log("No coin plan selected");
        return;
      }

      String productKey = selectedCoinPlan!.productKey ?? "";

      Package package = offerings.firstWhere((element) => element.storeProduct.identifier == productKey);
      PremiumManager.instance.executeCustomPurchase(package).then((value) {
        if (value != null) {
          log("In-app purchase completed for product: $productKey");

          recordCoinPlanHistoryApi("in_app_purchase");
          Utils.showToast(Get.context!, "In-app purchase Successfully for product: $productKey");
        } else {
          log("In-app purchase failed for product: $productKey");
          Utils.showToast(Get.context!, "In-app purchase failed for product");
        }
      });
    } catch (e) {
      print("Error in handleCoinPlanInAppPurchase: $e");
      Utils.showToast(Get.context!, "Error initiating purchase");
    }
  }

  Future<bool> recordCoinPlanHistoryApi(String paymentType) async {
    final isSuccess = await StoreApi.recordCoinPlanHistory(
      loginUserId: Preference.userId,
      coinPlanId: selectedCoinPlan?.sId ?? '',
      paymentType: paymentType,
    );

    if (isSuccess) {
      update(['updateCoin']);
    }

    return isSuccess;
  }

  recordVipPlanHistoryApi(String paymentType, String id) async {
    await StoreApi.recordVipPlanHistory(
      loginUserId: Preference.userId,
      vipPlanId: id,
      paymentType: paymentType,
    );
    Utils.showLog("Call Payment Type ${paymentType}");
    Preference.isVip;
    update(['vipPlan']);
  }

  Future<void> onSubscription({String? productKey, required VipPlan plan}) async {
    packages.forEach(
      (element) {
        log("Looking for productKey: 01 ${element.identifier}");
      },
    );
    // log("Looking for productKey: ${}");
    try {
      log("Subscription packages >>>> ${packages.map((e) => e.toString()).toList()}");
      log("Looking for productKey: $productKey");

      // Find matching package by comparing productKey with storeProduct.identifier
      Package? matchedPackage = packages.firstWhere(
        (package) {
          log("message>>>> ${package.storeProduct.identifier}");
          return package.identifier == productKey;
        },
      );

      log("Matched package identifier: ${matchedPackage.identifier}");
      bool? status = await PremiumManager.instance.processPurchase(matchedPackage);
      if (status == true) {
        recordVipPlanHistoryApi("In App Purchase", plan.sId ?? "");

        Get.snackbar(
          "Success",
          "Successfully subscribed to plan!",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        // Get.snackbar(
        //   "Error",
        //   "Failed to subscribe to plan!",
        //   snackPosition: SnackPosition.BOTTOM,
        //   backgroundColor: Colors.red,
        //   colorText: Colors.white,
        // );
        Utils.showToast(Get.context!, EnumLocal.txtFailedToSubscribeToPlan.name.tr);
      }
    } catch (e) {
      Utils.showLog("Error in onSubscription: $e");
      Get.snackbar(
        "Error",
        "An error occurred while subscribing!",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}

class CoinPlanIAPCallback extends IAPCallback {
  final String coinPlanId;
  final RefillController refillController;

  CoinPlanIAPCallback({
    required this.coinPlanId,
    required this.refillController,
  });

  @override
  void onSuccessPurchase(PurchaseDetails product) {
    log("Coin Plan purchase successful: ${product.productID}");

    // Call the API to record coin plan history
    refillController.recordCoinPlanHistoryApi(
      "in_app_purchase",
    );

    // Show success message
    Utils.showToast(Get.context!, "Coins purchased successfully!");

    // Navigate back or refresh UI if needed
    Get.back();
  }

  @override
  void onBillingError(dynamic error) {
    log("Coin Plan purchase error: $error");
    Utils.showToast(Get.context!, "Purchase failed. Please try again.");
  }

  @override
  void onPending(PurchaseDetails product) {
    log("Coin Plan purchase pending: ${product.productID}");
    Utils.showToast(Get.context!, "Purchase is pending...");
  }
}
