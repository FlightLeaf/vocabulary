package com.vocabulary.vocabulary

import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity

import org.devio.flutter.splashscreen.SplashScreen // add


class MainActivity: FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        SplashScreen.show(this, true)
        super.onCreate(savedInstanceState)
    }
    override fun onBackPressed() {
        // 移动Task到后台
        moveTaskToBack(true)
        // 或者，如果你不想完全移到后台，而是想返回上一个Flutter路由，可以使用下面的代码
        // super.onBackPressed()
    }
}