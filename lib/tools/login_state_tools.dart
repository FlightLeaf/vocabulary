import 'package:oktoast/oktoast.dart';
import 'package:vocabulary/tools/sharedPreferences_tools.dart';

class LoginState{

  static String user = '';
  static String em = '';
  static bool state = false; //是否登录

  static void init(){
    if(DataUtils.hasKey('user')&&DataUtils.hasKey('em')){
      state = true;
    }else{
      state = false;
      showToast('请登录');
    }
  }

  static void login(String userName, String email){
    DataUtils.putString('user', userName);
    DataUtils.putString('em', email);
  }

  static void unLogin(){
    if(DataUtils.hasKey('user')&&DataUtils.hasKey('em')){
      DataUtils.remove('user');
      DataUtils.remove('em');
      showToast('已退出登录');
    }else{
      showToast('请先登录');
    }
  }
}