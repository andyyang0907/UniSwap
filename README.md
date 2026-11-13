# UniSwap

面向云南大学的校园二手交易与物品交换应用（iOS + Android）。三种交易类型：**Buy（二手出售）**、**Give（免费赠送）**、**Swap（以物易物）**。特色功能：校园最短路径配送规划，基于呈贡/东陆校区真实路网数据。

## 界面预览

[![iOS 首页](/andyyang0907/UniSwap/raw/main/screenshots/ios_01_home.jpg)](/andyyang0907/UniSwap/blob/main/screenshots/ios_01_home.jpg) [![iOS 发现](/andyyang0907/UniSwap/raw/main/screenshots/ios_02_discover.jpg)](/andyyang0907/UniSwap/blob/main/screenshots/ios_02_discover.jpg) [![iOS 发布](/andyyang0907/UniSwap/raw/main/screenshots/ios_03_publish.jpg)](/andyyang0907/UniSwap/blob/main/screenshots/ios_03_publish.jpg) [![iOS 消息](/andyyang0907/UniSwap/raw/main/screenshots/ios_04_messages.jpg)](/andyyang0907/UniSwap/blob/main/screenshots/ios_04_messages.jpg) [![iOS 我的](/andyyang0907/UniSwap/raw/main/screenshots/ios_05_profile.jpg)](/andyyang0907/UniSwap/blob/main/screenshots/ios_05_profile.jpg)
_iOS_

[![Android 首页](/andyyang0907/UniSwap/raw/main/screenshots/android_01_home.png)](/andyyang0907/UniSwap/blob/main/screenshots/android_01_home.png) [![Android 发现](/andyyang0907/UniSwap/raw/main/screenshots/android_02_discover.png)](/andyyang0907/UniSwap/blob/main/screenshots/android_02_discover.png) [![Android 发布](/andyyang0907/UniSwap/raw/main/screenshots/android_03_publish.png)](/andyyang0907/UniSwap/blob/main/screenshots/android_03_publish.png) [![Android 消息](/andyyang0907/UniSwap/raw/main/screenshots/android_04_messages.png)](/andyyang0907/UniSwap/blob/main/screenshots/android_04_messages.png) [![Android 商品详情](/andyyang0907/UniSwap/raw/main/screenshots/android_05_product.png)](/andyyang0907/UniSwap/blob/main/screenshots/android_05_product.png) [![Android 校园地图](/andyyang0907/UniSwap/raw/main/screenshots/android_06_campus_map.png)](/andyyang0907/UniSwap/blob/main/screenshots/android_06_campus_map.png)
_Android_

## 下载安装

* **iOS**：开发者模式安装 IPA（见下文）
* **Android**：扫码或从 [Releases](https://github.com/andyyang0907/UniSwap/releases/latest) 下载 APK 安装

[![Android 版下载二维码](/andyyang0907/UniSwap/raw/main/screenshots/download_qr.png "扫码下载 Android 版")](/andyyang0907/UniSwap/blob/main/screenshots/download_qr.png)

扫码后若微信拦截下载，请点右上角菜单 →「在浏览器打开」，浏览器下载后点击安装（需允许安装未知来源应用）。

### iOS 安装（开发者模式）

```bash
flutter build ipa --release --export-method=development
xcrun devicectl device install app --device <UDID> build/ios/ipa/uniswap_app.ipa
```

## 功能

* **三种交易模式**：Buy（出售）/ Give（免费赠送）/ Swap（以物易物），不同 UI 不同发布流程
* **智能搜索**：标题 > 分类 > 交换意向 > 描述 多层加权匹配 + 同义词扩展（书包→双肩包、耳机→降噪耳麦 等）
* **校园最短路径**：基于 Dijkstra 的配送点导航，呈贡/东陆校区真实路网，自动计算步行时间
* **图片选取**：手机相册/相机直接拍摄发布
* **即时消息**：商品详情 → 聊聊 → 创建或进入会话，未读计数自动更新
* **本地数据**：所有数据存本地（SharedPreferences），无需联网、无需账号

## 技术栈

* Flutter 3.x + Dart
* Provider 状态管理
* CupertinoPageRoute（iOS 原生右滑返回手势）
* SharedPreferences 设置持久化
* image_picker 真实相册/相机集成
* OpenStreetMap 真实校园地图底图

## 开发

```bash
flutter pub get
flutter run -d <device-id>
flutter build apk --release
flutter build ipa --release --export-method=development
```

支持 iOS 与 Android 双平台，平台目录 `ios/`、`android/` 均在库中。

## 隐私

应用数据（发布、收藏、消息）仅存储在设备本地，不采集任何个人信息。校园地图底图数据来源 © OpenStreetMap contributors。
