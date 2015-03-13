//
//  HRViewController.m
//  HRRoutes
//
//  Created by Ryota Hayashi on 03/13/2015.
//  Copyright (c) 2014 Ryota Hayashi. All rights reserved.
//

#import "HRViewController.h"
#import "UINavigationController+HRRoutes.h"

@interface HRViewController ()

@end

@implementation HRViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self.navigationController hr_pushViewControllerForURL:[NSURL URLWithString:@"/sample/hoge"]
                                                      animated:YES];
    });
}


@end
