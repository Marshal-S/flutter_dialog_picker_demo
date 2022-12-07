import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../dialog_config.dart';
import 'picker_completed_model.dart';
import 'picker_config.dart';

Future<SinglePickerCompletedModel> showCupertinoPicker({
  BuildContext? context, //如果没设置全局，需要传递自己的context
  required List pickerList,
  defaultIndex = 0,
  String? title = '',
  String? confirmText = '确定',
  String? cancelText = '取消',
  Color? confirmColor,
  Color? cancelColor,
  void Function(int index, dynamic item)? onValueChanged,
}) {
  context = context ?? DialogConfig.context;
  final completer = Completer<SinglePickerCompletedModel>();
  showCupertinoModalPopup<void>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) => PickerWidget(
      pickerList: pickerList,
      defaultIndex: defaultIndex,
      confirmText: confirmText,
      cancelText: cancelText,
      onValueChanged: onValueChanged,
      onCompleted: (index, item) {
        completer.complete(SinglePickerCompletedModel(
          index: index,
          item: item
        ));
      },
    ),
  );
  return completer.future;
}

//如果上面弹窗部分不喜欢，可以直接使用widget
class PickerWidget extends StatefulWidget {
  final List pickerList;
  final int defaultIndex;
  final String? title;
  final String? confirmText;
  final String? cancelText;
  final Color? confirmColor;
  final Color? cancelColor;
  final void Function(int index, dynamic item)? onValueChanged;
  final void Function(int index, dynamic item)? onCompleted;

  const PickerWidget({
    Key? key,
    required this.pickerList,
    required this.defaultIndex,
    this.title,
    this.confirmText = '确定',
    this.cancelText = '取消',
    this.confirmColor,
    this.cancelColor,
    this.onValueChanged,
    this.onCompleted,
  }) : super(key: key);

  @override
  State<PickerWidget> createState() => _PickerState();
}

class _PickerState extends State<PickerWidget> {
  late FixedExtentScrollController _controller;
  int _index = 0;

  @override
  void initState() {
    super.initState();
    _index = widget.defaultIndex;
    _controller = FixedExtentScrollController(
      initialItem: _index, // 默认索引
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: pickerTotolHeight,
          child: Column(
            children: [
              Container(
                color: CupertinoColors.extraLightBackgroundGray,
                child: widget.confirmText != null && widget.cancelText != null
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          CupertinoButton(
                            minSize: pickerMinNaviLabelHeight,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              widget.cancelText!,
                              style: TextStyle(color: widget.confirmColor ?? CupertinoColors.label),
                            ),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),

                          widget.title != null ? Text(
                            widget.title!,
                            style: TextStyle(color: widget.cancelColor ?? CupertinoColors.systemBlue),
                          ) : Container(),

                          CupertinoButton(
                            minSize: pickerMinNaviLabelHeight,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              widget.confirmText!,
                              style: TextStyle(color: widget.cancelColor ?? CupertinoColors.systemBlue),
                            ),
                            onPressed: () {
                              if (widget.onCompleted != null) {
                                widget.onCompleted!(_index, widget.pickerList[_index]);
                              }
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      )
                    : null,
              ),
              SizedBox(
                height: pickerHeight,
                child: CupertinoPicker.builder(
                  scrollController: _controller,
                  magnification: 1.22,
                  squeeze: 1.2,
                  useMagnifier: true,
                  itemExtent: 32,
                  childCount: widget.pickerList.length,
                  onSelectedItemChanged: (int idx) {
                    if (widget.onValueChanged != null) {
                      widget.onValueChanged!(idx, widget.pickerList[idx]);
                    }
                    _index = idx;
                  },
                  itemBuilder: (context, index) => Center(
                    child: Text(
                      widget.pickerList[index].toString(),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
