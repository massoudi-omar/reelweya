// import 'dart:convert';

// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:http/http.dart' as http;
// import 'package:video_player/video_player.dart';

// import 'api.dart';

// class CustomRewardAd {
//   static String get adsApi =>
//       '${ApiConstant.getBaseURL()}${ApiConstant.ads}';

//   static Future<void> showAd({
//     required Future<void> Function() fun,
//   }) async {
//     try {
//       debugPrint('Custom Reward Ad: Loading ads...');
//       debugPrint('Custom Reward Ad API => $adsApi');

//       final response = await http.get(
//         Uri.parse(adsApi),
//       );

//       debugPrint(
//         'Custom Reward Ad API status: ${response.statusCode}',
//       );

//       if (response.statusCode != 200) {
//         debugPrint('Custom Reward Ad: API failed');
//         return;
//       }

//       final json = jsonDecode(response.body);

//       if (json['status'] != true ||
//           json['data'] == null ||
//           json['data'] is! List ||
//           (json['data'] as List).isEmpty) {
//         debugPrint('Custom Reward Ad: No ads available');
//         return;
//       }

//       final ads = json['data'] as List;

//       Map<String, dynamic>? ad;

//       for (final item in ads) {
//         if (item is Map<String, dynamic> &&
//             item['mediaType'] == 'video' &&
//             item['status'] == 'active' &&
//             item['mediaUrl'] != null &&
//             item['mediaUrl'].toString().isNotEmpty) {
//           ad = item;
//           break;
//         }
//       }

//       if (ad == null) {
//         debugPrint(
//           'Custom Reward Ad: No active video ad found',
//         );
//         return;
//       }

//       String videoUrl = ad['mediaUrl'].toString();

//       debugPrint(
//         'Custom Reward Ad: Original Video URL => $videoUrl',
//       );

//       if (videoUrl.startsWith('http://')) {
//         videoUrl = videoUrl.replaceFirst(
//           'http://',
//           'https://',
//         );
//       }

//       debugPrint(
//         'Custom Reward Ad: Video URL => $videoUrl',
//       );

//       final completed = await GetAdVideo.show(
//         videoUrl: videoUrl,
//         link: ad['link']?.toString(),
//       );

//       if (completed) {
//         debugPrint(
//           'Custom Reward Ad: Video completed, giving reward',
//         );

//         await fun();
//       } else {
//         debugPrint(
//           'Custom Reward Ad: Video was not completed',
//         );
//       }
//     } catch (e) {
//       debugPrint(
//         'Custom Reward Ad error: $e',
//       );
//     }
//   }
// }

// class GetAdVideo {
//   static Future<bool> show({
//     required String videoUrl,
//     String? link,
//   }) async {
//     final result = await Get.to<bool>(
//       () => CustomAdVideoPage(
//         videoUrl: videoUrl,
//         link: link,
//       ),
//     );

//     return result == true;
//   }
// }

// class CustomAdVideoPage extends StatefulWidget {
//   final String videoUrl;
//   final String? link;

//   const CustomAdVideoPage({
//     super.key,
//     required this.videoUrl,
//     this.link,
//   });

//   @override
//   State<CustomAdVideoPage> createState() =>
//       _CustomAdVideoPageState();
// }

// class _CustomAdVideoPageState
//     extends State<CustomAdVideoPage> {
//   VideoPlayerController? controller;

//   bool loading = true;
//   bool completed = false;
//   bool hasError = false;

//   @override
//   void initState() {
//     super.initState();

//     _initializeVideo();
//   }

//   Future<void> _initializeVideo() async {
//     try {
//       debugPrint(
//         'Custom Ad Video: Initializing...',
//       );

//       final videoController =
//           VideoPlayerController.networkUrl(
//         Uri.parse(widget.videoUrl),
//       );

//       controller = videoController;

//       await videoController.initialize();

//       if (!mounted) return;

//       setState(() {
//         loading = false;
//       });

//       videoController.addListener(
//         _videoListener,
//       );

//       await videoController.play();

//       debugPrint(
//         'Custom Ad Video: Playing',
//       );
//     } catch (e) {
//       debugPrint(
//         'Custom Ad Video error: $e',
//       );

//       if (!mounted) return;

//       setState(() {
//         loading = false;
//         hasError = true;
//       });
//     }
//   }

//   void _videoListener() {
//     final video = controller;

//     if (video == null) return;

//     if (!video.value.isInitialized) {
//       return;
//     }

//     final position = video.value.position;
//     final duration = video.value.duration;

