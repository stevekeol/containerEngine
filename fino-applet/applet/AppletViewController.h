#import <UIKit/UIKit.h>
#import "AppletService.h"
NS_ASSUME_NONNULL_BEGIN

@interface AppletViewController : UIViewController
@property (nonatomic, weak) AppletService *service;
- (void)callSubscribeHandlerWithEvent:(NSString *)eventName param:(NSString *)jsonParam;

@end

NS_ASSUME_NONNULL_END
