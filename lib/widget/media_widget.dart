import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:image_editor/image_editor.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../pages/video_previewer.dart';

class MediaWidget extends StatelessWidget {
  final String uri;
  final BoxFit fit;
  final bool isThumb;
  final MediaController controller;

  MediaWidget(
    this.uri, {
    Key key,
    this.fit,
    this.isThumb = false,
  })  : controller = MediaController(uri),
        super(key: key);

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
      builder: (BuildContext context, value, Widget child) {
        if (value == null) return CupertinoActivityIndicator();
        return RawImage(
          fit: fit,
          image: value,
          scale: 1.0,
          width: value.width * 1.0,
          height: value.height * 1.0,
        );
      },
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
    return VideoPreviewer(
      uri,
      isThumb: isThumb,
    );
  }
}

class MediaController extends ValueNotifier<ui.Image> {
  final String uri;
  int angle = 0;
  MediaController(this.uri) : super(null) {
    _getImage();
  }

  void _getImage() {
    ImageProvider provider =
        uri.startsWith('http') ? NetworkImage(uri) : FileImage(File(uri));
    provider
        .resolve(ImageConfiguration.empty)
        .addListener(ImageStreamListener(_updateImage));
  }

  void _updateImage(ImageInfo imageInfo, bool synchronousCall) {
    value = imageInfo.image;
  }

  ///
  ///旋转图片
  ///TODO:不生效，待优化
  ///
  void rotate() async {
    if (value == null) return;
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    canvas.drawImage(value.clone(), Offset.zero, Paint());
    canvas.rotate(90);
    canvas.save();
    final picture =
        await recorder.endRecording().toImage(value.width, value.height);
    final byteData = await picture.toByteData(format: ui.ImageByteFormat.png);

    angle += 90;
    if (angle == 360) {
      angle = 0;
    }

    value = await decodeImageFromList(byteData.buffer.asUint8List());
  }

  ///
  ///旋转图片
  ///
  void rotateImage() async {
    if (value == null) return;
    final option = ImageEditorOption();
    option.addOption(RotateOption(90));
    option.outputFormat = OutputFormat.png();

    final imageByte = await value.toByteData(format: ui.ImageByteFormat.png);
    final rotatedImage = await ImageEditor.editImage(
      image: imageByte.buffer.asUint8List(),
      imageEditorOption: option,
    );

    angle += 90;
    if (angle == 360) {
      angle = 0;
    }

    value = await decodeImageFromList(rotatedImage);
  }

  ///
  ///保存旋转后的图片
  ///
  Future<String> saveTemp() async {
    //未旋转或旋转360度，直接返回原图路径
    if (angle == 0) return uri;

    final imageByte = await value.toByteData(format: ui.ImageByteFormat.png);
    final name = '${DateTime.now().millisecond}.png';
    final path = '${Directory.systemTemp.path}/$name';
    final file = await File(path).writeAsBytes(imageByte.buffer.asUint8List());
    return file.path;
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