//     if (duration.inMilliseconds > 0 &&
//         position >= duration &&
//         !completed) {
//       completed = true;

//       debugPrint(
//         'Custom Ad Video: Completed',
//       );

//       if (mounted) {
//         Get.back(result: true);
//       }

//       return;
//     }

//     if (mounted) {
//       setState(() {});
//     }
//   }

//   Future<void> _openLink() async {
//     debugPrint(
//       'Advertiser link: ${widget.link}',
//     );

//     // Add url_launcher here later if you want
//     // the "Visit advertiser" button to actually
//     // open the advertiser website.
//   }

//   @override
//   void dispose() {
//     controller?.removeListener(
//       _videoListener,
//     );

//     controller?.dispose();

//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return PopScope(
//       canPop: completed,
//       child: Scaffold(
//         backgroundColor: Colors.black,
//         body: SafeArea(
//           child: Stack(
//             children: [
//               Center(
//                 child: _buildVideo(),
//               ),

//               Positioned(
//                 top: 15,
//                 right: 15,
//                 child: _buildTimer(),
//               ),

//               if (!loading &&
//                   !hasError &&
//                   widget.link != null &&
//                   widget.link!.isNotEmpty)
//                 Positioned(
//                   bottom: 25,
//                   left: 20,
//                   right: 20,
//                   child: _buildVisitButton(),
//                 ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildVideo() {
//     if (loading) {
//       return const CircularProgressIndicator(
//         color: Colors.white,
//       );
//     }

//     if (hasError || controller == null) {
//       return const Text(
//         'Unable to load advertisement',
//         style: TextStyle(
//           color: Colors.white,
//           fontSize: 16,
//         ),
//       );
//     }

//     if (!controller!.value.isInitialized) {
//       return const CircularProgressIndicator(
//         color: Colors.white,
//       );
//     }

//     return AspectRatio(
//       aspectRatio: controller!.value.aspectRatio,
//       child: VideoPlayer(
//         controller!,
//       ),
//     );
//   }

//   Widget _buildTimer() {
//     if (controller == null ||
//         !controller!.value.isInitialized) {
//       return const SizedBox();
//     }

//     final duration = controller!.value.duration;
//     final position = controller!.value.position;

//     int remaining =
//         duration.inSeconds - position.inSeconds;

//     if (remaining < 0) {
//       remaining = 0;
//     }

//     return Container(
//       padding: const EdgeInsets.symmetric(
//         horizontal: 12,
//         vertical: 7,
//       ),
//       decoration: BoxDecoration(
//         color: Colors.black.withOpacity(0.65),
//         borderRadius: BorderRadius.circular(20),
//       ),
//       child: Text(
//         '${remaining}s',
//         style: const TextStyle(
//           color: Colors.white,
//           fontWeight: FontWeight.bold,
//         ),
//       ),
//     );
//   }

//   Widget _buildVisitButton() {
//     return ElevatedButton(
//       onPressed: _openLink,
//       child: const Text(
//         'Visit advertiser',
//       ),
//     );
//   }
// }



import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';

import 'api.dart';

class CustomRewardAd {
  static String get adsApi =>
      '${ApiConstant.getBaseURL()}${ApiConstant.ads}';

  static Future<void> showAd({
    required Future<void> Function() fun,
  }) async {
    try {
      debugPrint('Custom Reward Ad: Loading ads...');
      debugPrint('Custom Reward Ad API => $adsApi');

      final response = await http.get(Uri.parse(adsApi));

      debugPrint(
        'Custom Reward Ad API status: ${response.statusCode}',
      );

      if (response.statusCode != 200) {
        debugPrint('Custom Reward Ad: API failed');
        return;
      }

      final json = jsonDecode(response.body);

      if (json['status'] != true ||
          json['data'] == null ||
          json['data'] is! List ||
          (json['data'] as List).isEmpty) {
        debugPrint('Custom Reward Ad: No ads available');
        return;
      }

      final ads = json['data'] as List;

      Map<String, dynamic>? ad;

      for (final item in ads) {
        if (item is Map<String, dynamic> &&
            item['mediaType'] == 'video' &&
            item['status'] == 'active' &&
            item['mediaUrl'] != null &&
            item['mediaUrl'].toString().isNotEmpty) {
          ad = item;
          break;
        }
      }

      if (ad == null) {
        debugPrint(
          'Custom Reward Ad: No active video ad found',
        );
        return;
      }

      String videoUrl = ad['mediaUrl'].toString();

      if (videoUrl.startsWith('http://')) {
        videoUrl = videoUrl.replaceFirst(
          'http://',
          'https://',
        );
      }

      String? imageUrl = ad['imageUrl']?.toString();

      if (imageUrl != null &&
          imageUrl.startsWith('http://')) {
        imageUrl = imageUrl.replaceFirst(
          'http://',
          'https://',
        );
      }

      final completed = await GetAdVideo.show(
        videoUrl: videoUrl,
        link: ad['link']?.toString(),
        imageUrl: imageUrl,
        title: ad['title']?.toString(),
        description: ad['description']?.toString(),
      );

      if (completed) {
        debugPrint(
          'Custom Reward Ad: Video completed, giving reward',
        );

        await fun();
      }
    } catch (e) {
      debugPrint(
        'Custom Reward Ad error: $e',
      );
    }
  }
}

