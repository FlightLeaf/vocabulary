import 'dart:core';

void main() {
  // 获取当前时间
  DateTime now = DateTime.now();

  // 获取自Unix纪元以来的毫秒数
  int millisecondsSinceEpoch = now.millisecondsSinceEpoch;
  print('Milliseconds since epoch: $millisecondsSinceEpoch');
}
