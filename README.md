# react-native-getui （请使用版本@1.1.25）
react-native-getui 是个推官方开发的 React Native 插件，使用该插件可以方便快速地集成推送功能。


# 环境

- React Native Version ： 0.42(demo中使用的rn版本)，理论上可以任意使用其他任何RN版本
- react-native-getui >= 1.1.23
- taobao的源和npm源版本可能存在不一致

# 安装

### 使用 npm 自动安装

在您的项目根目录下执行

````
npm install react-native-getui -save
````

````
react-native link
````
#### 注意:

- 在 iOS 工程中如果找不到头文件可能要在 TARGETS-> BUILD SETTINGS -> Search Paths -> Header Search Paths 添加如下如路径：
````
$(SRCROOT)/../node_modules/react-native-getui/ios/
````
- 您的工程目录/android/app/src/main/{您的包名}/MainActivity的onCreate中调用
````
GetuiModule.initPush(this);
````
#### 注意：

- 有可能您的MainActivity中未重写onCreate方法，如果未重写，请重写onCreate方法，方法如下：
````
protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        GetuiModule.initPush(this);
    }
````
如果您使用Android Studio作为IDE，Android Studio会自动为您import 相应的类名，如果您使用其他的IDE，请import相关的类

````
import android.os.Bundle;
import com.getui.reactnativegetui.GetuiModule;
````

### 手动安装
1、
````
npm install react-native-getui -save
````

2、
````
react-native link
````

3、
[Xcode 工程配置](https://github.com/SunXingZ/react-native-getui/blob/master/document/ios.md)

4、
[Android Studio 工程配置](https://github.com/SunXingZ/react-native-getui/blob/master/document/android.md)

5、修改iOS 工程中TARGETS-> BUILD SETTINGS -> Search Paths -> Header Search Paths

````
$(SRCROOT)/../node_modules/react-native-getui/ios/
````