class GetAdVideo {
  static Future<bool> show({
    required String videoUrl,
    String? link,
    String? imageUrl,
    String? title,
    String? description,
  }) async {
    final result = await Get.to<bool>(
      () => CustomAdVideoPage(
        videoUrl: videoUrl,
        link: link,
        imageUrl: imageUrl,
        title: title,
        description: description,
      ),
    );

    return result == true;
  }
}

class CustomAdVideoPage extends StatefulWidget {
  final String videoUrl;
  final String? link;
  final String? imageUrl;
  final String? title;
  final String? description;

  const CustomAdVideoPage({
    super.key,
    required this.videoUrl,
    this.link,
    this.imageUrl,
    this.title,
    this.description,
  });

  @override
  State<CustomAdVideoPage> createState() =>
      _CustomAdVideoPageState();
}

class _CustomAdVideoPageState
    extends State<CustomAdVideoPage> {
  VideoPlayerController? controller;

  bool loading = true;
  bool hasError = false;
  bool completed = false;

  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    try {
      debugPrint(
        'Custom Ad Video: Initializing...',
      );

      final videoController =
          VideoPlayerController.networkUrl(
        Uri.parse(widget.videoUrl),
      );

      controller = videoController;

      await videoController.initialize();

      if (!mounted) return;

      setState(() {
        loading = false;
      });

      videoController.addListener(
        _videoListener,
      );

      await videoController.play();

      _timer = Timer.periodic(
        const Duration(milliseconds: 250),
        (_) {
          if (mounted) {
            setState(() {});
          }
        },
      );

      debugPrint(
        'Custom Ad Video: Playing',
      );
    } catch (e) {
      debugPrint(
        'Custom Ad Video error: $e',
      );

      if (!mounted) return;

      setState(() {
        loading = false;
        hasError = true;
      });
    }
  }

  void _videoListener() {
    final video = controller;

    if (video == null ||
        !video.value.isInitialized) {
      return;
    }

    final position = video.value.position;
    final duration = video.value.duration;

    if (duration.inMilliseconds > 0 &&
        position >= duration &&
        !completed) {
      completed = true;

      debugPrint(
        'Custom Ad Video: Completed',
      );

      if (mounted) {
        setState(() {});
      }
    }
  }

  bool get canSkip {
    final video = controller;

    if (video == null ||
        !video.value.isInitialized) {
      return false;
    }

    // Allow skip after 5 seconds.
    return video.value.position.inSeconds >= 5;
  }

  void _closeAd() {
    if (!completed) {
      debugPrint(
        'Custom Ad Video: Closed before completion',
      );

      Get.back(result: false);
      return;
    }

    Get.back(result: true);
  }

  Future<void> _openLink() async {
    if (widget.link == null ||
        widget.link!.trim().isEmpty) {
      return;
    }

    String url = widget.link!.trim();

    if (!url.startsWith('http://') &&
        !url.startsWith('https://')) {
      url = 'https://$url';
    }

    final uri = Uri.tryParse(url);

    if (uri == null) {
      return;
    }

    await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );
  }

  @override
  void dispose() {
    _timer?.cancel();

    controller?.removeListener(
      _videoListener,
    );

    controller?.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: completed,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && completed) {
          Get.back(result: true);
        }
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: Stack(
            children: [
              Positioned.fill(
                child: completed
                    ? _buildCompletedAd()
                    : _buildVideoAd(),
              ),

              // Top close button
              Positioned(
                top: 14,
                left: 14,
                child: _buildCloseButton(),
              ),

              // Top timer
              if (!completed)
                Positioned(
                  top: 14,
                  right: 14,
                  child: _buildTimer(),
                ),

              // Bottom progress bar
              if (!completed)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: _buildProgressBar(),
                ),

              // Skip button
              if (!completed)
                Positioned(
                  right: 16,
                  bottom: 25,
                  child: _buildSkipButton(),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVideoAd() {
    if (loading) {
      return const Center(
        child: CircularProgressIndicator(
          color: Colors.white,
        ),
      );
    }

    if (hasError || controller == null) {
      return const Center(
        child: Text(
          'Unable to load advertisement',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
          ),
        ),
      );
    }

    if (!controller!.value.isInitialized) {
      return const Center(
        child: CircularProgressIndicator(
          color: Colors.white,
        ),
      );
    }

    return Center(
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 50,
        ),
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
        ),
        child: AspectRatio(
          aspectRatio:
              controller!.value.aspectRatio,
          child: VideoPlayer(controller!),
        ),
      ),
    );
  }

  Widget _buildCompletedAd() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          28,
          70,
          28,
          40,
        ),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            // Ad image
            if (widget.imageUrl != null &&
                widget.imageUrl!.isNotEmpty)
              Container(
                width: 180,
                height: 180,
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  borderRadius:
                      BorderRadius.circular(20),
                ),
                child: Image.network(
                  widget.imageUrl!,
                  fit: BoxFit.cover,
                  errorBuilder:
                      (_, __, ___) {
                    return Container(
                      color: Colors.grey.shade900,
                      child: const Icon(
                        Icons.image_outlined,
                        color: Colors.white54,
                        size: 55,
                      ),
                    );
                  },
                ),
              ),

            const SizedBox(height: 25),

            // Title
            if (widget.title != null &&
                widget.title!.trim().isNotEmpty)
              Text(
                widget.title!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),

            const SizedBox(height: 12),

            // Description
            if (widget.description != null &&
                widget.description!
                    .trim()
                    .isNotEmpty)
              Text(
                widget.description!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withOpacity(
                    0.72,
                  ),
                  fontSize: 15,
                  height: 1.5,
                ),
              ),

            const SizedBox(height: 28),

            // CTA
            if (widget.link != null &&
                widget.link!.trim().isNotEmpty)
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _openLink,
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        Colors.white,
                    foregroundColor: Colors.black,
                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'Visit advertiser',
                    style: TextStyle(
                      fontWeight:
                          FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),

            const SizedBox(height: 14),

            TextButton(
              onPressed: _closeAd,
              child: const Text(
                'Close',
                style: TextStyle(
                  color: Colors.white70,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCloseButton() {
    return Material(
      color: Colors.black.withOpacity(0.55),
      shape: const CircleBorder(),
      child: InkWell(
        onTap: completed
            ? _closeAd
            : (canSkip ? _closeAd : null),
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 42,
          height: 42,
          child: Icon(
            Icons.close,
            color: completed || canSkip
                ? Colors.white
                : Colors.white38,
            size: 22,
          ),
        ),
      ),
    );
  }

  Widget _buildTimer() {
    if (controller == null ||
        !controller!.value.isInitialized) {
      return const SizedBox();
    }

    final duration =
        controller!.value.duration;

    final position =
        controller!.value.position;

    int remaining =
        duration.inSeconds -
        position.inSeconds;

    if (remaining < 0) {
      remaining = 0;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 13,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.65),
        borderRadius:
            BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.timer_outlined,
            color: Colors.white,
            size: 16,
          ),
          const SizedBox(width: 6),
          Text(
            '${remaining}s',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    if (controller == null ||
        !controller!.value.isInitialized) {
      return const SizedBox();
    }

    final duration =
        controller!.value.duration.inMilliseconds;

    final position =
        controller!.value.position.inMilliseconds;

    double progress = 0;

    if (duration > 0) {
      progress = position / duration;
    }

    progress = progress.clamp(0.0, 1.0);

    return LinearProgressIndicator(
      value: progress,
      minHeight: 4,
      backgroundColor:
          Colors.white.withOpacity(0.25),
      valueColor:
          const AlwaysStoppedAnimation<Color>(
        Colors.white,
      ),
    );
  }

  Widget _buildSkipButton() {
    final enabled = canSkip;

    return AnimatedOpacity(
      opacity: enabled ? 1 : 0.65,
      duration:
          const Duration(milliseconds: 200),
      child: Material(
        color: Colors.black.withOpacity(0.7),
        borderRadius:
            BorderRadius.circular(10),
        child: InkWell(
          onTap: enabled ? _closeAd : null,
          borderRadius:
              BorderRadius.circular(10),
          child: Padding(
            padding:
                const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 10,
            ),
            child: Text(
              enabled
                  ? 'Passer'
                  : 'Passer dans ${5 - (controller?.value.position.inSeconds ?? 0)}s',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}