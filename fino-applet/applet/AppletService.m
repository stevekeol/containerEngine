#import "AppletService.h"
#import "AppletViewController.h"
#import <WebKit/WebKit.h>

@interface AppletService()<WKScriptMessageHandler>
@property (nonatomic, strong) WKWebView *webView;
@property (nonatomic, strong) AppletViewController *controller;

@end

@implementation AppletService

-(void)setupService {
    WKUserContentController *userContentController = [WKUserContentController new];
    NSString *souce = @"window.__fcjs_environment='miniprogram'";
    WKUserScript *script = [[WKUserScript alloc] initWithSource:souce injectionTime:WKUserScriptInjectionTimeAtDocumentStart forMainFrameOnly:true];
    [userContentController addUserScript:script];

    // 将名为publishHandler的ScriptMessageHandler 注册到webkit中:
    [userContentController addScriptMessageHandler:self name:@"publishHandler"];
    
    WKWebViewConfiguration *wkWebViewConfiguration = [WKWebViewConfiguration new];
    wkWebViewConfiguration.allowsInlineMediaPlayback = YES;
    // 真正注入publishHandler的地方
    wkWebViewConfiguration.userContentController = userContentController;
    
    if (@available(iOS 9.0, *)) {
        [wkWebViewConfiguration.preferences setValue:@(true) forKey:@"allowFileAccessFromFileURLs"];
    }
    WKPreferences *preferences = [WKPreferences new];
    preferences.javaScriptCanOpenWindowsAutomatically = YES;
    wkWebViewConfiguration.preferences = preferences;
    
    // 此处利用上面的配置，修改webkit的初始化函数(让webkit初始化时就拥有publishHandler等自定义的方法)
    self.webView = [[WKWebView alloc] initWithFrame:(CGRect){0,0,1,1} configuration:wkWebViewConfiguration];
    NSString *urlStr = [[NSBundle mainBundle] pathForResource:@"service.html" ofType:nil];
    NSURL *fileURL = [NSURL fileURLWithPath:urlStr];
    [self.webView loadFileURL:fileURL allowingReadAccessToURL:fileURL];
}

-(void)startApplet:(UINavigationController*)nav {
    self.controller = [[AppletViewController alloc] init];
    self.controller.service = self;
    [nav pushViewController:self.controller animated:YES];
    [self setupService];
}

- (void)callSubscribeHandlerWithEvent:(NSString *)eventName param:(NSString *)jsonParam {
    NSString *js = [NSString stringWithFormat:@"ServiceJSBridge.subscribeHandler('%@',%@)", eventName, jsonParam];
    // 该函数将event和paramsString转换成js的字符串，并交给evaluateJavaScript函数处理
    [self evaluateJavaScript:js completionHandler:nil];
}

- (void)evaluateJavaScript:(NSString *)javaScriptString completionHandler:(void(^)(id result,NSError *error))completionHandler {
    [self.webView evaluateJavaScript:javaScriptString completionHandler:completionHandler];
}

// 此处是在原生内部注册一个js接口(如publishHandler)的处理函数
#pragma mark - WKScriptMessageHandler
- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message
{
    // 如果传过来的message.name是publishHandler时，
    if ([message.name isEqualToString:@"publishHandler"]) {
        NSString *e = message.body[@"event"];
        // 取出postMessage传过来的data中的event和paramsString，交给callSubscribeHandlerWithEvent函数处理
        [self.controller callSubscribeHandlerWithEvent:e param:message.body[@"paramsString"]];    }
}
@end
