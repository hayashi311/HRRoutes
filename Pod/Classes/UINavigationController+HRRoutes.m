//
// Created by hayashi311 on 15/03/13.
//

#import "UINavigationController+HRRoutes.h"
#import "HRRoutes.h"


@implementation UINavigationController (HRRoutes)

- (void)hr_pushViewControllerForURL:(NSURL *)url animated:(BOOL)animated {
    UIViewController *controller = [[HRRoutes sharedRoutes] instantiateViewControllerWithURL:url];
    if (controller){
        [self pushViewController:controller animated:animated];
    }
}

@end