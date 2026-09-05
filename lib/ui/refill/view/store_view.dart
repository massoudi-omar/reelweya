// ignore_for_file: must_be_immutable

import 'dart:developer';
import 'dart:io';
import 'dart:ui';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:blurrycontainer/blurrycontainer.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:clipboard/clipboard.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:story_box/custom_widget/custom_blur_widget.dart';
import 'package:story_box/custom_widget/custom_gradiant_text.dart';
import 'package:story_box/main.dart';
import 'package:story_box/payment/controller/payment_controller.dart';
import 'package:story_box/payment/in_app_purchase/iap_callback.dart';
import 'package:story_box/payment/in_app_purchase/in_app_purchase_helper.dart';
import 'package:story_box/payment/razor_pay/razor_pay_service.dart';
import 'package:story_box/payment/subscription/subscription_manager.dart';
import 'package:story_box/payment/view/payment_gateway_list_page.dart';
import 'package:story_box/shimmer/my_subscription_shimmer.dart';
import 'package:story_box/shimmer/refill_grid_shimmer.dart';
import 'package:story_box/shimmer/vip_plan_shimmer.dart';
import 'package:story_box/ui/home_page/controller/home_controller.dart';
import 'package:story_box/ui/refill/controller/refill_controller.dart';
import 'package:story_box/ui/refill/model/coin_plan.dart';
import 'package:story_box/ui/refill/model/vip_plan.dart';
import 'package:story_box/utils/asset.dart';
import 'package:story_box/utils/color.dart';
import 'package:story_box/utils/constant.dart';
import 'package:story_box/utils/dummy_data.dart';
import 'package:story_box/utils/enums.dart';
import 'package:story_box/utils/font_style.dart';
import 'package:story_box/utils/preference.dart';
import 'package:story_box/utils/utils.dart';

class StoreView extends StatelessWidget {
  StoreView({super.key});

