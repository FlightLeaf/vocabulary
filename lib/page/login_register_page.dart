import 'dart:async';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:oktoast/oktoast.dart';
import 'package:vocabulary/tools/login_state_tools.dart';
import 'package:vocabulary/tools/sharedPreferences_tools.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPage createState() => _LoginPage();
}

class _LoginPage extends State<LoginPage> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();


  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: const Text('登录'),
        //backgroundColor: Colors.transparent, // 将AppBar的背景颜色设置为透明
        elevation: 0,
        flexibleSpace: FlexibleSpaceBar(
          background: Container(
            color: Colors.white, // 背景色设置为透明
          ),
          collapseMode: CollapseMode.parallax,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            TextFormField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: '邮箱',
                labelStyle: const TextStyle(color: Colors.black),
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.black),
                  borderRadius: BorderRadius.circular(10),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.blue),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 16.0),
            TextFormField(
              obscureText: true,
              controller: passwordController,
              decoration: InputDecoration(
                labelText: '密码',
                labelStyle: const TextStyle(color: Colors.black),
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.black),
                  borderRadius: BorderRadius.circular(10),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.blue),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 24.0),
            ElevatedButton(
              onPressed: () async {
                final dio = Dio();
                final data = {
                  "email":emailController.text.toString(),
                  "password":passwordController.text.toString()
                };
                try {
                  // 发送POST请求
                  final response = await dio.post(
                    'http://114.55.94.213:5001/login',
                    data: data,
                  );
                  if(response.data.toString() == '{message: Login successful}'){
                    showToast('登录成功');
                    LoginState.login('lv', emailController.text);
                    LoginState.state = true;
                    Navigator.pop(context);
                  }else{
                    showToast('登录失败');
                  }
                } catch (e) {
                  print('Error: $e');
                }

              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                    horizontal: 50.0, vertical: 15.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                backgroundColor: Colors.blue,
              ),
              child: const Text(
                '登录',
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
            ),
            const SizedBox(height: 16.0),
            TextButton(
              onPressed: () {
                // 跳转到注册页面
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => RegisterPage()),
                );
              },
              child: const Text('没有账号？注册新账号'),
            ),
          ],
        ),
      ),
    );
  }
}

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController surePasswordController = TextEditingController();
  TextEditingController codeController = TextEditingController();

  bool emailValid = true;
  String codeTime = '120';

  void postRegisterRequestFunction(String email, String password, String name,
      String code, BuildContext context) async {
    if(name !='' && password !='' && code !='' && email !=''){
      if(DataUtils.hasKey('code')){
        String _code = DataUtils.getString('code')!;
        if(_code == code){
          final dio = Dio();
          // 定义要发送的数据
          var data = {
            'name': name,
            'email': email,
            'password': password,
          };
          try {
            // 发送POST请求
            final response = await dio.post(
              'http://114.55.94.213:5001/register',
              data: data,
            );
            print(response.data);
            if(response.data.toString() == '{message: User registered successfully}'){
              print('================成功注册');
              showToast('注册成功');
            }else{
              showToast('注册失败');
            }
          } catch (e) {
            print('Error: $e');
          }
        }else{
          showToast('验证码不正确');
        }
      }else{
        showToast('验证码已失效或未发送');
      }
    }else{
      showToast('信息不完整');
    }
  }

  // 创建一个计时器，每秒减少剩余时间并打印
  Timer? timer;

  void postSendRequestFunction(String email) async {
    final random = Random();
    int randomNumber = 100000 + random.nextInt(900000);
    String code = randomNumber.toString();
    DataUtils.putString('code', code);
    Dio dio = Dio();
    final jsonData = {
      'email': email,
      'code': randomNumber.toString(),
    };
    Response response =
    await dio.post('http://114.55.94.213:5001/send', data: jsonData);
    print('response.data: ${response.data}');
    if(response.data.toString() == 'success'){
      showToast('验证码发送成功');
      isSend = true;
      setState(() {

      });

      // 定义剩余时间
      int remainingSeconds = 120; // 2分钟转换为秒


      timer = Timer.periodic(Duration(seconds: 1), (Timer t) {
        codeTime = remainingSeconds.toString();
        remainingSeconds--;
        if (remainingSeconds < 0) {
          print(DataUtils.getString('code'));
          isSend = false;
          DataUtils.remove('code');
          showToast('验证码失效');
          print('2分钟后自动执行的操作');
          t.cancel();
        }
        setState(() {

        });
      });
      Future.delayed(Duration(seconds: 123)).then((_) {
        timer?.cancel();
      });
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    DataUtils.remove('code');
    super.dispose();
  }

  bool isSuccess = true;
  bool isLooking = false;
  bool isSend = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '注册',
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const SizedBox(
                height: 10,
              ),
              TextFormField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: '昵称',
                  labelStyle: const TextStyle(color: Colors.black),
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.black),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.blue),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 20.0),
              TextFormField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: '邮箱',
                  labelStyle: const TextStyle(color: Colors.black),
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.black),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.blue),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  suffixIcon: EmailValidator.validate(emailController.text)
                      ? const Icon(Icons.check, color: Colors.green)
                      : const Icon(
                    Icons.error_rounded,
                    color: Colors.red,
                  ),
                ),
                onChanged: (value) async {
                  Dio dio = Dio();
                  final jsonData = {
                    'email': emailController.text
                  };
                  Response response = await dio.post(
                      'http://114.55.94.213:5001/verify_email',
                      data: jsonData);
                  if(response.data.toString() == '{message: not exist}'){
                    emailValid = false;
                  }else{
                    emailValid = true;
                  }
                  setState(() {});
                },
              ),
              const SizedBox(height: 20.0),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: codeController,
                      decoration: InputDecoration(
                          labelText: '验证码',
                          labelStyle: const TextStyle(color: Colors.black),
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: Colors.black),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: Colors.blue),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          suffixIcon: Container(
                            margin: EdgeInsets.all(5),
                            child: isSend?Container(
                              width: 120,
                              height: 30,
                              child: Center(
                                child: Text('验证码已发送\n$codeTime秒后重试'),
                              ),
                            ): ElevatedButton(
                              onPressed: () async {
                                if(!emailValid && EmailValidator.validate(emailController.text)){
                                  postSendRequestFunction(emailController.text);
                                }else{
                                  showToast('邮箱格式不合法或已被注册');
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20.0,
                                    vertical: 15,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                  backgroundColor: Colors.blue,
                                  elevation: 0),
                              child: const Text(
                                '发送验证码',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 15),
                              ),
                            ),
                          )),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20.0),
              TextFormField(
                controller: passwordController,
                obscureText: !isLooking,
                decoration: InputDecoration(
                  labelText: '密码',
                  labelStyle: const TextStyle(color: Colors.black),
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.black),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.blue),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  suffixIcon: isLooking
                      ? IconButton(
                    onPressed: () {
                      isLooking = false;
                      setState(() {});
                    },
                    icon: const Icon(
                      Icons.visibility_rounded,
                      color: Colors.blue,
                    ),
                  )
                      : IconButton(
                    onPressed: () {
                      isLooking = true;
                      setState(() {});
                    },
                    icon: const Icon(
                      Icons.visibility_off_rounded,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20.0),
              TextFormField(
                controller: surePasswordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: '确认密码',
                  labelStyle: const TextStyle(color: Colors.black),
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.black),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.blue),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  suffixIcon: isSuccess
                      ? const Icon(Icons.check, color: Colors.green)
                      : const Icon(
                    Icons.error_rounded,
                    color: Colors.red,
                  ),
                ),
                onChanged: (value) {
                  if (passwordController.text != surePasswordController.text) {
                    isSuccess = false;
                    setState(() {});
                  } else {
                    isSuccess = true;
                    setState(() {});
                  }
                },
              ),
              SizedBox(height: 30.0),
              ElevatedButton(
                onPressed: () {
                  String Name = nameController.text;
                  String Email = emailController.text;
                  String Password = passwordController.text;
                  String surePassword = surePasswordController.text;
                  if (Password != surePassword) {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text("错误"),
                          content: const Text("密码不相同"),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: const Text("确认"),
                            ),
                          ],
                        );
                      },
                    );
                  } else {
                    postRegisterRequestFunction(
                        emailController.text,
                        passwordController.text,
                        nameController.text,
                        codeController.text,
                        context);
                  }
                },
                style: ElevatedButton.styleFrom(
                  padding:
                  EdgeInsets.symmetric(horizontal: 50.0, vertical: 15.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  backgroundColor: Colors.blue,
                ),
                child: Text(
                  '注册',
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
