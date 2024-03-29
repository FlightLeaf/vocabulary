import 'dart:math';

void main() {
  // 创建一个Random对象实例
  final random = Random();

  // 生成一个六位的随机数
  // 100000是最小的六位数，999999是最大的六位数
  int randomNumber = 100000 + random.nextInt(900000); // 从100000到999999的范围中生成随机数

  print(randomNumber); // 输出六位随机数
}
