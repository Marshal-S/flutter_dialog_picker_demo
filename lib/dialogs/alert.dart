import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter_dialog_picker_demo/dialogs/dialog_config.dart';

//封装一个适合我们项目的，结果返回一个 future
//颜色等受系统默认的值影响，这里面就不填写属性了，primaryColor 更新会影响到所有的默认效果
Future<bool> showCupertinoAlert({
  BuildContext? context, //如果没设置全局，需要传递自己的context
  String title = '',
  String message = '',
  confirmText = '确定',
  cancelText = '取消',
  isShowCancel = true,
  isDestructiveConfirm = false,
  isDestructiveCancel = false,
}) {
  context = context ?? DialogConfig.context;
  final completer = Completer<bool>();
  final actions = <CupertinoDialogAction>[
    CupertinoDialogAction(
      isDestructiveAction: isDestructiveConfirm,
      onPressed: () {
        completer.complete(true);
        Navigator.of(context!).pop();
      },
      child: Text(confirmText),
    ),
  ];
  if (isShowCancel) {
    actions.insert(
      0,
      CupertinoDialogAction(
        isDestructiveAction: isDestructiveCancel,
        onPressed: () {
          completer.complete(false);
          Navigator.of(context!).pop();
        },
        child: Text(
          cancelText,
        ),
      ),
    );
  }
  showCupertinoModalPopup<void>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) => CupertinoAlertDialog(
      title: Text(title),
      content: Padding(
        padding: const EdgeInsets.only(top: 10),
        child: Text(message),
      ),
      actions: actions,
    ),
  );
  return completer.future;
}
