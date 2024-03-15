
import 'package:dio/dio.dart';

void main() async {
  Response response = await Dio().get('https://api.wer.plus/api/wytop?t=4');
  print(response.data.toString());
}
