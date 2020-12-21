import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';

import '../utils/date_ext.dart';

class VideoPreviewer extends StatefulWidget {
  final String dataSrc; //资源路径
  final String title;

  VideoPreviewer(
    this.dataSrc, {
    Key key,
    this.title,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => VideoPreviewerState();
}

class VideoPreviewerState extends State<VideoPreviewer> {
  VideoPlayerController _controller;
  Future<void> _futureTask;
  bool isLandscape = false;
  bool showProgress = false;

  @override
  void initState() {
    //全屏
    SystemChrome.setEnabledSystemUIOverlays([]);
    _controller = _createController();
    _controller.addListener(() {
      final progress = _controller.value.position;
      final total = _controller.value.duration;
      if (progress == total) {
        _controller.pause();
        _controller.seekTo(Duration(milliseconds: 0));
      }
    });
    _futureTask = _controller.initialize();
    super.initState();
  }

  VideoPlayerController _createController() {
    if (widget.dataSrc.startsWith('http')) {
      return VideoPlayerController.network(widget.dataSrc);
    } else {
      return VideoPlayerController.file(File(widget.dataSrc));
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _futureTask,
      builder: (_, snapshot) => snapshot.connectionState != ConnectionState.done
          ? Center(child: CupertinoActivityIndicator())
          : GestureDetector(
              onTap: _showProgressBar,
              child: Container(
                color: CupertinoColors.black,
                child: ValueListenableBuilder(
                  valueListenable: _controller,
                  builder: (_, value, __) => isLandscape
                      ? _buildHorizontal(value)
                      : _buildVertical(value),
                ),
              ),
            ),
    );
  }

  ///
  ///竖屏播放
  ///
  Widget _buildVertical(VideoPlayerValue value) {
    return Stack(
      children: [
        Center(
          child: GestureDetector(
            onTap: _showProgressBar,
            child: AspectRatio(
              aspectRatio: value.aspectRatio,
              child: VideoPlayer(_controller),
            ),
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Offstage(
            offstage: !showProgress,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                VideoProgressIndicator(
                  _controller,
                  allowScrubbing: true,
                  padding: EdgeInsets.zero,
                ),
                Row(
                  children: [
                    CupertinoButton(
                      onPressed: _onTouch,
                      child: Icon(
                        value.isPlaying
                            ? CupertinoIcons.pause_fill
                            : CupertinoIcons.play_fill,
                        color: CupertinoColors.white,
                      ),
                    ),
                    Text(
                      '${value.position.format()} / ${value.duration.format()}',
                      style:
                          TextStyle(fontSize: 12, color: CupertinoColors.white),
                    ),
                    Expanded(child: Container()),
                    CupertinoButton(
                      onPressed: _changeScreen,
                      child: Icon(
                        CupertinoIcons.rotate_right_fill,
                        color: CupertinoColors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        Align(
          alignment: Alignment.topRight,
          child: CupertinoButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Icon(
              CupertinoIcons.multiply,
              color: CupertinoColors.white,
            ),
          ),
        ),
        if (!value.isPlaying) _buildPalyButton(),
      ],
    );
  }

  ///
  ///横屏播放
  ///
  Widget _buildHorizontal(VideoPlayerValue value) {
    return RotatedBox(
      quarterTurns: 1,
      child: Stack(
        children: [
          Center(
            child: GestureDetector(
              onTap: _showProgressBar,
              child: VideoPlayer(_controller),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Offstage(
              offstage: !showProgress,
              child: Row(
                children: [
                  CupertinoButton(
                    onPressed: _onTouch,
                    child: Icon(
                      value.isPlaying
                          ? CupertinoIcons.pause_fill
                          : CupertinoIcons.play_fill,
                      color: CupertinoColors.white,
                    ),
                  ),
                  Text(
                    '${value.position.format()} / ${value.duration.format()}',
                    style:
                        TextStyle(fontSize: 12, color: CupertinoColors.white),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: VideoProgressIndicator(
                      _controller,
                      allowScrubbing: true,
                      padding: EdgeInsets.zero,
                    ),
                  ),
                  CupertinoButton(
                    onPressed: _changeScreen,
                    child: Icon(
                      CupertinoIcons.rotate_right_fill,
                      color: CupertinoColors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.topRight,
            child: Row(
              children: [
                CupertinoButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Icon(
                    CupertinoIcons.multiply,
                    color: CupertinoColors.white,
                  ),
                ),
                if (widget.title != null)
                  Text(
                    widget.title,
                    style: TextStyle(
                      color: CupertinoColors.white,
                      fontSize: 14,
                    ),
                  ),
              ],
            ),
          ),
          if (!value.isPlaying) _buildPalyButton(),
        ],
      ),
    );
  }

  Widget _buildPalyButton() {
    return Center(
      child: GestureDetector(
        onTap: _controller.play,
        behavior: HitTestBehavior.opaque,
        child: Container(
          height: 50,
          width: 50,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25),
            color: CupertinoColors.black.withOpacity(0.5),
          ),
          child: Icon(
            CupertinoIcons.play_fill,
            color: CupertinoColors.white,
          ),
        ),
      ),
    );
  }

  void _showProgressBar() {
    setState(() {
      showProgress = !showProgress;
    });
  }

  void _onTouch() {
    if (!_controller.value.isPlaying) {
      _controller.play();
    } else {
      _controller.pause();
    }
  }

  void _changeScreen() {
    setState(() {
      isLandscape = !isLandscape;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    SystemChrome.setEnabledSystemUIOverlays([
      SystemUiOverlay.top,
      SystemUiOverlay.bottom,
    ]);
    super.dispose();
  }
}
