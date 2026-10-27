import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_rx/src/rx_typedefs/rx_typedefs.dart';
import 'package:lottie/lottie.dart';
import 'package:share_plus/share_plus.dart';
import 'package:story_box/custom_widget/create_repprt/report_bottom_sheet_ui.dart';
import 'package:story_box/custom_widget/custom_icon_button.dart';
import 'package:story_box/deep_link/services/deep_link_services.dart';
import 'package:story_box/deep_link/share_manager/share_manager.dart';
import 'package:story_box/main.dart';
import 'package:story_box/payment/view/payment_gateway_list_page.dart';
import 'package:story_box/routes/app_routes.dart';
import 'package:story_box/service/video_notification_service.dart';
import 'package:story_box/shimmer/vip_plan_shimmer.dart';
import 'package:story_box/ui/episode_wise_reels_page/controller/episode_wise_reels_controller.dart';
import 'package:story_box/ui/home_page/controller/home_controller.dart';
import 'package:story_box/ui/profile_page/controller/profile_controller.dart';
import 'package:story_box/ui/reels_page/api/create_favorite_video_api.dart';
import 'package:story_box/ui/reels_page/api/create_like_dislike_of_video_api.dart';
import 'package:story_box/ui/reels_page/controller/reels_controller.dart';
import 'package:story_box/ui/refill/controller/refill_controller.dart';
import 'package:story_box/ui/refill/view/store_view.dart';
import 'package:story_box/utils/asset.dart';
import 'package:story_box/utils/branch_io_services.dart';
import 'package:story_box/utils/color.dart';
import 'package:story_box/utils/enums.dart';
import 'package:story_box/utils/font_style.dart';
import 'package:story_box/utils/preference.dart';
import 'package:story_box/utils/utils.dart';
import 'package:vibration/vibration.dart';
import 'package:video_player/video_player.dart';

class EpisodeWisePreviewReelsView extends StatefulWidget {
  const EpisodeWisePreviewReelsView({super.key, required this.index, required this.currentPageIndex});

  final int index;
  final int currentPageIndex;

  @override
  State<EpisodeWisePreviewReelsView> createState() => _EpisodeWisePreviewReelsViewState();
}

class _EpisodeWisePreviewReelsViewState extends State<EpisodeWisePreviewReelsView> with SingleTickerProviderStateMixin, VideoNotificationMixin {
  final controller = Get.find<EpisodeWiseReelsController>();
  final homeController = Get.find<HomeController>();
  final reelsController = Get.find<ReelsController>();
  bool _hasHandledLockForCurrentSession = false;
  ChewieController? chewieController;
  VideoPlayerController? videoPlayerController;

  RxBool isPlaying = true.obs;
  RxBool isShowIcon = false.obs;

  RxBool isBuffering = false.obs;
  RxBool isVideoLoading = true.obs;

  RxBool isShowLikeAnimation = false.obs;
  RxBool isShowLikeIconAnimation = false.obs;

  RxBool isReelsPage = true.obs; // This is Use to Stop Auto Playing..

  RxBool isLike = false.obs;
  bool isFavorite = false;
  // RxBool isFavorite = false.obs;

  RxMap customChanges = {"like": 0, "favorite": 0}.obs;

  late Animation<double> animation;

  RxBool isReadMore = false.obs;

  RxDouble sliderValue = 0.0.obs;
  RxString currentPosition = "00:00".obs;
  RxString totalDuration = "00:00".obs;
  RxDouble playbackSpeed = 1.0.obs;
  RxBool isControlsVisible = true.obs;
  Timer? _hideControlsTimer;
  RxBool isFullScreen = false.obs;
  bool _isSeeking = false; // prevent slider/listener conflict
  bool _hasRunPostFrame = false; // prevent repeated postFrameCallback side-effects
  final profileController = Get.find<ProfileController>();
  RxBool isAutoScrollEnabled = Preference.isAutoScrollEnabled.obs;

  @override
  void initState() {
    super.initState();
    log("startHideControlsTimer:::::>>>>>>>");
    initializeVideoPlayer();
    // startHideControlsTimer();
    customSetting();
    if (Preference.isVip == false && controller.mainReels[widget.index].isLocked == true) {
      isPlaying.value = false;
      isShowIcon.value = true;
    }
  }

  void startHideControlsTimer() {
    _hideControlsTimer?.cancel(); // Cancel any existing timer
    _hideControlsTimer = Timer(const Duration(seconds: 5), () {
      log("startHideControlsTimer:::::>>>>>>>");
      isControlsVisible.value = false;
    });
  }

  @override
  void dispose() {
    log('startHideControlsTimer:::::>>>>>>> dispose');
    _hideControlsTimer?.cancel();
    // if video was still playing when disposed (e.g. page swipe)
    if (playStopwatch.isRunning) {
      playStopwatch.stop();
      final elapsed = playStopwatch.elapsed.inSeconds;
      if (elapsed > 0) {
        controller.updateWatchedTime(widget.index, elapsed);
      }
      playStopwatch.reset();
    }

    controller.flushWatchHistory(widget.index);
    onDisposeVideoPlayer();
    disposeNotification();
    if (widget.index == widget.currentPageIndex) {
      setHistory();
    }

    log("Dispose Method Called Success ${widget.index}");
    super.dispose();
  }

  // Add this flag variable in your class
  int retryCount = 0;
  final int maxRetryCount = 2;
  Future<void> initializeVideoPlayer() async {
    try {
      // Reset the completion flag when initializing new video
      controller.isVideoCompleted = false;

      String videoPath = controller.mainReels[widget.index].videoUrl ?? "";

      log(" Initialize Video Path => $videoPath");
      log('CURRENT INDEX ::${widget.index}');
      try {
        videoPlayerController = VideoPlayerController.networkUrl(
          Uri.parse(videoPath),
          videoPlayerOptions: VideoPlayerOptions(mixWithOthers: false),
        );

        await videoPlayerController?.initialize();

        log("✅ Video initialized successfully!");
      } catch (e, st) {
        log("⚠️ Video initialization failed! Running recovery...");
        log("Url INIT ERROR ==>  ${e.toString()}");
        log("Url INIT ERROR ST==> ${st.toString()}");

        // await _retryVideoInitialization(); // your recovery method
      }

      if (videoPlayerController != null && (videoPlayerController?.value.isInitialized ?? false)) {
        chewieController = ChewieController(
          videoPlayerController: videoPlayerController!,
          looping: true,
          allowedScreenSleep: false,
          allowMuting: false,
          showControlsOnInitialize: false,
          showControls: false,
          maxScale: 1,
        );

        if (chewieController != null) {
          log('CURRENT INDEX ::01');
          isVideoLoading.value = false;
          await initializeNotificationForVideo();
          if (widget.index == widget.currentPageIndex && isReelsPage.value) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              onPlayVideo();
            });
          }
        } else {
          isVideoLoading.value = true;
        }

