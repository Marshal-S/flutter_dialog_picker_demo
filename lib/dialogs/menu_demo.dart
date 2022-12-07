import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

//这里仅仅是一个menu案例，实际可以使用到自己客户端，本身就比较简洁，可以自己参考封装成一个固定的小组件
class CupertinoActionsMenu extends StatelessWidget {
  const CupertinoActionsMenu({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CupertinoContextMenu(
      actions: <Widget>[
        CupertinoContextMenuAction(
          onPressed: () {
            Navigator.pop(context);
          },
          isDefaultAction: true,
          trailingIcon: CupertinoIcons.doc_on_clipboard_fill,
          child: const Text('Copy'),
        ),
        CupertinoContextMenuAction(
          onPressed: () {
            Navigator.pop(context);
          },
          trailingIcon: CupertinoIcons.share,
          child: const Text('Share'),
        ),
        CupertinoContextMenuAction(
          onPressed: () {
            Navigator.pop(context);
          },
          trailingIcon: CupertinoIcons.heart,
          child: const Text('Favorite'),
        ),
        CupertinoContextMenuAction(
          onPressed: () {
            Navigator.pop(context);
          },
          isDestructiveAction: true,
          trailingIcon: CupertinoIcons.delete,
          child: const Text('Delete'),
        ),
      ],
      child: Container(
        decoration: BoxDecoration(
          color: CupertinoColors.systemYellow,
          borderRadius: BorderRadius.circular(20.0),
        ),
        child: const FlutterLogo(size: 500.0),
      ),
    );
  }
}
