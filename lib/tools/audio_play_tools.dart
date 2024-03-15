
import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:oktoast/oktoast.dart';
import 'package:vocabulary/tools/sqlite_tools.dart';

import '../model/music.dart';
import 'api_dio_get_source_tools.dart';

class AudioPlayerUtil{

  static MusicModel? get musicModel => _instance._musicModel; // 当前播放的音频模型
  static PlayerState get state => _instance._state; // 当前播放状态
  static Duration get position => _instance._position; // 当前音频播放进度
  static bool get isListPlayer => _instance._isListPlayer; // 当前是否是列表播放
  static List<MusicModel> get list => _instance._musicModels;
  static NextState get nextState => _instance._nextState;

  /// 添加音频模型
  static void addMusicModel({required MusicModel models}) {
    for(MusicModel model in _instance._musicModels){
      if(model.id == models.id){
        return;
      }
    }
    _instance._musicModels.add(models);
  }

  /// 删除音频模型
  static void removeMusicModel({required MusicModel model}){
    _instance._musicModels.remove(model);
  }

  /// 添加音频模型-下一首播放
  static void addMusicModelNext({required MusicModel models}){
    for(MusicModel model in _instance._musicModels){
      if(model.id == models.id){
        return;
      }
    }
    showToast('下一首播放');
    _instance._musicModels.insert(_instance._musicModels.indexOf(_instance._musicModel!)+1, models);

  }

  static void playerHandle({required MusicModel model}){
    if(_instance._musicModel == null){ // 播放新的音频
      _instance._playNewAudio(model);
      _instance._isListPlayer = false; // 关闭列表播放
    }else{
      if(_instance._musicModel!.mp3Url == model.mp3Url){ // 继续当前资源进行播放or暂停
        if(_instance._state == PlayerState.playing){
          _instance._audioPlayer.pause();
        }else{
          _instance._audioPlayer.resume();
        }
      }else{ // 播放新的音频
        _instance._playNewAudio(model);
        _instance._isListPlayer = false; // 关闭列表播放
      }
    }
  }

  // 列表播放
  static Future<void> listPlayerHandle({required List<MusicModel> musicModels,MusicModel? musicModel} ) async {
    if(_instance._musicModel == musicModel){
      _instance._audioPlayer.pause();
    }
    else{
      if(musicModel != null){ // 指定播放列表中某个曲子。自动开启列表播放
        _instance._playNewAudio(musicModel);
        _instance._musicModels = musicModels;
        _instance._isListPlayer = true;
      }
      else{
        if(_instance._isListPlayer == true){ // 列表已经开启过。此处破；判断暂停、播放
          if(_instance._state == PlayerState.playing){
            _instance._audioPlayer.pause();
          }
          else{
            _instance._audioPlayer.resume();
          }
        }
        else{ // 开启列表播放,从0开始
          _instance._playNewAudio(musicModels.first);
          _instance._musicModels = musicModels;
          _instance._isListPlayer = true;
        }
      }
    }
  }

  static void changeNextState(NextState nextState){
    _instance._nextState = nextState;
  }

  static List<int> _generateUniqueRandomIndices(int length) {
    List<int> indices = List.generate(length, (index) => index + 1);
    var random = Random();
    indices.shuffle(random);
    return indices;
  }

  // 上一曲 ，只在列表播放时有效
  static void previousMusic(){
    if(_instance._isListPlayer == false) return;
    switch(_instance._nextState){
      case NextState.sequential:
        int index = _instance._musicModels.indexOf(_instance._musicModel!);
        if(index == 0){
          index = _instance._musicModels.length-1;
        }else{
          index -= 1;
        }
        _instance._playNewAudio(_instance._musicModels[index]);
        break;

      case NextState.random:
        int randomIndex = Random().nextInt(_instance._musicModels.length);
        _instance._playNewAudio(_instance._musicModels[randomIndex]);
        break;

      case NextState.single:
        int index = _instance._musicModels.indexOf(_instance._musicModel!);
        if(index == 0){
          index = _instance._musicModels.length-1;
        }else{
          index -= 1;
        }
        _instance._playNewAudio(_instance._musicModels[index]);
        break;
    }
  }



