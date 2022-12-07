import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'dialog_config.dart';

//封装一个适合我们项目的，结果返回一个 future
//颜色等受系统默认的值影响，这里面就不填写属性了，primaryColor 更新会影响到所有的默认效果

Future<String?> showCupertinoInputAlert({
  BuildContext? context, //如果没设置全局，需要传递自己的context
  String title = '',
  String message = '',
  confirmText = '确定',
  cancelText = '取消',
  isShowCancel = true,
  isDestructiveConfirm = false,
  isDestructiveCancel = false,
  String? placeholder,
  String? defaultText,
  TextAlign? textAlign,
  OverlayVisibilityMode? clearButtonMode,
  TextInputType? keyboardType,
  String? Function(String value)? onChanged, //内容改变后的回调，可以通过返回值来校验text输入等操作
}) {
  context = context ?? DialogConfig.context;
  String? text;
  final completer = Completer<String?>();
  final actions = <CupertinoDialogAction>[
    CupertinoDialogAction(
      isDestructiveAction: isDestructiveConfirm,
      onPressed: () {
        completer.complete(text);
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
        onPressed: () => Navigator.of(context!).pop(),
        child: Text(
          cancelText,
        ),
      ),
    );
  }
  showCupertinoModalPopup<void>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) => InputAlertWidget(
      actions: actions,
      title: title,
      message: message,
      placeholder: placeholder,
      defaultText: defaultText,
      textAlign: textAlign,
      clearButtonMode: clearButtonMode,
      keyboardType: keyboardType,
      onChanged: onChanged,
      onSubmit: (value) {
        text = value;
        completer.complete(text);
        Navigator.of(context).pop();
      },
    ),
  );
  return completer.future;
}

class InputAlertWidget extends StatefulWidget {
  final List<CupertinoDialogAction> actions;
  final String title;
  final String message;
  final String? placeholder;
  final String? defaultText;
  final TextAlign? textAlign;
  final OverlayVisibilityMode? clearButtonMode;
  final TextInputType? keyboardType;

  final Function(String value)? onChanged;
  final Function(String value)? onSubmit;

  const InputAlertWidget({
    Key? key,
    required this.actions,
    required this.title,
    required this.message,
    this.placeholder,
    this.defaultText,
    this.textAlign,
    this.clearButtonMode,
    this.keyboardType,
    this.onChanged,
    this.onSubmit,
  }) : super(key: key);

  @override
  State<InputAlertWidget> createState() => _InputAlertWidgetState();
}

class _InputAlertWidgetState extends State<InputAlertWidget> {
  final TextEditingController _controller = TextEditingController();

  String text = '';

  @override
  void initState() {
    super.initState();
    if (widget.defaultText != null) {
      _controller.text = widget.defaultText!;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoAlertDialog(
      title: Text(widget.title),
      content: Padding(
        padding: const EdgeInsets.only(top: 5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(widget.message),
            const SizedBox(
              height: 12,
            ),
            CupertinoTextField(
              autofocus: true,
              placeholder: widget.placeholder,
              controller: _controller,
              textAlign: widget.textAlign ?? TextAlign.start,
              clearButtonMode: widget.clearButtonMode ?? OverlayVisibilityMode.editing,
              keyboardType: widget.keyboardType ?? TextInputType.text,
              onChanged: (value) {
                if (widget.onChanged != null) {
                  final text = widget.onChanged!(value);
                  if (text != null) {
                    _controller.text = text;
                  }
                }
              },
              onSubmitted: (value) {
                if (widget.onSubmit != null) widget.onSubmit!(value);
              },
            ),
          ],
        ),
      ),
      actions: widget.actions,
    );
  }
}
