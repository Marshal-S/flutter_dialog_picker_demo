import 'package:flutter/cupertino.dart';

//时间类型枚举
enum DatePickerType {
  date, //2020-10-10
  dateMonth, //2020-10
  dateTime, //2020-10-10 10:10:10
  dateTimeMinute, //2020-10-10 10:10 到分钟，默认用的最多
  time, //10:10:10
  timeMinute, //10:10:10
}

class DateTimerPickerInfo {
  final DateTime minDate; //日期区间，或者截止时间，避免选出不该选的
  final DateTime maxDate;
  final DatePickerType pickerMode;
  final List<List> minPickerList; //保存最小的pickerList
  final List<List> maxPickerList; //保存最大的pickerList
  final List<List> defaultPickerList;
  List<int> defaultIndexs; //选择的索引

  final List minList; //最大最小值索引
  final List maxList;

  DateTimerPickerInfo.internal({
    required this.minPickerList,
    required this.maxPickerList,
    required this.defaultPickerList,
    required this.defaultIndexs,
    required this.minDate,
    required this.maxDate,
    required this.pickerMode,
    required this.minList,
    required this.maxList,
  });

  factory DateTimerPickerInfo({
    DateTime? minDate, //日期区间，或者截止时间，避免选出不该选的，优先该属性
    DateTime? maxDate,
    int? beforeYearsInterval = 10, //根据当前时间或者传入时间向前向后多少年，以一年365天为基准
    int? afterYearsInterval = 10,
    DateTime? dateTime, //传入时间，可以控制默认选择位置，默认当前时间
    DatePickerType pickerMode = DatePickerType.dateTimeMinute,
  }) {
    //为了避免本地环境问题，取时间从0时区通过偏移获取中国位置
    assert(
      (minDate != null && maxDate != null) || (beforeYearsInterval != null && afterYearsInterval != null),
      '时间戳(minDate、maxDate)和时间间隔(beforeYearsInterval、afterYearsInterval)区间必须传递一组',
    );
    dateTime = dateTime ?? DateTime.now();
    if (minDate == null && maxDate == null && beforeYearsInterval != null && afterYearsInterval != null) {
      minDate = dateTime.subtract(Duration(days: beforeYearsInterval * 365)); //一年365天为准
      maxDate = dateTime.add(Duration(days: afterYearsInterval * 365));
    }
    //处理时间的，强制转为中国时区
    dateTime = dateTime.toUtc().add(const Duration(hours: 8));
    minDate = minDate!.toUtc().add(const Duration(hours: 8));
    maxDate = maxDate!.toUtc().add(const Duration(hours: 8));

    List minList = [minDate.year, minDate.month, minDate.day, minDate.hour, minDate.minute, minDate.second];
    List maxList = [maxDate.year, maxDate.month, maxDate.day, maxDate.hour, maxDate.minute, maxDate.second];

    List minDefaultValueList = [null, 1, 1, 0, 0, 0];
    List maxDefaultValueList = [null, 12, null, 23, 59, 59];

    List years = getLoopList(minDate.year, maxDate.year);
    List months = getLoopList(1, 12);
    List hours = getLoopList(0, 23);
    List minuteAndSeconds = getLoopList(0, 59);

    List<List> minPickerList = [years];
    List<List> maxPickerList = [years];
    //添加各组最大最小集合，避免方便获取
    bool isEqualFlag = true;
    for (int i = 1, last = i - 1; i < 6; i++, last++) {
      if (isEqualFlag && minList[last] == maxList[last]) {
        final loopList = getLoopList(minList[i], maxList[i]);
        minPickerList.add(loopList);
        maxPickerList.add(loopList);
      } else {
        isEqualFlag = false;
        if (i == 2) {
          //二月份最大值最小值单独处理
          minPickerList.add(getLoopList(minList[i], getMaxDay(year: minList[0], month: minList[1])));
          maxPickerList.add(getLoopList(minDefaultValueList[i], maxList[i]));
        } else {
          minPickerList.add(getLoopList(minList[i], maxDefaultValueList[i]));
          maxPickerList.add(getLoopList(minDefaultValueList[i], maxList[i]));
        }
      }
    }

    var selectYear = dateTime.year - minDate.year;
    final selectMonth = dateTime.month - 1; //默认1-12
    final day = dateTime.day - 1; //默认1-x
    final hour = dateTime.hour;
    final minute = dateTime.minute;
    final second = dateTime.second;

    //当前的picker和List需要矫正最大值最小值引起的索引越界与纠正后的pickerList更新问题
    List<List> defaultPickerList = [years, months, getLoopList(1, 31), hours, minuteAndSeconds, minuteAndSeconds];
    List<int> defaultIndexs = [selectYear, selectMonth, day, hour, minute, second];
    return DateTimerPickerInfo.internal(
      minDate: minDate,
      maxDate: maxDate,
      minPickerList: minPickerList,
      maxPickerList: maxPickerList,
      defaultPickerList: defaultPickerList,
      defaultIndexs: defaultIndexs,
      pickerMode: pickerMode,
      minList: minList,
      maxList: maxList,
    );
  }