  // 下一曲，只在列表播放时有效
  static void nextMusic(){
    if(_instance._isListPlayer == false) return;
    switch(_instance._nextState){
      case NextState.sequential:
        int index = _instance._musicModels.indexOf(_instance._musicModel!);
        if(index == _instance._musicModels.length-1){ // 最后一首
          index = 0;
        }else{
          index += 1;
        }
        _instance._playNewAudio(_instance._musicModels[index]);
        break;
      case NextState.random:
        int randomIndex = Random().nextInt(_instance._musicModels.length);
        _instance._playNewAudio(_instance._musicModels[randomIndex]);
        break;
      case NextState.single:
        int index = _instance._musicModels.indexOf(_instance._musicModel!);
        if(index == _instance._musicModels.length-1){ // 最后一首
          index = 0;
        }else{
          index += 1;
        }
        _instance._playNewAudio(_instance._musicModels[index]);
        break;
    }
  }

  // 跳转到某一时段
  static void seekTo({required Duration position,required MusicModel model}){
    if(_instance._musicModel == null){ // 先播放新的音频，再跳转
      _instance._playNewAudio(model);
      _instance._seekTo(position);
    }else{
      if(_instance._musicModel!.mp3Url == model.mp3Url){ // 继续当前资源进行播放or暂停
        _instance._seekTo(position);
      }else{ // 播放新的音频
        _instance._playNewAudio(model);
        _instance._seekTo(position);
      }
    }
  }

  // 获取音频总时长
  static Future<Duration?> getAudioDuration({required String url}) async{
    AudioPlayer audioPlayer = AudioPlayer();
    await audioPlayer.setSource(UrlSource(url));
    return audioPlayer.getDuration();
  }

  // 播放状态监听
  static void statusListener({required dynamic key,required Function(PlayerState) listener}){
    ListenerStateModel model = ListenerStateModel.fromList([key,listener]);
    _instance._statusPool.add(model);
  }

  // 移除播放状态监听
  static void removeStatusListener(dynamic key){
    _instance._statusPool.removeWhere((element) => element.key == key);
  }

  // 播放进度监听
  static void positionListener({required dynamic key,required Function(int) listener}){
    ListenerPositionModel model = ListenerPositionModel.fromList([key,listener]);
    _instance._positionPool.add(model);
  }

  // 移除播放进度监听
  static void removePositionListener(dynamic key){
    _instance._positionPool.removeWhere((element) => element.key == key);
  }

  // 底部显示tip监听
  static void showListener({required dynamic key,required Function listener}){
    ListenerShowModel model = ListenerShowModel.fromList([key,listener]);
    _instance._showPool.add(model);
  }

  // 移除底部显示tip监听
  static void removeShowListener(dynamic key){
    _instance._showPool.removeWhere((element) => element.key == key);
  }

  // 设置音量
  static Future<void> setVolume(double volume) async{
    await _instance._audioPlayer.setVolume(volume);
  }

  // 设置播放速度
  static Future<void> setSpeed(double speed) async{
    await _instance._audioPlayer.setPlaybackRate(speed);
  }

  // 释放资源
  static void dispose(){
    _instance._audioPlayer.release();
    _instance._audioPlayer.dispose();
    _instance._showPool.clear();
    _instance._positionPool.clear();
    _instance._statusPool.clear();
    _instance._musicModel = null;
    _instance._state = PlayerState.stopped;
    _instance._stopPosition = false;
    _instance._position = const Duration(seconds: 0);
    if(_instance._show){
      _instance._show = false;
      _instance._showTipView(false);
    }
  }