        videoPlayerController?.addListener(
          () async {
            // Use => If Video Buffering then show loading....
            (videoPlayerController?.value.isBuffering ?? false) ? isBuffering.value = true : isBuffering.value = false;
            if (videoPlayerController?.value.isInitialized ?? false) {
              final position = videoPlayerController?.value.position ?? Duration.zero;
              final duration = videoPlayerController?.value.duration ?? Duration.zero;

              // Only update slider if user is NOT actively seeking
              if (!_isSeeking && duration.inMilliseconds > 0) {
                sliderValue.value = position.inMilliseconds / duration.inMilliseconds;
              }

              // Update current position and total duration display
              currentPosition.value = Utils.formatDuration(position);
              totalDuration.value = Utils.formatDuration(duration);
            }
            if (isReelsPage.value == false) {
              onStopVideo(); // Use => On Change Routes...
            }

            // Check if video is completed and hasn't been marked as completed yet
            if (!controller.isVideoCompleted &&
                videoPlayerController!.value.position.inSeconds >= videoPlayerController!.value.duration.inSeconds &&
                videoPlayerController!.value.duration.inSeconds > 0) {
              controller.isVideoCompleted = true; // Mark as completed to prevent multiple calls
              videoPlayerController?.seekTo(Duration.zero);
              // onPlayVideo();
              onVideoCompleted(widget.index);
              log("Video Completed !!! ${widget.index}");
            }
          },
        );
      }
    } catch (e) {
      onDisposeVideoPlayer();
      log("Reels Video Initialization Failed !!! $e");
    }
  }

  // Future<void> _retryVideoInitialization() async {
  //   try {
  //     if (videoPlayerController == null) return;
  //
  //     final currentUrl = controller.mainReels[widget.index].videoUrl ?? ""; // your source
  //     final position = videoPlayerController!.value.position;
  //
  //     log("🧩 Retrying video initialization after codec error...");
  //
  //     // Dispose the broken controller
  //     await videoPlayerController!.dispose();
  //     videoPlayerController = null;
  //
  //     // Small delay to let ExoPlayer release native codecs
  //     await Future.delayed(const Duration(milliseconds: 300));
  //
  //     // ✅ Recreate controller
  //     videoPlayerController = VideoPlayerController.networkUrl(
  //       Uri.parse(currentUrl),
  //       videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
  //     );
  //
  //     await videoPlayerController!.initialize();
  //
  //     // Seek to last known position (optional)
  //     if (position != Duration.zero) {
  //       await videoPlayerController!.seekTo(position);
  //     }
  //
  //     await videoPlayerController!.play();
  //
  //     log("✅ Video recovered and playing again!");
  //   } catch (e, st) {
  //     log("❌ Failed to recover video: $e");
  //     log(st.toString());
  //   }
  // }

  Future<void> _retryVideoInitialization() async {
    try {
      log("🩹 Retrying video with software decoder...");
      final currentUrl = controller.mainReels[widget.index].videoUrl ?? "";
      // Dispose old controller if exists
      await videoPlayerController?.dispose();

      // Create new controller
      videoPlayerController = VideoPlayerController.networkUrl(
        Uri.parse(currentUrl),
        videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
      );

      // Initialize again
      await videoPlayerController!.initialize();
      await videoPlayerController!.play();

      log("✅ Video recovered with software decoder!");
    } catch (e) {
      log("❌ Failed to recover video: $e");
    }
  }

  Future<void> disposeVideoControllers() async {
    try {
      await videoPlayerController?.dispose();
      videoPlayerController = null;
      chewieController = null;
    } catch (_) {}
  }

  void onVideoCompleted(int index) {
    // Add additional check to prevent multiple API calls
    if (controller.isVideoCompleted) {
      controller.watchVideoApi(currentWatchTime: videoPlayerController!.value.position.inSeconds ?? 0, videoId: controller.mainReels[index].id ?? "");

      // Delay to ensure video is marked watched before changing page
      if (isAutoScrollEnabled.value == true) {
        Future.delayed(const Duration(milliseconds: 300), () {
          controller.preloadPageController.animateToPage(
            index + 1,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          );
        });
      }
    }
  }

  // 🎯 Initialize notification for current video
  Future<void> initializeNotificationForVideo() async {
    try {
      final title = controller.fetchEpisodeWiseReelsModel?.data?.movieSeriesName ?? "Video Player";
      final subtitle = "Episode ${widget.currentPageIndex + 1}";
      final thumbnail = controller.fetchEpisodeWiseReelsModel?.data?.movieSeriesThumbnail ?? "";

      await initializeNotification(
        title: title,
        subtitle: subtitle,
        thumbnailUrl: thumbnail,
        videoPlayerController: videoPlayerController,
      );

      log("✅ Notification initialized for: $title");
    } catch (e) {
      log("❌ Error initializing notification: $e");
    }
  }

  // 🎯 Update notification state
  Future<void> updateNotificationState() async {
    try {
      await updateNotificationForCurrentVideo(
        title: controller.fetchEpisodeWiseReelsModel?.data?.movieSeriesName ?? "Video Player",
        subtitle: "Episode ${widget.index + 1}",
        thumbnailUrl: controller.fetchEpisodeWiseReelsModel?.data?.movieSeriesThumbnail ?? "",
        videoPlayerController: videoPlayerController,
        isPlaying: videoPlayerController?.value.isPlaying ?? false,
      );
    } catch (e) {
      log("❌ Error updating notification: $e");
    }
  }

  // void onStopVideo() {
  //   if (controller.mainReels[widget.index].isLocked == false) {
  //     isPlaying.value = false;
  //     videoPlayerController?.pause();
  //     log("Video Player Pause");
  //     // VideoNotificationService.updatePlaybackState(false);
  //   }
  // }

  // void onPlayVideo() {
  //   if (controller.mainReels[widget.index].isLocked == false) {
  //     isPlaying.value = true;
  //     videoPlayerController?.play();
  //     // VideoNotificationService.updatePlaybackState(true);
  //     log("Video Player Play");
  //     startPositionUpdates(videoPlayerController);
  //   }
  // }

  // ✅ Fixed onStopVideo
  void onStopVideo() {
    if (controller.mainReels[widget.index].isLocked == false) {
      isPlaying.value = false;
      videoPlayerController?.pause();

      // Stop tracking and update notification
      VideoNotificationService.stopPositionTracking();
      VideoNotificationService.updatePlaybackState(false);

      log("⏸️ Video Paused");
    }
  }

  final Stopwatch playStopwatch = Stopwatch();

// ✅ Fixed onPlayVideo
  void onPlayVideo() {
    if (controller.mainReels[widget.index].isLocked == false) {
      isPlaying.value = true;
      videoPlayerController?.play();
      playStopwatch.start(); // ← start counting

      VideoNotificationService.updatePlaybackState(true);
      VideoNotificationService.startPositionTracking(videoPlayerController);

      log("▶️ Video Playing");
    }
  }

