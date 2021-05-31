#import "AppDelegate.h"
#import "ViewController.h"
#import <FinApplet/FinApplet.h>

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // 应用程序启动后自定义的覆盖点
    NSString *appKey = @"22LyZEib0gLTQdU3MUauAR1TgQsjmhH3rHM7vRrbY6UA";
    FATConfig *config = [FATConfig configWithAppSecret:@"9628ad1684944587" appKey:appKey];
    config.apiServer = @"https://mp.finogeeks.com";
    config.apiPrefix = @"/api/v1/mop";
    
    [[FATClient sharedClient] initWithConfig:config error:nil];
    
    // 此时在self.window上挂载自定义的nav等属性
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.backgroundColor = [UIColor whiteColor];
    UINavigationController* nav = [[UINavigationController alloc] initWithRootViewController:[[ViewController alloc] init] ];
    self.window.rootViewController = nav;
    [self.window makeKeyAndVisible];
    
    return YES;
}
@end
