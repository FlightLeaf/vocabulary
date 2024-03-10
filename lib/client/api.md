## 推荐 mv
说明 : 调用此接口 , 可获取推荐 mv
接口地址 : /personalized/mv
调用例子 : /personalized/mv

## 推荐新音乐
说明 : 调用此接口 , 可获取推荐新音乐
可选参数 : limit: 取出数量 , 默认为 10 (不支持 offset)
接口地址 : /personalized/newsong
调用例子 : /personalized/newsong

## mv 排行
说明 : 调用此接口 , 可获取 mv 排行
可选参数 : limit: 取出数量 , 默认为 30
area: 地区,可选值为内地,港台,欧美,日本,韩国,不填则为全部
offset: 偏移数量 , 用于分页 , 如 :( 页数 -1)*30, 其中 30 为 limit 的值 , 默认 为 0
接口地址 : /top/mv
调用例子 : /top/mv?limit=10

## 获取歌词
说明 : 调用此接口 , 传入音乐 id 可获得对应音乐的歌词 ( 不需要登录 )
必选参数 : id: 音乐 id
接口地址 : /lyric
调用例子 : /lyric?id=33894312

## 获取精品歌单
说明 : 调用此接口 , 可获取精品歌单
可选参数 : cat: tag, 比如 " 华语 "、" 古风 " 、" 欧美 "、" 流行 ", 默认为 "全部",可从歌单分类接口获取(/playlist/catlist)
limit: 取出歌单数量 , 默认为 20
before: 分页参数,取上一页最后一个歌单的 updateTime 获取下一页数据
接口地址 : /top/playlist/highquality

华语民谣 2387998356 2312165875 995552555 5386704458

## 获取音乐 url - 新版
说明 : 使用注意事项同上
必选参数 : id : 音乐 id level: 播放音质等级, 分为 standard => 标准,higher => 较高, exhigh=>极高, lossless=>无损, hires=>Hi-Res, jyeffect => 高清环绕声, sky => 沉浸环绕声, jymaster => 超清母带
接口地址 : /song/url/v1
调用例子 : /song/url/v1?id=33894312&level=standard /song/url/v1?id=405998841,33894312&level=lossless

## 新歌速递
说明 : 调用此接口 , 可获取新歌速递
必选参数 
type: 地区类型 id,对应以下:
全部:0
华语:7
欧美:96
日本:8
韩国:16
接口地址 : /top/song
调用例子 : /top/song?type=7

## banner
说明 : 调用此接口 , 可获取 banner( 轮播图 ) 数据
可选参数 :
type:资源类型,对应以下类型,默认为 0 即 PC
0: pc
1: android
2: iphone
3: ipad
接口地址 : /banner
调用例子 : /banner, /banner?type=2

## 获取歌手 mv
说明 : 调用此接口 , 传入歌手 id, 可获得歌手 mv 信息 , 具体 mv 播放地址可调 用/mv传入此接口获得的 mvid 来拿到 , 如 : /artist/mv?id=6452,/mv?mvid=5461064
必选参数 : id: 歌手 id, 可由搜索接口获得
接口地址 : /artist/mv
调用例子 : /artist/mv?id=6452

https://tenapi.cn/v2/wyymv -X POST -d 'id=5439044'   MV地址