  // ---------------------  private ------------------------
  static final AudioPlayerUtil _instance = AudioPlayerUtil._internal();
  factory AudioPlayerUtil() => _instance;
  AudioPlayerUtil._internal(){
    _statusPool = [];
    _positionPool = [];
    _showPool = [];
    _audioPlayer = AudioPlayer();
    // 状态监听
    _audioPlayer.onPlayerStateChanged.listen((PlayerState playerState) {
      switch(playerState){
        case PlayerState.stopped:
        // TODO: Handle this case.
          _state = PlayerState.stopped;
          break;
        case PlayerState.playing:
        // TODO: Handle this case.
          _state = PlayerState.playing;
          break;
        case PlayerState.paused:
        // TODO: Handle this case.
          _state = PlayerState.paused;
          break;
        case PlayerState.completed:
        // TODO: Handle this case.
          _state = PlayerState.completed;
          break;
        case PlayerState.disposed:
          break;
      }
      _stateUpdate(_state);
    });

    // 播放进度监听
    _audioPlayer.onPositionChanged.listen((Duration  p) {
      _position = p;
      if(p.inSeconds == _secondPosition || _stopPosition == true) return;
      _secondPosition = p.inSeconds;
      for(var element in _positionPool){
        element.listener(p.inSeconds);
      }
    });

    // 播放结束
    _audioPlayer.onPlayerComplete.listen((_) {
      if(_isListPlayer == true){ // 开启列表播放后，自动下一曲
        if(_nextState == NextState.single){
          int index = _instance._musicModels.indexOf(_instance._musicModel!);
          _instance._playNewAudio(_instance._musicModels[index]);
        }else{
          nextMusic();
        }
      }else{
        _state = PlayerState.completed;
        _stateUpdate(_state);
      }
    });

    // 播放错误
    _audioPlayer.onLog.listen((_) {
      _resetPlayer();
    });

  }

  PlayerState _state = PlayerState.stopped;
  late AudioPlayer _audioPlayer;
  MusicModel? _musicModel;
  // 创建播放状态监听池
  late List<ListenerStateModel> _statusPool;
  // 播放进度监听池
  late List<ListenerPositionModel> _positionPool;
  // show监听
  late List<ListenerShowModel> _showPool;
  bool _stopPosition = false; // 暂停进度监听，用于seekTo跳转播放缓冲时，Slider停止
  int _secondPosition = 0;
  Duration _position = const Duration(seconds: 0);
  bool _show = false;
  bool _isListPlayer = false;
  List<MusicModel> _musicModels = [];
  NextState _nextState = NextState.sequential;

  // 播放新音频
  void _playNewAudio(MusicModel model) async{
    await _audioPlayer.play(UrlSource(model.mp3Url));
    _musicModel = model;
    SqlTools.inTimeMusic(_musicModel!);
    ApiDio.getHistory();
    _showTipView(true);
  }

  // 跳转
  void _seekTo(Duration position) async{
    _stopPosition = true;
    await _audioPlayer.seek(position);
    _stopPosition = false;
  }

  // 更新播放状态
  void _stateUpdate(PlayerState state){
    _state = state;
    for(var element in _statusPool){
      element.listener(state);
    }
  }

  // 开启底部显示tip
  void _showTipView(bool show){
    _show = show;
    for(var element in _showPool){
      element.listener(show);
    }
  }

  // 重置播放器
  void _resetPlayer(){
    if(_state == PlayerState.playing){
      _audioPlayer.pause();
    }
    _audioPlayer.release();
    _secondPosition = 0;
    _state = PlayerState.stopped;
  }
}

// 播放状态监听模型
class ListenerStateModel{
  late dynamic key; /// 根据key标记是谁加入的通知，一般直接传widget就好
  late Function(PlayerState) listener;
  /// 简单写一个构造方法
  ListenerStateModel.fromList(List list){
    key = list.first;
    listener = list.last;
  }
}

// 播放进度监听模型
class ListenerPositionModel{
  late dynamic key; /// 根据key标记是谁加入的通知，一般直接传widget就好
  late Function(int) listener;
  /// 简单写一个构造方法
  ListenerPositionModel.fromList(List list){
    key = list.first;
    listener = list.last;
  }
}

// 底部showTip监听模型
class ListenerShowModel{
  late dynamic key; /// 根据key标记是谁加入的通知，一般直接传widget就好
  late Function(bool) listener;
  /// 简单写一个构造方法
  ListenerShowModel.fromList(List list){
    key = list.first;
    listener = list.last;
  }
}

//枚举
enum NextState{
  sequential,
  random,
  single
}