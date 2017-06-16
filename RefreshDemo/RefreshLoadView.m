//
//  RefreshLoadView.m
//  RefreshDemo
//
//  Created by 张尉 on 2017/1/11.
//  Copyright © 2017年 wayne. All rights reserved.
//

#import "RefreshLoadView.h"

CFTimeInterval RefreshScrollDuration = 0.5;

@interface RefreshLoadView ()

@property (nonatomic, copy) void (^action)(void);

@end

@implementation RefreshLoadView

- (instancetype)initWithAction:(void (^)(void))action
{
    self = [super initWithFrame:CGRectZero];
    if (self) {
        _action = action;
    }
    return self;
}

- (void)beginAction {
    !self.action ?: self.action();
}

- (void)endAction { }

@end
