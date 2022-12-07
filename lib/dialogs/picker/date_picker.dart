import 'dart:async';
import 'package:flutter/cupertino.dart';
import '../dialog_config.dart';
import 'date_time_picker_model.dart';
import 'picker_completed_model.dart';
import 'picker_config.dart';

Future<DatePickerCompletedModel> showCupertinoDatePicker({
  BuildContext? context, //如果没设置全局，需要传递自己的context
  DatePickerType pickerMode = DatePickerType.dateTimeMinute,
  List<int>? defaultIndexs,
  List<String>? units = const [], //如果想使用自己的单位正常传递，如果不显示默认单位传递null即可
  DateTime? dateTime, //传入时间，可以控制默认选择位置，默认当前时间
  DateTime? minDate, //可以设置前后截止时间，优先该属性
  DateTime? maxDate,
  int? beforeYearsInterval, //根据当前时间或者传入时间向前向后多少年,默认前后20年，以一年365天为基准
  int? afterYearsInterval,
  String title = '',
  confirmText = '确定',
  cancelText = '取消',
  double? itemFontSize,
  Color? confirmColor,
  Color? cancelColor,
}) {
  context = context ?? DialogConfig.context;
  units = units == [] ? getDefaultUnitsByPickerMode(pickerMode) : units;
  final completer = Completer<DatePickerCompletedModel>();
  showCupertinoModalPopup<void>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) => DatePickerWidget(
      pickerMode: pickerMode,
      defaultIndexs: defaultIndexs,
      minDate: minDate,
      maxDate: maxDate,
      beforeYearsInterval: beforeYearsInterval,
      afterYearsInterval: afterYearsInterval,
      units: units,
      confirmText: confirmText,
      cancelText: cancelText,
      itemFontSize: itemFontSize,
      onCompleted: (pickerList, indexs) {
        final list = List<int>.generate(pickerList.length, (index) {
          return pickerList[index][indexs[index]];
        });
        final String dateString;
        if (pickerMode == DatePickerType.dateTime) {
          dateString = '${list[0]}-${list[1]}-${list[2]} ${list[3]}:${list[4]}:${list[5]}';
        } else if (pickerMode == DatePickerType.dateTimeMinute) {
          dateString = '${list[0]}-${list[1]}-${list[2]} ${list[3]}:${list[4]}';
        } else if (pickerMode == DatePickerType.date || pickerMode == DatePickerType.dateMonth) {
          dateString = list.join('-');
        } else {
          dateString = list.join(':');
        }
        completer.complete(DatePickerCompletedModel(
          pickerList: pickerList,
          indexs: indexs,
          selectList: list,
          dateString: dateString,
        ));
      },
    ),
  );
  return completer.future;
}

List<String> getDefaultUnitsByPickerMode(DatePickerType pickerMode) {
   switch (pickerMode) {
     case DatePickerType.date:
       return ['年', '月', '日'];
     case DatePickerType.dateMonth:
       return ['年', '月'];
     case DatePickerType.dateTime:
       return ['年', '月', '日', '时', '分', '秒'];
     case DatePickerType.dateTimeMinute:
       return ['年', '月', '日', '时', '分'];
     case DatePickerType.time:
       return ['时', '分', '秒'];
     case DatePickerType.timeMinute:
       return ['时', '分'];
   }
}

class DatePickerWidget extends StatefulWidget {
  final DatePickerType pickerMode;
  final DateTime? dateTime;
  final DateTime? minDate; //可以设置前后截止时间
  final DateTime? maxDate;
  final int? beforeYearsInterval; //根据当前时间或者传入时间向前向后多少年，以一年365天为基准
  final int? afterYearsInterval;
  final List<int>? defaultIndexs;
  final List<String>? units; //单位，末尾是否使用单位，传入就显示
  final String? confirmText;
  final String? cancelText;
  final Color? confirmColor;
  final Color? cancelColor;
  final double? itemFontSize; //默认自动调节，也可以手动传入调节
  final void Function(List<List> pickerList, List<int> index)? onCompleted;

  const DatePickerWidget({
    Key? key,
    required this.pickerMode,
    required this.defaultIndexs,
    this.dateTime,
    this.minDate,
    this.maxDate,
    this.beforeYearsInterval = 10,
    this.afterYearsInterval = 10,
    this.units,
    this.confirmText,
    this.cancelText,
    this.confirmColor,
    this.cancelColor,
    this.itemFontSize,
    this.onCompleted,
  }) : super(key: key);

  @override
  State<DatePickerWidget> createState() => _DatePickerWidgetState();
}

class _DatePickerWidgetState extends State<DatePickerWidget> {
  late List<List> _pickerList;
  late List<int> _indexs;
  final List<FixedExtentScrollController> _controllers = [];
  late final double _itemFontSize;
  late final DateTimerPickerInfo _pickerInfo;

  @override
  void initState() {
    super.initState();
    _pickerInfo = DateTimerPickerInfo(
      minDate: widget.minDate,
      maxDate: widget.maxDate,
      beforeYearsInterval: widget.beforeYearsInterval,
      afterYearsInterval: widget.afterYearsInterval,
      dateTime: widget.dateTime,
      pickerMode: widget.pickerMode,
    );
    List list = _pickerInfo.getCurrentPickerDataByIndexs();
    setupBaseInfo(list);
  }

  void setupBaseInfo(List list) {
    _pickerList = list[0];

    //处理字体
    _itemFontSize = widget.itemFontSize ?? (_pickerList.length > 5 ? 14 : (_pickerList.length < 4 ? 18 : 16));
    //处理默认值
    if (widget.defaultIndexs != null) {
      _indexs = widget.defaultIndexs!;
    } else {
      _indexs = list[1];
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

  void onValueChanged(int index, int selectIndex) {
    //索引及时更新
    _indexs[index] = selectIndex;
    final list = _pickerInfo.getCurrentPickerDataByIndexs(
      pickerList: _pickerList,
      selectIndexs: _indexs,
    );
    setState(() {
      _pickerList = list[0];
      _indexs = list[1];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: CupertinoColors.white,
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
                                widget.onCompleted!(_pickerList, _indexs);
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
                children: List<Widget>.generate(_pickerList.length, (index) {
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
                        onSelectedItemChanged: (selectIndex) => onValueChanged(index, selectIndex),
                        childCount: _pickerList[index].length,
                        itemBuilder: (context, idx) {
                          return Center(
                            child: Text(
                              '${_pickerList[index][idx].toString()}${widget.units != null ? widget.units![index] : ''}',
                              style: TextStyle(
                                color: CupertinoColors.label,
                                fontSize: _itemFontSize,
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
