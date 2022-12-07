import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dialog_config.dart';

//封装一个适合我们项目的，结果返回一个 future，单选
//颜色等受系统默认的值影响，这里面就不填写属性了，primaryColor 更新会影响到所有的默认效果

class ActionSheetItem {
  String? text;
  Widget? titleWidget; //widget优先
  bool? isLoading = false; //isLoading为true
  bool isDestructive; //红色的
  bool isDefault; //是否默认加粗

  ActionSheetItem({
    this.text,
    this.titleWidget, //widget优先
    this.isLoading, //isLoading为true
    this.isDestructive = false, //红色的
    this.isDefault = false, //是否默认加粗
  }) : assert(text != null || titleWidget != null, 'text和widget必须传一个,widget优先');
}

Future<int> showCupertinoActionSheet({
  BuildContext? context, //如果没设置全局，需要传递自己的context
  String? title,
  String? message,
  List<ActionSheetItem> actions = const <ActionSheetItem>[],
  isShowCancel = true,
  cancelText = '取消',
  isDefaultActionCancel = false, //粗体
  isDestructiveCancel = false, //红色
}) {
  context = context ?? DialogConfig.context;
  final completer = Completer<int>();
  final cancelButton = isShowCancel
      ? CupertinoActionSheetAction(
          isDefaultAction: isDefaultActionCancel,
          isDestructiveAction: isDestructiveCancel,
          onPressed: () => Navigator.pop(context!),
          child: Text(cancelText),
        )
      : null;

  final actionWidgets = List<CupertinoActionSheetAction>.generate(actions.length, (index) {
    final item = actions[index];
    return CupertinoActionSheetAction(
      isDestructiveAction: item.isDestructive,
      isDefaultAction: item.isDefault,
      onPressed: () {
        completer.complete(index);
        Navigator.pop(context!);
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          item.isLoading == true
              ? const Padding(
                  padding: EdgeInsets.only(right: 10),
                  child: CupertinoActivityIndicator(
                    radius: 14,
                  ),
                )
              : Container(),
          item.titleWidget != null ? item.titleWidget! : Text(item.text!, style: TextStyle(color: item.isLoading == true ? Colors.grey[500] : null),),
        ],
      ),
    );
  });

  showCupertinoModalPopup<void>(
    context: context,
    builder: (BuildContext context) => CupertinoActionSheet(
      title: title != null ? Text(title) : null,
      message: message != null ? Text(message) : null,
      cancelButton: cancelButton,
      actions: actionWidgets,
    ),
  );
  return completer.future;
}
