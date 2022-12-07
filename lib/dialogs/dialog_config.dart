import 'package:flutter/material.dart';

class DialogConfig extends InheritedWidget {
  static GlobalKey<NavigatorState>? globalNavigatorKey;

  const DialogConfig.internal({
    Key? key,
    required Widget child,
  }) : super(key: key, child: child);

  factory DialogConfig({
    Key? key,
    required GlobalKey<NavigatorState> globalNavigatorKey,
    required Widget child,
  }) {
    DialogConfig.globalNavigatorKey = globalNavigatorKey;
    return DialogConfig.internal(
      key: key,
      child: child,
    );
  }

  /*
    GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

    DialogConfig(
      globalNavigatorKey: navigatorKey,
      child: MaterialApp(
        navigatorKey: navigatorKey,
        ...,
      ),
    );
   */
  static BuildContext get context {
    assert(globalNavigatorKey?.currentState?.context != null, '获取globalcontext失败，请在main函数中的 MaterialApp 外层，设置 DialogConfig，且传入MaterialApp的navigatorKey');
    return globalNavigatorKey!.currentState!.context;
  }

  //就像 Navigator.of(context)一样获取，用于调用内部参数
  static DialogConfig of(BuildContext context) {
    final DialogConfig? result = context.dependOnInheritedWidgetOfExactType<DialogConfig>();
    assert(result != null, 'No DialogConfig found in context');
    return result!;
  }

  @override
  bool updateShouldNotify(DialogConfig oldWidget) {
    return false;
  }
}