// ✅ Fixed onNextVideo
  @override
  void onNextVideo() {
    log("⏭️ Next video from notification");
    if (widget.index < controller.mainReels.length - 1) {
      if (Get.isBottomSheetOpen ?? false) Get.back();

      controller.preloadPageController.animateToPage(
        widget.index + 1,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    } else {
      Utils.showToast(Get.context!, "Last episode");
    }
  }

// ✅ Fixed onPreviousVideo
  @override
  void onPreviousVideo() {
    log("⏮️ Previous video from notification");
    if (widget.index > 0) {
      if (Get.isBottomSheetOpen ?? false) Get.back();

      controller.preloadPageController.animateToPage(
        widget.index - 1,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    } else {
      Utils.showToast(Get.context!, "First episode");
    }
  }

  void onDisposeVideoPlayer() {
    try {
      log("startHideControlsTimer:::::>>>>>>> END");
      onStopVideo();
      videoPlayerController?.dispose();
      chewieController?.dispose();
      disposeNotification();

      chewieController = null;
      videoPlayerController = null;
      isVideoLoading.value = true;
      // isVideoCompleted = false;
    } catch (e) {
      log(">>>> On Dispose VideoPlayer Error => $e");
    }
  }

  void customSetting() {
    isLike.value = controller.mainReels[widget.index].isLike ?? false;
    isFavorite = controller.fetchEpisodeWiseReelsModel?.data?.isAddedList ?? false;
    customChanges["like"] = int.parse("${controller.mainReels[widget.index].totalLikes ?? 0}");
    customChanges["favorite"] = int.parse("${controller.fetchEpisodeWiseReelsModel?.data?.totalAddedToList ?? 0}");
  }

  void onClickVideo() async {
    if (controller.mainReels[widget.index].isLocked == true) {
      log("is lock true....................");

      if (Preference.isVip == true || controller.isAutoUnlock) {
        // If user is VIP, unlock video and play directly
        print("is vip true....................");
        // controller.autoUnlockApi(type: true, shortVideoId: controller.mainReels[widget.index].id ?? "");
        return;
      } else {
        // For non-VIP users, show locked video handling
        print("not vip false....................");
        handleLockedVideo(context);
        return;
      }
    }

    if (isVideoLoading.value == false) {
      videoPlayerController!.value.isPlaying ? onStopVideo() : onPlayVideo();
      isShowIcon.value = true;
      await 2.seconds.delay();
      isShowIcon.value = false;
    }
    // isControlsVisible.value = true;
    // startHideControlsTimer();
    if (isReelsPage.value == false) {
      isReelsPage.value = true; // Use => On Back Reels Page...
    }
  }

  void onClickPlayPause() async {
    if (controller.mainReels[widget.index].isLocked == true) {
      // Open the bottom sheet again if the icon is clicked
      handleLockedVideo(context);
      return;
    }
    videoPlayerController!.value.isPlaying ? onStopVideo() : onPlayVideo();
    if (isReelsPage.value == false) {
      isReelsPage.value = true; // Use => On Back Reels Page...
    }
  }

  Future<void> onClickLike() async {
    if (isLike.value) {
      isLike.value = false;
      customChanges["like"]--;
      controller.update(["onGetEpisodeLikeCount"]);
    } else {
      isLike.value = true;
      customChanges["like"]++;
      controller.update(["onGetEpisodeLikeCount"]);
    }

    Vibration.vibrate(duration: 50, amplitude: 128);

    isShowLikeIconAnimation.value = true;
    await 500.milliseconds.delay();
    isShowLikeIconAnimation.value = false;

    await CreateLikeDislikeOfVideoApi.callApi(
      loginUserId: Preference.userId,
      videoId: controller.mainReels[widget.index].id ?? "",
    );
  }

  Future<void> onClickFavorite() async {
    await CreateFavoriteVideoApi.callApi(
      loginUserId: Preference.userId,
      movieSeriesId: controller.fetchEpisodeWiseReelsModel?.data?.id ?? "",
    );
    if (isFavorite) {
      isFavorite = false;
      customChanges["favorite"]--;
      controller.fetchEpisodeWiseReelsModel?.data?.isAddedList = isFavorite;
      controller.update(["onGetFavCount"]);
    } else {
      isFavorite = true;
      customChanges["favorite"]++;
      controller.fetchEpisodeWiseReelsModel?.data?.isAddedList = isFavorite;
      controller.update(["onGetFavCount"]);
    }

    reelsController.selectedIndexIsFavorite = isFavorite;
    reelsController.isFavoriteCount = customChanges["favorite"];
    // controller.update(["onGetFavCount"]);

    Vibration.vibrate(duration: 50, amplitude: 128);
  }

  Future<void> onDoubleClick() async {
    if (isLike.value) {
      isLike.value = false;
      customChanges["like"]--;
    } else {
      isLike.value = true;
      customChanges["like"]++;

      isShowLikeAnimation.value = true;
      Vibration.vibrate(duration: 50, amplitude: 128);
      await 1200.milliseconds.delay();
      isShowLikeAnimation.value = false;
    }

    // await CreateLikeDislikeOfVideoApi.callApi(
    //   loginUserId: Preference.userId,
    //   videoId: controller.mainReels[widget.index].videos?.id ?? "",
    // );
  }

  Future<void> handleLockedVideo(BuildContext context) async {
    if (!mounted) return;
    if (Preference.isVip) {
      controller.mainReels[widget.index].isLocked = false;
      onPlayVideo();
      return;
    }
    // Auto-unlock path — no sheet needed
    if (controller.isAutoUnlock && (controller.mainReels[widget.index].coin ?? 0) <= Preference.userCoin.value) {
      await controller.silentUnlock(widget.index);
      onPlayVideo();
      return;
    }

    onStopVideo();
    await 80.milliseconds.delay(); // Let pause settle before sheet animates in

    if (!mounted) return;
    if (Preference.isVip) return;
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: AppColor.transparent,
      builder: (_) => PremiumBottomSheet(
        shortVideoId: controller.mainReels[widget.index].id,
        coin: controller.mainReels[widget.index].coin ?? 0,
        videoId: controller.mainReels[widget.index].id,
        episodeUnlockCount: controller.fetchEpisodeWiseReelsModel?.userInfo?.episodeUnlockAds ?? 0,
        maxCount: controller.fetchEpisodeWiseReelsModel?.data?.movieSeriesMaxAdsForFreeView ?? 0,
        callback: () {
          if (Preference.isVip == false) {
            controller.unlockWithCoins(
              index: widget.index,
              onSuccess: () {
                Get.back();
              },
              onInsufficientCoins: () {
                Get.back();
                Get.bottomSheet(
                  UnlockNowBottomSheet(
                    coin: controller.mainReels[widget.index].coin ?? 0,
                  ),
                );
              },
            );
          }
        },
        adCallback: () async {
          await controller.unlockWithAd(videoId: controller.mainReels[widget.index].id, index: widget.index);
          //
        },
      ),
    );

    // Sheet is now fully dismissed — safe to play
    await 80.milliseconds.delay();
    if (!mounted) return;

    if (controller.mainReels[widget.index].isLocked == false) {
      onPlayVideo();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.index >= controller.mainReels.length) {
      return const SizedBox.shrink();
    }

    final bool isCurrentPage = widget.index == widget.currentPageIndex;

    // ✅ બધા side effects postFrameCallback માં — build() clean રહે
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;

      if (isCurrentPage) {
        if (!isVideoLoading.value && isReelsPage.value) {
          onPlayVideo();
          updateNotificationState();
        }

        if (Preference.isVip) {
          final video = controller.mainReels[widget.index];
          if (video.isLocked == true) video.isLocked = false;
          return;
        }

        if (controller.isAutoUnlock && (controller.mainReels[widget.index].coin ?? 0) <= Preference.userCoin.value) {
          await controller.silentUnlock(widget.index);
          return;
        }

        if (controller.mainReels[widget.index].isLocked == true && !_hasHandledLockForCurrentSession) {
          _hasHandledLockForCurrentSession = true;
          await handleLockedVideo(context);
        }
      } else {
        // ✅ else branch પણ postFrameCallback માં
        _hasHandledLockForCurrentSession = false;
        if (!isVideoLoading.value) {
          videoPlayerController?.seekTo(Duration.zero);
        }
        onStopVideo();
      }
    });
    return WillPopScope(
      onWillPop: () async {
        return true;
      },
      child: Scaffold(
        body: SizedBox(
          height: Get.height,
          width: Get.width,
          child: Stack(
            children: [
              GestureDetector(
                onTap: onClickVideo,
                // onDoubleTap: onDoubleClick,
                child: Container(
                  color: AppColor.colorBlack,
                  height: Get.height,
                  width: Get.width,
                  child: Obx(
                    () => isVideoLoading.value
                        ? const Align(
                            alignment: Alignment.bottomCenter,
                            child: LinearProgressIndicator(color: AppColor.colorPrimary),
                          )
                        : SizedBox.expand(
                            child: FittedBox(
                              fit: BoxFit.cover,
                              child: SizedBox(
                                width: videoPlayerController?.value.size.width ?? 0,
                                height: videoPlayerController?.value.size.height ?? 0,
                                child: Chewie(controller: chewieController!),
                              ),
                            ),
                          ),
                  ),
                ),
              ),
              Obx(
                () => isShowIcon.value
                    ? Align(
                        alignment: Alignment.center,
                        child: isPlaying.value
                            ? GestureDetector(
                                onTap: onClickPlayPause,
                                child: const SizedBox(
                                  height: 50,
                                  width: 50,
                                  child: Center(
                                    child: Icon(
                                      Icons.pause_rounded,
                                      size: 60,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              )
                            : GestureDetector(
                                onTap: onClickPlayPause,
                                child: SizedBox(
                                  height: 50,
                                  width: 50,
                                  child: Center(
                                    child: Image.asset(
                                      AppAsset.icPlay,
                                      color: AppColor.colorWhite.withValues(alpha: 0.8),
                                    ),
                                  ),
                                ),
                              ),
                      )
                    : const Offstage(),
              ),
              Positioned(
                bottom: 0,
                child: Obx(
                  () => Visibility(
                    visible: (isVideoLoading.value == false),
                    child: Container(
                      height: Get.height / 4,
                      width: Get.width,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [AppColor.transparent, AppColor.colorBlack.withValues(alpha: 0.7)],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Container(
                // color: Colors.teal,
                padding: Platform.isAndroid ? const EdgeInsets.only(top: 30, left: 10, bottom: 10, right: 10) : const EdgeInsets.only(top: 46, left: 10, bottom: 10, right: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    5.width,
                    Obx(
                      () => Visibility(
                        visible: isControlsVisible.value,
                        child: InkWell(
                          onTap: () async {
                            isReelsPage.value = false;
                            Get.back();
                          },
                          child: Container(
                            height: 50,
                            width: 30,
                            decoration: const BoxDecoration(
                              color: Colors.transparent,
                              shape: BoxShape.circle,
                            ),
                            alignment: Alignment.centerLeft,
                            child: const Icon(
                              Icons.arrow_back_ios_new_rounded,
                              color: AppColor.colorWhite,
                            ),
                          ),
                        ),
                      ),
                    ),
                    3.width,
                    Obx(
                      () => Visibility(
                        visible: isControlsVisible.value,
                        child: SizedBox(
                          width: Get.width * 0.55,
                          child: Text(
                            controller.fetchEpisodeWiseReelsModel?.data?.movieSeriesName ?? "",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppFontStyle.styleW600(AppColor.colorWhite, 18).copyWith(
                              shadows: [
                                const Shadow(
                                  offset: Offset(1.5, 1.5), // shadow ni position
                                  blurRadius: 4.0, // blur effect
                                  color: Colors.black54, // shadow nu color
                                ),
                              ],
                            ),
                          ).paddingOnly(top: 3),
                        ),
                      ),
                    ),
                    3.width,
                    Obx(
                      () => Visibility(
                        visible: isControlsVisible.value,
                        child: Text(
                          "${widget.index}/${controller.mainReels.length - 1}",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppFontStyle.styleW600(AppColor.colorWhite, 15).copyWith(
                            shadows: [
                              const Shadow(
                                offset: Offset(1.5, 1.5), // shadow ni position
                                blurRadius: 4.0, // blur effect
                                color: Colors.black54, // shadow nu color
                              ),
                            ],
                          ),
                        ).paddingOnly(top: 5),
                      ),
                    ),
                    const Spacer(),
                    Obx(
                      () => GestureDetector(
                        onTap: () {
                          isFullScreen.value = !isFullScreen.value;
                          isControlsVisible.value = !isControlsVisible.value;
                          // Don't touch isControlsVisible here
                        },
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: .2),
                            shape: BoxShape.circle,
                          ),
                          child: Image.asset(
                            !isFullScreen.value ? AppAsset.halfScreen : AppAsset.fullScreen,
                            fit: BoxFit.cover,
                            height: 20,
                            color: AppColor.colorWhite,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Obx(
                () => Visibility(
                  visible: isControlsVisible.value,
                  child: Positioned(
                    right: 10,
                    child: Container(
                      padding: const EdgeInsets.only(top: 30, bottom: 100),
                      height: Get.height,
                      child: Column(
                        children: [
                          const Spacer(),
                          10.height,
                          Obx(
                            () => SizedBox(
                              height: 40,
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                height: isShowLikeIconAnimation.value ? 15 : 50,
                                width: isShowLikeIconAnimation.value ? 15 : 50,
                                alignment: Alignment.center,
                                child: CustomIconButton(
                                  icon: isLike.value ? AppAsset.icSelectedLike : AppAsset.icLike,
                                  callback: onClickLike,
                                  iconSize: 34,
                                  // iconColor: isLike.value ? AppColor.colorRedContainer : AppColor.colorWhite,
                                ),
                              ),
                            ),
                          ),
                          GetBuilder<EpisodeWiseReelsController>(
                            id: 'onGetEpisodeLikeCount',
                            builder: (context) {
                              return Text(
                                CustomFormatNumber.convert(customChanges["like"]),
                                style: AppFontStyle.styleW700(AppColor.colorWhite, 14),
                              );
                            },
                          ),
                          15.height,

                          Obx(() => SizedBox(
                                height: 40,
                                child: Container(
                                  height: 50,
                                  width: 50,
                                  alignment: Alignment.center,
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 3.0),
                                    child: CustomIconButton(
                                      icon: controller.isFavorite.value ? AppAsset.icFavoriteSelected : AppAsset.icFavorite,
                                      callback: () => controller.onClickFavorite(),
                                      iconSize: 34,
                                    ),
                                  ),
                                ),
                              )),

                          // Favorite Count with Obx for reactive updates
                          Obx(() => Text(
                                CustomFormatNumber.convert(controller.favoriteCount.value),
                                style: AppFontStyle.styleW700(AppColor.colorWhite, 14),
                              )),
                          15.height,
                          CustomIconButton(
                            icon: AppAsset.icList,
                            circleSize: 40,
                            callback: () {
                              Get.bottomSheet(ShowAllEpisodeBottomSheet(
                                currentPlayingIndex: widget.index,
                              ));
                            },
                            iconSize: 34,
                            iconColor: AppColor.colorWhite,
                          ),
                          Text(
                            EnumLocal.list.name.tr,
                            style: AppFontStyle.styleW700(AppColor.colorWhite, 14),
                          ),
                          15.height,
                          CustomIconButton(
                            icon: AppAsset.icShare,
                            circleSize: 40,
                            callback: () async {
                              print("-------- Episode Share");
                              ShareManager.shareContent(
                                  id: controller.fetchEpisodeWiseReelsModel?.data?.id ?? "",
                                  title: controller.fetchEpisodeWiseReelsModel?.data?.movieSeriesName ?? "",
                                  imageUrl: controller.fetchEpisodeWiseReelsModel?.data?.movieSeriesThumbnail ?? "",
                                  shareType: ShareType.withImage, // Choose your preferred type
                                  pageRoutes: DeepLinkServices.episodeKey,
                                  episodeNumber: widget.index,
                                  totalVideos: controller.totalVideos ?? 0,
                                  movieName: controller.fetchEpisodeWiseReelsModel?.data?.movieSeriesName ?? "");
                            },
                            iconSize: 34,
                            iconColor: AppColor.colorWhite,
                          ),
                          Text(
                            EnumLocal.share.name.tr,
                            style: AppFontStyle.styleW700(AppColor.colorWhite, 14),
                          ),
                          15.height,
                          CustomIconButton(
                            icon: AppAsset.icMore,
                            circleSize: 40,
                            callback: () async {
                              ReportBottomSheetUi.show(context: context, eventId: controller.mainReels[widget.index].id ?? "", eventType: 1);
                            },
                            iconSize: 24,
                            iconColor: AppColor.colorWhite,
                          ),
                          28.height,
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: GestureDetector(
                  onTap: () {
                    isControlsVisible.value = true;
                    // startHideControlsTimer();
                  },
                  child: Obx(
                    () => Visibility(
                      visible: isControlsVisible.value,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Slimmer Slider
                          SliderTheme(
                            data: SliderTheme.of(context).copyWith(
                              trackHeight: 2.5,
                              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8.0),
                              overlayShape: const RoundSliderOverlayShape(overlayRadius: 16.0),
                            ),
                            child: Slider(
                              value: sliderValue.value,
                              onChanged: (value) async {
                                final duration = videoPlayerController?.value.duration ?? Duration.zero;
                                final newPosition = duration * value;
                                await videoPlayerController?.seekTo(newPosition);
                              },
                              activeColor: AppColor.colorPrimary,
                              inactiveColor: AppColor.colorWhite.withValues(alpha: 0.3),
                            ),
                          ),
                          // Compact duration and speed controls
                          Padding(
                            padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 32, top: 0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Obx(() => Text(
                                      "${currentPosition.value} / ${totalDuration.value}",
                                      style: AppFontStyle.styleW500(AppColor.colorWhite, 14),
                                    )),
                                Row(
                                  children: [
                                    Obx(() => Text(
                                          "${playbackSpeed.value.toStringAsFixed(1)}x",
                                          style: AppFontStyle.styleW500(AppColor.colorWhite, 14),
                                        )),
                                    16.width,
                                    GestureDetector(
                                        onTap: () {
                                          if (playbackSpeed.value == 1.0) {
                                            playbackSpeed.value = 1.5;
                                            videoPlayerController?.setPlaybackSpeed(1.5);
                                          } else if (playbackSpeed.value == 1.5) {
                                            playbackSpeed.value = 2.0;
                                            videoPlayerController?.setPlaybackSpeed(2.0);
                                          } else {
                                            playbackSpeed.value = 1.0;
                                            videoPlayerController?.setPlaybackSpeed(1.0);
                                          }
                                        },
                                        child: const Icon(Icons.speed, color: AppColor.colorWhite, size: 18)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> setHistory() async {
    await 100.milliseconds.delay();
    final videoData = {
      "id": controller.fetchEpisodeWiseReelsModel?.data?.id ?? "",
      "title": controller.fetchEpisodeWiseReelsModel?.data?.movieSeriesName ?? "",
      "thumbnail": controller.fetchEpisodeWiseReelsModel?.data?.movieSeriesThumbnail ?? "",
      "videoUrl": controller.fetchEpisodeWiseReelsModel?.data?.videos?[widget.index].videoUrl ?? "",
      "lastEpisode": widget.index,
      "totalEpisodes": controller.mainReels.length - 1,
      "isLike": isFavorite,
    };
    log("DATA :: $videoData");
    await Preference.addVideoToHistory(videoData);
    await homeController.getHistory();
  }

  // @override
  // void onNextVideo() {
  //   // TODO: implement onNextVideo
  // }
  //
  // @override
  // void onPreviousVideo() {
  //   // TODO: implement onPreviousVideo
  // }
}

class CustomFormatNumber {
  static String convert(int number) {
    if (number >= 1000000) {
      // Handle 1 million and above
      return '${(number / 1000000).toStringAsFixed(2)}m';
    } else if (number >= 1000) {
      // Handle thousands
      return '${(number / 1000).toStringAsFixed(2)}k';
    } else {
      // Handle less than a thousand
      return number.toString();
    }
  }
}

class ShowAllEpisodeBottomSheet extends StatelessWidget {
  const ShowAllEpisodeBottomSheet({super.key, this.currentPlayingIndex = 0});

  final int? currentPlayingIndex;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<EpisodeWiseReelsController>();

    return Container(
      width: Get.width,
      decoration: const BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: SizedBox(
        height: Get.height * 0.5, // Adjust height
        child: Builder(
          builder: (context) {
            List<int> episodeList = List.generate((controller.totalVideos ?? 0), (index) => index);

            ///

            List<int> tab1List = episodeList.length >= 50 ? episodeList.sublist(0, 50) : episodeList;
            List<int>? tab2List = episodeList.length > 50 ? episodeList.sublist(50) : null;

            return DefaultTabController(
              length: tab2List == null ? 1 : 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Text(
                          "${EnumLocal.list.name.tr} ",
                          style: const TextStyle(color: Colors.white, fontSize: 16),
                        ),
                        Text(
                          "(${EnumLocal.completed.name.tr})",
                          style: const TextStyle(color: AppColor.colorTextDarkGrey, fontSize: 14),
                        ),
                        const Spacer(),
                        GestureDetector(
                          onTap: () => Get.back(),
                          child: const Icon(
                            Icons.close,
                            color: AppColor.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  TabBar(
                    indicatorColor: AppColor.colorButtonPink,
                    labelColor: AppColor.colorButtonPink,
                    unselectedLabelColor: AppColor.colorWhite,
                    isScrollable: true,
                    tabAlignment: TabAlignment.start,
                    tabs: [
                      Tab(text: '0 - ${tab1List.length - 1}'),
                      if (tab2List != null) Tab(text: '50 - ${episodeList.length - 1}'),
                    ],
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        GridView.builder(
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 5,
                            crossAxisSpacing: 6.0,
                            mainAxisSpacing: 6.0,
                            childAspectRatio: 1.7,
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                          itemCount: tab1List.length,
                          itemBuilder: (context, index) {
                            if (index == 0) {
                              return GestureDetector(
                                onTap: () {
                                  controller.jumpPage(index);
                                },
                                child: Container(
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: currentPlayingIndex == index ? AppColor.bgGreyColor : AppColor.shimmer,
                                    border: Border.all(color: currentPlayingIndex == index ? AppColor.shimmer : Colors.transparent),
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  child: currentPlayingIndex == index
                                      ? Lottie.asset(
                                          AppAsset.play,
                                          fit: BoxFit.cover,
                                          height: 26,
                                          width: 26,
                                        ).paddingOnly(right: 8)
                                      : Text(
                                          EnumLocal.trailer.name.tr,
                                          style: const TextStyle(color: Colors.white),
                                        ),
                                ),
                              );
                            }

                            ///TODO
                            // else if (index > 0 && index <= 7 /*controller.mainReels[index].isLocked == true*/) {
                            else if (controller.mainReels[index].isLocked == false || Preference.isVip == true) {
                              return GestureDetector(
                                onTap: () {
                                  controller.jumpPage(index);
                                },
                                child: Container(
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: currentPlayingIndex == index ? AppColor.bgGreyColor : AppColor.shimmer,
                                    border: Border.all(color: currentPlayingIndex == index ? AppColor.shimmer : Colors.transparent),
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  child: currentPlayingIndex == index
                                      ? Lottie.asset(
                                          AppAsset.play,
                                          fit: BoxFit.cover,
                                          height: 26,
                                          width: 26,
                                        ).paddingOnly(right: 8)
                                      : Text(
                                          '$index',
                                          style: const TextStyle(color: AppColor.colorWhite),
                                        ),
                                ),
                              );
                            } else {
                              return GestureDetector(
                                onTap: () {
                                  // int? firstLockedIndex = controller.mainReels.indexWhere((video) => video.isLocked == true);
                                  // if (firstLockedIndex == index) {
                                  // Open the PremiumBottomSheet for the first locked video
                                  // Get.bottomSheet(
                                  //   isDismissible: false,
                                  //   enableDrag: false,
                                  //   PremiumBottomSheet(
                                  //     coin: controller.mainReels[index].coin ?? 0,
                                  //     videoId: controller.mainReels[index].id,
                                  //     maxCount: controller.fetchEpisodeWiseReelsModel?.data?.movieSeriesMaxAdsForFreeView ?? 0,
                                  //     episodeUnlockCount: controller.fetchEpisodeWiseReelsModel?.userInfo?.episodeUnlockAds ?? 0,
                                  //   ),
                                  // );
                                  // } else {
                                  // Show a toast message for other locked videos
                                  // showTooltip(context);
                                  controller.jumpPage(index);
                                  // Get.snackbar(
                                  //   'Locked Video',
                                  //   'The stories in between are also very interesting. Don\'t miss out!',
                                  //   snackPosition: SnackPosition.BOTTOM,
                                  //   backgroundColor: Colors.black,
                                  //   colorText: Colors.white,
                                  //   duration: const Duration(seconds: 3),
                                  // );
                                  // }
                                  // Get.bottomSheet(
                                  //   isDismissible: false,
                                  //   enableDrag: false,
                                  //   PremiumBottomSheet(
                                  //     coin: controller.mainReels[index].coin ?? 0,
                                  //     videoId: controller.mainReels[index].id,
                                  //     maxCount: controller.fetchEpisodeWiseReelsModel?.data?.movieSeriesMaxAdsForFreeView ?? 0,
                                  //     episodeUnlockCount: controller.fetchEpisodeWiseReelsModel?.userInfo?.episodeUnlockAds ?? 0,
                                  //   ),
                                  // );
                                },
                                child: Container(
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: currentPlayingIndex == index ? AppColor.bgGreyColor : AppColor.shimmer,
                                    border: Border.all(color: currentPlayingIndex == index ? AppColor.shimmer : Colors.transparent),
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      currentPlayingIndex == index
                                          ? Lottie.asset(
                                              AppAsset.play,
                                              fit: BoxFit.cover,
                                              height: 26,
                                              width: 26,
                                            ).paddingOnly(right: 8)
                                          : Text(
                                              '$index',
                                              style: const TextStyle(color: AppColor.colorWhite),
                                            ),
                                      Align(
                                        alignment: Alignment.topRight,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                          decoration: const BoxDecoration(
                                            color: AppColor.colorButtonPink,
                                            borderRadius: BorderRadius.only(
                                              topRight: Radius.circular(8),
                                              bottomLeft: Radius.circular(4),
                                            ),
                                          ),
                                          child: const Icon(
                                            Icons.lock,
                                            color: Colors.white,
                                            size: 10,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }
                          },
                        ),
                        if (tab2List != null)
                          GridView.builder(
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 5,
                              crossAxisSpacing: 10.0,
                              mainAxisSpacing: 10.0,
                              childAspectRatio: 1.7,
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                            itemCount: tab2List.length,
                            itemBuilder: (context, index) {
                              final actualIndex = 50 + index;
                              return Container(
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade800,
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    Text(
                                      '$actualIndex',
                                      style: const TextStyle(color: Colors.white),
                                    ),

                                    ///condition check
                                    // Align(
                                    //   alignment: Alignment.topRight,
                                    //   child: Container(
                                    //     padding: const EdgeInsets.symmetric(
                                    //         horizontal: 4, vertical: 2),
                                    //     decoration: const BoxDecoration(
                                    //       color: AppColor.colorButtonPink,
                                    //       borderRadius: BorderRadius.only(
                                    //         topRight: Radius.circular(8),
                                    //         bottomLeft: Radius.circular(4),
                                    //       ),
                                    //     ),
                                    //     child: const Icon(
                                    //       Icons.lock,
                                    //       color: Colors.white,
                                    //       size: 10,
                                    //     ),
                                    //   ),
                                    // ),
                                    controller.mainReels[actualIndex].isLocked == false || Preference.isVip == true
                                        ? GestureDetector(
                                            onTap: () {
                                              controller.jumpPage(actualIndex);
                                            },
                                            child: Container(
                                              alignment: Alignment.center,
                                              decoration: BoxDecoration(
                                                color: currentPlayingIndex == actualIndex ? AppColor.bgGreyColor : AppColor.shimmer,
                                                border: Border.all(color: currentPlayingIndex == actualIndex ? AppColor.shimmer : Colors.transparent),
                                                borderRadius: BorderRadius.circular(8.0),
                                              ),
                                              child: currentPlayingIndex == actualIndex
                                                  ? Lottie.asset(
                                                      AppAsset.play,
                                                      fit: BoxFit.cover,
                                                      height: 26,
                                                      width: 26,
                                                    ).paddingOnly(right: 8)
                                                  : Text(
                                                      '$actualIndex',
                                                      style: const TextStyle(color: AppColor.colorWhite),
                                                    ),
                                            ),
                                          )
                                        : GestureDetector(
                                            onTap: () {
                                              showTooltip(context);
                                            },
                                            child: Container(
                                              alignment: Alignment.center,
                                              decoration: BoxDecoration(
                                                color: currentPlayingIndex == actualIndex ? AppColor.bgGreyColor : AppColor.shimmer,
                                                border: Border.all(color: currentPlayingIndex == actualIndex ? AppColor.shimmer : Colors.transparent),
                                                borderRadius: BorderRadius.circular(8.0),
                                              ),
                                              child: Stack(
                                                alignment: Alignment.center,
                                                children: [
                                                  currentPlayingIndex == actualIndex
                                                      ? Lottie.asset(
                                                          AppAsset.play,
                                                          fit: BoxFit.cover,
                                                          height: 26,
                                                          width: 26,
                                                        ).paddingOnly(right: 8)
                                                      : Text(
                                                          '$actualIndex',
                                                          style: const TextStyle(color: AppColor.colorWhite),
                                                        ),
                                                  Align(
                                                    alignment: Alignment.topRight,
                                                    child: Container(
                                                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                                      decoration: const BoxDecoration(
                                                        color: AppColor.colorButtonPink,
                                                        borderRadius: BorderRadius.only(
                                                          topRight: Radius.circular(8),
                                                          bottomLeft: Radius.circular(4),
                                                        ),
                                                      ),
                                                      child: const Icon(
                                                        Icons.lock,
                                                        color: Colors.white,
                                                        size: 10,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                  ],
                                ),
                              );
                            },
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  void showTooltip(BuildContext context) {
    OverlayState overlayState = Overlay.of(context);
    OverlayEntry overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).size.height * 0.4,
        left: MediaQuery.of(context).size.width * 0.2,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColor.shimmer,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "The stories in between are also very\n interesting. Don't miss out!",
                  style: TextStyle(color: Colors.white),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );

    overlayState.insert(overlayEntry);

    Future.delayed(const Duration(seconds: 2), () {
      overlayEntry.remove();
    });
  }
}

class PremiumBottomSheet extends StatefulWidget {
  const PremiumBottomSheet({
    super.key,
    required this.coin,
    required this.videoId,
    this.callback,
    required this.maxCount,
    required this.episodeUnlockCount,
    this.adCallback,
    this.shortVideoId,
  });

  final int? coin;
  final int? maxCount;
  final int? episodeUnlockCount;
  final String? videoId;
  final String? shortVideoId;
  final Callback? callback;
  final Callback? adCallback;

  @override
  State<PremiumBottomSheet> createState() => _PremiumBottomSheetState();
}

class _PremiumBottomSheetState extends State<PremiumBottomSheet> {
  final profileController = Get.find<ProfileController>();
  final controller = Get.find<EpisodeWiseReelsController>();

  bool isCustomAdLoading = false;

  late bool isAutoUnlock = controller.isAutoUnlock; // per-series from API

  void toggleAutoUnlock() async {
    final newValue = !isAutoUnlock;
    setState(() => isAutoUnlock = newValue);

    // Update model immediately for per-series tracking
    controller.fetchEpisodeWiseReelsModel?.isAutoUnlockEnabled = newValue;
    await Preference.onIsAutoCheck(newValue);

    if (newValue && (widget.coin ?? 0) <= Preference.userCoin.value) {
      // Fire API in background — don't block the UI or sheet close
      if ((widget.shortVideoId ?? "").isNotEmpty) {
        controller.setAutoUnlock(
          value: true,
          shortVideoId: widget.shortVideoId ?? "",
        );
      }

      // Immediately unlock with coins → closes sheet → plays video
      widget.callback?.call();
    }
  }

  void applyAutoUnlockIfEnabled() {
    if (isAutoUnlock && (widget.shortVideoId ?? "").isNotEmpty) {
      controller.setAutoUnlock(
        value: true,
        shortVideoId: widget.shortVideoId ?? "",
      );
    }
  
}

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          margin: const EdgeInsets.only(top: 92),
          width: Get.width,
          decoration: const BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: GetBuilder<RefillController>(
            id: 'updateCoin',
            builder: (context) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    12.height,
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        GestureDetector(
                          onTap: () => Get.back(),
                          child: const Icon(Icons.close, color: AppColor.grey),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text("${EnumLocal.price.name.tr} :", style: AppFontStyle.styleW800(AppColor.grey, 16)),
                                7.width,
                                Row(
                                  children: [
                                    Image.asset(AppAsset.starCoin, height: 12).paddingOnly(right: 3),
                                    Text('${widget.coin}', style: AppFontStyle.styleW800(AppColor.colorWhite, 16)),
                                  ],
                                ),
                                7.width,
                              ],
                            ),
                            Row(
                              children: [
                                Text("${EnumLocal.balance.name.tr} :", style: AppFontStyle.styleW800(AppColor.grey, 14)),
                                7.width,
                                Obx(() => Row(
                                      children: [
                                        Image.asset(AppAsset.starCoin, height: 12).paddingOnly(right: 3),
                                        Text("${Preference.userCoin}", style: AppFontStyle.styleW800(AppColor.colorWhite, 14)),
                                      ],
                                    )),
                                7.width,
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                    25.height,
                    GetBuilder<EpisodeWiseReelsController>(
                      id: 'onGetReels',
                      builder: (logic) {
                        return widget.maxCount == 0 && logic.episodeUnlockAdsCount == 0
                            ? const SizedBox()
                            : GestureDetector(
                                onTap: () {
                                  if (logic.episodeUnlockAdsCount == widget.maxCount) {
                                    Utils.showToast(Get.context!, EnumLocal.yourMaxAdLimitIsReachedForToday.name.tr);
                                  } else {
                                    widget.adCallback!();
                                  }
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 5),
                                  decoration: BoxDecoration(
                                    color: logic.episodeUnlockAdsCount == widget.maxCount ? AppColor.colorIconGrey : AppColor.primaryColor,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          const Icon(Icons.local_movies_outlined, size: 20, color: Colors.white),
                                          4.width,
                                          Text(EnumLocal.watchAdToUnlockForFree.name.tr, style: AppFontStyle.styleW400(AppColor.colorWhite, 14)),
                                        ],
                                      ),
                                      Text(
                                        "${EnumLocal.watchedToday.name.tr} (${logic.episodeUnlockAdsCount}/${widget.maxCount})",
                                        style: AppFontStyle.styleW400(AppColor.colorWhite, 14),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                      },
                    ),
                    16.height,
                    GestureDetector(
                      onTap: () {
                        applyAutoUnlockIfEnabled();
                        widget.callback?.call();
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColor.colorIconGrey),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.lock_outline, size: 20, color: Colors.white),
                            4.width,
                            Text(EnumLocal.txtWatchWithCoin.name.tr, style: AppFontStyle.styleW400(AppColor.colorWhite, 14)),
                          ],
                        ),
                      ),
                    ),
                    42.height,
                    GestureDetector(
                      onTap: toggleAutoUnlock,
                      child: Container(
                        padding: const EdgeInsets.only(right: 10, left: 10, top: 5, bottom: 5),
                        decoration: BoxDecoration(
                          color: AppColor.shimmer,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isAutoUnlock ? Icons.check_circle_outlined : Icons.circle_outlined,
                              color: isAutoUnlock ? AppColor.primaryColor : AppColor.colorWhite,
                              size: 18,
                            ),
                            4.width,
                            Text(EnumLocal.autoUnlockNextEpisode.name.tr, style: AppFontStyle.styleW500(AppColor.colorWhite, 15)),
                          ],
                        ),
                      ),
                    ),
                    30.height,
                  ],
                ),
              );
            },
          ),
        ),
        if (Preference.isVip == false)
          GetBuilder<RefillController>(
            id: 'vipPlan',
            builder: (refillController) {
              return refillController.isLoadingVipPlan
                  ? const VipPlanShimmer()
                  : SizedBox(
                      height: 90,
                      child: ListView.builder(
                        itemCount: refillController.vipPlan.length,
                        physics: const AlwaysScrollableScrollPhysics(),
                        scrollDirection: Axis.horizontal,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: VipPlanCard(
                              vipPlan: refillController.vipPlan[index],
                              index: index,
                            ),
                          );
                        },
                      ).paddingOnly(left: 16),
                    );
            },
          ),
      ],
    );
  }
}

class UnlockNowBottomSheet extends StatelessWidget {
  UnlockNowBottomSheet({super.key, required this.coin});

  final int coin;
  final profileController = Get.find<ProfileController>();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          margin: const EdgeInsets.only(top: 95),
          width: Get.width,
          decoration: const BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: SizedBox(
            height: Get.height * 0.5, // Adjust height
            child: GetBuilder<RefillController>(
              id: 'updateCoin',
              builder: (context) {
                return Padding(
                  padding: const EdgeInsets.all(16),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        12.height,
                        Row(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text("${EnumLocal.price.name.tr} :", style: AppFontStyle.styleW400(AppColor.grey, 16)),
                                    7.width,
                                    Row(
                                      children: [
                                        Image.asset(
                                          AppAsset.starCoin,
                                          height: 12,
                                        ).paddingOnly(right: 3),
                                        Text("$coin", style: AppFontStyle.styleW800(AppColor.colorWhite, 16)),
                                      ],
                                    ),
                                    7.width,
                                    Text(EnumLocal.coins.name.tr, style: AppFontStyle.styleW400(AppColor.grey, 16)),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Text("${EnumLocal.balance.name.tr} :", style: AppFontStyle.styleW400(AppColor.grey, 14)),
                                    7.width,
                                    Obx(() => Row(
                                          children: [
                                            Image.asset(
                                              AppAsset.starCoin,
                                              height: 12,
                                            ).paddingOnly(right: 3),
                                            Text("${Preference.userCoin}", style: AppFontStyle.styleW800(AppColor.colorWhite, 14)),
                                          ],
                                        )),
                                    7.width,
                                    Text(EnumLocal.coins.name.tr, style: AppFontStyle.styleW400(AppColor.grey, 14)),
                                  ],
                                ),
                              ],
                            ),
                            const Spacer(),
                            GestureDetector(
                              onTap: () {
                                Get.toNamed(AppRoutes.wallet);
                              },
                              child: Row(
                                children: [
                                  Text(EnumLocal.viewAll.name.tr, style: AppFontStyle.styleW400(AppColor.grey, 16)),
                                  const Icon(
                                    Icons.navigate_next,
                                    color: AppColor.grey,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        25.height,
                        GetBuilder<RefillController>(
                          builder: (controller) {
                            return GridView.builder(
                              padding: EdgeInsets.zero,
                              physics: const NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                mainAxisSpacing: 12,
                                crossAxisSpacing: 12,
                                childAspectRatio: 1.6,
                              ),
                              itemCount: controller.coinPlan.length,
                              itemBuilder: (context, index) {
                                final coinPlan = controller.coinPlan[index];
                                return RefillCard(
                                  coinPlan: coinPlan,
                                  isSelected: controller.selectedCoinPlan == coinPlan,
                                  onTap: () {
                                    controller.selectCoinPlan(index);
                                    controller.update();
                                    showModalBottomSheet(
                                      context: context,
                                      backgroundColor: AppColor.bgGreyColor,
                                      builder: (context) {
                                        return PaymentGatewayListPage();
                                      },
                                    );
                                  },
                                );
                              },
                            ).paddingOnly(right: 16);
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        if (Preference.isVip == false)
          GetBuilder<RefillController>(
            id: 'coinPlan',
            builder: (controller) {
              return SizedBox(
                height: 90,
                child: ListView.builder(
                  itemCount: controller.vipPlan.length,
                  physics: const AlwaysScrollableScrollPhysics(),
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: VipPlanCard(
                        vipPlan: controller.vipPlan[index],
                        index: index,
                      ),
                    );
                  },
                ).paddingOnly(left: 16),
              );
            },
          ),
      ],
    );
  }
}
