//
//  RefreshLoadView.h
//  RefreshDemo
//
//  Created by 张尉 on 2017/1/11.
//  Copyright © 2017年 wayne. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RefreshLoadView : UIView

- (instancetype)initWithAction:(void (^)())action;

- (void)beginAction;
- (void)endAction;

@end
