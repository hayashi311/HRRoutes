//
//  HRSampleViewController.m
//  HRRoutes
//
//  Created by hayashi311 on 15/03/13.
//  Copyright (c) 2015 Ryota Hayashi. All rights reserved.
//

#import "HRSampleViewController.h"

@implementation HRSampleViewController

+ (NSString *)hr_urlPattern {
    return @"/sample/:title";
}

+ (HRSampleViewController*)controllerWithParameters:(NSDictionary *)parameters {
    HRSampleViewController *controller = [[HRSampleViewController alloc] init];
    controller.title = parameters[@"title"];
    return controller;
}

- (void)loadView {
    self.view = [[UIView alloc] init];
    self.view.backgroundColor = [UIColor greenColor];
}

@end