  final controller = Get.put(RefillController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.colorBlack,
      body: Container(
        height: Get.height,
        width: Get.width,
        decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage(
                  AppAsset.vipBackground,
                ),
                fit: BoxFit.fill)),
        child: SingleChildScrollView(
          child: GetBuilder<RefillController>(
              id: 'vipPlan',
              builder: (context) {
                return Column(
                  children: [
                    Container(
                      height: 80,
                      padding: const EdgeInsets.only(right: 20, top: 16, bottom: 16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [
                          AppColor.colorPrimary.withOpacity(0.15),
                          AppColor.colorPrimary.withOpacity(0.1),
                          AppColor.colorBlack.withOpacity(0.1),
                        ], begin: Alignment.topCenter, end: Alignment.bottomCenter),
                      ),
                      child: Row(
                        children: [
                          GestureDetector(
                            child: Container(
                              height: 50,
                              width: 50,
                              color: Colors.transparent,
                              child: const Icon(
                                Icons.arrow_back_ios,
                                color: Colors.white,
                              ),
                            ),
                            onTap: () {
                              print("back..................");
                              Get.back();
                            },
                          ),
                          // const Spacer(),
                          // Text(
                          //   EnumLocal.store.name.tr,
                          //   style: AppFontStyle.styleW600(AppColor.colorWhite, 20),
                          // ),
                          // const Spacer(),
                          // Container(
                          //   padding: const EdgeInsets.symmetric(
                          //     horizontal: 10,
                          //     vertical: 2,
                          //   ),
                          //   decoration: BoxDecoration(
                          //     borderRadius: BorderRadius.circular(6),
                          //     color: AppColor.colorTextDarkGrey.withOpacity(.2),
                          //   ),
                          //   child: Text(
                          //     EnumLocal.restore.name.tr,
                          //     style: AppFontStyle.styleW400(AppColor.colorTextDarkGrey, 12),
                          //   ),
                          // )
                        ],
                      ).paddingOnly(top: 20),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 20, right: 20),
                      child: Column(
                        children: [
                          Preference.shared.getString(Preference.profilePic) != null && Preference.shared.getString(Preference.profilePic)!.isNotEmpty
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(50),
                                  child: CachedNetworkImage(
                                    imageUrl: Preference.shared.getString(Preference.profilePic) ?? '',
                                    placeholder: (context, url) => Container(
                                      height: 55,
                                      width: 55,
                                      child: Image.asset(
                                        AppAsset.placeHolderImage,
                                        color: AppColor.colorIconGrey,
                                      ).paddingAll(16),
                                    ),
                                    imageBuilder: (context, imageProvider) {
                                      return Container(
                                        height: 55,
                                        width: 55,
                                        padding: EdgeInsets.zero,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(width: 1, color: AppColor.colorWhite),
                                        ),
                                        child: Image(
                                          image: imageProvider,
                                        ),
                                      );
                                    },
                                    errorWidget: (context, url, error) => Container(child: const Icon(Icons.error, color: Colors.red)),
                                    fit: BoxFit.cover,
                                    height: 55,
                                    width: 55,
                                  ),
                                )
                              : Container(
                                  height: 55,
                                  width: 55,
                                  padding: EdgeInsets.zero,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(width: 1, color: AppColor.colorWhite),
                                  ),
                                  child: Image.asset(
                                    AppAsset.icProfileMenNew,
                                  ),
                                ),
                          16.width,
                          Text(
                            Preference.shared.getString(Preference.name) ?? '',
                            style: AppFontStyle.styleW600(Colors.white, 20),
                          ),
                          Preference.isVip
                              ? SizedBox()
                              : Text(
                                  EnumLocal.txtYouAreNotAVipYet.name.tr,
                                  style: AppFontStyle.styleW400(Colors.white70, 14),
                                ),
                        ],
                      ),
                    ),
                    16.height,
                    Container(
                      width: Get.width * 0.8,
                      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
                      margin: EdgeInsets.symmetric(horizontal: 6),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColor.colorLightOrange.withOpacity(0.5), width: 1),
                        gradient: LinearGradient(colors: [
                          AppColor.colorPrimary.withOpacity(0.04),
                          AppColor.colorPrimary.withOpacity(0.01),
                          // AppColor.colorBlack.withOpacity(0.1),
                        ], begin: Alignment.bottomCenter, end: Alignment.topCenter),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    EnumLocal.txtMyCurrentBalance.name.tr,
                                    style: AppFontStyle.styleW600(AppColor.colorWhite.withAlpha(200), 18),
                                  ),
                                ),
                              ),
                              10.width,
                              Obx(
                                () => Row(
                                  children: [
                                    Container(
                                      height: 18,
                                      width: 18,
                                      decoration: BoxDecoration(shape: BoxShape.circle, color: AppColor.lightYellow),
                                    ).paddingOnly(right: 3),
                                    Text(
                                      '${Preference.userCoin}',
                                      style: AppFontStyle.styleW500(AppColor.colorWhite.withAlpha(200), 20),
                                    ),
                                  ],
                                ),
                              ),
                              6.width,
                              // Text(
                              //   EnumLocal.coin.name.tr,
                              //   style: AppFontStyle.styleW400(AppColor.greyColor, 14),
                              // ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    10.height,
                    BlurryContainer(
                      blur: 30,
                      borderRadius: BorderRadius.circular(0),
                      child: Padding(
                        padding: const EdgeInsets.only(left: 10, right: 10, bottom: 16, top: 5),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // if (Preference.isVip == false) 20.height,

                            Preference.isVip == false || controller.isActive
                                ? GetBuilder<RefillController>(
                                    id: 'vipPlan',
                                    builder: (controller) {
                                      return controller.isLoadingVipPlan
                                          ? const VipPlanShimmer(
                                              isShow: true,
                                            )
                                          : ListView.builder(
                                              itemCount: controller.vipPlan.length,
                                              physics: const NeverScrollableScrollPhysics(),
                                              scrollDirection: Axis.vertical,
                                              shrinkWrap: true,
                                              padding: EdgeInsets.zero,
                                              itemBuilder: (context, index) {
                                                return Padding(
                                                  padding: const EdgeInsets.symmetric(horizontal: 4),
                                                  child: VipPlanCard(
                                                    vipPlan: controller.vipPlan[index],
                                                    index: index,
                                                  ),
                                                );
                                              },
                                            );
                                    },
                                  )
                                : GetBuilder<HomeController>(
                                    id: "userProfile",
                                    builder: (logic) {
                                      return logic.loginUserModel?.user?.vipPlanStartDate == null
                                          ? const MySubscriptionShimmer()
                                          : Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  EnumLocal.mySubscription.name.tr,
                                                  style: AppFontStyle.styleW500(AppColor.greyColor, 20),
                                                ).paddingOnly(top: 16),
                                                Stack(
                                                  children: [
                                                    ClipRRect(
                                                      borderRadius: BorderRadius.circular(10),
                                                      child: Image.asset(
                                                        AppAsset.subscriptionBg,
                                                        height: 200,
                                                        width: Get.width,
                                                        fit: BoxFit.cover,
                                                      ),
                                                    ).paddingOnly(right: 16, top: 16),
                                                    Center(
                                                      child: Padding(
                                                        padding: const EdgeInsets.only(
                                                          top: 22,
                                                          right: 32,
                                                          left: 16,
                                                          bottom: 22,
                                                        ),
                                                        child: Column(
                                                          mainAxisAlignment: MainAxisAlignment.center,
                                                          crossAxisAlignment: CrossAxisAlignment.center,
                                                          children: [
                                                            Image.asset(
                                                              AppAsset.vipCrown,
                                                              scale: 4,
                                                            ),
                                                            Text(
                                                              logic.loginUserModel?.user?.currentPlan?.validityType == 'month'
                                                                  ? EnumLocal.monthlyVIP.name.tr
                                                                  : logic.loginUserModel?.user?.currentPlan?.validityType == 'year'
                                                                      ? EnumLocal.yearlyVIP.name.tr
                                                                      : EnumLocal.weeklyVIP.name.tr,
                                                              style: AppFontStyle.styleW900(AppColor.brownColor, 22),
                                                            ),
                                                            Text(
                                                              '${EnumLocal.unlockAllSeriesFor.name.tr} ${logic.loginUserModel?.user?.currentPlan?.validity} ${logic.loginUserModel?.user?.currentPlan?.validityType}',
                                                              style: AppFontStyle.styleW600(AppColor.brownColor.withOpacity(.7), 14),
                                                            ),
                                                            10.height,
                                                            Row(
                                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                              children: [
                                                                Text(
                                                                  EnumLocal.dateOfPurchase.name.tr,
                                                                  style: AppFontStyle.styleW600(AppColor.brownColor.withOpacity(.7), 16),
                                                                ),
                                                                Text(
                                                                  Utils.formatDate(logic.loginUserModel?.user?.vipPlanStartDate ?? ''),
                                                                  style: AppFontStyle.styleW800(AppColor.brownColor, 16),
                                                                ),
                                                              ],
                                                            ),
                                                            4.height,
                                                            Row(
                                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                              children: [
                                                                Text(
                                                                  EnumLocal.planDuration.name.tr,
                                                                  style: AppFontStyle.styleW600(AppColor.brownColor.withOpacity(.7), 16),
                                                                ),
                                                                Text(
                                                                  calculateDateDifference(logic.loginUserModel?.user?.vipPlanEndDate ?? ''),
                                                                  style: AppFontStyle.styleW800(AppColor.brownColor, 16),
                                                                ),
                                                              ],
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            );
                                    },
                                  ),

                            20.height,
                            Text(
                              EnumLocal.reFill.name.tr,
                              style: AppFontStyle.styleW500(AppColor.greyColor, 20),
                            ).paddingOnly(right: 16),
                            12.height,
                            GetBuilder<RefillController>(
                                id: "coinPlan",
                                builder: (controller) {
                                  return controller.isLoadingCoinPlan
                                      ? const RefillGridShimmer()
                                      : GridView.builder(
                                          padding: EdgeInsets.zero,
                                          physics: const NeverScrollableScrollPhysics(),
                                          shrinkWrap: true,
                                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                            crossAxisCount: 2,
                                            mainAxisSpacing: 12,
                                            crossAxisSpacing: 12,
                                            childAspectRatio: 1.7,
                                          ),
                                          itemCount: controller.coinPlan.length,
                                          itemBuilder: (context, index) {
                                            final coinPlan = controller.coinPlan[index];
                                            return RefillCard(
                                              coinPlan: coinPlan,
                                              isSelected: controller.selectedCoinPlan == coinPlan,
                                              onTap: () async {
                                                log("Selected Coin Plan: ${controller.selectedCoinPlan?.sId}");
                                                final refillController = Get.find<RefillController>();
                                                controller.selectedVipPlan = null;
                                                String productKey = refillController.selectedCoinPlan?.productKey ?? "";

                                                controller.selectCoinPlan(index);
                                                controller.update(['vipPlan']);

                                                final enabledMethods = {
                                                  'stripe': Constant.stripeSwitch,
                                                  'inApp': Constant.googlePlaySwitch || Platform.isIOS,
                                                  'razorpay': Constant.razorPaySwitch,
                                                  'flutterwave': Constant.flutterWaveSwitch,
                                                };

                                                final enabledList = enabledMethods.entries.where((e) => e.value).toList();

                                                if (enabledList.length == 1) {
                                                  // Only one method enabled — trigger it directly
                                                  final method = enabledList.first.key;
                                                  final refillController = Get.find<RefillController>();
                                                  final paymentController = Get.put(PaymentController());

                                                  switch (method) {
                                                    case 'stripe':
                                                      paymentController.makePaymentViaStripe();
                                                      break;

                                                    // case 'inApp':
                                                    //   PaymentGatewayListPage().onInAppPurchase(); // static call
                                                    //   break;

                                                    case 'razorpay':
                                                      paymentController.makePaymentViaRazorpay();
                                                      break;

                                                    case 'flutterwave':
                                                      paymentController.makePaymentViaFlutterWave();
                                                      break;

                                                    case 'inApp':
                                                      paymentController.makeInAppPurchase(controller.selectedCoinPlan?.productKey ?? "");
                                                      await controller.handleCoinPlanInAppPurchase();

                                                      break;
                                                  }
                                                } else {
                                                  // Multiple methods enabled — show bottom sheet
                                                  showModalBottomSheet(
                                                    isScrollControlled: true,
                                                    // clipBehavior: Clip.antiAlias,
                                                    context: context,
                                                    backgroundColor: AppColor.bgGreyColor,
                                                    builder: (context) {
                                                      return PaymentGatewayListPage();
                                                    },
                                                  );
                                                }
                                              },
                                            );
                                          },
                                        ).paddingOnly(right: 16);
                                }),
                            20.height,
                            Text(
                              "${EnumLocal.txtTips.name.tr}:",
                              style: AppFontStyle.styleW500(AppColor.greyColor, 14.5),
                            ),
                            ListView.builder(
                              padding: EdgeInsets.zero,
                              physics: const NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              itemCount: DummyData.tips.length,
                              itemBuilder: (context, index) => Text(
                                DummyData.tips[index],
                                style: AppFontStyle.styleW500(AppColor.greyColor, 14.5),
                              ),
                            ).paddingOnly(right: 16),
                            GestureDetector(
                              onTap: () {
                                print("copy");

                                FlutterClipboard.copy(Constant.contactEmail).then((_) {
                                  Utils.showToast(Get.context!, Constant.contactEmail);
                                });
                              },
                              child: Container(
                                color: AppColor.transparent,
                                child: Text(
                                  Constant.contactEmail,
                                  style: AppFontStyle.styleW700(AppColor.primaryColor, 14.5),
                                ).paddingOnly(left: 15),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              }),
        ),
      ),
      bottomNavigationBar: GetBuilder<RefillController>(
          id: "vipPlan",
          builder: (controller) {
            return controller.selectedVipPlan == null
                ? SizedBox()
                : GestureDetector(
                    onTap: () {
                      // onInAppPurchase();
                      controller.onSubscription(productKey: controller.selectedVipPlan?.productKey, plan: controller.selectedVipPlan!);
                    },
                    child: Container(
                      color: AppColor.borderColor.withAlpha(60),
                      child: Container(
                        height: 50,
                        width: Get.width,
                        margin: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                        padding: EdgeInsetsGeometry.symmetric(vertical: 4, horizontal: 4),
                        decoration: BoxDecoration(borderRadius: BorderRadius.circular(30), gradient: AppColor.subscribeGradient),
                        child: Center(
                          child: Text(
                            EnumLocal.txtSubscribeNow.name.tr,
                            style: AppFontStyle.styleW800(AppColor.darkCemal, 24),
                          ),
                        ),
                      ),
                    ),
                  );
          }),
    );
  }

  String calculateDateDifference(String? endDateString) {
    if (endDateString == null || endDateString.isEmpty) {
      return "No VIP plan"; // Handle null or empty end date
    }

    // Parse the end date string to a DateTime object
    DateTime? endDate;
    try {
      endDate = DateTime.parse(endDateString);
    } catch (e) {
      return "Invalid date"; // Handle invalid date format
    }

    // Get the current date
    DateTime currentDate = DateTime.now();

    if (endDate.isBefore(currentDate)) {
      return "Plan expired"; // Handle expired plan
    }

    // Calculate the difference in days
    Duration difference = endDate.difference(currentDate);
    int totalDays = difference.inDays;

    // Convert the difference to weeks, months, and years
    if (totalDays >= 365) {
      int years = totalDays ~/ 365;
      return "$years year${years > 1 ? 's' : ''} left";
    } else if (totalDays >= 30) {
      int months = totalDays ~/ 30;
      return "$months month${months > 1 ? 's' : ''} left";
    } else if (totalDays >= 7) {
      int weeks = totalDays ~/ 7;
      return "$weeks week${weeks > 1 ? 's' : ''} left";
    } else {
      return "$totalDays day${totalDays > 1 ? 's' : ''} left";
    }
  }
}

class VipPlanCard extends StatelessWidget {
  VipPlanCard({super.key, required this.vipPlan, required this.index});

  final VipPlan vipPlan;
  final int index;
  final refillController = Get.find<RefillController>();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          refillController.selectedVipPlan = vipPlan;
          refillController.update(['vipPlan']);
          Utils.showLog("VIP CONTROL => ${refillController.selectedVipPlan?.toJson()}");
          refillController.selectVipPlan(index);
        },
        child: GetBuilder<RefillController>(
            id: "vipPlan",
            builder: (controller) {
              return Container(
                width: double.infinity,
                // padding:,
                margin: EdgeInsets.only(top: 15),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: controller.selectedVipPlan == vipPlan ? Colors.amber.withOpacity(0.5) : AppColor.borderColor, width: 2),
                  image: DecorationImage(
                      image: AssetImage(
                        AppAsset.icVipUnselectedPlanBG,
                      ),
                      fit: BoxFit.fill),
                ),
                child: Stack(
                  clipBehavior: Clip.antiAlias,
                  alignment: Alignment.bottomCenter,
                  children: [
                    BlurryContainer(
                        blur: 20,
                        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(22), bottomRight: Radius.circular(22)),
                        color: AppColor.colorWhite.withAlpha(23),
                        // color: AppColor.colorSecondary,
                        child: Container(
                          height: 30,
                          width: Get.width,
                        )),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 15, top: 20, left: 20, right: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  GradientText(
                                    text: vipPlan.validityType == 'month'
                                        ? EnumLocal.monthlyVIP.name.tr
                                        : vipPlan.validityType == 'year'
                                            ? EnumLocal.yearlyVIP.name.tr
                                            : EnumLocal.weeklyVIP.name.tr,
                                    gradient: AppColor.vipGradient,
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: Constant.appFontFamily,
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      vipPlan.offerPrice != null
                                          ? Text("${Constant.currencyIcon} ${vipPlan.price?.toStringAsFixed(2)}  ",
                                              style: TextStyle(
                                                  decoration: TextDecoration.lineThrough,
                                                  fontSize: 28,
                                                  fontFamily: Constant.appFontFamily,
                                                  color: AppColor.colorIconGrey,
                                                  decorationColor: AppColor.colorIconGrey,
                                                  decorationThickness: 4.0,
                                                  fontWeight: FontWeight.w700))
                                          : SizedBox(),
                                      Text(
                                        "${Constant.currencyIcon} ${vipPlan.offerPrice != null || vipPlan.offerPrice == 0 ? vipPlan.offerPrice?.toStringAsFixed(2) : vipPlan.price?.toStringAsFixed(2)}",
                                        style: AppFontStyle.styleW900(AppColor.colorLightYellow, 28),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            "● ${EnumLocal.txtUnlockAllEpisodesForWeek.name.tr}\n● ${EnumLocal.txtAutoRenewal.name.tr}  ● ${EnumLocal.txtCancelAnytime.name.tr}",
                            style: AppFontStyle.styleW400(AppColor.colorLightOrange, 14),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              _benefitChip(AppAsset.icWatchAll, EnumLocal.txtWatchAllForFree.name.tr),
                              10.width,
                              _benefitChip(AppAsset.icNoAds, EnumLocal.txtAdFree.name.tr),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }));
  }

  PaymentController paymentController = Get.put(PaymentController());

  Future<void> onInAppPurchase() async {
    try {
      String productKey = vipPlan.productKey ?? "";
      if (productKey.isEmpty) {
        log("Product key is empty for VIP plan");
        return;
      }

      List<String> kProductIds = <String>[productKey];

      // Initialize with custom callback
      InAppPurchaseHelper().init(
        paymentType: "In App Purchase",
        userId: Preference.userId,
        productKey: kProductIds,
        rupee: (vipPlan.offerPrice != null || vipPlan.offerPrice == 0 ? vipPlan.offerPrice?.toDouble() : vipPlan.price?.toDouble()) ?? 0.0,
      );

      // Setup purchase listener with callback
      InAppPurchaseHelper().setupPurchaseListener(VipPlanIAPCallback(
        vipPlanId: vipPlan.sId ?? '',
        refillController: refillController,
      ));

      log("Initialization completed");

      // Wait for store info to load
      bool storeInitialized = await InAppPurchaseHelper().initStoreInfo();

      if (!storeInitialized) {
        log("Store initialization failed");
        return;
      }

      log("vipPlan.productKey :: $productKey");

      // Check if user already owns this subscription
      Map<String, PurchaseDetails> existingPurchases = InAppPurchaseHelper().getPurchases();

      if (existingPurchases.containsKey(productKey)) {
        log("User already owns this subscription");

        // Check if it's still active
        PurchaseDetails existingPurchase = existingPurchases[productKey]!;

        // For subscriptions, we should verify if it's still active
        bool isActive = await _checkSubscriptionActive(existingPurchase);

        if (isActive) {
          // Subscription is active, no need to purchase again
          Utils.showToast(Get.context!, "You already have an active subscription!");
          return;
        } else {
          // Subscription expired, proceed with purchase
          log("Existing subscription expired, proceeding with new purchase");
        }
      }

      ProductDetails? product = InAppPurchaseHelper().getProductDetail(productKey);
      if (product != null) {
        log("Product details retrieved successfully for :: ${product.id}");
        await InAppPurchaseHelper().buyProduct(product);
      } else {
        log("Product is null for :: $productKey");
      }
    } catch (e) {
      print("Error in onInAppPurchase: $e");
      Utils.showToast(Get.context!, "Error initiating purchase");
    }
  }

  Future<bool> _checkSubscriptionActive(PurchaseDetails purchase) async {
    // Implement your logic to check if subscription is still active
    // This could involve checking with your backend or parsing the purchase date

    // For now, return true if the purchase exists
    // In production, you should implement proper subscription validation
    return true;
  }
}

