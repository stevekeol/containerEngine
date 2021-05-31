# 在ReactNative中内嵌的小程序容器引擎的解析

## 主页面的启动流程
```
main.m  =======================>  AppDelegate.m
        =======================>  ViewController.m  
        =====OnTestClick()=====>  AppletService.m
        =======================>  AppletViewController.m
        =======================>  view.html
        =======================>  service.html
```

## 各个文件的功能定义

|                 File                |         Description          |
| :---------------------------------- | :-------------------------:  |
| [main.m](./main.m)                                      | ? |
| [AppDelegate.m](./AppDelegate.m)                        | ? |
| [ViewController.m](./ViewController.m)                  | ? |
| [AppletService.m](./AppletService.m)                    | ? |
| [AppletViewController.m](./AppletViewController.m)      | ? |
| [view.html](./view.html)                                | ? |
| [service.html](./service.html)                          | ? |


## 部分核心代码解析

##### `AppletSercice.m` 的执行机制:

+ js传过来的
```
userContentController()  
=======================>  callSubscribeHandlerWithEvent()
=======================>  evaluateJavaScript()
=======================>  completionHandler
```

##### `ViewController.m` 中 `onTestClick()`:

```
onTestClick(): (id) sender {
  self.service = [[AppletService alloc] init];
  [self.service startApplet: self.navigationController]
}
```

##### `view.html` 中 `window.webkit.messageHandlers.postMessage()`将数据发送给 `service.html`:

```js
window.webkit.messageHandlers.publishHandler.postMessage({
  event: event,
  paramsString: paramsString,
  webviewIds: webviewIds
})
```
  + (`AppletService.m`中)先将名为`publishHandler` 的 `ScriptMessageHandler` 注册到webkit:
  ```
  [userContentController addScriptMessageHandler:self name:@"publishHandler"];
  ```

> [适当参考下](https://lvwenhan.com/ios/461.html) Apple 在WkWebView中的js runtime里，事先注入了一个 window.webkit.messageHandlers.xxx.postMessage() 方法，我们可以使用这个方法直接向 Native 层传值，异常方便。首先，我们要把一个名为 xxx 的 ScriptMessageHandler 注册到我们的 wk。


## 零散疑问
+ [] 

## 注入API的实现方式（自己想的）

+ 文件目录结构:
  ```md
  jsbridge
    - index.js
    - iOS/
      - index.js
      - getUserInfo.js
      - xxx.js
    - android/
      - index.js
      - getUserInfo.js
      - xxx.js
  ```

+ `jsbridge/index.js`:
  ```js
  import iosBridge from './iOS';
  import androidBridge from './android';

  export default class Bridge {
    constructor() {
      super();
      if (isAndroid) {
        this.jsbridge = androidBridge;
      } else {
        this.jsbridge = iosBridge;
      }
    }
    getUserInfo = (...args) => this.jsbridge.getUserInfo(...args);
  }
  ```

+ `jsbridge/iOS/index.js`:
  ```js
  import getUserInfo from './getUserInfo';
  export {
    getUserInfo
  }
  ```

+ `jsbridge/iOS/getUserInfo.js`
  ```js
  import registerCallback from '../registerCallback';

  export default function getUserInfo() {
    return new Promise((resolve, reject) => {
      try {
        window.webkit.messageHandlers.getUserInfo.postMessage({
          callback: registerCallback(resolve),
        });
      } catch (e) {
        reject(e);
      }
    });
  }
  ```

+ `jsbridge/android/index.js`:
  ```js
  import getUserInfo from './getUserInfo';
  export {
    getUserInfo
  }
  ```

+ `jsbridge/android/getUserInfo.js`:
  ```js
  import registerCallback from '../registerCallback';

  export default function getUserInfo() {
    return new Promise((resolve, reject) => {
      try {
        window.webkit.messageHandlers.getUserInfo.postMessage({
          callback: registerCallback(resolve),
        });
      } catch (e) {
        reject(e);
      }
    });
  }
  ```