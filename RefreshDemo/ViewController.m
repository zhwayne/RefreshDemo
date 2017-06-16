//
//  ViewController.m
//  RefreshDemo
//
//  Created by 张尉 on 2017/1/11.
//  Copyright © 2017年 wayne. All rights reserved.
//

#import "ViewController.h"
#import "UIScrollView+Refresh.h"
#import "RefreshHeader.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
//    [self.navigationController.navigationBar setShadowImage:[UIImage new]];
    // Do any additional setup after loading the view, typically from a nib.
    _scrollView.contentInset = UIEdgeInsetsMake(20, 0, 0, 0);
    _scrollView.refreshHeader = [[RefreshHeader alloc] initWithAction:^{
        NSLog(@"refreshing...");
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [_scrollView.refreshHeader endAction];
            NSLog(@"end refresh");
        });
    }];

    
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        [_tableView.refreshHeader beginAction];
    });
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
