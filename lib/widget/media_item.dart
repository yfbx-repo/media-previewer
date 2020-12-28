import 'package:flutter/cupertino.dart';
import 'package:media_previewer/media_previewer.dart';
import 'package:media_previewer/utils/Icons.dart';

class MediaItem extends StatelessWidget {
  final double size;
  final Color background;
  final String dataSrc;
  final VoidCallback onRemove;
  final VoidCallback onTap;

  MediaItem({
    Key key,
    this.size,
    this.background,
    this.dataSrc,
    this.onRemove,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(4.0),
      ),
      child: Stack(
        children: <Widget>[
          Center(
            child: GestureDetector(
              onTap: onTap,
              behavior: HitTestBehavior.opaque,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4.0),
                child: MediaWidget(
                  dataSrc,
                  fit: BoxFit.cover,
                  isThumb: true,
                ),
              ),
            ),
          ),
          Positioned(
            right: 2,
            top: 2,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onRemove,
              child: Container(
                width: 20,
                height: 20,
                padding: EdgeInsets.all(4.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: CupertinoColors.black.withOpacity(0.5),
                ),
                child: Icon(
                  Icons.close,
                  size: 10,
                  color: CupertinoColors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
