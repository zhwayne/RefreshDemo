//
//  RefreshLoadView.h
//  RefreshDemo
//
//  Created by 张尉 on 2017/1/11.
//  Copyright © 2017年 wayne. All rights reserved.
//

#import <UIKit/UIKit.h>

extern CFTimeInterval RefreshScrollDuration;

typedef NS_ENUM(NSUInteger, RefreshState) {
    RefreshStatePossible,
    RefreshStatePreparing,
    RefreshStateReady,
    RefreshStateRefreshing
};


@interface RefreshLoadView : UIView

- (instancetype)initWithAction:(void (^)(void))action;

- (void)beginAction;
- (void)endAction;

@end