  //返回新的pickerList和索引,除了初始化时索引，默认必传
  //0为pickerList，1位新索引
  List getCurrentPickerDataByIndexs({
    List<List>? pickerList,
    List<int>? selectIndexs,
  }) {
    int start = 0, end = 5;
    switch (pickerMode) {
      case DatePickerType.date:
        start = 0;
        end = 3;
        break;
      case DatePickerType.dateMonth:
        start = 0;
        end = 2;
        break;
      case DatePickerType.dateTime:
        start = 0;
        end = 6;
        break;
      case DatePickerType.dateTimeMinute:
        break;
      case DatePickerType.time:
        start = 3;
        end = 6;
        break;
      case DatePickerType.timeMinute:
        start = 3;
        end = 5;
        break;
    }
    if (selectIndexs == null) {
      selectIndexs = [];
      for (int i = start; i < end; i++) {
        selectIndexs.add(defaultIndexs[i]);
      }
    }
    if (pickerList == null) {
      pickerList = [];
      for (int i = start; i < end; i++) {
        pickerList.add(defaultPickerList[i]);
      }
    }
    final List<List> newPickerList = [];
    newPickerList.add(defaultPickerList[start]);
    int flag = 3; //是否仍然最大、最小标识
    for (int i = start + 1, last = start; i < end; i++, last++) {
      final lastIndex = last-start;
      final index = i - start;
      final lastValue = pickerList[lastIndex][selectIndexs[lastIndex]];
      if (flag & 1 == 1 && lastValue == minList[last]) {
        newPickerList.add(minPickerList[i]);
        flag = 1;
      } else if (flag & 2 == 2 && lastValue == maxList[last]) {
        newPickerList.add(maxPickerList[i]);
        flag = 2;
      } else {
        flag = 0;
        if (i == 2) {
          //动态获取二月份天数单独处理
          newPickerList.add(getDaysList(year: pickerList[0][selectIndexs[0]], month: pickerList[1][selectIndexs[1]]));
        } else {
          newPickerList.add(defaultPickerList[i]);
        }
      }
      final list = newPickerList[index];
      final max = list.length;
      if (selectIndexs[index] >= max) {
        selectIndexs[index] = max - 1;
      }
    }
    return [newPickerList, selectIndexs];
  }
}

//获取指定区间集合
List getLoopList(start, end) {
  final list = [];
  for (int i = start; i <= end; i++) {
    list.add(i);
  }
  return list;
}

//获取月份最大值
int getMaxDay({
  required int year,
  required int month,
}) {
  final isLeapYear = year % 400 == 0 || (year % 4 == 0 && year % 100 != 0);
  int max;
  switch (month) {
    case 1:
    case 3:
    case 5:
    case 7:
    case 8:
    case 10:
    case 12:
      max = 31;
      break;
    case 4:
    case 6:
    case 9:
    case 11:
      max = 30;
      break;
    case 2:
      max = isLeapYear ? 29 : 28;
      break;
    default:
      throw ErrorHint("月份不正确");
  }
  return max;
}

//获取月份数组
List getDaysList({
  required int year,
  required int month,
}) {
  final isLeapYear = year % 400 == 0 || (year % 4 == 0 && year % 100 != 0);
  List list;
  switch (month) {
    case 1:
    case 3:
    case 5:
    case 7:
    case 8:
    case 10:
    case 12:
      list = getLoopList(1, 31);
      break;
    case 4:
    case 6:
    case 9:
    case 11:
      list = getLoopList(1, 30);
      break;
    case 2:
      list = isLeapYear ? getLoopList(1, 29) : getLoopList(1, 28);
      break;
    default:
      throw ErrorHint("月份不正确");
  }
  return list;
}