Widget _benefitChip(String image, String label) {
  return Row(
    children: [
      Image.asset(
        image,
        height: 20,
        width: 20,
        color: AppColor.colorLightOrange,
      ),
      const SizedBox(width: 4),
      GradientText(text: label, style: const TextStyle(fontSize: 14, fontFamily: Constant.appFontFamily, overflow: TextOverflow.ellipsis), gradient: AppColor.vipGradient)
    ],
  );
}

// Custom callback class for VIP plan purchases
class VipPlanIAPCallback extends IAPCallback {
  final String vipPlanId;
  final RefillController refillController;

  VipPlanIAPCallback({
    required this.vipPlanId,
    required this.refillController,
  });

  @override
  void onSuccessPurchase(PurchaseDetails product) {
    log("VIP Plan purchase successful: ${product.productID}");

    // Call the API to record VIP plan history
    refillController.recordVipPlanHistoryApi("subscription", vipPlanId);

    // Show success message
    Utils.showToast(Get.context!, "VIP subscription activated successfully!");

    // Navigate back or refresh UI if needed
    Get.back();
  }

  @override
  void onBillingError(dynamic error) {
    log("VIP Plan purchase error: $error");
    Utils.showToast(Get.context!, "Purchase failed. Please try again.");
  }

  @override
  void onPending(PurchaseDetails product) {
    log("VIP Plan purchase pending: ${product.productID}");
    Utils.showToast(Get.context!, "Purchase is pending...");
  }
}

