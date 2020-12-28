import 'package:flutter/cupertino.dart';
import 'package:media_previewer/utils/Icons.dart';

import 'media_widget.dart';

class ImagePreviewer extends StatefulWidget {
  final List<String> data; //图片数据(url & local path)
  final int initialPage; //初始页码
  final ValueChanged<String> onDownload;

  ImagePreviewer({
    Key key,
    this.data,
    this.initialPage,
    this.onDownload,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => ImageState();
}

class ImageState extends State<ImagePreviewer> {
  PageController controller;
  int index;
  List<String> data;
  List<MediaWidget> views;

  @override
  void initState() {
    super.initState();
    data = widget.data;
    views = data.map((e) => MediaWidget(e)).toList();
    index = widget.initialPage;
    controller = PageController(initialPage: index);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _onPop(context);
        return false;
      },
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => _onPop(context),
        child: Stack(
          children: [
            PageView.builder(
              itemCount: data.length,
              itemBuilder: (_, index) => Container(
                color: CupertinoColors.black,
                child: views[index],
              ),
              controller: controller,
              onPageChanged: onPageChanged,
            ),
            Positioned(
              bottom: 84,
              left: 0,
              right: 0,
              child: Text(
                '${index + 1}/${data.length}',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: CupertinoColors.white,
                  fontSize: 16,
                  inherit: false,
                ),
              ),
            ),
            Positioned(
              bottom: 16,
              left: 0,
              right: 0,
              child: SafeArea(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (isImage) _buildButton(Icons.rotate, _onRotateImage),
                    if (isImage) SizedBox(width: 40),
                    _buildButton(
                      Icons.download,
                      () => widget.onDownload?.call(data[index]),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void onPageChanged(int index) {
    setState(() {
      this.index = index;
    });
  }

  bool get isImage => data[index].mediaType() == MediaType.image;

  ///
  ///按钮
  ///
  Widget _buildButton(IconData icon, VoidCallback onPress) {
    return GestureDetector(
      onTap: onPress,
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: CupertinoColors.black,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(width: 2, color: Color(0xFF535353)),
        ),
        child: Icon(icon, color: CupertinoColors.white),
      ),
    );
  }

  ///
  ///图片旋转
  ///
  void _onRotateImage() async {
    views[index].controller.rotateImage();
  }

  ///
  ///退出预览时，更新图片路径
  ///
  void _onPop(BuildContext context) async {
    for (var i = 0; i < views.length; i++) {
      data[i] = await views[i].controller.saveTemp();
    }
    Navigator.of(context).pop(data);
  }

  @override
  void dispose() {
    super.dispose();
  }
}
