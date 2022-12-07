
//单个picker model
class SinglePickerCompletedModel {
  final int index;
  final dynamic item;

  SinglePickerCompletedModel({
    required this.index,
    required this.item,
  });
}

//分组mutli-picker model
class MutliPickerCompletedModel {
  final List<List> pickerList;
  final List<int> indexs;
  final List selectList;

  MutliPickerCompletedModel({
    required this.pickerList,
    required this.indexs,
    required this.selectList,
  });
}

//date-picker系列 model
class DatePickerCompletedModel {
  final List<List> pickerList;
  final List<int> indexs;
  final List selectList;
  final String dateString;

  DatePickerCompletedModel({
    required this.pickerList,
    required this.indexs,
    required this.selectList,
    required this.dateString,
  });
}

