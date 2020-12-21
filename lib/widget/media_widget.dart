import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:image_editor/image_editor.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../pages/video_previewer.dart';
import 'image_widget.dart';

class MediaWidget extends StatelessWidget {
  final String uri;
  final BoxFit fit;
  final MediaController controller;

  MediaWidget(
    this.uri, {
    this.fit,
  }) : this.controller = MediaController(uri);

  @override
  Widget build(BuildContext context) {
    final type = uri.mediaType();
    switch (type) {
      case MediaType.image:
        return _buildImage();
      case MediaType.video:
        return _buildVideo();
      case MediaType.pdf:
        return _buildPdf();
      default:
        return WebView(
          initialUrl: uri,
          javascriptMode: JavascriptMode.unrestricted,
        );
    }
  }

  Widget _buildImage() {
    return ValueListenableBuilder(
      valueListenable: controller,
      builder: (conetxt, value, child) => ImageWidget(
        key: controller.imageKey,
        fit: fit,
        imageProvider: value.startsWith('http')
            ? NetworkImage(value)
            : FileImage(File(value)),
      ),
    );
  }

  Widget _buildPdf() {
    final String pdfViewer = 'https://static.yuxiaor.com/web/viewer.html?file=';
    return WebView(
      initialUrl: pdfViewer + uri,
      javascriptMode: JavascriptMode.unrestricted,
    );
  }

  Widget _buildVideo() {
    return VideoPreviewer(uri);
  }
}

class MediaController extends ValueNotifier<String> {
  final imageKey = GlobalKey();

  MediaController(String value) : super(value);

  ///
  ///旋转图片
  ///
  Future<String> rotate() async {
    final state = imageKey.currentState as ImageWidgetState;
    final image = await state.getCachedImage();
    final option = ImageEditorOption();
    option.addOption(RotateOption(90));

    final rotatedImage = await ImageEditor.editImage(
      image: image.buffer.asUint8List(),
      imageEditorOption: option,
    );
    final name = '${DateTime.now().millisecond}.png';
    final path = '${Directory.systemTemp.path}/$name';
    final file = await File(path).writeAsBytes(rotatedImage);
    value = file.path;
    return value;
  }
}

///
/// MediaType
///
enum MediaType {
  unknown,
  image,
  video,
  pdf,
}

class MediaTypeArray {
  static final pdfType = [
    'pdf',
  ];

  static final imageType = [
    'png',
    'jpg',
    'jpeg',
    'bmp',
    'webp',
    'gif',
  ];

  static final videoType = [
    'mp4',
    'mpg',
    'mpeg',
    'mov',
    '3gp',
    '3gpp',
    '3gp2',
    '3gpp2',
    'mkv',
    'ts',
    'avi',
    'webm',
  ];
}

extension MediaTypeExt on String {
  MediaType mediaType() {
    final ext = this.substring(this.lastIndexOf('.') + 1).toLowerCase();
    if (MediaTypeArray.imageType.contains(ext)) return MediaType.image;
    if (MediaTypeArray.videoType.contains(ext)) return MediaType.video;
    if (MediaTypeArray.pdfType.contains(ext)) return MediaType.pdf;
    return MediaType.unknown;
  }
}
