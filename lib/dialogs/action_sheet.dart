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

class ActionSheetUpdater {
  late List<ActionSheetItem> _actions;
  late Function(List<ActionSheetItem>) _updateCallback;

  set updateCallback(Function(List<ActionSheetItem>) callback) {
    _updateCallback = callback;
  }

  set actions(newActions) {
    _actions = newActions;
  }

  List<ActionSheetItem> get actions => _actions;

  //更新使用
  void update(List<ActionSheetItem>? newActions) {
    _actions = newActions ?? _actions;
    _updateCallback(_actions);
  }

  ActionSheetUpdater();
}

Future<int> showCupertinoActionSheet({
  BuildContext? context, //如果没设置全局，需要传递自己的context
  String? title,
  String? message,
  ActionSheetUpdater? updater, //外部声明该变量用于更新 ActionSheetUpdater updater = ActionSheetUpdater();
  List<ActionSheetItem>? actions,
  isShowCancel = true,
  cancelText = '取消',
  isDefaultActionCancel = false, //粗体
  isDestructiveCancel = false, //红色
}) {
  assert(actions != null || updater?.actions != null, '请在action或updater中传递参数');
  final completer = Completer<int>();
  context = context ?? DialogConfig.context;
  showCupertinoModalPopup<void>(
    context: context,
    builder: (BuildContext context) {
      final cancelButton = isShowCancel
          ? CupertinoActionSheetAction(
              isDefaultAction: isDefaultActionCancel,
              isDestructiveAction: isDestructiveCancel,
              onPressed: () => Navigator.pop(context),
              child: Text(cancelText),
            )
          : null;
      actions = actions ?? updater!.actions;
      return ActionSheetWidget(
        title: title != null ? Text(title) : null,
        message: message != null ? Text(message) : null,
        cancelButton: cancelButton,
        updater: updater,
        actions: actions!,
      );
    },
  );
  return completer.future;
}

class ActionSheetWidget extends StatefulWidget {
  final Widget? title;
  final Widget? message;
  final Widget? cancelButton;
  final ActionSheetUpdater? updater;
  final List<ActionSheetItem> actions;

  const ActionSheetWidget({
    Key? key,
    this.title,
    this.message,
    this.cancelButton,
    this.updater,
    required this.actions,
  }) : super(key: key);

  @override
  State<ActionSheetWidget> createState() => _ActionSheetWidgetState();
}

class _ActionSheetWidgetState extends State<ActionSheetWidget> {
  late List<Widget> _actionWidgets;

  @override
  void initState() {
    super.initState();
    final updater = widget.updater;
    if (updater != null) {
      updater.actions = widget.actions;
      updater.updateCallback = (actions) {
        print(actions);
        generateActionWidgets(actions);
      };
    }
    generateActionWidgets(widget.actions);
  }

  void generateActionWidgets(List<ActionSheetItem> actions) {
    _actionWidgets = List<CupertinoActionSheetAction>.generate(
      actions.length,
      (index) {
        final item = actions[index];
        return CupertinoActionSheetAction(
          isDestructiveAction: item.isDestructive,
          isDefaultAction: item.isDefault,
          onPressed: () {
            Navigator.pop(context);
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
              item.titleWidget != null
                  ? item.titleWidget!
                  : Text(
                      item.text!,
                      style: TextStyle(color: item.isLoading == true ? Colors.grey[500] : null),
                    ),
            ],
          ),
        );
      },
    );
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoActionSheet(
      title: widget.title,
      message: widget.message,
      cancelButton: widget.cancelButton,
      actions: _actionWidgets,
    );
    ;
  }
}
