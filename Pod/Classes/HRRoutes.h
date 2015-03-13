//
// Created by hayashi311 on 15/03/13.
//

#import <UIKit/UIKit.h>


@protocol HRRoutesViewController <NSObject>

+ (NSString *)hr_urlPattern;
+ (UIViewController *)controllerWithParameters:(NSDictionary *)parameters;

@end

@interface HRRoutes : NSObject

+ (HRRoutes *)sharedRoutes;

- (void)registerViewController:(Class <HRRoutesViewController>)c;

- (UIViewController *)instantiateViewControllerWithURL:(NSURL*)url;

@end

