/**
 * Sample React Native App
 * https://github.com/facebook/react-native
 *
 * @format
 * @flow
 */

import React, { Component } from 'react';
import { Platform, StyleSheet, Text, View, NativeAppEventEmitter } from 'react-native';
import Getui from "react-native-getui";

const instructions = Platform.select({
  ios: 'Press Cmd+R to reload,\n' + 'Cmd+D or shake for dev menu',
  android:
    'Double tap R on your keyboard to reload,\n' +
    'Shake or press menu button for dev menu',
});

type Props = {};
export default class App extends Component<Props> {

  componentDidMount() {
    // iOS两种独享事件
    this.GT_REGISTER_CLIENT_ID = NativeAppEventEmitter.addListener("GT_REGISTER_CLIENT_ID", (clientid) => {
      // iOS收到clientid
      alert("GT_REGISTER_CLIENT_ID： " + clientid);
    });

    // iOS和安卓都能收到的事件
    this.GT_CLICK_REMOTE_NOTIFICATION = NativeAppEventEmitter.addListener("GT_CLICK_REMOTE_NOTIFICATION", (response) => {
      // 点击锁屏通知栏或桌面通知栏进入app时的事件
      // 注意：收到此事件的同时也会收到GT_RECEIVE_REMOTE_NOTIFICATION事件
      alert("GT_CLICK_REMOTE_NOTIFICATION： " + JSON.stringify(response));
    });
    
    // iOS和安卓都能收到的事件
    this.GT_RECEIVE_REMOTE_NOTIFICATION = NativeAppEventEmitter.addListener("GT_RECEIVE_REMOTE_NOTIFICATION", (response) => {
      // app在前台或在后台但未被杀死或点击app图标进入的事件
      alert("GT_RECEIVE_REMOTE_NOTIFICATION： " + JSON.stringify(response));
    });

    // 获取运行状态
    // Getui.status((status) => {
    //   alert(status);
    // });

    // 获取版本号
    // Getui.version((version) => {
    //   alert(version);
    // });

    // 获取clientid
    // Getui.clientId((clientid) => {
    //   alert(clientid);
    // });
  }

  componentWillUnmount() {
    this.GT_REGISTER_CLIENT_ID.remove();
    this.GT_CLICK_REMOTE_NOTIFICATION.remove();
    this.GT_RECEIVE_REMOTE_NOTIFICATION.remove();
  }

  render() {
    return (
      <View style={styles.container}>
        <Text style={styles.welcome}>Welcome to React Native!</Text>
        <Text style={styles.instructions}>To get started, edit App.js</Text>
        <Text style={styles.instructions}>{instructions}</Text>
      </View>
    );
  }
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    backgroundColor: '#F5FCFF',
  },
  welcome: {
    fontSize: 20,
    textAlign: 'center',
    margin: 10,
  },
  instructions: {
    textAlign: 'center',
    color: '#333333',
    marginBottom: 5,
  },
});
