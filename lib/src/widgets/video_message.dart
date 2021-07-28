import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_ui/src/conditional/conditional.dart';
import 'package:intl/intl.dart';

/// A class that represents video message widget
class VideoMessage extends StatefulWidget {
  /// Creates an video message widget based on a [types.VideoMessage]
  const VideoMessage({
    Key? key,
    required this.message,
    required this.messageWidth,
    this.onVideoTap,
  }) : super(key: key);

  static final durationFormat = DateFormat('m:ss', 'en_US');

  /// [types.VideoMessage]
  final types.VideoMessage message;

  final Function(types.VideoMessage)? onVideoTap;

  /// Maximum message width
  final int messageWidth;

  @override
  _VideoMessageState createState() => _VideoMessageState();
}

class _VideoMessageState extends State<VideoMessage> {
  //late VideoPlayerController _controller;
  ImageProvider? _imageProvider;
  ImageStream? _imageStream;
  Size _size = const Size(0, 0);

  //bool _videoPlayerReady = false;

  @override
  void initState() {
    super.initState();
    //_initVideoPlayer();
    _imageProvider = Conditional().getProvider(widget.message.thumbUri);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_size.isEmpty) {
      _getImage();
    }
  }

  @override
  void didUpdateWidget(covariant VideoMessage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.message.thumbUri != widget.message.thumbUri) {
      setState(() {
        _imageProvider = Conditional().getProvider(widget.message.thumbUri);
      });
      _getImage();
    }
  }

  void _getImage() {
    final oldImageStream = _imageStream;
    _imageStream =
        _imageProvider?.resolve(createLocalImageConfiguration(context));
    if (_imageStream?.key != oldImageStream?.key) {
      final listener = ImageStreamListener(_updateImage);
      oldImageStream?.removeListener(listener);
      _imageStream?.addListener(listener);
    }
  }

  void _updateImage(ImageInfo info, bool _) {
    setState(() {
      _size = Size(
        info.image.width.toDouble(),
        info.image.height.toDouble(),
      );
    });
  }

  @override
  Future<void> dispose() async {
    super.dispose();
    _imageStream?.removeListener(ImageStreamListener(_updateImage));
    //await _controller.dispose();
  }

  /*Future<void> _initVideoPlayer() async {
    _controller = VideoPlayerController.network(widget.message.uri);
    _controller.addListener(() async {
      setState(() {});
    });
    await _controller.initialize();
    setState(() {
      _videoPlayerReady = true;
    });
  }

  Future<void> _togglePlaying() async {
    if (!_videoPlayerReady) return;
    if (_controller.value.isPlaying) {
      await _controller.pause();
      setState(() {});
    } else {
      if (_controller.value.position >= _controller.value.duration) {
        await _controller.seekTo(const Duration());
      }
      await _controller.play();
      setState(() {});
    }
  }*/

  @override
  Widget build(BuildContext context) {
    if (widget.message.uri != '') {
      //il video è sul firestore
      return GestureDetector(
        child: Stack(alignment: AlignmentDirectional.center, children: [
          Container(
            constraints: BoxConstraints(
              maxHeight: widget.messageWidth.toDouble(),
              minWidth: 170,
            ),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 1, sigmaY: 1),
              child: AspectRatio(
                aspectRatio: 9 / 16,
                child: Image(
                  fit: BoxFit.contain,
                  image: _imageProvider!,
                ),
              ),
            ),
          ),
          const Icon(
            Icons.play_circle,
            color: Colors.white,
            size: 60,
          )
        ]),
        onTap: () => widget.onVideoTap?.call(widget.message),
      );
    } else {
      return Container(
        constraints: BoxConstraints(
          maxHeight: widget.messageWidth.toDouble(),
          minWidth: 170,
        ),
        color: Colors.white,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 1, sigmaY: 1),
          child: AspectRatio(
            aspectRatio: 9 / 16,
            child: Image(
              fit: BoxFit.contain,
              image: _imageProvider!,
            ),
          ),
        ),
      );
    }
  }
}

/*if (_controller.value.isInitialized) {
      return Container(
          constraints: BoxConstraints(
            maxHeight: widget.messageWidth.toDouble(),
            minWidth: 170,
          ),
          child: Tooltip(
            message:
                InheritedL10n.of(context).l10n.videoPlayerAccessibilityLabel,
            child: AspectRatio(
              aspectRatio: _controller.value.aspectRatio,
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  VideoPlayer(_controller),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 50),
                    reverseDuration: const Duration(milliseconds: 200),
                    child: _controller.value.isPlaying
                        ? const SizedBox.shrink()
                        : Container(
                            color: Colors.black26,
                            child: Center(
                              child: InheritedChatTheme.of(context)
                                          .theme
                                          .playButtonIcon !=
                                      null
                                  ? Image.asset(
                                      InheritedChatTheme.of(context)
                                          .theme
                                          .playButtonIcon!,
                                      color: _background,
                                    )
                                  : Icon(
                                      Icons.play_circle_fill,
                                      color: _background,
                                      size: 44,
                                    ),
                            ),
                          ),
                  ),
                  VideoProgressIndicator(
                    _controller,
                    allowScrubbing: true,
                    colors: VideoProgressColors(
                      playedColor: InheritedChatTheme.of(context)
                          .theme
                          .videoTrackPlayedColor,
                      bufferedColor: InheritedChatTheme.of(context)
                          .theme
                          .videoTrackBufferedColor,
                      backgroundColor: InheritedChatTheme.of(context)
                          .theme
                          .videoTrackBackgroundColor,
                    ),
                  ),
                  Align(
                    alignment: Alignment.topRight,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 10.0, top: 10.0),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius:
                              const BorderRadius.all(Radius.circular(10.0)),
                          color: _background.withOpacity(0.5),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6.0, vertical: 3.0),
                          child: Text(
                            VideoMessage.durationFormat.format(
                              DateTime.fromMillisecondsSinceEpoch(
                                _controller.value.isPlaying
                                    ? (_controller
                                            .value.duration.inMilliseconds -
                                        _controller
                                            .value.position.inMilliseconds)
                                    : _controller.value.duration.inMilliseconds,
                              ),
                            ),
                            style: InheritedChatTheme.of(context)
                                .theme
                                .caption
                                .copyWith(color: _foreground),
                          ),
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: _togglePlaying,
                  ),
                ],
              ),
            ),
          ));
    }*/
