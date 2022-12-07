import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../dialog_config.dart';
import 'picker_completed_model.dart';
import 'picker_config.dart';

Future<MutliPickerCompletedModel> showCupertinoMutliPicker({
  BuildContext? context, //如果没设置全局，需要传递自己的context
  required List<List> pickerList,
  List<int>? defaultIndex,
  List<String>? units, //单位
  String? title = '',
  String? confirmText = '确定',
  String? cancelText = '取消',
  Color? confirmColor,
  Color? cancelColor,
  double? itemFontSize,
  void Function(List<int> index)? onValueChanged, //由于pickerList外面传递进来的，因此里面不在返回其他
}) {
  context = context ?? DialogConfig.context;
  final completer = Completer<MutliPickerCompletedModel>();
  showCupertinoModalPopup<void>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) => MutliPickerWidget(
      pickerList: pickerList,
      defaultIndexs: defaultIndex,
      confirmText: confirmText,
      cancelText: cancelText,
      onValueChanged: onValueChanged,
      onCompleted: (indexs) {
        completer.complete(MutliPickerCompletedModel(
          pickerList: pickerList,
          indexs: indexs,
          selectList: List.generate(pickerList.length, (index) => pickerList[index][indexs[index]])
        ));
      },
    ),
  );
  return completer.future;
}

//pickerList为五个数组数据源， defaultIndexs默认选项，units为单位
class MutliPickerWidget extends StatefulWidget {
  final List<List> pickerList;
  final List<int>? defaultIndexs;
  final List<String>? units; //单位，末尾是否使用单位，传入就显示
  final String? confirmText;
  final String? cancelText;
  final Color? confirmColor;
  final Color? cancelColor;
  final double? itemFontSize; //默认自动调节，也可以手动传入调节
  final void Function(List<int> index)? onValueChanged;
  final void Function(List<int> index)? onCompleted;

  const MutliPickerWidget({
    Key? key,
    required this.pickerList,
    required this.defaultIndexs,
    this.units,
    this.confirmText,
    this.cancelText,
    this.confirmColor,
    this.cancelColor,
    double? itemFontSize,
    this.onValueChanged,
    this.onCompleted,
  })  : assert(defaultIndexs == null || defaultIndexs.length == pickerList.length, 'defaultIndexs应和pickerList长度一致'),
        assert(units == null || units.length >= pickerList.length, 'units应和pickerList长度一致'),
        itemFontSize = itemFontSize ?? (pickerList.length > 5 ? 14 : (pickerList.length < 4 ? 18 : 16)),
        super(key: key);

  @override
  State<MutliPickerWidget> createState() => _MutliPickerWidgetState();
}

class _MutliPickerWidgetState extends State<MutliPickerWidget> {
  late List<int> _indexs;
  final List<FixedExtentScrollController> _controllers = [];

  @override
  void initState() {
    super.initState();
    //处理默认值
    if (widget.defaultIndexs != null) {
      _indexs = widget.defaultIndexs!;
    } else {
      _indexs = List<int>.generate(widget.pickerList.length, (index) => 0);
    }
    for (final index in _indexs) {
      _controllers.add(FixedExtentScrollController(initialItem: index));
    }
  }

  @override
  void dispose() {
    for (final element in _controllers) {
      element.dispose();
    }
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
                          CupertinoButton(
                            minSize: pickerMinNaviLabelHeight,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              widget.confirmText!,
                              style: TextStyle(color: widget.cancelColor ?? CupertinoColors.systemBlue),
                            ),
                            onPressed: () {
                              if (widget.onCompleted != null) {
                                widget.onCompleted!(_indexs);
                              }
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      )
                    : null,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List<Widget>.generate(widget.pickerList.length, (index) {
                  //CupertinoPicker使用多列宽度要使用Expanded等计算好，高度写死，不然会计算报错
                  return Expanded(
                    child: SizedBox(
                      height: pickerHeight,
                      child: CupertinoPicker.builder(
                        scrollController: _controllers[index],
                        magnification: 1.22,
                        squeeze: 1.2,
                        useMagnifier: true,
                        itemExtent: 32,
                        onSelectedItemChanged: (int selectIndex) {
                          _indexs[index] = selectIndex;
                          if (widget.onValueChanged != null) {
                            widget.onValueChanged!(_indexs);
                          }
                        },
                        childCount: widget.pickerList[index].length,
                        itemBuilder: (context, idx) {
                          return Center(
                            child: Text(
                              '${widget.pickerList[index][idx].toString()}${widget.units != null ? widget.units![index] : ''}',
                              style: TextStyle(
                                color: CupertinoColors.label,
                                fontSize: widget.itemFontSize,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