class RefillCard extends StatelessWidget {
  final CoinPlan coinPlan;
  final bool isSelected;
  final VoidCallback onTap;

  const RefillCard({super.key, required this.coinPlan, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    double percentageBonus = ((coinPlan.bonusCoin ?? 0) / (coinPlan.coin ?? 1)) * 100;

    return GestureDetector(
      onTap: onTap,
      child: Stack(
        alignment: Alignment.topRight,
        children: [
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColor.colorWhite.withOpacity(0.06),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: isSelected ? AppColor.colorButtonPink : AppColor.colorWhite.withOpacity(0.14),
                width: 1,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                4.height,
                Padding(
                  padding: const EdgeInsets.only(left: 12.0),
                  child: Row(
                    children: [
                      Container(
                        height: 16,
                        width: 16,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColor.lightYellow,
                        ),
                      ),
                      3.width,
                      Flexible(
                        child: AutoSizeText(
                          '${coinPlan.coin}',
                          style: AppFontStyle.styleW600(AppColor.colorWhite, 28),
                          maxLines: 1,
                          minFontSize: 12,
                        ),
                      ),
                      3.width,
                      Container(
                        height: 12,
                        width: 1,
                        margin: const EdgeInsets.only(left: 3, right: 3),
                        decoration: BoxDecoration(gradient: AppColor.linesGradient),
                      ),
                      Flexible(
                        child: AutoSizeText(
                          '+${coinPlan.bonusCoin}',
                          style: AppFontStyle.styleW600(AppColor.greyColor, 16),
                          maxLines: 1,
                          minFontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 12.0, bottom: 4.0),
                  child: AutoSizeText(
                    '${Constant.currencyIcon} ${coinPlan.offerPrice?.toStringAsFixed(2)}',
                    style: AppFontStyle.styleW600(AppColor.colorLightOrange, 16),
                    maxLines: 1,
                    minFontSize: 10,
                  ),
                ),
              ],
            ),
          ),
          if (coinPlan.offerPrice != null && coinPlan.offerPrice != 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
              decoration: BoxDecoration(
                gradient: AppColor.viewsGradient,
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(14),
                  bottomLeft: Radius.circular(8),
                ),
              ),
              child: AutoSizeText(
                '+${percentageBonus.toStringAsFixed(0)}%',
                style: const TextStyle(color: Colors.white, fontSize: 12),
                maxLines: 1,
                minFontSize: 8,
              ),
            ),
        ],
      ),
    );
  }
}
