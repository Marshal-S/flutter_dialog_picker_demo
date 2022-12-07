import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dialogs/dialogs.dart';
import 'dialogs/menu_demo.dart';

GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return DialogConfig(
      globalNavigatorKey: navigatorKey,
      child: MaterialApp(
        navigatorKey: navigatorKey,
        debugShowCheckedModeBanner: false,
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: const MyHomePage(),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String value = '';

  void showAlert() {
    showCupertinoAlert(
      // context: context,
      title: "提示",
      message: "检测到未登录，请前往登陆！",
      confirmText: "立即前往",
      cancelText: "取消",
      // isDestructiveCancel: true,
    ).then((res) {
      print(res);
      setState(() {
        value = res.toString();
      });
    });
  }

  void showActionSheet() {
    final actions = <ActionSheetItem>[
      ActionSheetItem(text: "确定"),
      ActionSheetItem(text: "特殊", isDestructive: true),
      ActionSheetItem(text: "加载中...", isLoading: true),
    ];
    showCupertinoActionSheet(
      // context: context,
      title: '演示',
      message: "请选择一个效果",
      actions: actions,
      // isDestructiveCancel: true,
    ).then((res) {
      print(res);
      setState(() {
        value = actions[res].text!;
      });
    });
  }

  void showInputAlert() {
    showCupertinoInputAlert(
      // context: context,
      title: "标题",
      message: '内容',
      isDestructiveCancel: true,
      onChanged: (String text) {
        print(text);
        setState(() {
          value = text;
        });
      },
    ).then((res) {
      print(res);
      //可以干别的事情
      if (res != null) {
        setState(() {
          value = res;
        });
      }
    });
  }

  void showSinglePicker() {
    showCupertinoPicker(
      // context: context,
      pickerList: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
      defaultIndex: 2,
      onValueChanged: (index, item) {
        print(index);
        print(item);
      },
    ).then((res) {
      setState(() {
        value = res.item.toString();
      });
      print(res.index);
      print(res.item);
    });
  }

  void showMutliPicker() {
    showCupertinoMutliPicker(
      // context: context,
      pickerList: [
        [100, 200, 300, 400, 500],
        [10, 20, 30, 40, 50],
        [1, 2, 3, 4, 5],
      ],
      onValueChanged: (indexs) {
        print(indexs);
      },
    ).then((res) {
      setState(() {
        value = res.selectList.join(',');
      });
      print(res);
    });
  }

  void showIosStyleDatePicker(DatePickerType pickerMode) {
    showCupertinoDatePicker(
      // context: context,
      pickerMode: pickerMode,
      beforeYearsInterval: 10,
      afterYearsInterval: 10,
      // minDate: DateTime.now().subtract(const Duration(days: 1000)),
      // maxDate: DateTime.now().add(const Duration(days: 1000)),
    ).then((res) {
      print(res);
      setState(() {
        value = res.dateString;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('ios style dialog'),
        ),
        body: ListView(
          children: [
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: Text(
                      '$value',
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  const Text("alert、action-sheet、input-alert"),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      CupertinoButton(
                        padding: const EdgeInsets.all(10),
                        onPressed: showAlert,
                        child: const Text('alert'),
                      ),
                      CupertinoButton(
                        padding: const EdgeInsets.all(10),
                        onPressed: showActionSheet,
                        child: const Text('action sheet'),
                      ),
                      CupertinoButton(
                        padding: const EdgeInsets.all(10),
                        onPressed: showInputAlert,
                        child: const Text('input alert'),
                      ),
                    ],
                  ),
                  const Text("单列、多列 picker"),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      CupertinoButton(
                        padding: const EdgeInsets.all(10),
                        onPressed: showSinglePicker,
                        child: const Text('picker'),
                      ),
                      CupertinoButton(
                        padding: const EdgeInsets.all(10),
                        onPressed: showMutliPicker,
                        child: const Text('mutli-picker'),
                      ),
                    ],
                  ),
                  const Text("date-timer-picker 多种风格"),
                  Wrap(
                    alignment: WrapAlignment.spaceEvenly,
                    children: [
                      CupertinoButton(
                        padding: const EdgeInsets.all(10),
                        onPressed: () => showIosStyleDatePicker(DatePickerType.dateMonth),
                        child: const Text('年-月'),
                      ),
                      CupertinoButton(
                        padding: const EdgeInsets.all(10),
                        onPressed: () => showIosStyleDatePicker(DatePickerType.date),
                        child: const Text('年-月-日'),
                      ),
                      CupertinoButton(
                        padding: const EdgeInsets.all(10),
                        onPressed: () => showIosStyleDatePicker(DatePickerType.dateTimeMinute),
                        child: const Text('年-月-日 时-分'),
                      ),
                      CupertinoButton(
                        padding: const EdgeInsets.all(10),
                        onPressed: () => showIosStyleDatePicker(DatePickerType.dateTime),
                        child: const Text('年-月-日 时:分:秒'),
                      ),
                      CupertinoButton(
                        padding: const EdgeInsets.all(10),
                        onPressed: () => showIosStyleDatePicker(DatePickerType.timeMinute),
                        child: const Text('时:分'),
                      ),
                      CupertinoButton(
                        padding: const EdgeInsets.all(10),
                        onPressed: () => showIosStyleDatePicker(DatePickerType.time),
                        child: const Text('时:分:秒'),
                      ),
                    ],
                  ),
                  const Text("ios menu风格menu，比较简单，未封装"),
                  const Padding(
                    padding: EdgeInsets.all(10),
                    child: SizedBox(
                      width: 100,
                      height: 100,
                      child: CupertinoActionsMenu(),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ));
  }
}
