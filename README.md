Build Setup for Andorid

1、android/settings.gradle

```
include ':react-native-getui'
project(':react-native-getui').projectDir = new File(rootProject.projectDir, '../node_modules/react-native-getui/android')
```

2、android/app/proguard-rules.pro

```
-dontwarn com.igexin.**
-keep class com.igexin.**{*;}
-keep class org.json.** { *; }

-keep class android.support.v4.app.NotificationCompat { *; }
-keep class android.support.v4.app.NotificationCompat$Builder { *; }
```

3、android/app/build.gradle中的defaultConfig

```
ndk {
    abiFilters "armeabi", "armeabi-v7a", "x86_64"
}
manifestPlaceholders = [
    GETUI_APP_ID : "",
    GETUI_APP_KEY : "",
    GETUI_APP_SECRET : ""
]
```

4、android/app/build.gradle中的dependencies

```
compile project(':react-native-getui')
```

5、android/app/src/main/AndroidManifest.xml

```
    <!-- 个推SDK权限配置开始 -->
    <uses-permission android:name="android.permission.INTERNET" />
    <uses-permission android:name="android.permission.READ_PHONE_STATE" />
    <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
    <uses-permission android:name="android.permission.CHANGE_WIFI_STATE" />
    <uses-permission android:name="android.permission.ACCESS_WIFI_STATE" />
    <uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED" />
    <uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
    <uses-permission android:name="android.permission.VIBRATE" />
    <uses-permission android:name="android.permission.GET_TASKS" />
    <!-- 支持iBeancon 需要蓝牙权限 -->
    <uses-permission android:name="android.permission.BLUETOOTH" />
    <uses-permission android:name="android.permission.BLUETOOTH_ADMIN" />
    <!-- 支持个推3.0 电子围栏功能 -->
    <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
    <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
    <!-- 浮动通知权限 -->
    <uses-permission android:name="android.permission.SYSTEM_ALERT_WINDOW" />
    <!-- 自定义权限 -->
    <uses-permission android:name="getui.permission.GetuiService.${applicationId}" />
    <permission
        android:name="getui.permission.GetuiService.${applicationId}"
        android:protectionLevel="normal" >
    </permission>
    <!-- 个推SDK权限配置结束 -->

    // 以下内容加在application节点下
    <!-- 个推SDK配置开始 -->
        <!-- 配置的第三方参数属性 -->
        <meta-data
            android:name="PUSH_APPID"
            android:value="${GETUI_APP_ID}" />
        <meta-data
            android:name="PUSH_APPKEY"
            android:value="${GETUI_APP_KEY}" />
        <meta-data
            android:name="PUSH_APPSECRET"
            android:value="${GETUI_APP_SECRET}" />

        <!-- 配置SDK核心服务 -->
        <service
            android:name="com.igexin.sdk.PushService"
            android:exported="true"
            android:label="NotificationCenter"
            android:process=":pushservice">
            <intent-filter>
                <action android:name="com.igexin.sdk.action.service.message"/>
            </intent-filter>
        </service>

        <receiver android:name="com.igexin.sdk.PushReceiver" >
            <intent-filter>
                <action android:name="android.intent.action.BOOT_COMPLETED" />
                <action android:name="android.net.conn.CONNECTIVITY_CHANGE" />
                <action android:name="android.intent.action.USER_PRESENT" />
                <action android:name="com.igexin.sdk.action.refreshls" />
                <!-- 以下三项为可选的action声明，可大大提高service存活率和消息到达速度 -->
                <action android:name="android.intent.action.MEDIA_MOUNTED" />
                <action android:name="android.intent.action.ACTION_POWER_CONNECTED" />
                <action android:name="android.intent.action.ACTION_POWER_DISCONNECTED" />
            </intent-filter>
        </receiver>

        <activity
            android:name="com.igexin.sdk.PushActivity"
            android:excludeFromRecents="true"
            android:exported="false"
            android:process=":pushservice"
            android:taskAffinity="com.igexin.sdk.PushActivityTask"
            android:theme="@android:style/Theme.Translucent.NoTitleBar" >
        </activity>

        <activity
        android:name="com.igexin.sdk.GActivity"
        android:excludeFromRecents="true"
        android:exported="true"
        android:process=":pushservice"
        android:taskAffinity="com.igexin.sdk.PushActivityTask"
        android:theme="@android:style/Theme.Translucent.NoTitleBar"/>

        <!-- 个推SDK配置结束 -->

        <service
            android:name="com.getui.reactnativegetui.PushService"
            android:exported="true"
            android:label="PushService"
            android:process=":pushservice"/>

        <service android:name="com.getui.reactnativegetui.PushIntentService"/>

        // 在application标签中添加
        <application android:usesCleartextTraffic="true">
```

6、将react-native-getui/example/pushDemoWithFramework/android/app/src/main/jniLibs目录复制到你的项目android相同目录下。

7、在android/app/src/main/java/com/你的项目/MainActivity.java中添加以下代码

```
import com.getui.reactnativegetui.GetuiModule;

protected void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    GetuiModule.initPush(this);
}
```

8、在android/app/src/main/java/com/你的项目/MainApplication.java中添加以下代码

```
import com.getui.reactnativegetui.GetuiPackage;

@Override
protected List<ReactPackage> getPackages() {
    return Arrays.<ReactPackage>asList(
        new MainReactPackage(),
        new GetuiPackage()
    );
}
```

9、将react-native-getui/example/pushDemoWithFramework/android/app/src/main/res/layout目录复制到你的android相同目录下。