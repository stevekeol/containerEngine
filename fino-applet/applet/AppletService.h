#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface AppletService : NSObject

-(void)startApplet:(UINavigationController*)nav;

- (void)callSubscribeHandlerWithEvent:(NSString *)eventName param:(NSString *)param ;
@end

NS_ASSUME_NONNULL_END
